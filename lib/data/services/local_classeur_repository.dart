import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';

import '../models/local_classeur.dart';

/// Persists the user-owned classeur on the device: a `manifest.json` holding
/// the categories/pictograms metadata, and an `images/` folder holding the
/// pictogram image files. Everything lives under the app's private directory,
/// so no data ever leaves the device (CDC 5.1).
///
/// The root directory is injected so tests can point it at a temp folder; the
/// app resolves it through [create] using path_provider.
class LocalClasseurRepository {
  LocalClasseurRepository(this.rootDir);

  /// Resolves the classeur root under the app's private documents directory.
  static Future<LocalClasseurRepository> create() async {
    final documents = await getApplicationDocumentsDirectory();
    final root = Directory('${documents.path}/classeur');
    return LocalClasseurRepository(root);
  }

  /// Root of the *active* profile's classeur. Mutable so switching profile
  /// (A-11) re-points the same repository instead of rebuilding the graph.
  Directory rootDir;

  File get _manifestFile => File('${rootDir.path}/manifest.json');
  Directory get _imagesDir => Directory('${rootDir.path}/images');

  /// Reads the classeur, returning an empty one when nothing is stored yet or
  /// the manifest is unreadable.
  Future<LocalClasseur> load() async {
    final file = _manifestFile;
    if (!await file.exists()) {
      return LocalClasseur.empty();
    }
    try {
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return LocalClasseur.fromJson(decoded);
      }
      if (decoded is Map) {
        return LocalClasseur.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      // Fall back to an empty classeur rather than blocking the app.
    }
    return LocalClasseur.empty();
  }

  Future<void> save(LocalClasseur classeur) async {
    await rootDir.create(recursive: true);
    await _manifestFile.writeAsString(jsonEncode(classeur.toJson()));
  }

  /// Copies image [bytes] into `images/` and returns the path to store in the
  /// manifest, relative to [rootDir] (e.g. `images/picto_3.png`).
  ///
  /// The file is named after [pictogramId] so it stays stable and unique.
  Future<String> storeImageBytes(
    List<int> bytes, {
    required int pictogramId,
    required String extension,
  }) async {
    await _imagesDir.create(recursive: true);
    final ext = _sanitizeExtension(extension);
    final relativePath = 'images/picto_$pictogramId$ext';
    final file = File('${rootDir.path}/$relativePath');
    await file.writeAsBytes(bytes, flush: true);
    return relativePath;
  }

  /// Absolute path of an image referenced by its manifest-relative path.
  String absoluteImagePath(String relativePath) {
    return '${rootDir.path}/$relativePath';
  }

  /// Removes an image file; missing files are ignored.
  Future<void> deleteImage(String relativePath) async {
    if (relativePath.isEmpty) {
      return;
    }
    final file = File('${rootDir.path}/$relativePath');
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Packs the whole classeur (manifest + every image) into a self-contained
  /// zip so it can be moved to another device (A-09).
  Future<List<int>> exportToZipBytes() async {
    final archive = Archive();

    final manifest = _manifestFile;
    if (await manifest.exists()) {
      archive.addFile(
        ArchiveFile.bytes('manifest.json', await manifest.readAsBytes()),
      );
    }

    final images = _imagesDir;
    if (await images.exists()) {
      await for (final entity in images.list()) {
        if (entity is File) {
          final name = entity.uri.pathSegments.last;
          archive.addFile(
            ArchiveFile.bytes('images/$name', await entity.readAsBytes()),
          );
        }
      }
    }

    return ZipEncoder().encode(archive);
  }

  /// Restores a classeur exported with [exportToZipBytes], **replacing** the
  /// current one (A-10). Returns false when the archive is not a valid
  /// classeur, in which case nothing is modified.
  Future<bool> importFromZipBytes(List<int> bytes) async {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (_) {
      return false;
    }

    // Validate before touching anything on disk.
    final manifestEntries = archive.files
        .where((f) => f.name == 'manifest.json')
        .toList();
    if (manifestEntries.isEmpty) {
      return false;
    }
    final manifestBytes = manifestEntries.first.readBytes();
    if (manifestBytes == null) {
      return false;
    }
    try {
      final decoded = jsonDecode(utf8.decode(manifestBytes));
      if (decoded is! Map) {
        return false;
      }
      LocalClasseur.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return false;
    }

    if (await rootDir.exists()) {
      await rootDir.delete(recursive: true);
    }
    await rootDir.create(recursive: true);

    for (final entry in archive.files) {
      if (!entry.isFile) {
        continue;
      }
      final name = entry.name;
      // Only accept the expected layout, and never escape the root dir.
      final allowed = name == 'manifest.json' || name.startsWith('images/');
      if (!allowed || name.contains('..')) {
        continue;
      }
      final content = entry.readBytes();
      if (content == null) {
        continue;
      }
      final out = File('${rootDir.path}/$name');
      await out.parent.create(recursive: true);
      await out.writeAsBytes(content, flush: true);
    }
    return true;
  }

  static String _sanitizeExtension(String extension) {
    final cleaned = extension.trim().replaceAll('.', '').toLowerCase();
    if (cleaned.isEmpty) {
      return '.png';
    }
    return '.$cleaned';
  }
}

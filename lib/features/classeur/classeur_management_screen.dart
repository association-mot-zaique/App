import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/local_category.dart';
import '../../data/models/local_pictogram.dart';
import '../../data/services/pictogram_search_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../settings/settings_controller.dart';
import 'arasaac_import_screen.dart';
import 'category_seeds.dart';
import 'local_classeur_controller.dart';

/// Aidant screen to manage the local classeur: create/rename/delete
/// categories (US-1.05) and reach each category's pictograms (US-1.06).
class ClasseurManagementScreen extends StatelessWidget {
  const ClasseurManagementScreen({
    required this.controller,
    required this.searchService,
    required this.settingsController,
    required this.languageCode,
    super.key,
  });

  final LocalClasseurController controller;
  final PictogramSearchService searchService;
  final SettingsController settingsController;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.classeurManageTitle),
        actions: [
          IconButton(
            tooltip: l10n.exportClasseur,
            onPressed: () => _exportClasseur(context),
            icon: const Icon(Icons.upload_file_outlined),
          ),
          IconButton(
            tooltip: l10n.importClasseur,
            onPressed: () => _importClasseur(context),
            icon: const Icon(Icons.download_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addCategory(context),
        icon: const Icon(Icons.create_new_folder_outlined),
        label: Text(l10n.addCategory),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final categories = controller.classeur.categoriesSorted;
          if (categories.isEmpty) {
            return _EmptyState(
              message: l10n.classeurEmpty,
              action: FilledButton.tonalIcon(
                onPressed: () => _addStarterCategories(context),
                icon: const Icon(Icons.playlist_add_rounded),
                label: Text(l10n.addStarterCategories),
              ),
            );
          }
          // Reorderable: only the aidant changes the order, so the end user
          // keeps stable positions (CDC 3.1 / A-08).
          return ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
            itemCount: categories.length,
            onReorderItem: controller.reorderCategories,
            itemBuilder: (context, index) {
              final category = categories[index];
              final count = controller.classeur
                  .pictogramsIn(category.id)
                  .length;
              return ListTile(
                key: ValueKey(category.id),
                leading: const Icon(Icons.folder_outlined),
                title: Text(category.name),
                subtitle: Text('$count ${l10n.pictogramsWord}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'rename') {
                      _renameCategory(context, category);
                    } else if (value == 'delete') {
                      _deleteCategory(context, category);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'rename',
                      child: Text(l10n.renameAction),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(l10n.deleteAction),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => _CategoryPictogramsScreen(
                        controller: controller,
                        searchService: searchService,
                        settingsController: settingsController,
                        categoryId: category.id,
                        languageCode: languageCode,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _addCategory(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    // Localized suggestions to avoid blind typing; the aidant can still write a
    // fully custom name (personalization stays — CDC 6.3).
    final suggestions = <String>[
      l10n.categoryNeeds,
      l10n.categoryEmotions,
      l10n.categoryHome,
      l10n.categorySchool,
      l10n.suggestionMeals,
      l10n.categoryHealth,
      l10n.suggestionPeople,
      l10n.suggestionActivities,
      l10n.suggestionPlaces,
      l10n.suggestionToys,
    ];
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _AddCategoryDialog(suggestions: suggestions),
    );
    if (name != null && name.isNotEmpty) {
      final added = await controller.addCategory(name);
      if (context.mounted && !added) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.categoryExists)));
      }
    }
  }

  Future<void> _renameCategory(
    BuildContext context,
    LocalCategory category,
  ) async {
    final l10n = AppLocalizations.of(context);
    final name = await _promptText(
      context,
      title: l10n.renameAction,
      label: l10n.categoryNameLabel,
      initialValue: category.name,
    );
    if (name != null) {
      final renamed = await controller.renameCategory(category.id, name);
      if (context.mounted && !renamed) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.categoryExists)));
      }
    }
  }

  Future<void> _deleteCategory(
    BuildContext context,
    LocalCategory category,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirmDelete(context, l10n.deleteCategoryConfirm);
    if (confirmed) {
      await controller.deleteCategory(category.id);
    }
  }

  /// Exports the classeur as a self-contained zip and lets the aidant choose
  /// where to save it, outside the app (A-09 / US-3.01).
  Future<void> _exportClasseur(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final bytes = await controller.exportArchive();
    if (!context.mounted) {
      return;
    }
    final path = await FilePicker.saveFile(
      dialogTitle: l10n.exportClasseur,
      fileName: 'classeur-mot-zaique.zip',
      bytes: Uint8List.fromList(bytes),
    );
    if (!context.mounted || path == null) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.classeurExported)));
  }

  /// Imports a classeur zip, replacing the current one after confirmation
  /// (A-10 / US-3.02).
  Future<void> _importClasseur(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final picked = await FilePicker.pickFiles(withData: true);
    if (!context.mounted || picked == null || picked.files.isEmpty) {
      return;
    }
    final bytes = picked.files.first.bytes;
    if (bytes == null) {
      return;
    }
    final confirmed = await _confirmDelete(context, l10n.importClasseurConfirm);
    if (!context.mounted || !confirmed) {
      return;
    }
    final imported = await controller.importArchive(bytes);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          imported ? l10n.classeurImported : l10n.classeurImportFailed,
        ),
      ),
    );
  }

  /// Seeds a few localized starter categories so the aidant does not face a
  /// blank slate. Empty and fully editable — duplicates are skipped.
  Future<void> _addStarterCategories(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final starters = <String>[
      l10n.categoryNeeds,
      l10n.categoryEmotions,
      l10n.categoryHome,
      l10n.categorySchool,
      l10n.suggestionMeals,
      l10n.categoryHealth,
    ];
    for (final name in starters) {
      await controller.addCategory(name);
    }
  }
}

class _CategoryPictogramsScreen extends StatelessWidget {
  const _CategoryPictogramsScreen({
    required this.controller,
    required this.searchService,
    required this.settingsController,
    required this.categoryId,
    required this.languageCode,
  });

  final LocalClasseurController controller;
  final PictogramSearchService searchService;
  final SettingsController settingsController;
  final int categoryId;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addPictogram(context),
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: Text(l10n.addPictogram),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final category = controller.classeur.categoriesSorted
              .where((c) => c.id == categoryId)
              .toList();
          final title = category.isEmpty ? '' : category.single.name;
          final pictograms = controller.classeur.pictogramsIn(categoryId);

          return CustomScrollView(
            slivers: [
              SliverAppBar(title: Text(title), pinned: true),
              if (pictograms.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(message: l10n.categoryEmptyPictograms),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 160,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.8,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _PictogramTile(
                        controller: controller,
                        pictogram: pictograms[index],
                      ),
                      childCount: pictograms.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Offers the three alimentation sources at parity (CDC 6.3): a file
  /// (US-1.02), a photo (US-1.03) or ARASAAC (US-1.04).
  Future<void> _addPictogram(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final source = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.addFromFile),
              onTap: () => Navigator.of(context).pop('file'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.addFromCamera),
              onTap: () => Navigator.of(context).pop('camera'),
            ),
            ListTile(
              leading: const Icon(Icons.travel_explore_outlined),
              title: Text(l10n.importFromArasaac),
              onTap: () => Navigator.of(context).pop('arasaac'),
            ),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) {
      return;
    }

    switch (source) {
      case 'file':
        await _addFromGallery(context);
      case 'camera':
        await _addFromCamera(context);
      case 'arasaac':
        final match = controller.classeur.categoriesSorted
            .where((c) => c.id == categoryId)
            .toList();
        final categoryName = match.isEmpty ? '' : match.single.name;
        final seeds = categorySeedKeywords(
          AppLocalizations.of(context),
          categoryName,
        );
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ArasaacImportScreen(
              controller: controller,
              searchService: searchService,
              settingsController: settingsController,
              categoryId: categoryId,
              languageCode: languageCode,
              initialQuery: categoryName,
              seedKeywords: seeds,
            ),
          ),
        );
    }
  }

  /// Imports **several** images at once from the gallery/files (US-1.02). Each
  /// becomes a pictogram whose label defaults to the file name (renamed later),
  /// so the aidant can garnish a category quickly. The original format is kept
  /// (no re-encode), preserving PNG transparency.
  Future<void> _addFromGallery(BuildContext context) async {
    final files = await ImagePicker().pickMultiImage();
    if (files.isEmpty || !context.mounted) {
      return;
    }
    for (final file in files) {
      final bytes = await file.readAsBytes();
      await controller.addPictogram(
        label: _labelFromFileName(file.name),
        categoryId: categoryId,
        imageBytes: bytes,
        extension: _extensionOf(file.name),
      );
    }
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).pictogramAddedNotice),
      ),
    );
  }

  /// Takes a single photo (US-1.03) and creates a pictogram with a typed label.
  Future<void> _addFromCamera(BuildContext context) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked == null || !context.mounted) {
      return;
    }
    final bytes = await picked.readAsBytes();
    if (!context.mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final label = await _promptText(
      context,
      title: l10n.addPictogram,
      label: l10n.pictogramLabelLabel,
    );
    if (label == null) {
      return;
    }
    await controller.addPictogram(
      label: label,
      categoryId: categoryId,
      imageBytes: bytes,
      extension: _extensionOf(picked.name),
    );
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.pictogramAddedNotice)));
  }

  static String _extensionOf(String name) {
    final dot = name.lastIndexOf('.');
    if (dot == -1 || dot == name.length - 1) {
      return 'png';
    }
    return name.substring(dot + 1);
  }

  static String _labelFromFileName(String name) {
    final dot = name.lastIndexOf('.');
    final stem = dot > 0 ? name.substring(0, dot) : name;
    return stem.trim().isEmpty ? name : stem.trim();
  }
}

class _PictogramTile extends StatelessWidget {
  const _PictogramTile({required this.controller, required this.pictogram});

  final LocalClasseurController controller;
  final LocalPictogram pictogram;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.file(
              File(controller.absoluteImagePath(pictogram.imagePath)),
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.broken_image_outlined),
            ),
          ),
          Row(
            children: [
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pictogram.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'rename':
                      _rename(context);
                    case 'delete':
                      _delete(context);
                    case 'move':
                      _moveToCategory(context);
                    case 'up':
                      controller.movePictogramBy(pictogram.id, -1);
                    case 'down':
                      controller.movePictogramBy(pictogram.id, 1);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'up', child: Text(l10n.moveUpAction)),
                  PopupMenuItem(
                    value: 'down',
                    child: Text(l10n.moveDownAction),
                  ),
                  PopupMenuItem(
                    value: 'move',
                    child: Text(l10n.moveToCategory),
                  ),
                  PopupMenuItem(
                    value: 'rename',
                    child: Text(l10n.renameAction),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(l10n.deleteAction),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _rename(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final label = await _promptText(
      context,
      title: l10n.renameAction,
      label: l10n.pictogramLabelLabel,
      initialValue: pictogram.label,
    );
    if (label != null) {
      await controller.renamePictogram(pictogram.id, label);
    }
  }

  Future<void> _delete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirmDelete(
      context,
      l10n.deletePictogramConfirm,
    );
    if (confirmed) {
      await controller.deletePictogram(pictogram.id);
    }
  }

  /// Moves the pictogram to another category (A-07 / US-3.04).
  Future<void> _moveToCategory(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final others = controller.classeur.categoriesSorted
        .where((c) => c.id != pictogram.categoryId)
        .toList();
    if (others.isEmpty) {
      return;
    }
    final targetId = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.moveToCategory),
        children: [
          for (final category in others)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(category.id),
              child: Text(category.name),
            ),
        ],
      ),
    );
    if (targetId != null) {
      await controller.movePictogramToCategory(pictogram.id, targetId);
    }
  }
}

/// Category creation with localized, clickable suggestions plus a free text
/// field. Suggestions pre-fill the field; the aidant can still type a fully
/// custom name (keeps the classeur personalized — CDC 6.3).
class _AddCategoryDialog extends StatefulWidget {
  const _AddCategoryDialog({required this.suggestions});

  final List<String> suggestions;

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pick(String value) {
    setState(() {
      _controller.text = value;
      _controller.selection = TextSelection.collapsed(offset: value.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.addCategory),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l10n.categoryNameLabel),
              onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.categorySuggestionsLabel,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final suggestion in widget.suggestions)
                  ActionChip(
                    label: Text(suggestion),
                    onPressed: () => _pick(suggestion),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, this.action});

  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

/// Shared dialog returning the trimmed text, or null when cancelled/empty.
Future<String?> _promptText(
  BuildContext context, {
  required String title,
  required String label,
  String initialValue = '',
}) async {
  final result = await showDialog<String>(
    context: context,
    builder: (_) => _TextPromptDialog(
      title: title,
      label: label,
      initialValue: initialValue,
    ),
  );
  if (result == null || result.isEmpty) {
    return null;
  }
  return result;
}

/// Owns its [TextEditingController] via State so it is disposed only once the
/// dialog route is gone — avoids "used after disposed" that happens when a
/// controller is disposed synchronously right after showDialog returns.
class _TextPromptDialog extends StatefulWidget {
  const _TextPromptDialog({
    required this.title,
    required this.label,
    required this.initialValue,
  });

  final String title;
  final String label;
  final String initialValue;

  @override
  State<_TextPromptDialog> createState() => _TextPromptDialogState();
}

class _TextPromptDialogState extends State<_TextPromptDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: widget.label),
        onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

Future<bool> _confirmDelete(BuildContext context, String message) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.deleteAction),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

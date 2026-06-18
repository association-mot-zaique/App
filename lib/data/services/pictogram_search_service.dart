import '../models/pictogram.dart';
import '../models/pictogram_search_result.dart';
import 'arasaac_api.dart';
import 'search_cache_repository.dart';

abstract class PictogramSearchService {
  Future<PictogramSearchResult> search(
    String query, {
    required String language,
    required bool offlineOnly,
    required bool onlyAacPictograms,
    required bool onlySchematicPictograms,
    required int minDownloads,
  });
}

class ArasaacSearchService implements PictogramSearchService {
  ArasaacSearchService({
    required ArasaacApi api,
    required SearchCacheRepository cache,
  }) : _api = api,
       _cache = cache;

  final ArasaacApi _api;
  final SearchCacheRepository _cache;

  @override
  Future<PictogramSearchResult> search(
    String query, {
    required String language,
    required bool offlineOnly,
    required bool onlyAacPictograms,
    required bool onlySchematicPictograms,
    required int minDownloads,
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return const PictogramSearchResult(
        pictograms: [],
        source: SearchResultSource.cache,
        offlineOnly: false,
      );
    }

    if (offlineOnly) {
      final cached = _process(
        _cache.read(cleanQuery, language: language) ?? const [],
        onlyAacPictograms: onlyAacPictograms,
        onlySchematicPictograms: onlySchematicPictograms,
        minDownloads: minDownloads,
      );
      return PictogramSearchResult(
        pictograms: cached,
        source: SearchResultSource.cache,
        offlineOnly: true,
      );
    }

    try {
      final networkResults = await _api.searchPictograms(
        cleanQuery,
        language: language,
      );
      await _cache.write(cleanQuery, networkResults, language: language);
      final processed = _process(
        networkResults,
        onlyAacPictograms: onlyAacPictograms,
        onlySchematicPictograms: onlySchematicPictograms,
        minDownloads: minDownloads,
      );
      return PictogramSearchResult(
        pictograms: processed,
        source: SearchResultSource.network,
        offlineOnly: false,
      );
    } on ArasaacException {
      final cached = _cache.read(cleanQuery, language: language);
      if (cached != null) {
        final processed = _process(
          cached,
          onlyAacPictograms: onlyAacPictograms,
          onlySchematicPictograms: onlySchematicPictograms,
          minDownloads: minDownloads,
        );
        return PictogramSearchResult(
          pictograms: processed,
          source: SearchResultSource.cache,
          offlineOnly: false,
        );
      }
      rethrow;
    } catch (_) {
      final cached = _cache.read(cleanQuery, language: language);
      if (cached != null) {
        final processed = _process(
          cached,
          onlyAacPictograms: onlyAacPictograms,
          onlySchematicPictograms: onlySchematicPictograms,
          minDownloads: minDownloads,
        );
        return PictogramSearchResult(
          pictograms: processed,
          source: SearchResultSource.cache,
          offlineOnly: false,
        );
      }
      throw const ArasaacException(
        'No se pudo consultar ARASAAC ni encontrar resultados en cache.',
      );
    }
  }

  List<Pictogram> _process(
    List<Pictogram> items, {
    required bool onlyAacPictograms,
    required bool onlySchematicPictograms,
    required int minDownloads,
  }) {
    final filtered = <Pictogram>[];

    for (final picto in items) {
      if (onlyAacPictograms && !picto.aac) {
        continue;
      }
      if (onlySchematicPictograms && !picto.schematic) {
        continue;
      }
      if (picto.downloads < minDownloads) {
        continue;
      }
      filtered.add(picto);
    }

    final deduplicated = <String, Pictogram>{};
    for (final item in filtered) {
      final key = item.semanticKey;
      final existing = deduplicated[key];
      if (existing == null) {
        deduplicated[key] = item;
        continue;
      }

      if (item.qualityScore > existing.qualityScore) {
        deduplicated[key] = item;
      }
    }

    final results = deduplicated.values.toList();
    results.sort((a, b) {
      final byQuality = b.qualityScore.compareTo(a.qualityScore);
      if (byQuality != 0) {
        return byQuality;
      }
      return a.label.toLowerCase().compareTo(b.label.toLowerCase());
    });
    return results;
  }
}

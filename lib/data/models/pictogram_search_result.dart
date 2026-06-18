import 'pictogram.dart';

enum SearchResultSource { network, cache }

class PictogramSearchResult {
  const PictogramSearchResult({
    required this.pictograms,
    required this.source,
    required this.offlineOnly,
  });

  final List<Pictogram> pictograms;
  final SearchResultSource source;
  final bool offlineOnly;

  bool get fromCache => source == SearchResultSource.cache;
}

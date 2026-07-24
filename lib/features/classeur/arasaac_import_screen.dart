import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../data/models/pictogram.dart';
import '../../data/services/arasaac_api.dart';
import '../../data/services/pictogram_search_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../settings/settings_controller.dart';
import 'local_classeur_controller.dart';

/// Adds a pictogram to a category by importing it from ARASAAC: the picked
/// image is downloaded and copied onto the device, so the resulting pictogram
/// is owned locally and no longer depends on the network (US-1.04 source used
/// to fulfil US-1.06 creation).
///
/// Search goes through [PictogramSearchService], so it benefits from the same
/// quality filters and automatic cache fallback as the communication search.
class ArasaacImportScreen extends StatefulWidget {
  const ArasaacImportScreen({
    required this.controller,
    required this.searchService,
    required this.settingsController,
    required this.categoryId,
    required this.languageCode,
    this.initialQuery = '',
    this.seedKeywords = const [],
    super.key,
  });

  final LocalClasseurController controller;
  final PictogramSearchService searchService;
  final SettingsController settingsController;
  final int categoryId;
  final String languageCode;

  /// Pre-filled query (usually the category name) shown in the search box.
  final String initialQuery;

  /// Keywords searched all at once on open (the category's seed vocabulary),
  /// so a rich set of pictograms shows up without typing word by word.
  final List<String> seedKeywords;

  @override
  State<ArasaacImportScreen> createState() => _ArasaacImportScreenState();
}

class _ArasaacImportScreenState extends State<ArasaacImportScreen> {
  final TextEditingController _queryController = TextEditingController();
  final http.Client _httpClient = http.Client();
  Timer? _debounce;

  List<Pictogram> _results = const [];
  final Set<int> _addedIds = <int>{};
  bool _isLoading = false;
  bool _isImporting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialQuery.trim();
    if (initial.isNotEmpty) {
      _queryController.text = initial;
    }
    if (widget.seedKeywords.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _seedSearch(widget.seedKeywords);
        }
      });
    } else if (initial.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _search();
        }
      });
    }
  }

  /// Searches every seed keyword and merges the results (dedup by semantic key,
  /// keeping the best-quality pictogram) — the same aggregation the category
  /// presets use, so opening a category shows many relevant pictograms at once.
  Future<void> _seedSearch(List<String> keywords) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final settings = widget.settingsController.settings;
    final language = widget.languageCode.isEmpty ? 'fr' : widget.languageCode;
    final merged = <String, Pictogram>{};
    for (final keyword in keywords) {
      try {
        final result = await widget.searchService.search(
          keyword,
          language: language,
          offlineOnly: settings.offlineOnly,
          onlyAacPictograms: settings.onlyAacPictograms,
          onlySchematicPictograms: settings.onlySchematicPictograms,
          minDownloads: settings.minDownloads,
        );
        for (final pictogram in result.pictograms) {
          final existing = merged[pictogram.semanticKey];
          if (existing == null ||
              pictogram.qualityScore > existing.qualityScore) {
            merged[pictogram.semanticKey] = pictogram;
          }
        }
      } catch (_) {
        // Skip a failing keyword, keep the others.
      }
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _results = merged.values.toList();
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    _httpClient.close();
    super.dispose();
  }

  /// Live search: debounces typing so results refresh as the aidant types,
  /// without pressing the button.
  void _onQueryChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _results = const [];
        _error = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), _search);
  }

  Future<void> _search() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) {
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final settings = widget.settingsController.settings;
    final language = widget.languageCode.isEmpty ? 'fr' : widget.languageCode;
    try {
      final result = await widget.searchService.search(
        query,
        language: language,
        offlineOnly: settings.offlineOnly,
        onlyAacPictograms: settings.onlyAacPictograms,
        onlySchematicPictograms: settings.onlySchematicPictograms,
        minDownloads: settings.minDownloads,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _results = result.pictograms;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _results = const [];
        _isLoading = false;
        _error = AppLocalizations.of(context).serviceUnavailable;
      });
    }
  }

  Future<void> _import(Pictogram pictogram) async {
    if (_isImporting || _addedIds.contains(pictogram.id)) {
      return;
    }
    setState(() => _isImporting = true);
    final l10n = AppLocalizations.of(context);
    try {
      final response = await _httpClient
          .get(Uri.parse(pictogram.imageUrl(size: 500)))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw ArasaacException(statusCode: response.statusCode);
      }
      await widget.controller.addPictogram(
        label: pictogram.label,
        categoryId: widget.categoryId,
        imageBytes: response.bodyBytes,
        extension: 'png',
      );
      if (!mounted) {
        return;
      }
      // Stay on the screen so the aidant can add several pictograms in a row;
      // added ones get a check mark. Close with the back button when done.
      setState(() {
        _addedIds.add(pictogram.id);
        _isImporting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pictogramAddedNotice),
          duration: const Duration(milliseconds: 700),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isImporting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.serviceUnavailable)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.importFromArasaac)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryController,
                    textInputAction: TextInputAction.search,
                    onChanged: _onQueryChanged,
                    onSubmitted: (_) => _search(),
                    decoration: InputDecoration(
                      labelText: l10n.searchHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _isLoading ? null : _search,
                  child: Text(l10n.searchButton),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildResults(l10n)),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (_results.isEmpty) {
      return Center(child: Text(l10n.searchEmptyTitle));
    }
    return AbsorbPointer(
      absorbing: _isImporting,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 140,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: _results.length,
        itemBuilder: (context, index) {
          final pictogram = _results[index];
          final added = _addedIds.contains(pictogram.id);
          return InkWell(
            onTap: () => _import(pictogram),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Opacity(
                          opacity: added ? 0.4 : 1,
                          child: CachedNetworkImage(
                            imageUrl: pictogram.imageUrl(size: 300),
                            fit: BoxFit.contain,
                            placeholder: (_, _) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (_, _, _) =>
                                const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                      if (added)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(2),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pictogram.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

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
    super.key,
  });

  final LocalClasseurController controller;
  final PictogramSearchService searchService;
  final SettingsController settingsController;
  final int categoryId;
  final String languageCode;

  @override
  State<ArasaacImportScreen> createState() => _ArasaacImportScreenState();
}

class _ArasaacImportScreenState extends State<ArasaacImportScreen> {
  final TextEditingController _queryController = TextEditingController();
  final http.Client _httpClient = http.Client();

  List<Pictogram> _results = const [];
  bool _isLoading = false;
  bool _isImporting = false;
  String? _error;

  @override
  void dispose() {
    _queryController.dispose();
    _httpClient.close();
    super.dispose();
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
    if (_isImporting) {
      return;
    }
    setState(() => _isImporting = true);
    final l10n = AppLocalizations.of(context);
    try {
      final response =
          await _httpClient.get(Uri.parse(pictogram.imageUrl(size: 500)));
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
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pictogramAddedNotice)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isImporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.serviceUnavailable)),
      );
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
          return InkWell(
            onTap: () => _import(pictogram),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: pictogram.imageUrl(size: 300),
                    fit: BoxFit.contain,
                    placeholder: (_, _) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (_, _, _) =>
                        const Icon(Icons.broken_image_outlined),
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

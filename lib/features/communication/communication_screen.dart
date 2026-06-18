import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/models/pictogram.dart';
import '../../data/models/saved_phrase.dart';
import '../../data/services/arasaac_api.dart';
import '../../data/services/pictogram_search_service.dart';
import '../../data/services/speech_service.dart';
import '../../features/favorites/favorites_controller.dart';
import '../../features/settings/settings_controller.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/pictogram_card.dart';
import 'phrase_book_controller.dart';

class CommunicationScreen extends StatefulWidget {
  const CommunicationScreen({
    required this.searchService,
    required this.favoritesController,
    required this.phraseBookController,
    required this.settingsController,
    required this.speechService,
    super.key,
  });

  final PictogramSearchService searchService;
  final FavoritesController favoritesController;
  final PhraseBookController phraseBookController;
  final SettingsController settingsController;
  final SpeechService speechService;

  @override
  State<CommunicationScreen> createState() => _CommunicationScreenState();
}

class _CommunicationScreenState extends State<CommunicationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Pictogram> _results = <Pictogram>[];

  Timer? _debounce;
  bool _isLoading = false;
  String? _error;
  String? _info;
  int _selectedCategoryIndex = 0;
  bool _showSearch = false;
  String _lastLocaleCode = '';
  _CategoryPreset? _lastCategoryPreset;
  String _lastStandaloneQuery = '';

  static const double _tabletBreakpoint = 900.0;

  static const _categoryColors = [
    Color(0xFF7EC8B8), // Needs - teal
    Color(0xFFF2A6A6), // Emotions - coral
    Color(0xFFF7D77E), // School - amber
    Color(0xFFA8D5A2), // Home - green
    Color(0xFFCBB3E6), // Health - lavender
  ];

  @override
  void initState() {
    super.initState();
    _lastLocaleCode = widget.settingsController.settings.localeCode;
    widget.settingsController.addListener(_onSettingsChanged);

    final initialWord = _initialTermForLocale(_lastLocaleCode);
    _searchController.text = initialWord;
    _lastStandaloneQuery = initialWord;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _search(initialWord);
      }
    });
  }

  @override
  void dispose() {
    widget.settingsController.removeListener(_onSettingsChanged);
    _debounce?.cancel();
    _searchController.dispose();
    widget.speechService.stop();
    super.dispose();
  }

  void _onSettingsChanged() {
    final newLocale = widget.settingsController.settings.localeCode;
    if (newLocale == _lastLocaleCode) {
      return;
    }
    _lastLocaleCode = newLocale;

    if (!mounted) {
      return;
    }

    final newInitial = _initialTermForLocale(newLocale);
    _searchController.text = newInitial;
    _lastStandaloneQuery = newInitial;
    _lastCategoryPreset = null;
    _search(newInitial);
  }

  String _initialTermForLocale(String localeCode) {
    switch (localeCode) {
      case 'fr':
        return 'je veux';
      case 'en':
        return 'want';
      case 'de':
        return 'ich will';
      case 'it':
        return 'voglio';
      case 'es':
      default:
        return 'quiero';
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      _search(value);
    });
  }

  Future<void> _search(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) {
      setState(() {
        _results.clear();
        _error = null;
        _info = null;
        _isLoading = false;
      });
      return;
    }

    _lastStandaloneQuery = clean;
    _lastCategoryPreset = null;

    final settings = widget.settingsController.settings;

    setState(() {
      _error = null;
      _info = null;
      _isLoading = true;
    });

    try {
      final result = await widget.searchService.search(
        clean,
        language: settings.localeCode,
        offlineOnly: settings.offlineOnly,
        onlyAacPictograms: settings.onlyAacPictograms,
        onlySchematicPictograms: settings.onlySchematicPictograms,
        minDownloads: settings.minDownloads,
      );

      if (!mounted) {
        return;
      }

      final l10n = AppLocalizations.of(context);
      var infoMessage = '';
      if (result.fromCache) {
        infoMessage = result.pictograms.isEmpty
            ? l10n.offlineNoCacheNotice
            : l10n.cacheResultsNotice;
      }

      setState(() {
        _results
          ..clear()
          ..addAll(result.pictograms);
        _info = infoMessage.isEmpty ? null : infoMessage;
      });
    } on ArasaacException catch (exception) {
      if (!mounted) {
        return;
      }
      setState(() {
        _results.clear();
        _error = exception.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _results.clear();
        _error = AppLocalizations.of(context).serviceUnavailable;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _searchCategory(_CategoryPreset category) async {
    _lastCategoryPreset = category;
    _lastStandaloneQuery = '';

    final settings = widget.settingsController.settings;

    setState(() {
      _error = null;
      _info = null;
      _isLoading = true;
    });

    final merged = <String, Pictogram>{};
    var usedNetwork = false;
    var usedCache = false;

    for (final term in category.terms) {
      final cleanTerm = term.trim();
      if (cleanTerm.isEmpty) {
        continue;
      }

      try {
        final result = await widget.searchService.search(
          cleanTerm,
          language: settings.localeCode,
          offlineOnly: settings.offlineOnly,
          onlyAacPictograms: settings.onlyAacPictograms,
          onlySchematicPictograms: settings.onlySchematicPictograms,
          minDownloads: settings.minDownloads,
        );

        if (result.fromCache) {
          usedCache = true;
        } else {
          usedNetwork = true;
        }

        for (final pictogram in result.pictograms) {
          final existing = merged[pictogram.semanticKey];
          if (existing == null ||
              pictogram.qualityScore > existing.qualityScore) {
            merged[pictogram.semanticKey] = pictogram;
          }
        }
      } on ArasaacException {
        // Continues with remaining keywords to maximize category coverage.
      } catch (_) {
        // Continues with remaining keywords to maximize category coverage.
      }
    }

    if (!mounted) {
      return;
    }

    final l10n = AppLocalizations.of(context);

    setState(() {
      _results
        ..clear()
        ..addAll(merged.values);

      if (settings.offlineOnly && _results.isEmpty) {
        _info = l10n.offlineNoCacheNotice;
      } else if (usedCache && !usedNetwork) {
        _info = l10n.cacheResultsNotice;
      }

      _isLoading = false;
    });
  }

  Future<void> _refreshCurrent() async {
    if (_lastCategoryPreset != null) {
      await _searchCategory(_lastCategoryPreset!);
      return;
    }
    final query = _lastStandaloneQuery.isEmpty
        ? _searchController.text
        : _lastStandaloneQuery;
    if (query.trim().isEmpty) {
      return;
    }
    await _search(query);
  }

  Future<void> _toggleFavorite(Pictogram pictogram) async {
    await widget.favoritesController.toggleFavorite(pictogram);
    if (!mounted) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    final wasSaved = widget.favoritesController.isFavorite(pictogram.id);
    final message = wasSaved ? l10n.favoriteSaved : l10n.favoriteRemoved;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  Future<void> _addToPhrase(Pictogram pictogram) {
    return widget.phraseBookController.addToCurrent(pictogram);
  }

  Future<void> _removeLastPhraseItem() {
    return widget.phraseBookController.removeLastFromCurrent();
  }

  Future<void> _clearPhrase() {
    return widget.phraseBookController.clearCurrent();
  }

  Future<void> _speakPhrase() async {
    final phraseText = widget.phraseBookController.currentText;
    if (phraseText.isEmpty) {
      return;
    }

    await widget.speechService.speak(
      phraseText,
      languageCode: widget.settingsController.settings.localeCode,
    );
  }

  Future<void> _saveCurrentPhrase() async {
    final l10n = AppLocalizations.of(context);
    final currentText = widget.phraseBookController.currentText;
    if (currentText.isEmpty) {
      return;
    }

    final nameController = TextEditingController();
    try {
      final customName = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(l10n.savePhraseDialogTitle),
            content: TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.savePhraseNameLabel,
                hintText: l10n.savePhraseNameHint,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.of(context).pop(nameController.text),
                child: Text(l10n.save),
              ),
            ],
          );
        },
      );

      if (customName == null) {
        return;
      }

      await widget.phraseBookController.saveCurrentAsPhrase(
        customName: customName,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.savedPhraseAdded)));
    } finally {
      nameController.dispose();
    }
  }

  Future<void> _loadSavedPhrase(SavedPhrase phrase) {
    return widget.phraseBookController.loadSavedPhrase(phrase);
  }

  Future<void> _deleteSavedPhrase(String id) {
    return widget.phraseBookController.deleteSavedPhrase(id);
  }

  void _selectCategory(int index, List<_CategoryPreset> categories) {
    setState(() {
      _selectedCategoryIndex = index;
    });

    final firstTerm = categories[index].terms.first;
    _searchController.text = firstTerm;
    _searchCategory(categories[index]);
  }

  int _columnsForWidth(double width) {
    if (width >= 1200) {
      return 6;
    }
    if (width >= 900) {
      return 5;
    }
    if (width >= 700) {
      return 4;
    }
    if (width >= 500) {
      return 3;
    }
    return 2;
  }

  double _aspectRatioForScale(double scale) {
    final adjusted = 0.66 - (scale - 1.0) * 0.12;
    return adjusted.clamp(0.52, 0.78);
  }

  double _composerIconSize(double width) {
    if (width >= 1200) {
      return 76;
    }
    if (width >= _tabletBreakpoint) {
      return 64;
    }
    if (width >= 600) {
      return 54;
    }
    return 44;
  }

  List<_CategoryPreset> _buildCategories(AppLocalizations l10n) {
    return <_CategoryPreset>[
      _CategoryPreset(
        icon: Icons.sentiment_satisfied_alt_rounded,
        label: l10n.categoryNeeds,
        color: _categoryColors[0],
        terms: [
          l10n.quickWant,
          l10n.quickEat,
          l10n.quickDrink,
          l10n.quickBathroom,
          l10n.quickSleep,
          l10n.quickHelp,
          l10n.quickHome,
        ],
      ),
      _CategoryPreset(
        icon: Icons.psychology_alt_outlined,
        label: l10n.categoryEmotions,
        color: _categoryColors[1],
        terms: [
          l10n.quickHappy,
          l10n.quickSad,
          l10n.quickAngry,
          l10n.quickFear,
          l10n.quickCalm,
          l10n.quickHelp,
        ],
      ),
      _CategoryPreset(
        icon: Icons.school_outlined,
        label: l10n.categorySchool,
        color: _categoryColors[2],
        terms: [
          l10n.quickSchool,
          l10n.quickTeacher,
          l10n.quickRead,
          l10n.quickWrite,
          l10n.quickPlay,
          l10n.quickHelp,
        ],
      ),
      _CategoryPreset(
        icon: Icons.home_outlined,
        label: l10n.categoryHome,
        color: _categoryColors[3],
        terms: [
          l10n.quickHome,
          l10n.quickMom,
          l10n.quickDad,
          l10n.quickSleep,
          l10n.quickPlay,
          l10n.quickEat,
          l10n.quickDrink,
        ],
      ),
      _CategoryPreset(
        icon: Icons.health_and_safety_outlined,
        label: l10n.categoryHealth,
        color: _categoryColors[4],
        terms: [
          l10n.quickDoctor,
          l10n.quickPain,
          l10n.quickMedicine,
          l10n.quickHelp,
          l10n.quickDrink,
          l10n.quickSleep,
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = _buildCategories(l10n);
    final selectedCategory = categories[_selectedCategoryIndex];

    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.favoritesController,
        widget.phraseBookController,
        widget.settingsController,
      ]),
      builder: (context, _) {
        final settings = widget.settingsController.settings;

        return SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= _tabletBreakpoint;
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: isTablet
                    ? _buildTabletLayout(
                        context: context,
                        l10n: l10n,
                        settings: settings,
                        categories: categories,
                        selectedCategory: selectedCategory,
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                      )
                    : _buildMobileLayout(
                        context: context,
                        l10n: l10n,
                        settings: settings,
                        categories: categories,
                        selectedCategory: selectedCategory,
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                      ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout({
    required BuildContext context,
    required AppLocalizations l10n,
    required dynamic settings,
    required List<_CategoryPreset> categories,
    required _CategoryPreset selectedCategory,
    required double width,
    required double height,
  }) {
    final columns = _columnsForWidth(width);
    final gridHeight = (height * 0.42).clamp(220.0, 520.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PhraseComposer(
          phrasePictograms: widget.phraseBookController.currentPhrase,
          phraseText: widget.phraseBookController.currentText,
          speakLabel: l10n.speakPhrase,
          removeLastLabel: l10n.removeLast,
          clearLabel: l10n.clear,
          savePhraseLabel: l10n.savePhrase,
          iconSize: _composerIconSize(width),
          onSpeak: _speakPhrase,
          onRemoveLast: _removeLastPhraseItem,
          onClear: _clearPhrase,
          onSavePhrase: _saveCurrentPhrase,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            children: [
              _buildCategoriesRow(l10n, categories),
              if (_showSearch) ...[
                const SizedBox(height: 8),
                _buildSearchRow(l10n),
              ],
              const SizedBox(height: 8),
              if (settings.offlineOnly)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Chip(
                    avatar: const Icon(Icons.wifi_off_rounded, size: 18),
                    label: Text(l10n.offlineModeChip),
                  ),
                ),
              _buildKeywordChipsRow(selectedCategory),
              if (_info != null) ...[
                const SizedBox(height: 8),
                _InfoBanner(message: _info!),
              ],
              if (_error != null) ...[
                const SizedBox(height: 8),
                _ErrorBanner(message: _error!),
              ],
              const SizedBox(height: 10),
              SizedBox(
                height: gridHeight,
                child: _buildResultsArea(
                  l10n: l10n,
                  settings: settings,
                  columns: columns,
                  selectedCategory: selectedCategory,
                ),
              ),
              const SizedBox(height: 8),
              _SavedPhrasesStrip(
                title: l10n.savedPhrasesTitle,
                emptyMessage: l10n.savedPhrasesEmpty,
                loadLabel: l10n.loadPhrase,
                deleteLabel: l10n.deletePhrase,
                phrases: widget.phraseBookController.savedPhrases,
                onLoad: _loadSavedPhrase,
                onDelete: _deleteSavedPhrase,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout({
    required BuildContext context,
    required AppLocalizations l10n,
    required dynamic settings,
    required List<_CategoryPreset> categories,
    required _CategoryPreset selectedCategory,
    required double width,
    required double height,
  }) {
    final columns = _columnsForWidth(width);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 42,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PhraseComposer(
                phrasePictograms: widget.phraseBookController.currentPhrase,
                phraseText: widget.phraseBookController.currentText,
                speakLabel: l10n.speakPhrase,
                removeLastLabel: l10n.removeLast,
                clearLabel: l10n.clear,
                savePhraseLabel: l10n.savePhrase,
                iconSize: _composerIconSize(width),
                onSpeak: _speakPhrase,
                onRemoveLast: _removeLastPhraseItem,
                onClear: _clearPhrase,
                onSavePhrase: _saveCurrentPhrase,
              ),
              const SizedBox(height: 10),
              if (settings.offlineOnly)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      avatar: const Icon(Icons.wifi_off_rounded, size: 18),
                      label: Text(l10n.offlineModeChip),
                    ),
                  ),
                ),
              Expanded(
                child: _SavedPhrasesPanel(
                  title: l10n.savedPhrasesTitle,
                  emptyMessage: l10n.savedPhrasesEmpty,
                  loadLabel: l10n.loadPhrase,
                  deleteLabel: l10n.deletePhrase,
                  phrases: widget.phraseBookController.savedPhrases,
                  onLoad: _loadSavedPhrase,
                  onDelete: _deleteSavedPhrase,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 58,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategoriesRow(l10n, categories),
              if (_showSearch) ...[
                const SizedBox(height: 8),
                _buildSearchRow(l10n),
              ],
              const SizedBox(height: 8),
              _buildKeywordChipsRow(selectedCategory),
              if (_info != null) ...[
                const SizedBox(height: 8),
                _InfoBanner(message: _info!),
              ],
              if (_error != null) ...[
                const SizedBox(height: 8),
                _ErrorBanner(message: _error!),
              ],
              const SizedBox(height: 10),
              Expanded(
                child: _buildResultsArea(
                  l10n: l10n,
                  settings: settings,
                  columns: columns,
                  selectedCategory: selectedCategory,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesRow(
    AppLocalizations l10n,
    List<_CategoryPreset> categories,
  ) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = categories[index];
                final isSelected = index == _selectedCategoryIndex;
                return ChoiceChip(
                  selected: isSelected,
                  selectedColor: item.color.withValues(alpha: 0.45),
                  backgroundColor: item.color.withValues(alpha: 0.15),
                  onSelected: (_) => _selectCategory(index, categories),
                  avatar: Icon(item.icon, size: 18),
                  label: Text(item.label),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: l10n.showSearch,
            isSelected: _showSearch,
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
              });
            },
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchRow(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            key: const Key('search_field'),
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onChanged: _onSearchChanged,
            onSubmitted: _search,
            decoration: InputDecoration(
              hintText: l10n.searchHint,
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: () => _search(_searchController.text),
          child: Text(l10n.searchButton),
        ),
      ],
    );
  }

  Widget _buildKeywordChipsRow(_CategoryPreset selectedCategory) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: selectedCategory.terms.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final term = selectedCategory.terms[index];
          return ActionChip(
            backgroundColor: selectedCategory.color.withValues(alpha: 0.12),
            label: Text(term),
            onPressed: () {
              _searchController.text = term;
              _search(term);
            },
          );
        },
      ),
    );
  }

  Widget _buildResultsArea({
    required AppLocalizations l10n,
    required dynamic settings,
    required int columns,
    required _CategoryPreset selectedCategory,
  }) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshCurrent,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 220,
              child: _EmptySearchView(title: l10n.searchEmptyTitle),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshCurrent,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _results.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: _aspectRatioForScale(settings.pictogramScale),
        ),
        itemBuilder: (context, index) {
          final pictogram = _results[index];
          return PictogramCard(
            pictogram: pictogram,
            isFavorite: widget.favoritesController.isFavorite(pictogram.id),
            onSelect: () => _addToPhrase(pictogram),
            onToggleFavorite: () => _toggleFavorite(pictogram),
            scale: settings.pictogramScale,
            reducedMotion: settings.reducedMotion,
            highContrast: settings.highContrast,
            phraseActionLabel: l10n.addToPhrase,
            saveFavoriteTooltip: l10n.saveFavorite,
            removeFavoriteTooltip: l10n.removeFavoriteTooltip,
            accentColor: selectedCategory.color,
          );
        },
      ),
    );
  }
}

class _CategoryPreset {
  const _CategoryPreset({
    required this.icon,
    required this.label,
    required this.color,
    required this.terms,
  });

  final IconData icon;
  final String label;
  final Color color;
  final List<String> terms;
}

class _EmptySearchView extends StatelessWidget {
  const _EmptySearchView({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_rounded, size: 44, color: colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(message),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.errorContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(message),
    );
  }
}

class _SavedPhrasesStrip extends StatelessWidget {
  const _SavedPhrasesStrip({
    required this.title,
    required this.emptyMessage,
    required this.loadLabel,
    required this.deleteLabel,
    required this.phrases,
    required this.onLoad,
    required this.onDelete,
  });

  final String title;
  final String emptyMessage;
  final String loadLabel;
  final String deleteLabel;
  final List<SavedPhrase> phrases;
  final Future<void> Function(SavedPhrase phrase) onLoad;
  final Future<void> Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            if (phrases.isEmpty)
              Text(emptyMessage)
            else
              SizedBox(
                height: 76,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: phrases.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final phrase = phrases[index];
                    return _SavedPhraseTile(
                      phrase: phrase,
                      loadLabel: loadLabel,
                      deleteLabel: deleteLabel,
                      onLoad: onLoad,
                      onDelete: onDelete,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SavedPhrasesPanel extends StatelessWidget {
  const _SavedPhrasesPanel({
    required this.title,
    required this.emptyMessage,
    required this.loadLabel,
    required this.deleteLabel,
    required this.phrases,
    required this.onLoad,
    required this.onDelete,
  });

  final String title;
  final String emptyMessage;
  final String loadLabel;
  final String deleteLabel;
  final List<SavedPhrase> phrases;
  final Future<void> Function(SavedPhrase phrase) onLoad;
  final Future<void> Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: phrases.isEmpty
                  ? Center(child: Text(emptyMessage))
                  : ListView.separated(
                      itemCount: phrases.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final phrase = phrases[index];
                        return _SavedPhraseTile(
                          phrase: phrase,
                          loadLabel: loadLabel,
                          deleteLabel: deleteLabel,
                          onLoad: onLoad,
                          onDelete: onDelete,
                          fullWidth: true,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedPhraseTile extends StatelessWidget {
  const _SavedPhraseTile({
    required this.phrase,
    required this.loadLabel,
    required this.deleteLabel,
    required this.onLoad,
    required this.onDelete,
    this.fullWidth = false,
  });

  final SavedPhrase phrase;
  final String loadLabel;
  final String deleteLabel;
  final Future<void> Function(SavedPhrase phrase) onLoad;
  final Future<void> Function(String id) onDelete;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: fullWidth ? double.infinity : 220,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => onLoad(phrase),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    phrase.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phrase.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              IconButton(
                tooltip: loadLabel,
                onPressed: () => onLoad(phrase),
                icon: const Icon(Icons.upload_rounded),
              ),
              IconButton(
                tooltip: deleteLabel,
                onPressed: () => onDelete(phrase.id),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhraseComposer extends StatelessWidget {
  const _PhraseComposer({
    required this.phrasePictograms,
    required this.phraseText,
    required this.speakLabel,
    required this.removeLastLabel,
    required this.clearLabel,
    required this.savePhraseLabel,
    required this.iconSize,
    required this.onSpeak,
    required this.onRemoveLast,
    required this.onClear,
    required this.onSavePhrase,
  });

  final List<Pictogram> phrasePictograms;
  final String phraseText;
  final String speakLabel;
  final String removeLastLabel;
  final String clearLabel;
  final String savePhraseLabel;
  final double iconSize;
  final Future<void> Function() onSpeak;
  final Future<void> Function() onRemoveLast;
  final Future<void> Function() onClear;
  final Future<void> Function() onSavePhrase;

  @override
  Widget build(BuildContext context) {
    final hasPhrase = phrasePictograms.isNotEmpty;
    final labelWidth = iconSize + 8;
    final stripHeight = iconSize + 22;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasPhrase) ...[
              SizedBox(
                height: stripHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: phrasePictograms.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final pictogram = phrasePictograms[index];
                    return Column(
                      children: [
                        Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: pictogram.imageUrl(size: 100),
                              fit: BoxFit.contain,
                              placeholder: (_, _) => const SizedBox.shrink(),
                              errorWidget: (_, _, _) => const Icon(
                                Icons.image_not_supported_outlined,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        SizedBox(
                          width: labelWidth,
                          child: Text(
                            pictogram.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  phraseText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: hasPhrase ? onSpeak : null,
                  icon: const Icon(Icons.volume_up_rounded),
                  label: Text(speakLabel),
                ),
                FilledButton.tonalIcon(
                  key: const Key('save_phrase_button'),
                  onPressed: hasPhrase ? onSavePhrase : null,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(savePhraseLabel),
                ),
                FilledButton.tonalIcon(
                  onPressed: hasPhrase ? onRemoveLast : null,
                  icon: const Icon(Icons.backspace_outlined),
                  label: Text(removeLastLabel),
                ),
                FilledButton.tonalIcon(
                  onPressed: hasPhrase ? onClear : null,
                  icon: const Icon(Icons.delete_sweep_outlined),
                  label: Text(clearLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../data/models/local_pictogram.dart';
import '../../data/models/pictogram.dart';
import '../../data/services/speech_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/pictogram_image.dart';
import '../classeur/local_classeur_controller.dart';
import '../settings/settings_controller.dart';
import 'phrase_book_controller.dart';
import 'repeat_tap_guard.dart';

/// Communication mode backed by the owned local classeur (US-1.01 → US-1.06):
/// the end user browses their own categories and pictograms, entirely from
/// disk and offline, and composes the bande-phrase. This is the classeur put
/// at the heart of the app (CDC 6.3/6.4). Only assimilated pictograms ever
/// show up here: ARASAAC lives in the aidant area and never appears on its
/// own (retour IME, US-1.14 / US-2.03).
class ClasseurCommunicationScreen extends StatefulWidget {
  const ClasseurCommunicationScreen({
    required this.classeurController,
    required this.phraseBookController,
    required this.settingsController,
    required this.speechService,
    super.key,
  });

  final LocalClasseurController classeurController;
  final PhraseBookController phraseBookController;
  final SettingsController settingsController;
  final SpeechService speechService;

  @override
  State<ClasseurCommunicationScreen> createState() =>
      _ClasseurCommunicationScreenState();
}

class _ClasseurCommunicationScreenState
    extends State<ClasseurCommunicationScreen> {
  int _selectedCategoryIndex = 0;

  // Keeps owned-pictogram ids clear of ARASAAC ids in the shared phrase book.
  static const int _localIdOffset = 1000000000;

  // System language cached from didChangeDependencies, so callbacks never read
  // the context (avoids the '_dependents.isEmpty' inherited-widget assertion).
  String _systemLocaleCode = 'fr';

  final RepeatTapGuard _tapGuard = RepeatTapGuard();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _systemLocaleCode = Localizations.localeOf(context).languageCode;
  }

  @override
  void dispose() {
    widget.speechService.stop();
    super.dispose();
  }

  String _effectiveLocaleCode() {
    final settings = widget.settingsController.settings;
    return settings.isAutomaticLocale ? _systemLocaleCode : settings.localeCode;
  }

  Pictogram _toPictogram(LocalPictogram picto) {
    return Pictogram(
      id: _localIdOffset + picto.id,
      label: picto.label,
      localImagePath: widget.classeurController.absoluteImagePath(
        picto.imagePath,
      ),
    );
  }

  Future<void> _onSelect(LocalPictogram picto) async {
    // Ignore an accidental fast repeat of the same pictogram (CDC 3.1).
    if (!_tapGuard.accept(_localIdOffset + picto.id)) {
      return;
    }
    final languageCode = _effectiveLocaleCode();
    final pictogram = _toPictogram(picto);
    await widget.phraseBookController.addToCurrent(pictogram);
    // Speak the pictogram as it is added (C-07).
    await widget.speechService.speak(
      picto.label,
      languageCode: languageCode,
      rate: widget.settingsController.settings.speechRate,
    );
  }

  Future<void> _speakPhrase() async {
    final text = widget.phraseBookController.currentText;
    if (text.isEmpty) {
      return;
    }
    await widget.speechService.speak(
      text,
      languageCode: _effectiveLocaleCode(),
      rate: widget.settingsController.settings.speechRate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // On a short screen (phone in landscape) the vertical stack wastes
          // the one resource that matters: height. Everything flattens into
          // rows so the grid keeps the lion's share of the screen.
          final isCompactHeight = constraints.maxHeight < 500;

          return AnimatedBuilder(
            animation: Listenable.merge([
              widget.classeurController,
              widget.phraseBookController,
            ]),
            builder: (context, _) {
              final settings = widget.settingsController.settings;
              // Empty categories are hidden: an end user tapping one would land on
              // a blank screen, which reads as a broken app (CDC 3.1).
              final categories = widget
                  .classeurController
                  .classeur
                  .categoriesSorted
                  .where(
                    (category) => widget.classeurController.classeur
                        .pictogramsIn(category.id)
                        .isNotEmpty,
                  )
                  .toList();
              if (categories.isEmpty) {
                return _EmptyClasseurView(
                  title: l10n.communicationEmptyTitle,
                  message: l10n.communicationEmptyMessage,
                );
              }
              // The favorites view is a chip pinned in first position (US-R.03).
              // It only exists once the aidant marked a favorite, so the category
              // slots never move while the end user is browsing (CDC 3.1).
              final favorites = widget.classeurController.classeur.favorites;
              final hasFavorites = favorites.isNotEmpty;
              final tabCount = categories.length + (hasFavorites ? 1 : 0);

              final index = _selectedCategoryIndex.clamp(0, tabCount - 1);
              final isFavoritesTab = hasFavorites && index == 0;
              final pictograms = isFavoritesTab
                  ? favorites
                  : widget.classeurController.classeur.pictogramsIn(
                      categories[hasFavorites ? index - 1 : index].id,
                    );

              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PhraseStrip(
                      pictograms: widget.phraseBookController.currentPhrase,
                      onSpeak: _speakPhrase,
                      onRemoveLast:
                          widget.phraseBookController.removeLastFromCurrent,
                      onClear: widget.phraseBookController.clearCurrent,
                      speakLabel: l10n.speakPhrase,
                      removeLastLabel: l10n.removeLast,
                      clearLabel: l10n.clear,
                      compact: isCompactHeight,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: tabCount,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          if (hasFavorites && i == 0) {
                            return ChoiceChip(
                              avatar: const Icon(
                                Icons.favorite_rounded,
                                size: 18,
                              ),
                              label: Text(l10n.favoritesNav),
                              selected: i == index,
                              onSelected: (_) =>
                                  setState(() => _selectedCategoryIndex = i),
                            );
                          }
                          final category = categories[hasFavorites ? i - 1 : i];
                          return ChoiceChip(
                            label: Text(category.name),
                            selected: i == index,
                            onSelected: (_) =>
                                setState(() => _selectedCategoryIndex = i),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: pictograms.isEmpty
                          ? Center(child: Text(l10n.categoryEmptyPictograms))
                          : GridView.builder(
                              // Explicit column count when the aidant set one
                              // (A-12), otherwise size-based automatic layout.
                              // Cards flatten on short screens so a full row
                              // (image + complete label) stays visible.
                              gridDelegate: settings.isAutomaticGridColumns
                                  ? SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 160,
                                      mainAxisSpacing: 10,
                                      crossAxisSpacing: 10,
                                      childAspectRatio: isCompactHeight
                                          ? 1.15
                                          : 0.82,
                                    )
                                  : SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: settings.gridColumns,
                                      mainAxisSpacing: 10,
                                      crossAxisSpacing: 10,
                                      childAspectRatio: isCompactHeight
                                          ? 1.15
                                          : 0.82,
                                    ),
                              itemCount: pictograms.length,
                              itemBuilder: (context, i) => _OwnedPictogramCard(
                                pictogram: _toPictogram(pictograms[i]),
                                label: pictograms[i].label,
                                showLabel: settings.showPictogramLabel,
                                onTap: () => _onSelect(pictograms[i]),
                              ),
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Calm end-user empty state: no ARASAAC fallback, no call to action. The
/// classeur only fills up through the aidant area (retour IME: pictograms
/// must be assimilated before they appear).
class _EmptyClasseurView extends StatelessWidget {
  const _EmptyClasseurView({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_rounded, size: 44, color: colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _OwnedPictogramCard extends StatelessWidget {
  const _OwnedPictogramCard({
    required this.pictogram,
    required this.label,
    required this.onTap,
    this.showLabel = true,
  });

  final Pictogram pictogram;
  final String label;
  final VoidCallback onTap;

  /// Text under the image can be hidden (A-14).
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // Large tap target, simple tap only (CDC 3.1).
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: PictogramImage(pictogram: pictogram),
                ),
              ),
              if (showLabel) ...[
                const SizedBox(height: 6),
                // Never truncated (retour client): a cut label defeats the
                // pairing between picture and word. Long labels wrap and the
                // image gives up the space.
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PhraseStrip extends StatelessWidget {
  const _PhraseStrip({
    required this.pictograms,
    required this.onSpeak,
    required this.onRemoveLast,
    required this.onClear,
    required this.speakLabel,
    required this.removeLastLabel,
    required this.clearLabel,
    required this.compact,
  });

  final List<Pictogram> pictograms;
  final Future<void> Function() onSpeak;
  final Future<void> Function() onRemoveLast;
  final Future<void> Function() onClear;
  final String speakLabel;
  final String removeLastLabel;
  final String clearLabel;

  /// Single-row layout for short screens (phone in landscape): the strip and
  /// its controls share one line, so the grid keeps most of the height.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final hasPhrase = pictograms.isNotEmpty;

    // Icon-only controls: any button text reads as parasitic information for
    // the end user (retour IME). Tooltips and semantic labels keep the
    // actions accessible. Speak has a fixed generous width: stretching it to
    // the full row just produces a giant empty bar.
    final speakButton = Semantics(
      button: true,
      label: speakLabel,
      child: SizedBox(
        width: 76,
        height: 48,
        child: FilledButton(
          onPressed: hasPhrase ? () => onSpeak() : null,
          child: const Icon(Icons.volume_up_rounded),
        ),
      ),
    );
    final removeLastButton = IconButton.filledTonal(
      tooltip: removeLastLabel,
      onPressed: hasPhrase ? () => onRemoveLast() : null,
      icon: const Icon(Icons.backspace_outlined),
    );
    final clearButton = IconButton.filledTonal(
      tooltip: clearLabel,
      onPressed: hasPhrase ? () => onClear() : null,
      icon: const Icon(Icons.delete_sweep_outlined),
    );

    if (compact) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                Expanded(
                  child: hasPhrase
                      ? _buildMiniPictoStrip(context, labelLines: 1)
                      : const SizedBox.shrink(),
                ),
                const SizedBox(width: 8),
                speakButton,
                const SizedBox(width: 8),
                removeLastButton,
                const SizedBox(width: 4),
                clearButton,
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              // Tall enough for the image plus a two-line label.
              height: 86,
              child: hasPhrase
                  ? _buildMiniPictoStrip(context, labelLines: 2)
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                speakButton,
                const Spacer(),
                removeLastButton,
                const SizedBox(width: 4),
                clearButton,
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// The tile widens with its label (up to a cap) so even long words stay
  /// readable in the bande-phrase (retour client : le texte doit rester
  /// complet). [labelLines] drops to 1 in compact mode where height is scarce.
  Widget _buildMiniPictoStrip(BuildContext context, {required int labelLines}) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: pictograms.length,
      separatorBuilder: (_, _) => const SizedBox(width: 6),
      itemBuilder: (context, index) => ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 60, maxWidth: 120),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(3),
                child: PictogramImage(pictogram: pictograms[index], size: 100),
              ),
            ),
            Text(
              pictograms[index].label,
              maxLines: labelLines,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

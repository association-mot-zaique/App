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
/// at the heart of the app (CDC 6.3/6.4), shown whenever the classeur has at
/// least one category.
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
      localImagePath:
          widget.classeurController.absoluteImagePath(picto.imagePath),
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
      child: AnimatedBuilder(
        animation: Listenable.merge(
          [widget.classeurController, widget.phraseBookController],
        ),
        builder: (context, _) {
          final categories = widget.classeurController.classeur.categoriesSorted;
          if (categories.isEmpty) {
            return const SizedBox.shrink();
          }
          final index = _selectedCategoryIndex.clamp(0, categories.length - 1);
          final selectedCategory = categories[index];
          final pictograms =
              widget.classeurController.classeur.pictogramsIn(selectedCategory.id);

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
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final category = categories[i];
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
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 160,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.82,
                          ),
                          itemCount: pictograms.length,
                          itemBuilder: (context, i) => _OwnedPictogramCard(
                            pictogram: _toPictogram(pictograms[i]),
                            label: pictograms[i].label,
                            onTap: () => _onSelect(pictograms[i]),
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OwnedPictogramCard extends StatelessWidget {
  const _OwnedPictogramCard({
    required this.pictogram,
    required this.label,
    required this.onTap,
  });

  final Pictogram pictogram;
  final String label;
  final VoidCallback onTap;

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
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
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
  });

  final List<Pictogram> pictograms;
  final Future<void> Function() onSpeak;
  final Future<void> Function() onRemoveLast;
  final Future<void> Function() onClear;
  final String speakLabel;
  final String removeLastLabel;
  final String clearLabel;

  @override
  Widget build(BuildContext context) {
    final hasPhrase = pictograms.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 74,
              child: hasPhrase
                  ? ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: pictograms.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 6),
                      itemBuilder: (context, index) => SizedBox(
                        width: 60,
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(3),
                                child: PictogramImage(
                                  pictogram: pictograms[index],
                                  size: 100,
                                ),
                              ),
                            ),
                            Text(
                              pictograms[index].label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: hasPhrase ? () => onSpeak() : null,
                    icon: const Icon(Icons.volume_up_rounded),
                    label: Text(speakLabel),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: removeLastLabel,
                  onPressed: hasPhrase ? () => onRemoveLast() : null,
                  icon: const Icon(Icons.backspace_outlined),
                ),
                const SizedBox(width: 4),
                IconButton.filledTonal(
                  tooltip: clearLabel,
                  onPressed: hasPhrase ? () => onClear() : null,
                  icon: const Icon(Icons.delete_sweep_outlined),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

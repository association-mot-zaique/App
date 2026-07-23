import '../../l10n/generated/app_localizations.dart';

/// Seed keywords for a classeur category, reused from the existing category
/// presets. When the aidant opens ARASAAC from a known category, these are
/// searched all at once so a rich set of relevant pictograms shows up without
/// typing word by word. Falls back to the category name for custom names.
List<String> categorySeedKeywords(AppLocalizations l10n, String categoryName) {
  final target = categoryName.trim().toLowerCase();
  bool matches(String candidate) => candidate.trim().toLowerCase() == target;

  if (matches(l10n.categoryNeeds)) {
    return [
      l10n.quickWant,
      l10n.quickEat,
      l10n.quickDrink,
      l10n.quickBathroom,
      l10n.quickSleep,
      l10n.quickHelp,
      l10n.quickHome,
    ];
  }
  if (matches(l10n.categoryEmotions)) {
    return [
      l10n.quickHappy,
      l10n.quickSad,
      l10n.quickAngry,
      l10n.quickFear,
      l10n.quickCalm,
      l10n.quickHelp,
    ];
  }
  if (matches(l10n.categoryHome)) {
    return [
      l10n.quickHome,
      l10n.quickMom,
      l10n.quickDad,
      l10n.quickSleep,
      l10n.quickPlay,
      l10n.quickEat,
      l10n.quickDrink,
    ];
  }
  if (matches(l10n.categorySchool)) {
    return [
      l10n.quickSchool,
      l10n.quickTeacher,
      l10n.quickRead,
      l10n.quickWrite,
      l10n.quickPlay,
      l10n.quickHelp,
    ];
  }
  if (matches(l10n.categoryHealth)) {
    return [
      l10n.quickDoctor,
      l10n.quickPain,
      l10n.quickMedicine,
      l10n.quickHelp,
      l10n.quickDrink,
      l10n.quickSleep,
    ];
  }
  if (matches(l10n.suggestionMeals)) {
    return [l10n.quickEat, l10n.quickDrink];
  }
  if (matches(l10n.suggestionPeople)) {
    return [l10n.quickMom, l10n.quickDad, l10n.quickTeacher, l10n.quickDoctor];
  }
  if (matches(l10n.suggestionActivities)) {
    return [l10n.quickPlay, l10n.quickRead, l10n.quickWrite];
  }
  if (matches(l10n.suggestionPlaces)) {
    return [l10n.quickHome, l10n.quickSchool];
  }
  if (matches(l10n.suggestionToys)) {
    return [l10n.quickPlay];
  }

  final trimmed = categoryName.trim();
  return trimmed.isEmpty ? const [] : [trimmed];
}

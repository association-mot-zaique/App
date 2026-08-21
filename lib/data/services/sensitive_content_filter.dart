import '../models/pictogram.dart';

/// Screens ARASAAC results for content that must never surface in the app.
///
/// The app is distributed in Google Play's children category (politique
/// Familles) : any violent or sexual content reachable through the app —
/// even behind the aidant PIN — is grounds for rejection (rejet Google du
/// 21/08/2026, "App Content: Violence").
///
/// Two nets, because neither is complete on its own:
/// 1. ARASAAC's own `violence` / `sex` flags (miss e.g. "pistolet", "guerre");
/// 2. a keyword blocklist over labels and tags, in the five app languages.
///
/// Vocabulary a family might legitimately need despite the filter (e.g. to
/// express "il m'a frappé") can still be added to the classeur through the
/// file and photo imports, which are fully under the aidant's control.
class SensitiveContentFilter {
  const SensitiveContentFilter._();

  /// Weapon / killing / explicit-violence terms. Everyday CAA vocabulary that
  /// is merely adjacent (couteau, sang, hopital...) is deliberately NOT
  /// listed: over-blocking would harm communication more than it protects.
  static final RegExp _blockedTerms = RegExp(
    r'\b('
    // francais
    r'pistolet|fusil|revolver|mitraillette|arme|armes|guerre|bombe|grenade|'
    r'poignard|tuer|meurtre|assassiner|suicide|violence|torture|'
    // english
    r'gun|guns|rifle|pistol|weapon|weapons|war|bomb|dagger|kill|murder|'
    r'violent|'
    // espanol
    r'pistola|arma|armas|guerra|bomba|granada|matar|asesinar|asesinato|'
    r'suicidio|violencia|tortura|'
    // deutsch
    r'pistole|gewehr|waffe|waffen|krieg|granate|dolch|morden|mord|'
    r'selbstmord|gewalt|folter|'
    // italiano
    r'fucile|armi|bombardare|pugnale|uccidere|omicidio|violenza|tortura'
    r')\b',
    caseSensitive: false,
  );

  /// True when the pictogram must be hidden from every ARASAAC search.
  static bool isBlocked(Pictogram pictogram) {
    if (pictogram.violence || pictogram.sex) {
      return true;
    }
    if (_blockedTerms.hasMatch(pictogram.label)) {
      return true;
    }
    return pictogram.tags.any(_blockedTerms.hasMatch);
  }
}

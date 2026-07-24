import 'dart:ui';

class AppSettings {
  const AppSettings({
    required this.pictogramScale,
    required this.highContrast,
    required this.reducedMotion,
    required this.offlineOnly,
    required this.localeCode,
    required this.onlyAacPictograms,
    required this.onlySchematicPictograms,
    required this.minDownloads,
    required this.savedPhrasesEnabled,
    required this.speechRate,
    required this.gridColumns,
    required this.showPictogramLabel,
  });

  static const AppSettings defaults = AppSettings(
    pictogramScale: 1.0,
    highContrast: false,
    reducedMotion: false,
    offlineOnly: false,
    localeCode: '',
    // Off by default: ARASAAC tags few pictograms as "aac", so filtering on it
    // emptied whole categories (e.g. the emotions "afraid"/"calm"). The aidant
    // can re-enable it in the settings.
    onlyAacPictograms: false,
    onlySchematicPictograms: false,
    minDownloads: 0,
    savedPhrasesEnabled: false,
    speechRate: 0.42,
    gridColumns: 0,
    showPictogramLabel: true,
  );

  final double pictogramScale;
  final bool highContrast;
  final bool reducedMotion;
  final bool offlineOnly;
  final String localeCode;
  final bool onlyAacPictograms;
  final bool onlySchematicPictograms;

  /// Minimum download count. **Always 0 in practice**: the ARASAAC search
  /// endpoint reports `downloads: 0` for every pictogram, so any positive
  /// threshold discards *all* results and blanks the communication screen. The
  /// setting is therefore no longer exposed, and stored values are reset by the
  /// schema v3 migration. Kept in the model so the filter can come back if
  /// ARASAAC ever serves real counts.
  final int minDownloads;

  /// Saved sentences (C-11..C-13) are hidden from the communication interface
  /// by default; the aidant can turn them on (A-17). The feature code stays in
  /// place for non-regression (CDC 4.1).
  final bool savedPhrasesEnabled;

  /// TTS speech rate (A-13, reclassed Must): governs intelligibility once the
  /// spoken output is a first-class feature (C-06/C-07). 0.42 is the previous
  /// fixed value, now the default.
  final double speechRate;

  /// Pictograms per screen (A-12). `0` = automatic (derived from the screen
  /// width); 2..6 forces that many columns, so the aidant can trade choice for
  /// bigger touch targets depending on the profile.
  final int gridColumns;

  /// Show the label under the pictogram image (A-14): some users read it,
  /// others are distracted by it.
  final bool showPictogramLabel;

  bool get isAutomaticGridColumns => gridColumns <= 0;

  /// Empty [localeCode] means "automatic": follow the system language.
  /// Returning `null` lets [MaterialApp] resolve the locale from the device.
  bool get isAutomaticLocale => localeCode.isEmpty;

  Locale? get locale => localeCode.isEmpty ? null : Locale(localeCode);

  AppSettings copyWith({
    double? pictogramScale,
    bool? highContrast,
    bool? reducedMotion,
    bool? offlineOnly,
    String? localeCode,
    bool? onlyAacPictograms,
    bool? onlySchematicPictograms,
    int? minDownloads,
    bool? savedPhrasesEnabled,
    double? speechRate,
    int? gridColumns,
    bool? showPictogramLabel,
  }) {
    return AppSettings(
      pictogramScale: pictogramScale ?? this.pictogramScale,
      highContrast: highContrast ?? this.highContrast,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      offlineOnly: offlineOnly ?? this.offlineOnly,
      localeCode: localeCode ?? this.localeCode,
      onlyAacPictograms: onlyAacPictograms ?? this.onlyAacPictograms,
      onlySchematicPictograms:
          onlySchematicPictograms ?? this.onlySchematicPictograms,
      minDownloads: minDownloads ?? this.minDownloads,
      savedPhrasesEnabled: savedPhrasesEnabled ?? this.savedPhrasesEnabled,
      speechRate: speechRate ?? this.speechRate,
      gridColumns: gridColumns ?? this.gridColumns,
      showPictogramLabel: showPictogramLabel ?? this.showPictogramLabel,
    );
  }

  /// Bumped when the persisted shape changes so old data can be migrated.
  /// v2 introduced the "automatic" locale (empty [localeCode]); v1 defaulted
  /// to Spanish and had no automatic option. v3 resets [minDownloads], which
  /// could only ever blank the communication screen.
  static const int schemaVersion = 3;

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'pictogramScale': pictogramScale,
      'highContrast': highContrast,
      'reducedMotion': reducedMotion,
      'offlineOnly': offlineOnly,
      'localeCode': localeCode,
      'onlyAacPictograms': onlyAacPictograms,
      'onlySchematicPictograms': onlySchematicPictograms,
      'minDownloads': minDownloads,
      'savedPhrasesEnabled': savedPhrasesEnabled,
      'speechRate': speechRate,
      'gridColumns': gridColumns,
      'showPictogramLabel': showPictogramLabel,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final storedVersion = json['schemaVersion'] as int? ?? 1;
    var localeCode = json['localeCode'] as String? ?? '';
    // Migration v1 -> v2: v1 had no "automatic" option and defaulted to
    // Spanish, so a legacy bare 'es' was never a deliberate choice. Convert it
    // to automatic so the app follows the system language.
    if (storedVersion < 2 && localeCode == 'es') {
      localeCode = '';
    }

    // Migration v2 -> v3: a positive minDownloads discarded every ARASAAC
    // result (the API always reports 0 downloads), leaving the communication
    // screen empty with no explanation. Reset it so an affected install
    // recovers on its own.
    var minDownloads = json['minDownloads'] as int? ?? 0;
    if (storedVersion < 3) {
      minDownloads = 0;
    }

    return AppSettings(
      pictogramScale: (json['pictogramScale'] as num?)?.toDouble() ?? 1.0,
      highContrast: json['highContrast'] as bool? ?? false,
      reducedMotion: json['reducedMotion'] as bool? ?? false,
      offlineOnly: json['offlineOnly'] as bool? ?? false,
      localeCode: localeCode,
      onlyAacPictograms: json['onlyAacPictograms'] as bool? ?? false,
      onlySchematicPictograms:
          json['onlySchematicPictograms'] as bool? ?? false,
      minDownloads: minDownloads,
      savedPhrasesEnabled: json['savedPhrasesEnabled'] as bool? ?? false,
      speechRate: (json['speechRate'] as num?)?.toDouble() ?? 0.42,
      gridColumns: (json['gridColumns'] as num?)?.toInt() ?? 0,
      showPictogramLabel: json['showPictogramLabel'] as bool? ?? true,
    );
  }
}

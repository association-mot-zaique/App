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
  });

  static const AppSettings defaults = AppSettings(
    pictogramScale: 1.0,
    highContrast: false,
    reducedMotion: false,
    offlineOnly: false,
    localeCode: '',
    onlyAacPictograms: true,
    onlySchematicPictograms: false,
    minDownloads: 0,
  );

  final double pictogramScale;
  final bool highContrast;
  final bool reducedMotion;
  final bool offlineOnly;
  final String localeCode;
  final bool onlyAacPictograms;
  final bool onlySchematicPictograms;
  final int minDownloads;

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
    );
  }

  /// Bumped when the persisted shape changes so old data can be migrated.
  /// v2 introduced the "automatic" locale (empty [localeCode]); v1 defaulted
  /// to Spanish and had no automatic option.
  static const int schemaVersion = 2;

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
    return AppSettings(
      pictogramScale: (json['pictogramScale'] as num?)?.toDouble() ?? 1.0,
      highContrast: json['highContrast'] as bool? ?? false,
      reducedMotion: json['reducedMotion'] as bool? ?? false,
      offlineOnly: json['offlineOnly'] as bool? ?? false,
      localeCode: localeCode,
      onlyAacPictograms: json['onlyAacPictograms'] as bool? ?? true,
      onlySchematicPictograms:
          json['onlySchematicPictograms'] as bool? ?? false,
      minDownloads: json['minDownloads'] as int? ?? 0,
    );
  }
}

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
    localeCode: 'es',
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

  Locale get locale => Locale(localeCode);

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

  Map<String, dynamic> toJson() {
    return {
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
    return AppSettings(
      pictogramScale: (json['pictogramScale'] as num?)?.toDouble() ?? 1.0,
      highContrast: json['highContrast'] as bool? ?? false,
      reducedMotion: json['reducedMotion'] as bool? ?? false,
      offlineOnly: json['offlineOnly'] as bool? ?? false,
      localeCode: json['localeCode'] as String? ?? 'es',
      onlyAacPictograms: json['onlyAacPictograms'] as bool? ?? true,
      onlySchematicPictograms:
          json['onlySchematicPictograms'] as bool? ?? false,
      minDownloads: json['minDownloads'] as int? ?? 0,
    );
  }
}

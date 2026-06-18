import 'package:flutter/material.dart';

import '../../data/models/app_settings.dart';

class PastelTheme {
  static ThemeData build(AppSettings settings) {
    final colorScheme = settings.highContrast
        ? const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFF3A8D7A),
            onPrimary: Colors.white,
            secondary: Color(0xFFD07358),
            onSecondary: Colors.white,
            tertiary: Color(0xFF4C83B8),
            onTertiary: Colors.white,
            error: Color(0xFFA62928),
            onError: Colors.white,
            surface: Color(0xFFFFFFFF),
            onSurface: Color(0xFF121212),
          )
        : const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFF93D5C7),
            onPrimary: Color(0xFF13342B),
            secondary: Color(0xFFF6C1AF),
            onSecondary: Color(0xFF48251A),
            tertiary: Color(0xFFB7D9F7),
            onTertiary: Color(0xFF173246),
            error: Color(0xFFB44D4C),
            onError: Colors.white,
            surface: Color(0xFFFFF3E6),
            onSurface: Color(0xFF2E2A25),
          );

    final textTheme = ThemeData.light().textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: settings.highContrast
          ? const Color(0xFFFFFEFC)
          : const Color(0xFFFFFBF6),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.65),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.35),
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        selectedColor: colorScheme.secondary.withValues(alpha: 0.4),
        backgroundColor: Colors.white,
        side: BorderSide.none,
      ),
      pageTransitionsTheme: settings.reducedMotion
          ? const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: NoTransitionsBuilder(),
                TargetPlatform.iOS: NoTransitionsBuilder(),
                TargetPlatform.macOS: NoTransitionsBuilder(),
                TargetPlatform.windows: NoTransitionsBuilder(),
                TargetPlatform.linux: NoTransitionsBuilder(),
              },
            )
          : null,
    );
  }
}

class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

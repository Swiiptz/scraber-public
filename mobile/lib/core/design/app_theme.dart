import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';
import 'typography.dart';

/// Thème Scraber v2. Expose [AppTheme.light] et [AppTheme.dark].
class AppTheme {
  AppTheme._();

  static ThemeData light = _build(AppPalette.light, Brightness.light);
  static ThemeData dark = _build(AppPalette.dark, Brightness.dark);

  static SystemUiOverlayStyle overlayLight = const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFFEEF0F2),
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static SystemUiOverlayStyle overlayDark = const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Color(0xFF0F1318),
    systemNavigationBarIconBrightness: Brightness.light,
  );

  static ThemeData _build(AppPalette p, Brightness brightness) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: p.accent,
      onPrimary: brightness == Brightness.light ? Colors.white : p.ink,
      secondary: p.accent,
      onSecondary: brightness == Brightness.light ? Colors.white : p.ink,
      error: p.critique,
      onError: brightness == Brightness.light ? Colors.white : p.ink,
      surface: p.surface,
      onSurface: p.ink,
      surfaceContainerHighest: p.backgroundAlt,
      outline: p.border,
      outlineVariant: p.borderSoft,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      dividerColor: p.borderSoft,
      splashFactory: InkSparkle.splashFactory,
      textTheme: AppText.textTheme(p),
      extensions: <ThemeExtension<dynamic>>[AppPaletteExtension(p)],
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle:
            brightness == Brightness.light ? overlayLight : overlayDark,
        titleTextStyle: AppText.slab22(p.ink),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDims.radiusMd),
          side: BorderSide(color: p.border, width: AppDims.borderThin),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: p.borderSoft,
        space: 0,
        thickness: AppDims.borderThin,
      ),
      iconTheme: IconThemeData(color: p.inkSecondary, size: 20),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDims.sp4,
          vertical: AppDims.sp3,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDims.radiusMd),
          borderSide: BorderSide(color: p.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDims.radiusMd),
          borderSide: BorderSide(color: p.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDims.radiusMd),
          borderSide: BorderSide(color: p.accent, width: 1.5),
        ),
        hintStyle: AppText.body(p.inkTertiary),
        labelStyle: AppText.bodySmall(p.inkSecondary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        elevation: 0,
        indicatorColor: p.accentSoft,
        height: 64,
        labelTextStyle: WidgetStatePropertyAll(
          AppText.monoLabelSm(p.inkSecondary),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? p.accent : p.inkSecondary,
            size: 22,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.ink,
        contentTextStyle: AppText.bodySmall(p.surface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDims.radiusMd),
        ),
      ),
    );
  }
}

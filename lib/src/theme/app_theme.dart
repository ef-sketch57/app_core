import 'package:flutter/material.dart';

/// Palette d'une appli. Chaque appli de la série peut fournir la sienne.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.ink,
    required this.accent,
    required this.accentOnDark,
    required this.accentSoft,
    required this.muted,
    required this.border,
    required this.subtle,
  });

  /// Palette de l'appli Quittances.
  static const quittances = AppPalette(
    background: Color(0xFFF6F5F1),
    surface: Colors.white,
    ink: Color(0xFF1B2430),
    accent: Color(0xFF2F6B4F),
    accentOnDark: Color(0xFF7CC4A0),
    accentSoft: Color(0xFFE3F0E8),
    muted: Color(0xFF5B6472),
    border: Color(0xFFE6E3DB),
    subtle: Color(0xFFEAE7DF),
  );

  /// Fond des écrans.
  final Color background;

  /// Fond des cartes et des champs.
  final Color surface;

  /// Texte et boutons principaux.
  final Color ink;

  /// Accent (statut « Envoyée », bouton « Envoyer »).
  final Color accent;

  /// Accent lisible sur fond sombre.
  final Color accentOnDark;

  /// Fond léger des pastilles d'accent.
  final Color accentSoft;

  /// Texte secondaire.
  final Color muted;

  /// Bordures.
  final Color border;

  /// Fonds discrets (illustrations, sélecteurs).
  final Color subtle;

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? ink,
    Color? accent,
    Color? accentOnDark,
    Color? accentSoft,
    Color? muted,
    Color? border,
    Color? subtle,
  }) =>
      AppPalette(
        background: background ?? this.background,
        surface: surface ?? this.surface,
        ink: ink ?? this.ink,
        accent: accent ?? this.accent,
        accentOnDark: accentOnDark ?? this.accentOnDark,
        accentSoft: accentSoft ?? this.accentSoft,
        muted: muted ?? this.muted,
        border: border ?? this.border,
        subtle: subtle ?? this.subtle,
      );

  @override
  AppPalette lerp(AppPalette? other, double t) => t < 0.5 ? this : other!;
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}

/// Rayon commun des cartes, champs et boutons.
const kRadius = 14.0;

/// Police embarquée dans `app_core`.
const kFontFamily = 'packages/app_core/Manrope';

ThemeData buildAppTheme(AppPalette p) {
  final scheme = ColorScheme.fromSeed(
    seedColor: p.ink,
    brightness: Brightness.light,
  ).copyWith(
    primary: p.ink,
    onPrimary: Colors.white,
    secondary: p.accent,
    onSecondary: Colors.white,
    surface: p.background,
    onSurface: p.ink,
    onSurfaceVariant: p.muted,
    outline: p.border,
    outlineVariant: p.border,
    surfaceContainerLowest: p.surface,
    surfaceContainerLow: p.surface,
    surfaceContainer: p.surface,
    surfaceContainerHigh: p.surface,
    surfaceContainerHighest: p.subtle,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: kFontFamily,
    scaffoldBackgroundColor: p.background,
    extensions: [p],
  );

  final text = base.textTheme.apply(bodyColor: p.ink, displayColor: p.ink);

  final roundedField = OutlineInputBorder(
    borderRadius: BorderRadius.circular(kRadius),
    borderSide: BorderSide(color: p.border),
  );

  return base.copyWith(
    textTheme: text.copyWith(
      headlineLarge: text.headlineLarge?.copyWith(
          fontWeight: FontWeight.w800, fontSize: 30, letterSpacing: -0.5),
      headlineMedium: text.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800, fontSize: 26, letterSpacing: -0.4),
      headlineSmall: text.headlineSmall
          ?.copyWith(fontWeight: FontWeight.w800, fontSize: 22),
      titleLarge:
          text.titleLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 20),
      titleMedium:
          text.titleMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
      titleSmall:
          text.titleSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 14),
      bodyLarge: text.bodyLarge?.copyWith(fontSize: 16),
      bodyMedium: text.bodyMedium?.copyWith(fontSize: 14),
      bodySmall: text.bodySmall?.copyWith(fontSize: 12, color: p.muted),
      labelLarge:
          text.labelLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: p.background,
      foregroundColor: p.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: kFontFamily,
        fontWeight: FontWeight.w800,
        fontSize: 22,
        color: p.ink,
      ),
    ),
    cardTheme: CardThemeData(
      color: p.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadius),
        side: BorderSide(color: p.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: p.muted.withValues(alpha: 0.8)),
      border: roundedField,
      enabledBorder: roundedField,
      focusedBorder: roundedField.copyWith(
          borderSide: BorderSide(color: p.ink, width: 1.4)),
      errorBorder: roundedField.copyWith(
          borderSide: BorderSide(color: scheme.error)),
      focusedErrorBorder: roundedField.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 1.4)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.ink,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadius)),
        textStyle: const TextStyle(
            fontFamily: kFontFamily, fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.ink,
        backgroundColor: p.surface,
        minimumSize: const Size.fromHeight(52),
        side: BorderSide(color: p.ink, width: 1.2),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadius)),
        textStyle: const TextStyle(
            fontFamily: kFontFamily, fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.muted,
        minimumSize: const Size(44, 44),
        textStyle: const TextStyle(
            fontFamily: kFontFamily, fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: Colors.transparent,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
            fontFamily: kFontFamily,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? p.ink : p.muted,
          )),
      iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? p.ink : p.muted,
          )),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? Colors.white : p.muted),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? p.accent : p.subtle),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: p.ink,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.background,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.background,
      surfaceTintColor: Colors.transparent,
    ),
  );
}

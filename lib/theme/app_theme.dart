import 'package:flutter/material.dart';

import 'app_tokens.dart';

/// Tema visual do app — direção **Deep Ocean** (navy + ciano, fonte Manrope).
///
/// A paleta usa `ColorScheme.fromSeed` + `copyWith` para fixar os papéis de
/// superfície, e os tons de "água/sucesso/atraso" vêm do [AppTokens]. Trocar de
/// direção (ou de claro/escuro) é só passar outro par ao [appTheme].

// ---------------------------------------------------------------------------
// Paleta — Deep Ocean
// ---------------------------------------------------------------------------

final ColorScheme oceanLight = ColorScheme.fromSeed(
  seedColor: const Color(0xFF0E6FE0),
  brightness: Brightness.light,
).copyWith(
  primary: const Color(0xFF0E6FE0),
  onPrimary: const Color(0xFFFFFFFF),
  surface: const Color(0xFFEDF3FA), // fundo da tela
  surfaceContainerLowest: const Color(0xFFFFFFFF), // cards
  surfaceContainerLow: const Color(0xFFF2F7FC), // campos / steppers
  surfaceContainer: const Color(0xFFEAF2FB), // chips / prévia
  onSurface: const Color(0xFF0B2743),
  onSurfaceVariant: const Color(0xFF526478), // texto secundário
  outlineVariant: const Color(0xFFE3ECF4), // trilho do anel / divisórias
  error: const Color(0xFFDD4B36),
  errorContainer: const Color(0xFFFBEAE6),
);

const AppTokens oceanLightTokens = AppTokens(
  waterTop: Color(0xFF57BBF6),
  waterBottom: Color(0xFF0E7CD8),
  success: Color(0xFF10A085),
  overdue: Color(0xFFDD4B36),
  overdueContainer: Color(0xFFFBEAE6),
  cupLine: Color(0x380B2743), // ~22%
);

final ColorScheme oceanDark = ColorScheme.fromSeed(
  seedColor: const Color(0xFF0E6FE0),
  brightness: Brightness.dark,
).copyWith(
  primary: const Color(0xFF3AB6F4),
  onPrimary: const Color(0xFF052238),
  surface: const Color(0xFF08182A),
  surfaceContainerLowest: const Color(0xFF0C1E30),
  surfaceContainerLow: const Color(0xFF0F2438),
  surfaceContainer: const Color(0xFF152E46),
  onSurface: const Color(0xFFEAF3FB),
  onSurfaceVariant: const Color(0xFF9EB5CD),
  outlineVariant: const Color(0x17FFFFFF), // ~9% branco
  error: const Color(0xFFFF6B54),
  errorContainer: const Color(0xFF331915),
);

const AppTokens oceanDarkTokens = AppTokens(
  waterTop: Color(0xFF7CD0FB),
  waterBottom: Color(0xFF1E92E6),
  success: Color(0xFF2FD3B0),
  overdue: Color(0xFFFF6B54),
  overdueContainer: Color(0xFF331915),
  cupLine: Color(0x38FFFFFF),
);

// ---------------------------------------------------------------------------
// Tipografia — Manrope, com numerais tabulares nos estilos de número
// ---------------------------------------------------------------------------

TextTheme appTextTheme(TextTheme base) {
  // Manrope empacotada como asset (fonte variável) — carrega instantânea e
  // offline, sem a busca de rede/flash do google_fonts em runtime.
  final t = base.apply(fontFamily: 'Manrope');
  const tnum = [FontFeature.tabularFigures()];
  return t.copyWith(
    displaySmall: t.displaySmall!.copyWith(
      fontSize: 30,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.6,
      fontFeatures: tnum,
    ), // "12 de 12", % do anel
    headlineSmall: t.headlineSmall!.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.3,
    ),
    titleLarge: t.titleLarge!.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.2,
    ), // AppBar
    titleMedium: t.titleMedium!.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      fontFeatures: tnum,
    ),
    bodyMedium: t.bodyMedium!.copyWith(
      fontSize: 13.5,
      fontWeight: FontWeight.w500,
      height: 1.35,
    ),
    bodySmall: t.bodySmall!.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
    labelLarge: t.labelLarge!.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w800,
    ), // botões
    labelSmall: t.labelSmall!.copyWith(
      fontSize: 11.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.8,
    ), // "COPOS DE HOJE"
  );
}

// ---------------------------------------------------------------------------
// ThemeData
// ---------------------------------------------------------------------------

ThemeData appTheme(ColorScheme cs, AppTokens tokens) {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    brightness: cs.brightness,
  );
  final text = appTextTheme(base.textTheme);
  return base.copyWith(
    scaffoldBackgroundColor: cs.surface,
    textTheme: text,
    extensions: [tokens],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: cs.onSurface,
      centerTitle: false,
      titleTextStyle: text.titleLarge,
    ),
    cardTheme: CardThemeData(
      color: cs.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        textStyle: text.labelLarge,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: cs.primary,
      foregroundColor: cs.onPrimary,
      extendedTextStyle: text.labelLarge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}

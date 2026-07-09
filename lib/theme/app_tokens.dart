import 'package:flutter/material.dart';

/// Tokens de cor que o Material 3 não modela: os tons da "água" (gradiente do
/// copo e do anel), o verde de "sucesso/em dia", o vermelho de "atraso" e a
/// linha do copo pendente. Ficam num [ThemeExtension] para interpolar junto com
/// o tema (claro↔escuro anima suave) e serem lidos via `Theme.of(ctx).extension`.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.waterTop,
    required this.waterBottom,
    required this.success,
    required this.overdue,
    required this.overdueContainer,
    required this.cupLine,
  });

  /// Topo do gradiente de água (mais claro).
  final Color waterTop;

  /// Base do gradiente de água (mais escuro).
  final Color waterBottom;

  /// "Em dia" / meta atingida.
  final Color success;

  /// "Atrasado" — aro/água do copo vencido e chip de status.
  final Color overdue;

  /// Fundo do chip de status quando atrasado.
  final Color overdueContainer;

  /// Aro do copo ainda pendente (linha discreta sobre a superfície).
  final Color cupLine;

  @override
  AppTokens copyWith({
    Color? waterTop,
    Color? waterBottom,
    Color? success,
    Color? overdue,
    Color? overdueContainer,
    Color? cupLine,
  }) {
    return AppTokens(
      waterTop: waterTop ?? this.waterTop,
      waterBottom: waterBottom ?? this.waterBottom,
      success: success ?? this.success,
      overdue: overdue ?? this.overdue,
      overdueContainer: overdueContainer ?? this.overdueContainer,
      cupLine: cupLine ?? this.cupLine,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      waterTop: Color.lerp(waterTop, other.waterTop, t)!,
      waterBottom: Color.lerp(waterBottom, other.waterBottom, t)!,
      success: Color.lerp(success, other.success, t)!,
      overdue: Color.lerp(overdue, other.overdue, t)!,
      overdueContainer: Color.lerp(overdueContainer, other.overdueContainer, t)!,
      cupLine: Color.lerp(cupLine, other.cupLine, t)!,
    );
  }
}

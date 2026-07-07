import 'dart:convert';

/// Configuração do usuário: meta diária, tamanho do copo e a janela do dia.
///
/// Horários são guardados como minutos desde a meia-noite (0..1439).
class WaterConfig {
  const WaterConfig({
    required this.metaMl,
    required this.copoMl,
    required this.inicioMinutos,
    required this.fimMinutos,
  });

  /// Meta de água para o dia, em mililitros.
  final int metaMl;

  /// Capacidade do copo/garrafinha, em mililitros.
  final int copoMl;

  /// Minutos desde a meia-noite em que o dia do usuário começa.
  final int inicioMinutos;

  /// Minutos desde a meia-noite em que o dia do usuário termina.
  final int fimMinutos;

  static const WaterConfig padrao = WaterConfig(
    metaMl: 3000,
    copoMl: 250,
    inicioMinutos: 10 * 60, // 10:00
    fimMinutos: 22 * 60, // 22:00
  );

  /// Total de copos necessários para atingir a meta (arredondado para cima).
  int get totalCopos => copoMl <= 0 ? 0 : (metaMl / copoMl).ceil();

  WaterConfig copyWith({
    int? metaMl,
    int? copoMl,
    int? inicioMinutos,
    int? fimMinutos,
  }) {
    return WaterConfig(
      metaMl: metaMl ?? this.metaMl,
      copoMl: copoMl ?? this.copoMl,
      inicioMinutos: inicioMinutos ?? this.inicioMinutos,
      fimMinutos: fimMinutos ?? this.fimMinutos,
    );
  }

  Map<String, dynamic> toMap() => {
    'metaMl': metaMl,
    'copoMl': copoMl,
    'inicioMinutos': inicioMinutos,
    'fimMinutos': fimMinutos,
  };

  factory WaterConfig.fromMap(Map<String, dynamic> map) => WaterConfig(
    metaMl: map['metaMl'] as int,
    copoMl: map['copoMl'] as int,
    inicioMinutos: map['inicioMinutos'] as int,
    fimMinutos: map['fimMinutos'] as int,
  );

  String toJson() => jsonEncode(toMap());

  factory WaterConfig.fromJson(String source) =>
      WaterConfig.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

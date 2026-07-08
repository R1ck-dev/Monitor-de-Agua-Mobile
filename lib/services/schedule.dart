import '../models/water_config.dart';

/// Um lembrete agendado: horário do dia e quantos copos beber nesse momento.
class Lembrete {
  const Lembrete({required this.minutosDoDia, required this.copos});

  /// Minutos desde a meia-noite em que o lembrete dispara.
  final int minutosDoDia;

  /// Quantos copos beber nesse lembrete (1 ou mais, quando agrupado).
  final int copos;

  int get hora => minutosDoDia ~/ 60;
  int get minuto => minutosDoDia % 60;
}

/// Espaçamento mínimo entre lembretes. Abaixo disso, copos são agrupados
/// num mesmo lembrete para não interromper o usuário com muita frequência.
const int espacoMinimoMinutos = 45;

/// Calcula os lembretes do dia a partir da configuração.
///
/// Os copos são distribuídos uniformemente na janela [início, fim]. Se o
/// intervalo entre copos ficaria menor que [espacoMinimoMinutos], vários copos
/// são agrupados no mesmo lembrete (reduzindo a quantidade de notificações).
List<Lembrete> calcularLembretes(WaterConfig config) {
  final int totalCopos = config.totalCopos;
  if (totalCopos <= 0) return const [];

  final int inicio = config.inicioMinutos;
  final int duracao = config.fimMinutos - inicio;

  // Janela inválida ou nula: um único lembrete no início com todos os copos.
  if (duracao <= 0) {
    return [Lembrete(minutosDoDia: inicio, copos: totalCopos)];
  }

  // Máximo de lembretes que mantém o espaçamento >= mínimo.
  final int maxLembretes = (duracao ~/ espacoMinimoMinutos) + 1;
  final int qtdLembretes = totalCopos < maxLembretes ? totalCopos : maxLembretes;

  final int coposBase = totalCopos ~/ qtdLembretes;
  final int sobra = totalCopos % qtdLembretes; // primeiros lembretes levam +1

  final List<Lembrete> lembretes = [];
  for (int i = 0; i < qtdLembretes; i++) {
    final int minuto = qtdLembretes == 1
        ? inicio
        : inicio + (i * duracao / (qtdLembretes - 1)).round();
    final int copos = coposBase + (i < sobra ? 1 : 0);
    lembretes.add(Lembrete(minutosDoDia: minuto, copos: copos));
  }
  return lembretes;
}

/// Quantos copos já deveriam ter sido bebidos em [minutosAgora] (minutos desde
/// a meia-noite), segundo o cronograma [lembretes]: soma os copos de cada
/// lembrete cujo horário já passou.
///
/// Antes de [inicioMinutos] ainda estamos no fim do dia lógico anterior, cujos
/// lembretes já venceram todos — então o ideal é [totalCopos].
int coposEsperadosAte(
  List<Lembrete> lembretes,
  int minutosAgora, {
  required int inicioMinutos,
  required int totalCopos,
}) {
  if (totalCopos <= 0) return 0;
  if (minutosAgora < inicioMinutos) return totalCopos;
  var esperados = 0;
  for (final l in lembretes) {
    if (l.minutosDoDia <= minutosAgora) esperados += l.copos;
  }
  return esperados;
}

import 'package:contador_de_agua/models/water_config.dart';
import 'package:contador_de_agua/services/schedule.dart';
import 'package:flutter_test/flutter_test.dart';

int _somaCopos(List<Lembrete> l) => l.fold(0, (a, b) => a + b.copos);

void main() {
  group('WaterConfig.totalCopos', () {
    test('arredonda para cima', () {
      expect(_cfg(3000, 250).totalCopos, 12);
      expect(_cfg(2000, 300).totalCopos, 7); // 6,66 -> 7
    });

    test('copo inválido não quebra', () {
      expect(_cfg(3000, 0).totalCopos, 0);
    });
  });

  group('calcularLembretes', () {
    test('1 copo por lembrete quando há folga na janela', () {
      final lembretes = calcularLembretes(_cfg(3000, 250)); // 12 copos, 12h
      expect(lembretes.length, 12);
      expect(lembretes.every((l) => l.copos == 1), isTrue);
      expect(lembretes.first.minutosDoDia, 10 * 60);
      expect(lembretes.last.minutosDoDia, 22 * 60);
      expect(_somaCopos(lembretes), 12);
    });

    test('agrupa copos quando o intervalo ficaria curto', () {
      final lembretes = calcularLembretes(_cfg(3000, 150)); // 20 copos, 12h
      expect(lembretes.length, lessThanOrEqualTo(17));
      expect(lembretes.any((l) => l.copos > 1), isTrue);
      expect(_somaCopos(lembretes), 20);
    });

    test('mantém espaçamento mínimo entre lembretes', () {
      final lembretes = calcularLembretes(_cfg(3000, 150));
      for (var i = 1; i < lembretes.length; i++) {
        final gap = lembretes[i].minutosDoDia - lembretes[i - 1].minutosDoDia;
        expect(gap, greaterThanOrEqualTo(espacoMinimoMinutos));
      }
    });

    test('janela inválida (fim <= início) gera um único lembrete', () {
      final cfg = WaterConfig(
        metaMl: 1000,
        copoMl: 250,
        inicioMinutos: 10 * 60,
        fimMinutos: 10 * 60,
      );
      final lembretes = calcularLembretes(cfg);
      expect(lembretes.length, 1);
      expect(lembretes.first.copos, 4);
      expect(lembretes.first.minutosDoDia, 10 * 60);
    });

    test('preserva o total de copos independentemente do agrupamento', () {
      for (final copoMl in [100, 150, 200, 250, 330, 500]) {
        final cfg = _cfg(3000, copoMl);
        expect(_somaCopos(calcularLembretes(cfg)), cfg.totalCopos);
      }
    });
  });
}

WaterConfig _cfg(int metaMl, int copoMl) => WaterConfig(
  metaMl: metaMl,
  copoMl: copoMl,
  inicioMinutos: 10 * 60,
  fimMinutos: 22 * 60,
);

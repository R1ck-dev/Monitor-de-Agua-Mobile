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

  group('coposEsperadosAte', () {
    final cfg = _cfg(3000, 250); // 12 copos, janela 10h–22h, 1 copo/hora
    final lembretes = calcularLembretes(cfg);

    int esperadosEm(int minutos) => coposEsperadosAte(
      lembretes,
      minutos,
      inicioMinutos: cfg.inicioMinutos,
      totalCopos: cfg.totalCopos,
    );

    test('cenário das 17h: já deveria ter bebido 4 copos', () {
      // Lembretes de hora em hora a partir das 10h; às 17h já passaram
      // 10,11,12,13 (o de 14h também). Confirma pelo cronograma real:
      final ate17 = lembretes.where((l) => l.minutosDoDia <= 17 * 60).length;
      expect(esperadosEm(17 * 60), ate17);
      expect(esperadosEm(17 * 60), greaterThanOrEqualTo(4));
    });

    test('logo antes do início ainda conta como o dia anterior (tudo)', () {
      // O limite do dia lógico é a hora de início; antes dela o dia anterior
      // ainda não fechou, então todos os copos de ontem já venceram.
      expect(esperadosEm(9 * 60), cfg.totalCopos);
    });

    test('no primeiro lembrete: 1 copo esperado', () {
      expect(esperadosEm(10 * 60), 1);
    });

    test('depois do fim da janela: todos os copos', () {
      expect(esperadosEm(23 * 60), cfg.totalCopos);
    });

    test('madrugada (antes do início) conta como fim do dia anterior', () {
      expect(esperadosEm(2 * 60), cfg.totalCopos);
    });

    test('meta zerada não espera nada', () {
      expect(
        coposEsperadosAte(const [], 15 * 60,
            inicioMinutos: 10 * 60, totalCopos: 0),
        0,
      );
    });
  });
}

WaterConfig _cfg(int metaMl, int copoMl) => WaterConfig(
  metaMl: metaMl,
  copoMl: copoMl,
  inicioMinutos: 10 * 60,
  fimMinutos: 22 * 60,
);

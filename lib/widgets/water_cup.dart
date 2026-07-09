import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_tokens.dart';

/// Estado visual de um copo na grade.
enum CupState { pending, done, overdue }

/// Um copo com nível de água animado (direção **Deep Ocean**: vidro com aro,
/// gradiente de água e reflexo). Semântica: **beber = encher** — ao marcar, o
/// nível sobe e o copo dá um leve "pop". Pendente aparece quase vazio; atrasado
/// (já deveria ter sido bebido) destaca aro/água em vermelho com um relógio.
/// Tocar alterna o estado.
class WaterCup extends StatefulWidget {
  const WaterCup({
    super.key,
    required this.bebido,
    required this.onTap,
    this.atrasado = false,
    this.index,
    this.total,
  });

  final bool bebido;
  final bool atrasado;
  final VoidCallback onTap;

  /// Posição (0-based) e total, só para o rótulo de acessibilidade.
  final int? index;
  final int? total;

  CupState get _state => bebido
      ? CupState.done
      : atrasado
          ? CupState.overdue
          : CupState.pending;

  @override
  State<WaterCup> createState() => _WaterCupState();
}

class _WaterCupState extends State<WaterCup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
    lowerBound: 0,
    upperBound: 1,
  );

  @override
  void didUpdateWidget(covariant WaterCup old) {
    super.didUpdateWidget(old);
    // "Pop" ao passar de pendente/atrasado para bebido.
    if (!old.bebido && widget.bebido) {
      _pop.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.selectionClick();
    widget.onTap();
  }

  String get _label {
    final pos = (widget.index != null && widget.total != null)
        ? 'Copo ${widget.index! + 1} de ${widget.total}'
        : 'Copo';
    return switch (widget._state) {
      CupState.done => '$pos, bebido',
      CupState.overdue => '$pos, atrasado',
      CupState.pending => '$pos, a beber',
    };
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final state = widget._state;
    final target = state == CupState.done ? 0.88 : 0.13;

    return Semantics(
      button: true,
      label: _label,
      child: InkResponse(
        onTap: _handleTap,
        radius: 44,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: AnimatedBuilder(
            animation: _pop,
            builder: (context, child) {
              // Pico do "pop" no meio da animação (1.0 → 1.1 → 1.0).
              final scale = 1.0 + 0.1 * (1 - (2 * _pop.value - 1).abs());
              return Transform.scale(scale: scale, child: child);
            },
            child: AspectRatio(
              aspectRatio: 0.70,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: target, end: target),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, fill, _) => Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size.infinite,
                      painter: _WaterCupPainter(fill, state, cs, tokens),
                    ),
                    if (state == CupState.done)
                      Icon(Icons.check_rounded, size: 22, color: cs.onPrimary),
                    if (state == CupState.overdue)
                      Icon(Icons.schedule_rounded,
                          size: 17, color: tokens.overdue),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WaterCupPainter extends CustomPainter {
  _WaterCupPainter(this.fill, this.state, this.cs, this.t);

  final double fill; // 0..1 (animado)
  final CupState state;
  final ColorScheme cs;
  final AppTokens t;

  static const double _reflect = 0.55; // Deep Ocean
  static const double _radiusTop = 10;
  static const double _radiusBottom = 12;

  @override
  void paint(Canvas c, Size s) {
    final rect = Offset.zero & s;
    final glass = RRect.fromRectAndCorners(
      rect,
      topLeft: const Radius.circular(_radiusTop),
      topRight: const Radius.circular(_radiusTop),
      bottomLeft: const Radius.circular(_radiusBottom),
      bottomRight: const Radius.circular(_radiusBottom),
    );

    // Recorta tudo na silhueta do copo.
    c.save();
    c.clipRRect(glass);

    // Água.
    final level = s.height * (1 - fill.clamp(0.0, 1.0));
    final waterRect = Rect.fromLTRB(0, level, s.width, s.height);
    if (state == CupState.done) {
      c.drawRect(
        waterRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [t.waterTop, t.waterBottom],
          ).createShader(waterRect),
      );
      // Menisco.
      c.drawRect(
        Rect.fromLTWH(0, level, s.width, 3),
        Paint()..color = Colors.white.withValues(alpha: 0.42),
      );
    } else {
      c.drawRect(
        waterRect,
        Paint()
          ..color = state == CupState.overdue
              ? t.overdue.withValues(alpha: 0.14)
              : cs.primary.withValues(alpha: 0.10),
      );
    }

    // Reflexo (só Ocean).
    final r = Rect.fromLTWH(
      s.width * 0.16,
      s.height * 0.12,
      s.width * 0.10,
      s.height * 0.64,
    );
    c.drawRRect(
      RRect.fromRectXY(r, 6, 6),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.65 * _reflect),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(r),
    );
    c.restore();

    // Aro.
    final border = switch (state) {
      CupState.done => cs.primary,
      CupState.overdue => t.overdue,
      CupState.pending => t.cupLine,
    };
    c.drawRRect(
      glass.deflate(1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = border,
    );
  }

  @override
  bool shouldRepaint(_WaterCupPainter o) =>
      o.fill != fill || o.state != state || o.cs != cs || o.t != t;
}

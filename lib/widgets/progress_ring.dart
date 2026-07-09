import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Anel de progresso do cabeçalho: trilho + arco com gradiente de água, ponta
/// arredondada, percentual animado no centro e um leve brilho ao bater a meta.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 132,
  });

  /// Progresso 0..1.
  final double progress;

  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final goal = progress >= 1.0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size.square(size),
              painter: _ProgressRingPainter(value, cs, tokens, goal),
            ),
            Text(
              '${(value * 100).round()}%',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter(this.progress, this.cs, this.t, this.goal);

  final double progress; // 0..1 (animado)
  final ColorScheme cs;
  final AppTokens t;
  final bool goal;

  static const double _stroke = 12;
  static const double _start = -1.5708; // topo (−90°)
  static const double _full = 6.2832; // 2π

  @override
  void paint(Canvas c, Size s) {
    final r = (s.shortestSide - _stroke) / 2;
    final center = s.center(Offset.zero);

    // Trilho.
    c.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..color = cs.outlineVariant,
    );

    if (progress <= 0) return;

    // Arco de progresso com gradiente de água.
    final rect = Rect.fromCircle(center: center, radius: r);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: _start,
        endAngle: _start + _full,
        colors: [t.waterTop, t.waterBottom],
        transform: const GradientRotation(_start),
      ).createShader(rect);
    if (goal) {
      p.maskFilter = const MaskFilter.blur(BlurStyle.normal, 6); // brilho
    }
    c.drawArc(rect, _start, _full * progress.clamp(0.0, 1.0), false, p);
  }

  @override
  bool shouldRepaint(_ProgressRingPainter o) =>
      o.progress != progress || o.goal != goal || o.cs != cs;
}

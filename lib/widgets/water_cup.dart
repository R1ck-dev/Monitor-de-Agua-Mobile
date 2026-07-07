import 'package:flutter/material.dart';

/// Um copo desenhado. Cheio (azul) = pendente; vazio com "check" = já bebido.
/// Tocar alterna o estado.
class WaterCup extends StatelessWidget {
  const WaterCup({super.key, required this.bebido, required this.onTap});

  final bool bebido;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: bebido ? 'Copo bebido' : 'Copo a beber',
      child: InkResponse(
        onTap: onTap,
        radius: 44,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: AspectRatio(
            aspectRatio: 0.78,
            child: CustomPaint(
              painter: _CopoPainter(
                bebido: bebido,
                agua: scheme.primary,
                contorno: bebido ? scheme.outline : scheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CopoPainter extends CustomPainter {
  _CopoPainter({
    required this.bebido,
    required this.agua,
    required this.contorno,
  });

  final bool bebido;
  final Color agua;
  final Color contorno;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Copo levemente cônico (mais largo em cima).
    final copo = Path()
      ..moveTo(w * 0.12, h * 0.05)
      ..lineTo(w * 0.88, h * 0.05)
      ..lineTo(w * 0.76, h * 0.95)
      ..lineTo(w * 0.24, h * 0.95)
      ..close();

    final fundo = Paint()
      ..style = PaintingStyle.fill
      ..color = bebido ? agua.withValues(alpha: 0.10) : agua.withValues(alpha: 0.85);
    canvas.drawPath(copo, fundo);

    final borda = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeJoin = StrokeJoin.round
      ..color = contorno;
    canvas.drawPath(copo, borda);

    if (bebido) {
      final check = Path()
        ..moveTo(w * 0.34, h * 0.52)
        ..lineTo(w * 0.45, h * 0.66)
        ..lineTo(w * 0.68, h * 0.38);
      final checkPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.08
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = contorno;
      canvas.drawPath(check, checkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CopoPainter old) =>
      old.bebido != bebido || old.agua != agua || old.contorno != contorno;
}

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class BadgeMedal extends StatelessWidget {
  const BadgeMedal({
    super.key,
    required this.icon,
    required this.faceGradient,
    required this.ribbonGradient,
    this.locked = false,
    this.size = 74,
  });

  final IconData icon;
  final List<Color> faceGradient;
  final List<Color> ribbonGradient;
  final bool locked;
  final double size;

  @override
  Widget build(BuildContext context) {
    final dim = locked ? 0.35 : 1.0;
    final iconColor = locked ? AppColors.textMuted : Colors.white;
    return Opacity(
      opacity: dim,
      child: SizedBox(
        width: size,
        height: size + 22,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: size - 6,
              child: _Ribbon(
                width: size * 0.78,
                height: 30,
                gradient: ribbonGradient,
              ),
            ),
            _MedalFace(
              size: size,
              gradient: faceGradient,
              child: Icon(icon, color: iconColor, size: size * 0.42),
            ),
            Positioned(
              top: 6,
              child: Container(
                width: size - 14,
                height: size - 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: locked ? 0.10 : 0.14)),
                ),
              ),
            ),
            if (locked)
              Positioned(
                right: 0,
                bottom: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline, size: 14, color: AppColors.textMuted),
                      SizedBox(width: 6),
                      Text('Locked', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MedalFace extends StatelessWidget {
  const _MedalFace({
    required this.size,
    required this.gradient,
    required this.child,
  });

  final double size;
  final List<Color> gradient;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient.length >= 2 ? gradient : [AppColors.primary, AppColors.accentTeal],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            spreadRadius: 1,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}

class _Ribbon extends StatelessWidget {
  const _Ribbon({
    required this.width,
    required this.height,
    required this.gradient,
  });

  final double width;
  final double height;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _RibbonPainter(gradient: gradient),
    );
  }
}

class _RibbonPainter extends CustomPainter {
  _RibbonPainter({required this.gradient});

  final List<Color> gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: gradient.length >= 2 ? gradient : [AppColors.accentTeal, AppColors.primary],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.16, 0)
      ..lineTo(w * 0.84, 0)
      ..lineTo(w * 0.94, h * 0.42)
      ..lineTo(w * 0.70, h)
      ..lineTo(w * 0.50, h * 0.74)
      ..lineTo(w * 0.30, h)
      ..lineTo(w * 0.06, h * 0.42)
      ..close();

    canvas.drawPath(path, paint);

    final stroke = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _RibbonPainter oldDelegate) => false;
}


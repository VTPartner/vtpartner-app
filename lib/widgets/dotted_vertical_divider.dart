import 'package:flutter/material.dart';

class DottedVerticalDivider extends StatelessWidget {
  final double height;
  final double width;
  final Color color;
  final double dotRadius;
  final double spacing;

  DottedVerticalDivider({
    required this.height,
    this.width = 1.0,
    this.color = Colors.grey,
    this.dotRadius = 1.0,
    this.spacing = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: DottedLinePainter(
        color: color,
        dotRadius: dotRadius,
        spacing: spacing,
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  final Color color;
  final double dotRadius;
  final double spacing;

  DottedLinePainter({
    required this.color,
    this.dotRadius = 1.0,
    this.spacing = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    double y = 0;
    while (y < size.height) {
      canvas.drawCircle(Offset(size.width / 2, y), dotRadius, paint);
      y += dotRadius * 2 + spacing;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
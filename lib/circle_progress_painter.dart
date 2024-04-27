import 'package:flutter/material.dart';
import 'dart:math';

class CircleProgressPainter extends CustomPainter {
  final int remainingSeconds;

  CircleProgressPainter({required this.remainingSeconds});

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 2;

    final double startAngle = -pi / 2;
    final double sweepAngle = 2 * pi * (remainingSeconds / (24 * 3600));

    final Paint paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

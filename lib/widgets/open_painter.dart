import 'dart:ui';

import 'package:flutter/material.dart';

class OpenPainter extends CustomPainter {
  const OpenPainter({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.screenSize,
  });

  final double left;
  final double top;
  final double width;
  final double height;
  final Size screenSize;

  @override
  void paint(Canvas canvas, Size size) {
    double ratio = screenSize.width / 480; // / 240;
    var paintRect = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    var paintPoints = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill
      ..strokeWidth = 6;
    List<Offset> points = [
      Offset((left * ratio).toDouble(), (top * ratio).toDouble()),
      Offset(((left + width) * ratio).toDouble(), (top * ratio).toDouble()),
      Offset((left * ratio).toDouble(), ((top + height) * ratio).toDouble()),
      Offset(((left + width) * ratio).toDouble(),
          ((top + height) * ratio).toDouble()),
    ];

    canvas.drawRect(
        Offset(left * ratio, top * ratio) & Size(width * ratio, height * ratio),
        paintRect);

    canvas.drawPoints(PointMode.points, points, paintPoints);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

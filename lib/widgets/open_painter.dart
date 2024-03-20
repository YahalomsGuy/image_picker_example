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
    double widthRatio = screenSize.width / 240;
    double heightRatio = screenSize.height / 320;

    var paintRect = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    var paintPoints = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill
      ..strokeWidth = 6;
    List<Offset> points = [
      Offset((left * widthRatio).toDouble(), (top * heightRatio).toDouble()),
      Offset(((left + width) * widthRatio).toDouble(),
          (top * heightRatio).toDouble()),
      Offset((left * widthRatio).toDouble(),
          ((top + height) * heightRatio).toDouble()),
      Offset(((left + width) * widthRatio).toDouble(),
          ((top + height) * heightRatio).toDouble()),
    ];

    canvas.drawRect(
        Offset(left * widthRatio, top * heightRatio) &
            Size(width * widthRatio, height * heightRatio),
        paintRect);

    canvas.drawPoints(PointMode.points, points, paintPoints);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

import 'package:flutter/material.dart';
import 'dart:math' as math;

class ElementPainter extends CustomPainter {
  late Paint _paint;
  final List<Offset>? points;
  final Offset? lineFraction;
  final String key;

  //For Ellipse
  final double? radius;
  final Offset? center;
  final double? rotFraction;

  ElementPainter({this.lineFraction,
    this.center,
    this.radius,
    this.points,
    this.rotFraction,
    required this.key}) {
    _paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 5.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    switch (key) {
      case 'line':
        if (lineFraction != null) {
          canvas.drawLine(points!.first, lineFraction!, _paint);
        }
        break;
      case 'ellipse':
        double strokeWidth = 5.0;

        final circlePaint = Paint()
          ..color = Colors.blue
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke; //important set stroke style


        canvas.drawArc(Rect.fromCircle(center: center!, radius: radius!),
            0, 2 * math.pi, false, circlePaint);
        canvas.drawArc(
            Rect.fromCircle(center: center!, radius: radius!), 0, math.pi / 4,
            false, circlePaint..color = Colors.white);
        if(rotFraction!=null){
          debugPrint("RotFraction: " + rotFraction.toString());
          // canvas.rotate(rotFraction! * math.pi/180);
          // canvas.translate(100, 120);
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

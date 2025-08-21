import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pocketnotes/utils.dart/constants.dart';

class TaskProgressIndicator extends StatelessWidget {
  final int completed;
  final int total;
  final double size;

  const TaskProgressIndicator({
    super.key,
    required this.completed,
    required this.total,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress,
          color: Color(progressColor),
          background: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
        child: Center(
          child: Text(
            '$completed/$total',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color background;

  _RingPainter({required this.progress, required this.color, required this.background});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.08;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = math.min(size.width, size.height) / 2 - strokeWidth;

    final bgPaint = Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    final sweep = 2 * math.pi * progress;
    final start = -math.pi / 2;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color || oldDelegate.background != background;
  }
}



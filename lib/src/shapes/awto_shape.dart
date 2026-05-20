import 'dart:math' as math;

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shape types
// ─────────────────────────────────────────────────────────────────────────────

/// The type of shape drawn by [AwtoShape].
enum AwtoShapeType {
  /// A regular n-pointed star.
  star,

  /// A regular n-sided polygon (triangle, square, pentagon …).
  polygon,

  /// A perfect circle.
  circle,

  /// A simple rectangle / square.
  rectangle,
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom painter
// ─────────────────────────────────────────────────────────────────────────────

/// Custom painter that renders Awto framework shapes.
class AwtoShapesPainter extends CustomPainter {
  AwtoShapesPainter({
    required this.type,
    required this.fillColor,
    this.strokeColor,
    this.strokeWidth = 2.0,
    this.sides = 5,
    this.innerRadiusRatio = 0.4,
    this.rotationAngle = 0.0,
  });

  final AwtoShapeType type;
  final Color fillColor;
  final Color? strokeColor;
  final double strokeWidth;

  /// Number of sides / points (used for [AwtoShapeType.polygon] and
  /// [AwtoShapeType.star]).
  final int sides;

  /// Ratio of inner-radius to outer-radius for [AwtoShapeType.star].
  /// A value of `0.5` produces a classic 5-pointed star.
  final double innerRadiusRatio;

  /// Additional rotation in radians applied before drawing.
  final double rotationAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final strokePaint = strokeColor != null
        ? (Paint()
          ..color = strokeColor!
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round)
        : null;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    Path path;
    switch (type) {
      case AwtoShapeType.star:
        path = _buildStarPath(center, radius);
      case AwtoShapeType.polygon:
        path = _buildPolygonPath(center, radius);
      case AwtoShapeType.circle:
        path = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
      case AwtoShapeType.rectangle:
        path = Path()
          ..addRect(Rect.fromCenter(
              center: center, width: size.width, height: size.height));
    }

    canvas.drawPath(path, fillPaint);
    if (strokePaint != null) canvas.drawPath(path, strokePaint);
  }

  Path _buildStarPath(Offset center, double outerRadius) {
    final innerRadius = outerRadius * innerRadiusRatio;
    final path = Path();
    final angleStep = math.pi / sides; // half the central angle between points
    final startAngle = -math.pi / 2 + rotationAngle;

    for (int i = 0; i < sides * 2; i++) {
      final angle = startAngle + i * angleStep;
      final r = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  Path _buildPolygonPath(Offset center, double radius) {
    final path = Path();
    final angleStep = (2 * math.pi) / sides;
    final startAngle = -math.pi / 2 + rotationAngle;

    for (int i = 0; i < sides; i++) {
      final angle = startAngle + i * angleStep;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(AwtoShapesPainter old) =>
      old.type != type ||
      old.fillColor != fillColor ||
      old.strokeColor != strokeColor ||
      old.strokeWidth != strokeWidth ||
      old.sides != sides ||
      old.innerRadiusRatio != innerRadiusRatio ||
      old.rotationAngle != rotationAngle;
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────────────────────────────────────

/// A Flutter widget that renders an [AwtoShapeType] shape.
///
/// Example – a golden 5-pointed star:
/// ```dart
/// AwtoShape(
///   type: AwtoShapeType.star,
///   size: 120,
///   fillColor: Colors.amber,
///   strokeColor: Colors.orange,
///   sides: 5,
/// )
/// ```
class AwtoShape extends StatelessWidget {
  const AwtoShape({
    super.key,
    required this.type,
    required this.fillColor,
    this.size = 100.0,
    this.width,
    this.height,
    this.strokeColor,
    this.strokeWidth = 2.0,
    this.sides = 5,
    this.innerRadiusRatio = 0.4,
    this.rotationAngle = 0.0,
  });

  final AwtoShapeType type;
  final Color fillColor;

  /// Uniform size when [width] and [height] are not supplied.
  final double size;
  final double? width;
  final double? height;

  final Color? strokeColor;
  final double strokeWidth;

  /// Number of sides / points (ignored for [AwtoShapeType.circle] and
  /// [AwtoShapeType.rectangle]).
  final int sides;

  /// Inner-to-outer radius ratio for [AwtoShapeType.star].
  final double innerRadiusRatio;

  /// Clockwise rotation in radians.
  final double rotationAngle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? size,
      height: height ?? size,
      child: CustomPaint(
        painter: AwtoShapesPainter(
          type: type,
          fillColor: fillColor,
          strokeColor: strokeColor,
          strokeWidth: strokeWidth,
          sides: sides,
          innerRadiusRatio: innerRadiusRatio,
          rotationAngle: rotationAngle,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Convenience aliases
// ─────────────────────────────────────────────────────────────────────────────

/// A 5-pointed star widget with sensible defaults.
///
/// ```dart
/// StarShape(size: 80, fillColor: Colors.amber)
/// ```
class StarShape extends StatelessWidget {
  const StarShape({
    super.key,
    this.size = 80.0,
    this.fillColor = Colors.amber,
    this.strokeColor,
    this.strokeWidth = 2.0,
    this.points = 5,
    this.innerRadiusRatio = 0.4,
    this.rotationAngle = 0.0,
  });

  final double size;
  final Color fillColor;
  final Color? strokeColor;
  final double strokeWidth;
  final int points;
  final double innerRadiusRatio;
  final double rotationAngle;

  @override
  Widget build(BuildContext context) {
    return AwtoShape(
      type: AwtoShapeType.star,
      fillColor: fillColor,
      size: size,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      sides: points,
      innerRadiusRatio: innerRadiusRatio,
      rotationAngle: rotationAngle,
    );
  }
}

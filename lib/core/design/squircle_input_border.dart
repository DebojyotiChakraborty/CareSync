import 'package:flutter/material.dart';

/// A superellipse ("squircle") [InputBorder] for text fields.
///
/// Mirrors the corner geometry of [SquircleBorder] (each corner is a single
/// cubic Bézier anchored at the true corner) so filled fields read with the
/// same soft shape as [SquircleCard]. [OutlineInputBorder] can only draw
/// circular corners, hence this dedicated border.
class SquircleInputBorder extends InputBorder {
  const SquircleInputBorder({
    super.borderSide = BorderSide.none,
    this.radius = 36,
  });

  final double radius;

  @override
  bool get isOutline => true;

  double _effectiveRadius(Rect rect) =>
      radius.clamp(0.0, rect.shortestSide / 2);

  Path _path(Rect rect) {
    final r = _effectiveRadius(rect);
    final l = rect.left, t = rect.top, rt = rect.right, b = rect.bottom;
    return Path()
      ..moveTo(l + r, t)
      ..lineTo(rt - r, t)
      ..cubicTo(rt, t, rt, t, rt, t + r) // top-right
      ..lineTo(rt, b - r)
      ..cubicTo(rt, b, rt, b, rt - r, b) // bottom-right
      ..lineTo(l + r, b)
      ..cubicTo(l, b, l, b, l, b - r) // bottom-left
      ..lineTo(l, t + r)
      ..cubicTo(l, t, l, t, l + r, t) // top-left
      ..close();
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(borderSide.width);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => _path(rect);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _path(rect.deflate(borderSide.width));

  @override
  SquircleInputBorder copyWith({BorderSide? borderSide, double? radius}) =>
      SquircleInputBorder(
        borderSide: borderSide ?? this.borderSide,
        radius: radius ?? this.radius,
      );

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {
    if (borderSide.style == BorderStyle.none || borderSide.width == 0) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderSide.width
      ..color = borderSide.color;
    canvas.drawPath(_path(rect.deflate(borderSide.width / 2)), paint);
  }

  @override
  ShapeBorder scale(double t) =>
      SquircleInputBorder(borderSide: borderSide.scale(t), radius: radius * t);

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is SquircleInputBorder) {
      return SquircleInputBorder(
        borderSide: BorderSide.lerp(a.borderSide, borderSide, t),
        radius: a.radius + (radius - a.radius) * t,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is SquircleInputBorder) {
      return SquircleInputBorder(
        borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
        radius: radius + (b.radius - radius) * t,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  bool operator ==(Object other) =>
      other is SquircleInputBorder &&
      other.borderSide == borderSide &&
      other.radius == radius;

  @override
  int get hashCode => Object.hash(borderSide, radius);
}

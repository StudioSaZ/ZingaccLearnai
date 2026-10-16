import 'dart:math' as math;

class DiagramGeometry {
  const DiagramGeometry._();

  static bool positive(double? value) =>
      value != null && value.isFinite && value > 0;

  static double? rectangleArea(double? width, double? height) {
    if (!positive(width) || !positive(height)) return null;
    return width! * height!;
  }

  static double? rectanglePerimeter(double? width, double? height) {
    if (!positive(width) || !positive(height)) return null;
    return 2 * (width! + height!);
  }

  static double? squareArea(double? side) {
    if (!positive(side)) return null;
    return side! * side;
  }

  static double? triangleArea(double? base, double? height) {
    if (!positive(base) || !positive(height)) return null;
    return base! * height! / 2;
  }

  static double? parallelogramArea(double? base, double? height) {
    if (!positive(base) || !positive(height)) return null;
    return base! * height!;
  }

  static double? trapezoidArea(double? top, double? bottom, double? height) {
    if (!positive(top) || !positive(bottom) || !positive(height)) return null;
    return (top! + bottom!) * height! / 2;
  }

  static double? circleArea(double? radius) {
    if (!positive(radius)) return null;
    return math.pi * radius! * radius;
  }

  static double? circleCircumference(double? radius) {
    if (!positive(radius)) return null;
    return 2 * math.pi * radius!;
  }

  static bool validTriangleAngles(double? a, double? b, double? c) {
    if (!positive(a) || !positive(b) || !positive(c)) return false;
    return (a! + b! + c! - 180).abs() < 0.0001;
  }
}

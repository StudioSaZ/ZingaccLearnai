import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import '../lib/diagram_geometry.dart';

void main() {
  test('rectangle area', () => expect(DiagramGeometry.rectangleArea(8, 4), 32));
  test('rectangle perimeter', () => expect(DiagramGeometry.rectanglePerimeter(8, 4), 24));
  test('square area', () => expect(DiagramGeometry.squareArea(5), 25));
  test('triangle area', () => expect(DiagramGeometry.triangleArea(10, 6), 30));
  test('parallelogram area', () => expect(DiagramGeometry.parallelogramArea(8, 5), 40));
  test('trapezoid area', () => expect(DiagramGeometry.trapezoidArea(6, 10, 4), 32));
  test('circle area', () => expect(DiagramGeometry.circleArea(7), closeTo(49 * math.pi, 1e-9)));
  test('circle circumference', () => expect(DiagramGeometry.circleCircumference(7), closeTo(14 * math.pi, 1e-9)));
  test('valid triangle angles', () => expect(DiagramGeometry.validTriangleAngles(80, 50, 50), isTrue));
  test('invalid measurements and angles', () {
    expect(DiagramGeometry.rectangleArea(-8, 4), isNull);
    expect(DiagramGeometry.circleArea(0), isNull);
    expect(DiagramGeometry.validTriangleAngles(90, 60, 40), isFalse);
  });
}

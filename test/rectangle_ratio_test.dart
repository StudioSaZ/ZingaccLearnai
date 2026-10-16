import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';

void main() {
  double drawnRatio(double width, double height) {
    const availableWidth = 210.0;
    const availableHeight = 140.0;
    final scale = math.min(availableWidth / width, availableHeight / height);
    return (width * scale) / (height * scale);
  }

  test('wide rectangle keeps 2 to 1 ratio', () {
    expect(drawnRatio(8, 4), closeTo(2, 1e-10));
  });

  test('tall rectangle keeps 1 to 2 ratio', () {
    expect(drawnRatio(4, 8), closeTo(0.5, 1e-10));
  });

  test('square keeps 1 to 1 ratio', () {
    expect(drawnRatio(5, 5), closeTo(1, 1e-10));
  });
}

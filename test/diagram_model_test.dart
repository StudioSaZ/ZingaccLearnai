import 'package:flutter_test/flutter_test.dart';
import 'package:zingacclearnai/diagram_model.dart';

void main() {
  test('Valid triangle angles', () {
    const data = TriangleDiagramData(angleA: 80, angleB: 50, angleC: 50);
    expect(data.hasValidAngles, isTrue);
  });

  test('Invalid triangle angles', () {
    const data = TriangleDiagramData(angleA: 90, angleB: 60, angleC: 40);
    expect(data.hasValidAngles, isFalse);
  });

  test('Missing triangle angle', () {
    const data = TriangleDiagramData(angleA: 80, angleB: 50);
    expect(data.hasValidAngles, isFalse);
  });
}

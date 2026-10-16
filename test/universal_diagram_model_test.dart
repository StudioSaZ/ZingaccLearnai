import 'package:flutter_test/flutter_test.dart';
import '../lib/universal_diagram_engine.dart';

void main() {
  test('all eight diagram types are available', () {
    expect(DiagramShape.values.length, 8);
  });

  test('rectangle measurements are preserved', () {
    const diagram = DiagramSpecification(
      shape: DiagramShape.rectangle,
      measurements: {'width': 8, 'height': 4},
    );
    expect(diagram.measurements['width'], 8);
    expect(diagram.measurements['height'], 4);
  });

  test('circle radius is preserved', () {
    const diagram = DiagramSpecification(
      shape: DiagramShape.circle,
      measurements: {'radius': 7},
    );
    expect(diagram.measurements['radius'], 7);
  });

  test('force label is preserved', () {
    const diagram = DiagramSpecification(
      shape: DiagramShape.forceDiagram,
      labels: {'force': '20 N'},
    );
    expect(diagram.labels['force'], '20 N');
  });
}

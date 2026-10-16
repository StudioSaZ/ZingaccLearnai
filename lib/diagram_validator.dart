import 'diagram_geometry.dart';
import 'universal_diagram_engine.dart';

class DiagramValidator {
  const DiagramValidator._();

  static bool canDrawToScale(DiagramSpecification data) {
    final m = data.measurements;
    bool valid(String key) => DiagramGeometry.positive(m[key]);

    switch (data.shape) {
      case DiagramShape.triangle:
        return DiagramGeometry.validTriangleAngles(
            m['angleA'], m['angleB'], m['angleC']);
      case DiagramShape.square:
        return valid('side');
      case DiagramShape.rectangle:
        return valid('width') && valid('height');
      case DiagramShape.parallelogram:
        return valid('base') && valid('height') &&
            m['offset'] != null && m['offset']!.isFinite;
      case DiagramShape.trapezoid:
        return valid('top') && valid('bottom') && valid('height') &&
            m['offset'] != null && m['offset']!.isFinite;
      case DiagramShape.circle:
        return valid('radius');
      case DiagramShape.coordinateGraph:
        return false;
      case DiagramShape.forceDiagram:
        return false;
    // අලුතින් එකතු කළ පරිපථ සහ ආලෝක සටහන් සඳහා අවසර දීම
      case DiagramShape.electricalCircuit:
        return true;
      case DiagramShape.opticalDiagram:
        return true;
    }
  }
}
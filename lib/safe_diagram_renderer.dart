import 'package:flutter/material.dart';
import 'diagram_validator.dart';
import 'diagram_model.dart';
import 'dynamic_triangle_renderer.dart';
import 'measured_circle_renderer.dart';
import 'measured_rectangle_renderer.dart';
import 'universal_diagram_engine.dart';
import 'circuit_diagram_renderer.dart'; // අලුතින් හැදූ ෆයිල් එක
import 'optical_diagram_renderer.dart';

class SafeDiagramRenderer extends StatelessWidget {
  final DiagramSpecification data;

  const SafeDiagramRenderer({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (!DiagramValidator.canDrawToScale(data)) {
      return const SizedBox.shrink();
    }

    switch (data.shape) {
      case DiagramShape.triangle:
        return DynamicTriangleRenderer(
          data: TriangleDiagramData(
            angleA: data.measurements['angleA'],
            angleB: data.measurements['angleB'],
            angleC: data.measurements['angleC'],
          ),
        );
      case DiagramShape.rectangle:
        return MeasuredRectangleRenderer(
          width: data.measurements['width']!,
          height: data.measurements['height']!,
        );
      case DiagramShape.circle:
        return MeasuredCircleRenderer(
          radius: data.measurements['radius']!,
        );
      case DiagramShape.electricalCircuit:
      // විද්‍යුත් පරිපථ අඳින කොටස
        return CircuitDiagramRenderer(
          data: CircuitDiagramData(
            resistors: data.measurements['resistors']?.toInt() ?? 1,
            batteries: data.measurements['batteries']?.toInt() ?? 1,
            hasSwitch: (data.measurements['switch'] ?? 0) > 0,
            isParallel: (data.measurements['parallel'] ?? 0) > 0,
          ),
        );
      case DiagramShape.opticalDiagram:
      // ආලෝකය සහ කාච (Optics) අඳින කොටස
        return OpticalDiagramRenderer(
          data: OpticalDiagramData(
            isConvex: (data.measurements['isConvex'] ?? 1) > 0,
            focalLength: data.measurements['focalLength'] ?? 15.0,
            objectDistance: data.measurements['objectDistance'] ?? 30.0,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
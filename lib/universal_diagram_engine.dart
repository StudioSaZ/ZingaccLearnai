import 'package:flutter/material.dart';

enum DiagramShape {
  triangle,
  square,
  rectangle,
  parallelogram,
  trapezoid,
  circle,
  coordinateGraph,
  forceDiagram,
  electricalCircuit, // අලුතින් O/L සහ A/L විද්‍යුත් පරිපථ සඳහා
  opticalDiagram,    // අලුතින් A/L ආලෝකය සහ කාච සඳහා
}

@immutable
class DiagramSpecification {
  final DiagramShape shape;
  final Map<String, double> measurements;
  final Map<String, String> labels;

  const DiagramSpecification({
    required this.shape,
    this.measurements = const {},
    this.labels = const {},
  });
}
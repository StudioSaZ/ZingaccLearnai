import 'package:flutter/foundation.dart';

@immutable
class TriangleDiagramData {
  final String vertexA;
  final String vertexB;
  final String vertexC;
  final double? angleA;
  final double? angleB;
  final double? angleC;

  const TriangleDiagramData({
    this.vertexA = 'A',
    this.vertexB = 'B',
    this.vertexC = 'C',
    this.angleA,
    this.angleB,
    this.angleC,
  });

  bool get hasValidAngles {
    final angles = [angleA, angleB, angleC];
    if (angles.any((angle) => angle == null)) return false;
    if (angles.any((angle) => angle! <= 0 || angle >= 180 || !angle.isFinite)) return false;
    final sum = angleA! + angleB! + angleC!;
    return (sum - 180).abs() < 0.01;
  }
}

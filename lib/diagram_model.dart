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

// --- අලුතින් එකතු කළ කොටස (පරිපථ සඳහා) ---
@immutable
class CircuitDiagramData {
  final int resistors; // ප්‍රතිරෝධක ගණන
  final int batteries; // කෝෂ ගණන
  final bool hasSwitch; // ස්විචයක් තියෙනවද නැද්ද
  final bool isParallel; // සමාන්තරගතද ශ්‍රේණිගතද

  const CircuitDiagramData({
    this.resistors = 1,
    this.batteries = 1,
    this.hasSwitch = false,
    this.isParallel = false,
  });
}
// --- අලුතින් එකතු කළ කොටස (ආලෝකය/කාච සඳහා) ---
@immutable
class OpticalDiagramData {
  final bool isConvex; // උත්තල (Convex) ද අවතල (Concave) ද
  final double focalLength; // නාභිය දුර (f)
  final double objectDistance; // වස්තු දුර (u)

  const OpticalDiagramData({
    this.isConvex = true,
    this.focalLength = 15.0,
    this.objectDistance = 30.0,
  });
}
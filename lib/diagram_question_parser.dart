import 'universal_diagram_engine.dart';

class DiagramQuestionParser {
  const DiagramQuestionParser._();

  static DiagramSpecification? parse(String question) {
    final text = question.trim().toLowerCase();

    // 1. සෘජුකෝණාස්‍රය (Rectangle) - සිංහල, ඉංග්‍රීසි, දෙමළ
    final rectPattern1 = RegExp(r'^a rectangle has width\s+(\d+(?:\.\d+)?)\s*cm\s+and height\s+(\d+(?:\.\d+)?)\s*cm\.?$');
    final rectPattern2 = RegExp(r'^a rectangle has length\s+(\d+(?:\.\d+)?)\s*cm\s+and width\s+(\d+(?:\.\d+)?)\s*cm\.?$');
    final rectSinhala = RegExp(r'^සෘජුකෝණාස්‍රයක දිග\s+(\d+(?:\.\d+)?)\s*cm\s+සහ පළල\s+(\d+(?:\.\d+)?)\s*cm\s+වේ\.$');
    final rectTamil = RegExp(r'செவ்வகத்தின் நீளம்\s+(\d+(?:\.\d+)?)\s*cm\s+மற்றும் அகலம்\s+(\d+(?:\.\d+)?)\s*cm');

    final rectMatch = rectPattern1.firstMatch(text) ?? rectPattern2.firstMatch(text) ?? rectSinhala.firstMatch(text) ?? rectTamil.firstMatch(text);
    if (rectMatch != null) {
      final width = double.tryParse(rectMatch.group((rectPattern2.hasMatch(text) || rectSinhala.hasMatch(text) || rectTamil.hasMatch(text)) ? 2 : 1)!);
      final height = double.tryParse(rectMatch.group((rectPattern2.hasMatch(text) || rectSinhala.hasMatch(text) || rectTamil.hasMatch(text)) ? 1 : 2)!);
      if (width != null && height != null && width > 0 && height > 0) {
        return DiagramSpecification(
          shape: DiagramShape.rectangle,
          measurements: {'width': width, 'height': height},
        );
      }
    }

    // 2. වෘත්තය (Circle) - සිංහල, ඉංග්‍රීසි, දෙමළ
    final circlePattern = RegExp(r'a circle has radius\s+(\d+(?:\.\d+)?)\s*cm');
    final circleSinhala = RegExp(r'වෘත්තයක අරය\s+(\d+(?:\.\d+)?)\s*cm');
    final circleTamil = RegExp(r'வட்டத்தின் ஆரை\s+(\d+(?:\.\d+)?)\s*cm');
    final circleMatch = circlePattern.firstMatch(text) ?? circleSinhala.firstMatch(text) ?? circleTamil.firstMatch(text);

    if (circleMatch != null) {
      final radius = double.tryParse(circleMatch.group(1)!);
      if (radius != null && radius > 0) {
        return DiagramSpecification(
          shape: DiagramShape.circle,
          measurements: {'radius': radius},
        );
      }
    }

    // 3. ත්‍රිකෝණය (Triangle) - සිංහල, ඉංග්‍රීසි, දෙමළ
    final triPattern = RegExp(r'triangle.+angles\s+(\d+(?:\.\d+)?)[,\s]+(\d+(?:\.\d+)?)[,\s]+and\s+(\d+(?:\.\d+)?)');
    final triSinhala = RegExp(r'ත්‍රිකෝණයක කෝණ\s+(\d+(?:\.\d+)?)[,\s]+(\d+(?:\.\d+)?)[,\s]+සහ\s+(\d+(?:\.\d+)?)');
    final triTamil = RegExp(r'முக்கோணத்தின் கோணங்கள்\s+(\d+(?:\.\d+)?)[,\s]+(\d+(?:\.\d+)?)[,\s]+மற்றும்\s+(\d+(?:\.\d+)?)');
    final triMatch = triPattern.firstMatch(text) ?? triSinhala.firstMatch(text) ?? triTamil.firstMatch(text);

    if (triMatch != null) {
      final angleA = double.tryParse(triMatch.group(1)!);
      final angleB = double.tryParse(triMatch.group(2)!);
      final angleC = double.tryParse(triMatch.group(3)!);

      if (angleA != null && angleB != null && angleC != null && (angleA + angleB + angleC == 180)) {
        return DiagramSpecification(
          shape: DiagramShape.triangle,
          measurements: {'angleA': angleA, 'angleB': angleB, 'angleC': angleC},
        );
      }
    }

    // 4. විද්‍යුත් පරිපථ (Electrical Circuit) - සිංහල, ඉංග්‍රීසි, දෙමළ
    final circuitMatch = RegExp(r'(?:(\d+)\s*(?:resistors?|ප්‍රතිරෝධක|மின்தடை))|(?:(?:resistor|ප්‍රතිරෝධක|மின்தடை)\s*(\d+))').firstMatch(text);

    if (circuitMatch != null || text.contains('circuit') || text.contains('පරිපථ') || text.contains('மின்சுற்று')) {
      final resStr = circuitMatch?.group(1) ?? circuitMatch?.group(2) ?? '1';
      final resistors = double.tryParse(resStr) ?? 1.0;
      final batteries = RegExp(r'(?:2|two|දෙකක්|කෝෂ 2|இரண்டு)\s*(?:batter|කෝෂ|மின்கல)').hasMatch(text) ? 2.0 : 1.0;
      final hasSwitch = RegExp(r'switch|ස්විච|சுவிட்ச்').hasMatch(text) ? 1.0 : 0.0;
      final isParallel = RegExp(r'parallel|සමාන්තර|பக்க இணைப்பு').hasMatch(text) ? 1.0 : 0.0;

      return DiagramSpecification(
        shape: DiagramShape.electricalCircuit,
        measurements: {
          'resistors': resistors,
          'batteries': batteries,
          'switch': hasSwitch,
          'parallel': isParallel,
        },
      );
    }
    // 5. ආලෝකය සහ කාච (Optics/Lenses) - සිංහල, ඉංග්‍රීසි, දෙමළ
    final isOptical = RegExp(r'lens|කාච|வில்லை|mirror|දර්පණ|ஆடி|focal|නාභිය|குவிய').hasMatch(text);

    if (isOptical) {
      // උත්තල (convex) ද අවතල (concave) ද යන්න සෙවීම
      final isConvex = RegExp(r'concave|අවතල|குழி').hasMatch(text) ? 0.0 : 1.0;

      // නාභිය දුර (focal length) අල්ලගමු
      final fMatch = RegExp(r'(?:focal length|නාභිය දුර|குவிய தூரம்)\s*(?:is|වන්නේ|=)?\s*(\d+(?:\.\d+)?)').firstMatch(text);
      final f = double.tryParse(fMatch?.group(1) ?? '15.0') ?? 15.0;

      // වස්තු දුර (object distance) අල්ලගමු
      final uMatch = RegExp(r'(?:object distance|වස්තු දුර|பொருள் தூரம்)\s*(?:is|වන්නේ|=)?\s*(\d+(?:\.\d+)?)').firstMatch(text) ??
          RegExp(r'(?:placed at|තබා ඇත|வைக்கப்பட்டுள்ளது)\s*(\d+(?:\.\d+)?)').firstMatch(text);
      final u = double.tryParse(uMatch?.group(1) ?? '30.0') ?? 30.0;

      return DiagramSpecification(
        shape: DiagramShape.opticalDiagram,
        measurements: {
          'isConvex': isConvex,
          'focalLength': f,
          'objectDistance': u,
        },
      );
    }

    return null;
  }
}
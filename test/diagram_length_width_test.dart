import 'package:flutter_test/flutter_test.dart';
import '../lib/diagram_question_parser.dart';
import '../lib/universal_diagram_engine.dart';
import '../lib/diagram_validator.dart';

void main() {
  test('length and width are parsed correctly', () {
    final data = DiagramQuestionParser.parse(
      'A rectangle has length 8 cm and width 4 cm.',
    );
    expect(data, isNotNull);
    expect(data!.shape, DiagramShape.rectangle);
    expect(data.measurements['width'], 4);
    expect(data.measurements['height'], 8);
    expect(DiagramValidator.canDrawToScale(data), isTrue);
  });

  test('rejects incomplete length and width question', () {
    expect(
      DiagramQuestionParser.parse('A rectangle has length 8 cm.'),
      isNull,
    );
  });

  test('rejects zero length', () {
    expect(
      DiagramQuestionParser.parse(
        'A rectangle has length 0 cm and width 4 cm.',
      ),
      isNull,
    );
  });
}

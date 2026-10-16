import 'package:flutter_test/flutter_test.dart';
import '../lib/diagram_question_parser.dart';
import '../lib/universal_diagram_engine.dart';

void main() {
  test('recognizes Sinhala rectangle length and width', () {
    final data = DiagramQuestionParser.parse(
      'සෘජුකෝණාස්‍රයක දිග 8 cm සහ පළල 4 cm වේ.',
    );

    expect(data, isNotNull);
    expect(data!.shape, DiagramShape.rectangle);
    expect(data.measurements['width'], 4);
    expect(data.measurements['height'], 8);
  });

  test('rejects incomplete Sinhala rectangle question', () {
    expect(
      DiagramQuestionParser.parse(
        'සෘජුකෝණාස්‍රයක දිග 8 cm වේ.',
      ),
      isNull,
    );
  });
}

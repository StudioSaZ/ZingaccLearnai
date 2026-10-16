import 'package:flutter_test/flutter_test.dart';
import '../lib/diagram_question_parser.dart';
import '../lib/universal_diagram_engine.dart';

void main() {
  test('extracts explicit rectangle dimensions', () {
    final result = DiagramQuestionParser.parse(
      'A rectangle has width 8 cm and height 4 cm.',
    );
    expect(result, isNotNull);
    expect(result!.shape, DiagramShape.rectangle);
    expect(result.measurements['width'], 8);
    expect(result.measurements['height'], 4);
  });

  test('accepts positive decimal measurements', () {
    final result = DiagramQuestionParser.parse(
      'A rectangle has width 8.5 cm and height 4.25 cm.',
    );
    expect(result?.measurements['width'], 8.5);
    expect(result?.measurements['height'], 4.25);
  });

  test('rejects zero and negative dimensions', () {
    expect(DiagramQuestionParser.parse(
      'A rectangle has width 0 cm and height 4 cm.'), isNull);
    expect(DiagramQuestionParser.parse(
      'A rectangle has width -8 cm and height 4 cm.'), isNull);
  });

  test('rejects missing measurements', () {
    expect(DiagramQuestionParser.parse(
      'A rectangle has width 8 cm.'), isNull);
  });

  test('does not mistake another shape for rectangle', () {
    expect(DiagramQuestionParser.parse(
      'A triangle has width 8 cm and height 4 cm.'), isNull);
  });

  test('does not guess from unrelated numbers', () {
    expect(DiagramQuestionParser.parse(
      'A rectangle has area 32 cm2 and perimeter 24 cm.'), isNull);
  });
}

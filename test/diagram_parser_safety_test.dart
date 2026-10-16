import 'package:flutter_test/flutter_test.dart';
import '../lib/diagram_question_parser.dart';

void main() {
  test('rejects triangle dimensions', () {
    expect(DiagramQuestionParser.parse(
      'A triangle has width 8 cm and height 4 cm.'), isNull);
  });
  test('rejects dimensions without shape', () {
    expect(DiagramQuestionParser.parse(
      'Width 8 cm and height 4 cm.'), isNull);
  });
  test('rejects conflicting extra information', () {
    expect(DiagramQuestionParser.parse(
      'A rectangle has width 8 cm and height 4 cm but the width is actually 6 cm.'), isNull);
  });
  test('rejects unrecognized units', () {
    expect(DiagramQuestionParser.parse(
      'A rectangle has width 8 m and height 4 m.'), isNull);
  });
  test('rejects image-only question', () {
    expect(DiagramQuestionParser.parse(''), isNull);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/diagram_question_parser.dart';
import '../lib/diagram_validator.dart';
import '../lib/measured_rectangle_renderer.dart';
import '../lib/safe_diagram_renderer.dart';

void main() {
  testWidgets('explicit rectangle question produces a safe diagram', (tester) async {
    final data = DiagramQuestionParser.parse(
      'A rectangle has width 8 cm and height 4 cm.',
    );
    expect(data, isNotNull);
    expect(DiagramValidator.canDrawToScale(data!), isTrue);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: SizedBox(
        width: 280,
        child: SafeDiagramRenderer(data: data),
      )),
    ));
    expect(find.byType(MeasuredRectangleRenderer), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('incomplete question does not produce a diagram', () {
    final data = DiagramQuestionParser.parse(
      'A rectangle has width 8 cm.',
    );
    expect(data, isNull);
  });
}

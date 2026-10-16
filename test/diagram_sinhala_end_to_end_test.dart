import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/diagram_question_parser.dart';
import '../lib/diagram_validator.dart';
import '../lib/safe_diagram_renderer.dart';
import '../lib/measured_rectangle_renderer.dart';

void main() {
  testWidgets('Sinhala rectangle question produces a diagram', (tester) async {
    final data = DiagramQuestionParser.parse(
      'සෘජුකෝණාස්‍රයක දිග 8 cm සහ පළල 4 cm වේ.',
    );

    expect(data, isNotNull);
    expect(data!.measurements['width'], 4);
    expect(data.measurements['height'], 8);
    expect(DiagramValidator.canDrawToScale(data), isTrue);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 300,
          child: SafeDiagramRenderer(data: data),
        ),
      ),
    ));

    expect(find.byType(MeasuredRectangleRenderer), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('incomplete Sinhala question produces no specification', () {
    final data = DiagramQuestionParser.parse(
      'සෘජුකෝණාස්‍රයක දිග 8 cm වේ.',
    );
    expect(data, isNull);
  });
}

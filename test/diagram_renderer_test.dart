import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zingacclearnai/diagram_renderer.dart';

void main() {
  testWidgets('Diagram renderer displays a drawable triangle', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 280,
              height: 220,
              child: DiagramRenderer(),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(DiagramRenderer), findsOneWidget);
    expect(find.descendant(of: find.byType(DiagramRenderer), matching: find.byType(CustomPaint)), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

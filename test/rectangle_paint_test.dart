import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/measured_rectangle_renderer.dart';

void main() {
  Future<void> checkPainting(
    WidgetTester tester,
    double width,
    double height,
  ) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 280,
            child: MeasuredRectangleRenderer(
              width: width,
              height: height,
            ),
          ),
        ),
      ),
    ));

    final drawing = find.descendant(
      of: find.byType(MeasuredRectangleRenderer),
      matching: find.byType(CustomPaint),
    );

    expect(drawing, findsOneWidget);
    expect(drawing, paints..rect());
    expect(tester.takeException(), isNull);
  }

  testWidgets('wide rectangle draws a rectangle', (tester) async {
    await checkPainting(tester, 8, 4);
  });

  testWidgets('tall rectangle draws a rectangle', (tester) async {
    await checkPainting(tester, 4, 8);
  });
}

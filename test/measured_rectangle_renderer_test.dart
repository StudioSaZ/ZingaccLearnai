import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/measured_rectangle_renderer.dart';

void main() {
  testWidgets('valid rectangle creates a drawing', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Center(child: SizedBox(
          width: 280,
          child: MeasuredRectangleRenderer(width: 8, height: 4),
        )),
      ),
    ));
    expect(find.byType(MeasuredRectangleRenderer), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('invalid rectangle does not create a drawing', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: MeasuredRectangleRenderer(width: -8, height: 4),
      ),
    ));
    final widget = tester.widget<MeasuredRectangleRenderer>(
      find.byType(MeasuredRectangleRenderer),
    );
    expect(widget.width, -8);
    expect(find.byType(AspectRatio), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

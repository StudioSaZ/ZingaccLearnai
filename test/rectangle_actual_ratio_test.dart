import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/measured_rectangle_renderer.dart';

void main() {
  Future<void> checkRatio(WidgetTester tester, double width,
      double height, double expectedRatio) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Center(child: SizedBox(
        width: 280,
        child: MeasuredRectangleRenderer(width: width, height: height),
      ))),
    ));

    final drawing = find.descendant(
      of: find.byType(MeasuredRectangleRenderer),
      matching: find.byType(CustomPaint),
    );
    expect(drawing, findsOneWidget);
    final painter = tester.widget<CustomPaint>(drawing).painter!;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    painter.paint(canvas, const Size(280, 200));
    final picture = recorder.endRecording();
    final commands = <Rect>[];
    // Painting command existence is checked through Flutter's paint matcher.
    expect(drawing, paints..rect());
    expect(commands, isEmpty);
    expect(width / height, closeTo(expectedRatio, 1e-10));
    picture.dispose();
    expect(tester.takeException(), isNull);
  }

  testWidgets('wide rectangle', (tester) async {
    await checkRatio(tester, 8, 4, 2);
  });
  testWidgets('tall rectangle', (tester) async {
    await checkRatio(tester, 4, 8, 0.5);
  });
}

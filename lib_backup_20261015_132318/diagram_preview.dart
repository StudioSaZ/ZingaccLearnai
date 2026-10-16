import 'package:flutter/material.dart';
import 'diagram_renderer.dart';

void main() => runApp(const DiagramPreviewApp());

class DiagramPreviewApp extends StatelessWidget {
  const DiagramPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Zingacc Diagram Preview')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: DiagramRenderer(),
          ),
        ),
      ),
    );
  }
}

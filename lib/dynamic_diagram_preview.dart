import 'package:flutter/material.dart';
import 'diagram_model.dart';
import 'dynamic_triangle_renderer.dart';

void main() => runApp(const DynamicDiagramPreview());

class DynamicDiagramPreview extends StatelessWidget {
  const DynamicDiagramPreview({super.key});

  @override
  Widget build(BuildContext context) {
    const triangles = [
      TriangleDiagramData(angleA: 80, angleB: 50, angleC: 50),
      TriangleDiagramData(angleA: 90, angleB: 60, angleC: 30),
      TriangleDiagramData(angleA: 100, angleB: 40, angleC: 40),
    ];
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Dynamic Triangle Preview')),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: triangles.length,
          itemBuilder: (context, index) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Triangle ${index + 1}: ${triangles[index].angleA} / ${triangles[index].angleB} / ${triangles[index].angleC}'),
                  const SizedBox(height: 12),
                  Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 360), child: DynamicTriangleRenderer(data: triangles[index]))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

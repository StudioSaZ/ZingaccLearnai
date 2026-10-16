import 'package:flutter/material.dart';
import 'universal_diagram_engine.dart';
import 'universal_diagram_renderer.dart';

void main() => runApp(const UniversalDiagramPreview());

class UniversalDiagramPreview extends StatelessWidget {
  const UniversalDiagramPreview({super.key});

  @override
  Widget build(BuildContext context) {
    const shapes = DiagramShape.values;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Zingacc Diagram Preview')),
        body: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 380,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.15,
          ),
          itemCount: shapes.length,
          itemBuilder: (context, index) {
            final shape = shapes[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(shape.name, style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Center(
                        child: UniversalDiagramRenderer(
                          data: DiagramSpecification(shape: shape),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

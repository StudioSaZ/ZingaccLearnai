import 'package:flutter/material.dart';
import 'universal_diagram_engine.dart';
import 'universal_diagram_renderer.dart';

void main() => runApp(const UniversalDiagramPreview());

class UniversalDiagramPreview extends StatelessWidget {
  const UniversalDiagramPreview({super.key});

  @override
  Widget build(BuildContext context) {
    const shapes = DiagramShape.values;
    const background = Color(0xFF0A1C14); // Deep Dark Green
    const panel = Color(0xFF112A20); // Dark Green Panel
    const gold = Color(0xFFD4AF37); // Premium Gold

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
      ),
      home: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: background,
          foregroundColor: gold,
          title: const Text(
            'Zingacc Diagram Preview',
            style: TextStyle(fontWeight: FontWeight.bold, color: gold),
          ),
          centerTitle: true,
          elevation: 0,
        ),
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
              color: panel, // Dark Green Card
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: gold.withValues(alpha: 0.3)), // Subtle Gold Border
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      shape.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: gold, // Gold Shape Name
                      ),
                    ),
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
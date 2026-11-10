import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'math_text.dart';

class OfflineLibraryScreen extends StatefulWidget {
  const OfflineLibraryScreen({super.key});

  @override
  State<OfflineLibraryScreen> createState() => _OfflineLibraryScreenState();
}

class _OfflineLibraryScreenState extends State<OfflineLibraryScreen> {
  List<Map<String, dynamic>> _savedLessons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedLessons();
  }

  // ෆෝන් එකේ සේව් කරලා තියෙන පාඩම් ටික ගන්නවා (Offline)
  Future<void> _loadSavedLessons() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? lessonsJson = prefs.getStringList('offline_lessons');

    if (lessonsJson != null) {
      setState(() {
        _savedLessons = lessonsJson
            .map((lesson) => json.decode(lesson) as Map<String, dynamic>)
            .toList();
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  // සේව් කරපු පාඩමක් මකා දැමීම
  Future<void> _deleteLesson(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedLessons.removeAt(index);
    });

    final List<String> updatedLessons =
    _savedLessons.map((lesson) => json.encode(lesson)).toList();
    await prefs.setStringList('offline_lessons', updatedLessons);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('පාඩම මකා දමන ලදී.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF0A1C14); // Deep Dark Green
    const panel = Color(0xFF112A20); // Dark Green Panel
    const gold = Color(0xFFD4AF37); // Premium Gold

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: gold, // Gold Title
        title: const Text('මගේ පාඩම් (Offline)', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: gold)) // Gold loading indicator
          : _savedLessons.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 80, color: gold.withOpacity(0.5)), // Gold opacity icon
            const SizedBox(height: 16),
            const Text(
              'ඔබ තවමත් පාඩම් කිසිවක් Offline Save කර නැත.',
              style: TextStyle(color: Colors.white70, fontSize: 16), // Softer white text
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _savedLessons.length,
        itemBuilder: (context, index) {
          final lesson = _savedLessons[index];
          return Card(
            color: panel, // Dark Green Card
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: gold.withOpacity(0.4)), // Subtle Gold Border
            ),
            child: ExpansionTile(
              collapsedIconColor: gold, // Gold Icons
              iconColor: gold,
              title: Text(
                lesson['question'] ?? 'ප්‍රශ්නය',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                lesson['subject'] ?? 'විෂය',
                style: const TextStyle(color: gold, fontSize: 12), // Gold subject text
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: background, // Deep Green inside for contrast
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MathText(
                        text: lesson['answer'] ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5), // White text for reading comfort
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => _deleteLesson(index),
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        label: const Text('මකා දමන්න', style: TextStyle(color: Colors.redAccent)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent), // Delete button remains red
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
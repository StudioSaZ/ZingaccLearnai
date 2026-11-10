import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart'; // 👈 හරීම පැකේජ් එක මේකයි
import 'math_text.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isGeneratingReport = false;

  Future<void> _generateParentalReport(List<QueryDocumentSnapshot> docs) async {
    if (docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('වාර්තාවක් හැදීමට තරම් ප්‍රශ්න අසා නැත.')),
      );
      return;
    }

    setState(() {
      _isGeneratingReport = true;
    });

    try {
      final recentDocs = docs.take(15).toList();
      String questionsList = '';
      for (var i = 0; i < recentDocs.length; i++) {
        final data = recentDocs[i].data() as Map<String, dynamic>;
        final q = data['question'] ?? '';
        final sub = data['subject'] ?? '';
        if (q.toString().isNotEmpty) {
          questionsList += '${i + 1}. විෂය: $sub | ප්‍රශ්නය: $q\n';
        }
      }

      final prompt = '''
ඔබ දක්ෂ හා කරුණාවන්ත ශ්‍රී ලාංකික අධ්‍යාපන උපදේශකයෙකි (Educational Counselor).
මේ දරුවා විසින් පසුගිය දිනවල අපගේ "Zingacc Learn AI" යෙදුමෙන් ඇසූ ප්‍රශ්න ලැයිස්තුවකි:

$questionsList

මෙම ප්‍රශ්න හොඳින් අධ්‍යයනය කර, දරුවාගේ දෙමාපියන්ට කියවීම සඳහා සරල, ආදරණීය සිංහල භාෂාවෙන් වටිනා වාර්තාවක් (Parental Insight Report) සකස් කරන්න.
පහත කරුණු කෙරෙහි අවධානය යොමු කරන්න:
1. 
දරුවා වැඩිපුරම උනන්දුවක් දක්වන විෂයයන් සහ දක්ෂතා.
2. දරුවාට තරමක් අපහසු හෝ දුර්වලතා පෙන්වන පාඩම්/විෂයයන් මොනවාද යන්න.
3. දෙමාපියෙකු ලෙස දරුවාට නිවසේදී උදව් කළ හැකි ප්‍රායෝගික උපදෙස් 2ක්.

කරුණාකර ඉතා දිගු නොවන, පහසුවෙන් කියවිය හැකි ආකර්ෂණීය වාර්තාවක් ලබා දෙන්න. Markdown (Bold, Bullet points) භාවිතා කරන්න.
''';

      // 👈 අර එරර් ආපු කෑල්ල වෙනුවට ඔයාගේ සුපුරුදු AI කෝඩ් එක මෙතනට දැම්මා
      const apiKey = 'AQ.Ab8RN6KjvvtMPQtGecmGUTj6u2bMF7kY0kPOsgUjMuTlcJg1Iw';
      final model = GenerativeModel(
        model: 'gemini-3.5-flash-lite',
        apiKey: apiKey,
      );

      final response = await model.generateContent([Content.text(prompt)]);
      final reportText = response.text?.trim() ?? 'වාර්තාව සැකසීමට නොහැකි විය.';

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF112A20), // Dark Green Background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFD4AF37), width: 2), // Gold Border
          ),
          title: const Row(
            children: [
              Icon(Icons.analytics_rounded, color: Color(0xFFD4AF37)), // Gold Icon
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'දෙමාපිය වාර්තාව',
                  style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: MathText(
              text: reportText,
              style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('වැහන්න (Close)', style: TextStyle(color: Color(0xFFD4AF37))), // Gold Text
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('වාර්තාව සකස් කිරීමේදී ගැටලුවක් ඇති විය.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingReport = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1C14), // Luxury Dark Green
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1C14), // Luxury Dark Green
        foregroundColor: const Color(0xFFD4AF37), // Gold Title
        title: const Text(
          'මගේ අතීත පාඩම්',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: user == null
          ? const Center(
        child: Text(
          'කරුණාකර ලොග් වන්න',
          style: TextStyle(color: Colors.white),
        ),
      )
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('history')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD4AF37), // Gold Progress
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 80,
                    color: const Color(0xFFD4AF37).withOpacity(0.5), // Gold opacity
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ඔබ තවමත් ප්‍රශ්න කිසිවක් අසා නැත.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final question = data['question'] ?? 'ප්‍රශ්නයක් නැත';
                  final answer = data['answer'] ?? '';
                  final subject = data['subject'] ?? 'විෂය';

                  return Card(
                    color: const Color(0xFF112A20), // Dark Green Card
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.5), width: 1), // Gold Border
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        collapsedIconColor: const Color(0xFFD4AF37), // Gold Icons
                        iconColor: const Color(0xFFD4AF37),
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          question,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.menu_book_rounded, size: 14, color: Color(0xFFD4AF37)),
                              const SizedBox(width: 4),
                              Text(
                                subject,
                                style: const TextStyle(
                                  color: Color(0xFFD4AF37), // Gold Text
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0A1C14), // Deep Green inside
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                            child: MathText(
                              text: answer,
                              style: const TextStyle(
                                color: Color(0xFFE0E0E0),
                                fontSize: 15,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton.extended(
                  onPressed: _isGeneratingReport ? null : () => _generateParentalReport(docs),
                  backgroundColor: const Color(0xFFD4AF37), // Gold Button Background
                  foregroundColor: const Color(0xFF0A1C14), // Dark Green Text
                  icon: _isGeneratingReport
                      ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(color: Color(0xFF0A1C14), strokeWidth: 2)
                  )
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    _isGeneratingReport ? 'සකසමින්...' : '📊 දෙමාපිය වාර්තාව',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
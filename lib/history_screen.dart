import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'math_text.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF07132F), // අපේ Dark Theme වර්ණය
      appBar: AppBar(
        backgroundColor: const Color(0xFF07132F),
        foregroundColor: Colors.white,
        title: const Text(
          'මගේ අතීත පාඩම් (History)',
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
        // Database එකෙන් ළමයාගේ ප්‍රශ්න ටික අලුත්ම එකේ ඉඳන් පරණ එකට පිළිවෙලට ගන්නවා
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
                color: Color(0xFF70CFFF),
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
                    color: const Color(0xFF365393).withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ඔබ තවමත් ප්‍රශ්න කිසිවක් අසා නැත.',
                    style: TextStyle(
                      color: Color(0xFFABBCD8),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final question = data['question'] ?? 'ප්‍රශ්නයක් නැත';
              final answer = data['answer'] ?? '';
              final subject = data['subject'] ?? 'විෂය';

              return Card(
                color: const Color(0xFF101F43),
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFF365393)),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent, // මැද ඉර අයින් කරන්න
                  ),
                  child: ExpansionTile(
                    collapsedIconColor: const Color(0xFF70CFFF),
                    iconColor: const Color(0xFFB77AFF),
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
                          const Icon(Icons.menu_book_rounded, size: 14, color: Color(0xFF70CFFF)),
                          const SizedBox(width: 4),
                          Text(
                            subject,
                            style: const TextStyle(
                              color: Color(0xFF70CFFF),
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
                          color: Color(0xFF0C1733),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: MathText(
                          text: answer,
                          style: const TextStyle(
                            color: Color(0xFFE0E9FA),
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
          );
        },
      ),
    );
  }
}
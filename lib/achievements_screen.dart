import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    const background = Color(0xFF0A1C14); // Deep Dark Green
    const gold = Color(0xFFD4AF37); // Premium Gold

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: gold,
        title: const Text('මගේ ජයග්‍රහණ 🏆', style: TextStyle(fontWeight: FontWeight.bold, color: gold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: Text('කරුණාකර ලොග් වන්න', style: TextStyle(color: Colors.white70)))
          : StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: gold));
          }

          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final int points = data != null && data.containsKey('learning_points')
              ? data['learning_points']
              : 0;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Points පෙන්වන කාඩ් එක (Luxury Gold & Dark Green Gradient)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF112A20), Color(0xFF0A1C14)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: gold.withOpacity(0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: gold.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'ඔබේ මුළු ලකුණු',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.stars_rounded, color: gold, size: 40),
                        const SizedBox(width: 10),
                        Text(
                          '$points',
                          style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getLevelName(points),
                      style: const TextStyle(color: gold, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              const Text(
                'ඩිජිටල් පදක්කම් (Badges)',
                style: TextStyle(color: gold, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Badges Grid එක
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: [
                  _buildBadgeCard('ආධුනික ගවේෂක', 'ප්‍රශ්න අසා ඉගෙනීම ආරම්භ කිරීම.', Icons.explore_rounded, gold, points >= 20),
                  _buildBadgeCard('දිනපතා ගවේෂක', 'ලකුණු 100ක් ලබා ගැනීම.', Icons.local_fire_department_rounded, Colors.orangeAccent, points >= 100),
                  _buildBadgeCard('ගණිත ශූරයා', 'ලකුණු 250ක් ලබා ගැනීම.', Icons.calculate_rounded, Colors.lightBlueAccent, points >= 250),
                  _buildBadgeCard('Zingacc රන් තරුව', 'ලකුණු 500ක් ලබා ගැනීම.', Icons.military_tech_rounded, gold, points >= 500),
                  _buildBadgeCard('සුපිරි බුද්ධිමතා', 'ලකුණු 1000ක් ලබා ගැනීම.', Icons.diamond_rounded, Colors.purpleAccent, points >= 1000),
                  _buildBadgeCard('AI මිතුරා', 'ලකුණු 2000ක් ලබා ගැනීම.', Icons.smart_toy_rounded, Colors.cyanAccent, points >= 2000),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String _getLevelName(int points) {
    if (points < 100) return 'ආධුනික (Beginner)';
    if (points < 250) return 'උනන්දුමත් සිසුවා (Learner)';
    if (points < 500) return 'දක්ෂයා (Skilled)';
    if (points < 1000) return 'ශූරයා (Champion)';
    return 'සුපිරි බුද්ධිමතා (Genius)';
  }

  Widget _buildBadgeCard(String title, String desc, IconData icon, Color color, bool isUnlocked) {
    const panel = Color(0xFF112A20);
    const gold = Color(0xFFD4AF37);

    return Container(
      decoration: BoxDecoration(
        color: isUnlocked ? color.withOpacity(0.18) : panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnlocked ? color.withOpacity(0.6) : gold.withOpacity(0.2),
          width: isUnlocked ? 2 : 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUnlocked ? icon : Icons.lock_rounded,
            color: isUnlocked ? color : Colors.white24,
            size: 46,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isUnlocked ? Colors.white : Colors.white54,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isUnlocked ? Colors.white70 : Colors.white30,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
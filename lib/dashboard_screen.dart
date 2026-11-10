import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

import 'ai_tutor_screen.dart';
import 'backend_quota_service.dart';

import 'formula_library_screen.dart';
import 'premium_packages_screen.dart';
import 'firestore_service.dart';

import 'scholarship_practice_screen.dart';
import 'zingacc_brand_banner.dart';
import 'spoken_english_screen.dart';
import 'offline_library_screen.dart';
import 'achievements_screen.dart';
import 'admin_dashboard_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.selectedLevel,
    required this.selectedMedium,
    required this.selectedSubject,
    required this.language,
  });

  final String selectedLevel;
  final String selectedMedium;
  final String selectedSubject;
  final String language;

  bool get _isSinhala => language == 'සිංහල' || language.toLowerCase() == 'sinhala';
  bool get _isTamil => language == 'தமிழ்' || language.toLowerCase() == 'tamil';

  String _t(String sinhala, String english, String tamil) {
    if (_isSinhala) return sinhala;
    if (_isTamil) return tamil;
    return english;
  }

  String get _levelName {
    switch (selectedLevel) {
      case 'grade_5_scholarship': return _t('5 ශ්‍රේණිය ශිෂ්‍යත්වය', 'Grade 5 Scholarship', 'தரம் 5 புலமைப்பரிசில்');
      case 'grade_6': return _t('6 ශ්‍රේණිය', 'Grade 6', 'தரம் 6');
      case 'grade_7': return _t('7 ශ්‍රේණිය', 'Grade 7', 'தரம் 7');
      case 'grade_8': return _t('8 ශ්‍රේණිය', 'Grade 8', 'தரம் 8');
      case 'grade_9': return _t('9 ශ්‍රේණිය', 'Grade 9', 'தரம் 9');
      case 'ol': return _t('සාමාන්‍ය පෙළ', 'O/L', 'சாதாரண தரம்');
      case 'al': return _t('උසස් පෙළ', 'A/L', 'உயர் தரம்');
      default: return _titleCase(selectedLevel.replaceAll('_', ' '));
    }
  }

  String get _mediumName {
    switch (selectedMedium) {
      case 'sinhala': return _t('සිංහල මාධ්‍යය', 'Sinhala Medium', 'சிங்கள மொழிமூலம்');
      case 'english': return _t('ඉංග්‍රීසි මාධ්‍යය', 'English Medium', 'ஆங்கில மொழிமூலம்');
      case 'tamil': return _t('දෙමළ මාධ්‍යය', 'Tamil Medium', 'தமிழ் மொழிமூலம்');
      default: return _titleCase(selectedMedium.replaceAll('_', ' '));
    }
  }

  String get _subjectName {
    switch (selectedSubject) {
      case 'mathematics':
      case 'maths': return _t('ගණිතය', 'Mathematics', 'கணிதம்');
      case 'science': return _t('විද්‍යාව', 'Science', 'விஞ்ஞானம்');
      case 'english': return _t('ඉංග්‍රීසි', 'English', 'ஆங்கிலம்');
      case 'sinhala': return _t('සිංහල', 'Sinhala', 'சிங்களம்');
      case 'tamil': return _t('දෙමළ', 'Tamil', 'தமிழ்');
      case 'history': return _t('ඉතිහාසය', 'History', 'வரலாறு');
      case 'geography': return _t('භූගෝල විද්‍යාව', 'Geography', 'புவியியல்');
      case 'ict': return _t('තොරතුරු හා සන්නිවේදන තාක්ෂණය', 'ICT', 'தகவல் தொடர்பாடல் தொழில்நுட்பம்');
      case 'civics':
      case 'civic_education': return _t('පුරවැසි අධ්‍යාපනය', 'Civic Education', 'குடியியல் கல்வி');
      case 'health':
      case 'health_pe': return _t('සෞඛ්‍ය හා ශාරීරික අධ්‍යාපනය', 'Health & Physical Education', 'சுகாதாரம் மற்றும் உடற்கல்வி');
      case 'art': return _t('චිත්‍ර කලාව', 'Art', 'சித்திரம்');
      case 'music': return _t('සංගීතය', 'Music', 'இசை');
      case 'dancing': return _t('නර්තනය', 'Dancing', 'நடனம்');
      case 'drama': return _t('නාට්‍ය හා රංග කලාව', 'Drama & Theatre', 'நாடகமும் அரங்கியலும்');
      case 'buddhism': return _t('බුද්ධ ධර්මය', 'Buddhism', 'பௌத்தம்');
      case 'hinduism': return _t('හින්දු ධර්මය', 'Hinduism', 'இந்து சமயம்');
      case 'christianity': return _t('ක්‍රිස්තියානි ධර්මය', 'Christianity', 'கிறிஸ்தவம்');
      case 'catholicism': return _t('කතෝලික ධර්මය', 'Catholicism', 'கத்தோலிக்கம்');
      case 'islam': return _t('ඉස්ලාම් ධර්මය', 'Islam', 'இஸ்லாம்');
      case 'commerce': return _t('වාණිජ්‍යය', 'Commerce', 'வணிகம்');
      case 'media': return _t('මාධ්‍ය අධ්‍යයනය', 'Media', 'ஊடகக் கல்வி');
      default: return _titleCase(selectedSubject.replaceAll('_', ' '));
    }
  }

  String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value.split(' ').map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}').join(' ');
  }

  Future<void> _checkAdminAndOpenDashboard(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!context.mounted) return;
      if (doc.exists && doc.data()?['role'] == 'admin') {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ඔබට මෙම අංශයට පිවිසීමට අවසර නැත!')));
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('දෝෂයක් සිදු විය: $e')));
    }
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF112A20), // Dark Green Dialog
        title: Text(_t('ඉවත් වන්නද?', 'Log out?', 'வெளியேற வேண்டுமா?'), style: const TextStyle(color: Color(0xFFD4AF37))), // Gold Title
        content: Text(_t('ඔබගේ ගිණුමෙන් ඉවත් වීමට අවශ්‍යද?', 'Do you want to sign out of your account?', 'உங்கள் கணக்கிலிருந்து வெளியேற விரும்புகிறீர்களா?'), style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(_t('අවලංගු කරන්න', 'Cancel', 'ரத்து செய்'), style: const TextStyle(color: Colors.white70)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF0A1C14)), // Gold Button
            child: Text(_t('ඉවත් වන්න', 'Log out', 'வெளியேறு'), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute<void>(builder: (_) => const LoginScreen()), (route) => false);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t('ඉවත් වීමට නොහැකි වුණා. නැවත උත්සාහ කරන්න.', 'Could not log out. Please try again.', 'வெளியேற முடியவில்லை. மீண்டும் முயற்சிக்கவும்.'))));
    }
  }

  void _openAITutor(BuildContext context) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) => AITutorScreen(selectedLevel: selectedLevel, selectedMedium: selectedMedium, selectedSubject: selectedSubject, language: language)));
  }

  Future<void> _openSpokenEnglish(BuildContext context) async {
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))); // Gold Loader
    final paidRemaining = await FirestoreService.getPaidQuestionsRemaining();
    if (!context.mounted) return;
    Navigator.pop(context);

    if (paidRemaining > 0 || await FirestoreService.hasActiveSubscription(grade: '')) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const SpokenEnglishScreen()));
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF112A20), // Dark Green
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFD4AF37), width: 2)), // Gold Border
          title: Row(
            children: [
              const Icon(Icons.lock_rounded, color: Color(0xFFD4AF37)), // Gold Icon
              const SizedBox(width: 10),
              Text(_t('Premium පහසුකමක්', 'Premium Feature', 'Premium அம்சம்'), style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: Text(
            _t('Spoken English Partner යනු Premium පහසුකමකි. කරුණාකර ප්‍රශ්න 150ක පැකේජයක් සක්‍රිය කර මෙය සම්පූර්ණයෙන්ම නොමිලේ (Unlimited) භාවිතා කරන්න.', 'Spoken English Partner is a premium feature. Please activate a 150-question package to use this completely free (unlimited).', 'Spoken English Partner ஒரு பிரீமியம் அம்சமாகும். இதை முற்றிலும் இலவசமாகப் பயன்படுத்த 150 கேள்விகள் தொகுப்பைச் செயல்படுத்தவும்.'),
            style: const TextStyle(color: Colors.white, height: 1.5),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(_t('පසුව', 'Later', 'பின்னர்'), style: const TextStyle(color: Colors.white70))),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PremiumPackagesScreen()));
              },
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF0A1C14)), // Gold Button
              child: Text(_t('පැකේජ බලන්න', 'View Packages', 'தொகுப்புகளைக் காண்க'), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  void _openFormulaLibrary(BuildContext context) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) => FormulaLibraryScreen(selectedLevel: selectedLevel, selectedSubject: selectedSubject, language: language)));
  }

  void _openScholarshipPractice(BuildContext context) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) => ScholarshipPracticeScreen(language: language)));
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF0A1C14); // 🌟 Luxury Deep Green
    const panel = Color(0xFF112A20); // 🌟 Slightly lighter green for panels
    const gold = Color(0xFFD4AF37); // 🌟 Premium Gold

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: gold,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.asset(
                'assets/zingacc_logo.png',
                width: 34,
                height: 34,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.school_rounded, color: gold, size: 30),
              ),
            ),
            const SizedBox(width: 9),
            const Flexible(
              child: Text(
                'Zingacc Learn AI',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: gold),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(tooltip: 'Admin Dashboard', icon: const Icon(Icons.admin_panel_settings_rounded, color: gold), onPressed: () => _checkAdminAndOpenDashboard(context)),
          IconButton(tooltip: _t('ඉවත් වන්න', 'Log out', 'வெளியேறு'), onPressed: () => _logout(context), icon: const Icon(Icons.logout_rounded, color: Colors.orangeAccent)),
          IconButton(
            tooltip: 'Check AI Balance',
            icon: const Icon(Icons.account_balance_wallet_outlined, color: Colors.greenAccent),
            onPressed: () async {
              try {
                final result = await BackendQuotaService.getBalance();
                if (!context.mounted) return;
                await showDialog<void>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    backgroundColor: panel,
                    title: const Text('AI Quota Balance', style: TextStyle(color: gold)),
                    content: SelectableText(
                      result['unlimited'] == true ? 'ADMIN ACCOUNT\nUnlimited AI Questions' : 'Free Questions: ${result['quota']?['freeRemaining'] ?? 0}\nPaid Coins: ${result['quota']?['paidBalance'] ?? 0}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close', style: TextStyle(color: gold)))],
                  ),
                );
              } catch (error) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Balance check failed: $error')));
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(wide ? 28 : 14, 10, wide ? 28 : 14, 28),
                  children: [
                    const ZingaccBrandBanner(),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: panel,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: gold.withOpacity(0.3)), // Gold subtle border
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('ඔබගේ ඉගෙනුම් තොරතුරු', 'Your Study Details', 'உங்கள் கற்றல் விவரங்கள்'),
                            style: const TextStyle(color: gold, fontSize: 19, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _InfoChip(icon: Icons.school_outlined, text: _levelName),
                              _InfoChip(icon: Icons.language_rounded, text: _mediumName),
                              _InfoChip(icon: Icons.menu_book_rounded, text: _subjectName),
                              _InfoChip(icon: Icons.translate_rounded, text: language),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _t('AI ගුරුවරයාගෙන් අහන්න', 'Ask Your AI Tutor', 'AI ஆசிரியரிடம் கேளுங்கள்'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: gold, fontSize: 23, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _t('ඔබට නොතේරෙන පාඩම් ප්‍රශ්නය අහන්න. පියවරෙන් පියවර පැහැදිලි කිරීමක් ලබාගන්න.', 'Ask about something you find difficult and get a step-by-step explanation.', 'கடினமாக உள்ள பாடக் கேள்வியைக் கேட்டு படிப்படியான விளக்கத்தைப் பெறுங்கள்.'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 18),

                    // 🌟 AI Tutor Main Button (Gold Gradient)
                    Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(22),
                      child: InkWell(
                        onTap: () => _openAITutor(context),
                        borderRadius: BorderRadius.circular(22),
                        child: Ink(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFE5C058), Color(0xFFD4AF37), Color(0xFFB58E29)], // Gold Gradient
                            ),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(color: gold.withOpacity(0.4), blurRadius: 18, offset: const Offset(0, 7)),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(color: const Color(0xFF0A1C14).withOpacity(0.3), borderRadius: BorderRadius.circular(17)),
                                child: const Icon(Icons.smart_toy_rounded, color: Color(0xFF0A1C14), size: 34),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _t('AI ගුරුවරයා අරඹන්න', 'Open AI Tutor', 'AI ஆசிரியரைத் திறக்கவும்'),
                                      style: const TextStyle(color: Color(0xFF0A1C14), fontSize: 18, fontWeight: FontWeight.w900),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      _t('ප්‍රශ්නයක් ලියන්න හෝ පින්තූරයක් යොදන්න', 'Type a question or add a picture', 'கேள்வியை எழுதுங்கள் அல்லது படத்தைச் சேர்க்கவும்'),
                                      style: const TextStyle(color: Color(0xFF0A1C14), fontSize: 13, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_rounded, color: Color(0xFF0A1C14), size: 26),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 🌟 Spoken English Partner (Dark Green Card with Gold Text)
                    _buildOptionCard(
                      context,
                      title: _t('Spoken English Partner', 'Spoken English Partner', 'Spoken English Partner'),
                      subtitle: _t('AI ගුරුවරයා සමඟ කතා කරන්න', 'Speak with the AI Tutor', 'AI ஆசிரியருடன் பேசுங்கள்'),
                      icon: Icons.record_voice_over_rounded,
                      isPro: true,
                      onTap: () => _openSpokenEnglish(context),
                    ),
                    const SizedBox(height: 16),

                    // 🌟 Formula Library
                    _buildOptionCard(
                      context,
                      title: _t('සූත්‍ර හා දැනුම් පුස්තකාලය', 'Formula & Knowledge Library', 'சூத்திரங்கள் மற்றும் அறிவுக் களஞ்சியம்'),
                      subtitle: _t('සූත්‍ර, පැහැදිලි කිරීම් හා උදාහරණ', 'Formulas, explanations and examples', 'சூத்திரங்கள், விளக்கங்கள், எடுத்துக்காட்டுகள்'),
                      icon: Icons.menu_book_rounded,
                      onTap: () => _openFormulaLibrary(context),
                    ),
                    const SizedBox(height: 16),

                    // 🌟 Offline Library
                    _buildOptionCard(
                      context,
                      title: _t('මගේ පාඩම් (Offline)', 'My Lessons (Offline)', 'எனது பாடங்கள் (Offline)'),
                      subtitle: _t('සුරැකි ප්‍රශ්න සහ පිළිතුරු කියවන්න', 'Read saved questions and answers', 'சேமிக்கப்பட்ட கேள்விகள் மற்றும் பதில்களைப் படிக்கவும்'),
                      icon: Icons.bookmark_added_rounded,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OfflineLibraryScreen())),
                    ),
                    const SizedBox(height: 16),

                    // 🌟 Achievements
                    _buildOptionCard(
                      context,
                      title: _t('මගේ ජයග්‍රහණ 🏆', 'My Achievements 🏆', 'எனது வெற்றிகள் 🏆'),
                      subtitle: _t('ඔබේ ලකුණු සහ ඩිජිටල් පදක්කම් බලන්න', 'View your points and badges', 'உங்கள் புள்ளிகள் மற்றும் பதக்கங்களை பார்க்கவும்'),
                      icon: Icons.emoji_events_rounded,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AchievementsScreen())),
                    ),

                    if (selectedLevel == 'grade_5_scholarship') ...[
                      const SizedBox(height: 16),
                      _buildOptionCard(
                        context,
                        title: _t('5 ශ්‍රේණිය ශිෂ්‍යත්ව පුහුණුව', 'Grade 5 Scholarship Practice', 'தரம் 5 புலமைப்பரிசில் பயிற்சி'),
                        subtitle: _t('පුහුණු ප්‍රශ්න සහ පැහැදිලි කිරීම්', 'Practice questions and explanations', 'பயிற்சி வினாக்களும் விளக்கங்களும்'),
                        icon: Icons.school_rounded,
                        onTap: () => _openScholarshipPractice(context),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        _t('Zingacc Learn AI • දැනුමෙන් හෙට දිනමු', 'Zingacc Learn AI • Learn and grow', 'Zingacc Learn AI • கற்று வளர்வோம்'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: gold, fontSize: 12, fontWeight: FontWeight.bold),
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

  // 🌟 Helper method for creating matching Luxury Cards
  Widget _buildOptionCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required VoidCallback onTap, bool isPro = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF112A20), // Dark Green Panel
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5), width: 1.5), // Gold Border
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFFD4AF37), size: 32), // Gold Icon
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                        ),
                        if (isPro) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(4)),
                            child: const Text('PRO', style: TextStyle(color: Color(0xFF0A1C14), fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFD4AF37), size: 18), // Gold Arrow
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 290),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1C14), // Very Dark Green background
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)), // Gold Border
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 15), // Gold Icon
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

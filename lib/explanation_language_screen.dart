import 'package:flutter/material.dart';

import 'zingacc_brand_banner.dart';

/// Lets the learner choose the language for AI explanations.
/// Study medium and explanation language are kept separate.
class ExplanationLanguageScreen extends StatefulWidget {
  const ExplanationLanguageScreen({
    super.key,
    required this.selectedLevel,
    required this.selectedMedium,
    required this.selectedSubject,
    this.onLanguageSelected,
  });

  final String selectedLevel;
  final String selectedMedium;
  final String selectedSubject;
  final ValueChanged<String>? onLanguageSelected;

  @override
  State<ExplanationLanguageScreen> createState() =>
      _ExplanationLanguageScreenState();
}

class _ExplanationLanguageScreenState extends State<ExplanationLanguageScreen> {
  String? _selectedLanguage;

  static const List<ExplanationLanguage> _languages = [
    ExplanationLanguage(
      id: 'sinhala',
      title: 'සිංහල',
      subtitle: 'Explain in Sinhala',
      description: 'Get AI answers and step-by-step explanations in Sinhala.',
      icon: Icons.translate_rounded,
    ),
    ExplanationLanguage(
      id: 'english',
      title: 'English',
      subtitle: 'Explain in English',
      description: 'Get AI answers and step-by-step explanations in English.',
      icon: Icons.language_rounded,
    ),
    ExplanationLanguage(
      id: 'tamil',
      title: 'தமிழ்',
      subtitle: 'Explain in Tamil',
      description: 'Get AI answers and step-by-step explanations in Tamil.',
      icon: Icons.translate_rounded,
    ),
  ];

  bool get _isSinhala => widget.selectedMedium.toLowerCase() == 'sinhala';
  bool get _isTamil => widget.selectedMedium.toLowerCase() == 'tamil';

  String _text({
    required String english,
    required String sinhala,
    required String tamil,
  }) {
    if (_isSinhala) return sinhala;
    if (_isTamil) return tamil;
    return english;
  }

  String get _levelName {
    final grade = switch (widget.selectedLevel) {
      'grade_5_scholarship' => 5,
      'grade_6' => 6,
      'grade_7' => 7,
      'grade_8' => 8,
      'grade_9' => 9,
      _ => null,
    };

    if (grade != null) {
      return _text(
        english: 'Grade $grade',
        sinhala: '$grade ශ්‍රේණිය',
        tamil: '$grade ஆம் வகுப்பு',
      );
    }

    return switch (widget.selectedLevel) {
      'ol' => 'O/L',
      'al' => 'A/L',
      _ => widget.selectedLevel,
    };
  }

  String get _mediumName => switch (widget.selectedMedium.toLowerCase()) {
    'sinhala' => _text(
      english: 'Sinhala Medium',
      sinhala: 'සිංහල මාධ්‍යය',
      tamil: 'சிங்கள மொழிமூலம்',
    ),
    'tamil' => _text(
      english: 'Tamil Medium',
      sinhala: 'දෙමළ මාධ්‍යය',
      tamil: 'தமிழ் மொழிமூலம்',
    ),
    _ => _text(
      english: 'English Medium',
      sinhala: 'ඉංග්‍රීසි මාධ්‍යය',
      tamil: 'ஆங்கில மொழிமூலம்',
    ),
  };

  String get _subjectName {
    const names = <String, String>{
      'scholarship_paper_1': 'Scholarship - Paper I',
      'scholarship_paper_2': 'Scholarship - Paper II',
      'mathematics': 'Mathematics',
      'science': 'Science',
      'english': 'English',
      'sinhala': 'Sinhala',
      'tamil': 'Tamil',
      'first_language': 'First Language',
      'second_language_sinhala': 'Second Language: Sinhala',
      'second_language_tamil': 'Second Language: Tamil',
      'history': 'History',
      'geography': 'Geography',
      'ict': 'ICT',
      'media': 'Media',
      'civic_education': 'Civic Education',
      'civics': 'Civic Education',
      'religion': 'Religion',
      'buddhism': 'Buddhism',
      'hinduism': 'Hinduism / Saivanery',
      'christianity': 'Christianity',
      'catholicism': 'Catholicism',
      'islam': 'Islam',
      'health_pe': 'Health & PE',
      'health': 'Health & Physical Education',
      'practical_technical': 'Practical & Technical',
      'practical_technical_skills': 'Practical & Technical Skills',
      'art': 'Art',
      'music': 'Music',
      'eastern_music': 'Eastern Music',
      'western_music': 'Western Music',
      'dancing': 'Dancing',
      'drama': 'Drama',
      'business_accounting': 'Business & Accounting',
      'entrepreneurship': 'Entrepreneurship',
      'combined_mathematics': 'Combined Mathematics',
      'physics': 'Physics',
      'chemistry': 'Chemistry',
      'biology': 'Biology',
      'agriculture': 'Agricultural Science',
      'accounting': 'Accounting',
      'business_studies': 'Business Studies',
      'economics': 'Economics',
      'business_statistics': 'Business Statistics',
      'political_science': 'Political Science',
      'logic': 'Logic & Scientific Method',
      'engineering_technology': 'Engineering Technology',
      'science_for_technology': 'Science for Technology',
      'bio_systems_technology': 'Biosystems Technology',
    };
    return names[widget.selectedSubject] ?? widget.selectedSubject;
  }

  String _languageSubtitle(String id) => switch (id) {
    'sinhala' => _text(
      english: 'Explain in Sinhala',
      sinhala: 'සිංහලෙන් පැහැදිලි කරන්න',
      tamil: 'சிங்களத்தில் விளக்கவும்',
    ),
    'english' => _text(
      english: 'Explain in English',
      sinhala: 'ඉංග්‍රීසියෙන් පැහැදිලි කරන්න',
      tamil: 'ஆங்கிலத்தில் விளக்கவும்',
    ),
    _ => _text(
      english: 'Explain in Tamil',
      sinhala: 'දෙමළෙන් පැහැදිලි කරන්න',
      tamil: 'தமிழில் விளக்கவும்',
    ),
  };

  String _languageDescription(String id) => switch (id) {
    'sinhala' => _text(
      english: 'Get AI answers and step-by-step explanations in Sinhala.',
      sinhala:
      'AI පිළිතුරු සහ පියවරෙන් පියවර පැහැදිලි කිරීම් සිංහලෙන් ලබාගන්න.',
      tamil:
      'AI பதில்களையும் படிப்படியான விளக்கங்களையும் சிங்களத்தில் பெறுங்கள்.',
    ),
    'english' => _text(
      english: 'Get AI answers and step-by-step explanations in English.',
      sinhala:
      'AI පිළිතුරු සහ පියවරෙන් පියවර පැහැදිලි කිරීම් ඉංග්‍රීසියෙන් ලබාගන්න.',
      tamil:
      'AI பதில்களையும் படிப்படியான விளக்கங்களையும் ஆங்கிலத்தில் பெறுங்கள்.',
    ),
    _ => _text(
      english: 'Get AI answers and step-by-step explanations in Tamil.',
      sinhala:
      'AI පිළිතුරු සහ පියවරෙන් පියවර පැහැදිලි කිරීම් දෙමළෙන් ලබාගන්න.',
      tamil:
      'AI பதில்களையும் படிப்படியான விளக்கங்களையும் தமிழில் பெறுங்கள்.',
    ),
  };

  void _continueToNextStep() {
    final languageId = _selectedLanguage;
    if (languageId == null) return;

    final callback = widget.onLanguageSelected;
    if (callback == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              english:
              'The next page is not connected yet. Your language choice is $languageId.',
              sinhala:
              'ඊළඟ පිටුව තවම සම්බන්ධ කර නැහැ. තෝරාගත් භාෂාව: $languageId.',
              tamil:
              'அடுத்த பக்கம் இன்னும் இணைக்கப்படவில்லை. தேர்ந்தெடுத்த மொழி: $languageId.',
            ),
          ),
        ),
      );
      return;
    }
    callback(languageId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07132F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07132F),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Zingacc Learn AI',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final contentWidth = constraints.maxWidth - 36;
                      final columns = contentWidth >= 900
                          ? 3
                          : contentWidth >= 560
                          ? 2
                          : 1;
                      final cardWidth =
                          (contentWidth - 12 * (columns - 1)) / columns;

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                        children: [
                          const ZingaccBrandBanner(),
                          const SizedBox(height: 22),
                          Wrap(
                            spacing: 9,
                            runSpacing: 9,
                            children: [
                              _InfoChip(
                                icon: Icons.school_rounded,
                                text: _levelName,
                              ),
                              _InfoChip(
                                icon: Icons.menu_book_rounded,
                                text: _mediumName,
                              ),
                              _InfoChip(
                                icon: Icons.auto_stories_rounded,
                                text: _subjectName,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _text(
                              english: 'Choose Explanation Language',
                              sinhala: 'පැහැදිලි කරන භාෂාව තෝරන්න',
                              tamil: 'விளக்க மொழியைத் தேர்ந்தெடுக்கவும்',
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _text(
                              english:
                              'Choose the language for your AI lesson explanations.',
                              sinhala:
                              'AI පාඩම් පැහැදිලි කිරීම් ලබාගන්නා භාෂාව තෝරන්න.',
                              tamil:
                              'AI பாட விளக்கங்களைப் பெற விரும்பும் மொழியைத் தேர்ந்தெடுக்கவும்.',
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFC3D0EA),
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              for (final language in _languages)
                                SizedBox(
                                  width: cardWidth,
                                  child: ExplanationLanguageCard(
                                    language: language,
                                    subtitle: _languageSubtitle(language.id),
                                    description:
                                    _languageDescription(language.id),
                                    selected: _selectedLanguage == language.id,
                                    onTap: () => setState(
                                          () => _selectedLanguage = language.id,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          _StudyMediumNote(
                            text: _text(
                              english:
                              'Study medium and explanation language are separate. For example, you can study Science in English and ask the AI Tutor to explain a difficult lesson in Sinhala or Tamil.',
                              sinhala:
                              'ඉගෙන ගන්නා මාධ්‍යය සහ පැහැදිලි කරන භාෂාව වෙන වෙනම තෝරන්න පුළුවන්. උදාහරණයක් ලෙස, ඉංග්‍රීසි මාධ්‍යයෙන් Science ඉගෙනගෙන අමාරු පාඩමක් සිංහලෙන් හෝ දෙමළෙන් පැහැදිලි කරගන්න පුළුවන්.',
                              tamil:
                              'படிப்பு மொழியும் விளக்க மொழியும் தனித்தனியாகத் தேர்ந்தெடுக்கலாம். உதாரணமாக, ஆங்கிலத்தில் Science படித்துவிட்டு கடினமான பாடத்தைத் தமிழிலோ சிங்களத்திலோ விளக்கச் சொல்லலாம்.',
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _text(
                              english:
                              'You can change the explanation language later.',
                              sinhala:
                              'පසුවත් පැහැදිලි කරන භාෂාව වෙනස් කළ හැකියි.',
                              tamil: 'பின்னரும் விளக்க மொழியை மாற்றலாம்.',
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFC3D0EA),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                  decoration: const BoxDecoration(
                    color: Color(0xFF07132F),
                    border: Border(
                      top: BorderSide(color: Color(0xFF263960)),
                    ),
                  ),
                  child: FilledButton.icon(
                    onPressed:
                    _selectedLanguage == null ? null : _continueToNextStep,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        _text(
                          english: 'Continue to Dashboard',
                          sinhala: 'Dashboard වෙත යන්න',
                          tamil: 'Dashboard-க்கு செல்லவும்',
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF7546D8),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF263451),
                      disabledForegroundColor: const Color(0xFFABBCD8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ExplanationLanguageCard extends StatelessWidget {
  const ExplanationLanguageCard({
    super.key,
    required this.language,
    this.subtitle,
    this.description,
    required this.selected,
    required this.onTap,
  });

  final ExplanationLanguage language;
  final String? subtitle;
  final String? description;
  final bool selected;
  final VoidCallback onTap;

  Color get _accent => switch (language.id) {
    'sinhala' => const Color(0xFFB77AFF),
    'english' => const Color(0xFF55B9FF),
    'tamil' => const Color(0xFF39D5BD),
    _ => const Color(0xFFB77AFF),
  };

  @override
  Widget build(BuildContext context) {
    final displaySubtitle = subtitle ?? language.subtitle;
    final displayDescription = description ?? language.description;

    return Semantics(
      button: true,
      selected: selected,
      label: language.title + '. ' + displaySubtitle,
      child: Material(
        color: selected
            ? _accent.withValues(alpha: 0.18)
            : const Color(0xFF101F43),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selected ? _accent : const Color(0xFF263960),
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        language.icon,
                        color: _accent,
                        size: 28,
                      ),
                    ),
                    Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: selected ? _accent : const Color(0xFF8093B7),
                      size: 26,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  language.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  displaySubtitle,
                  style: TextStyle(
                    color: _accent,
                    fontSize: 15,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  displayDescription,
                  style: const TextStyle(
                    color: Color(0xFFC3D0EA),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StudyMediumNote extends StatelessWidget {
  const _StudyMediumNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14264B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF29436E)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.smart_toy_rounded,
            color: Color(0xFF70CFFF),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFD4E1F7),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF192B55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF365393)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 19, color: const Color(0xFF70CFFF)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(
                color: Color(0xFFE0E9FA),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExplanationLanguage {
  const ExplanationLanguage({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
}

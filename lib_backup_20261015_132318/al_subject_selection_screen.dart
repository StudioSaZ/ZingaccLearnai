import 'package:flutter/material.dart';
import 'zingacc_brand_banner.dart';

/// A/L study-subject picker.
/// This does not validate examination subject combinations.
class ALSubjectSelectionScreen extends StatefulWidget {
  const ALSubjectSelectionScreen({
    super.key,
    required this.selectedMedium,
    required this.selectedStream,
    this.onSubjectSelected,
  });

  final String selectedMedium;
  final String selectedStream;
  final ValueChanged<String>? onSubjectSelected;

  @override
  State<ALSubjectSelectionScreen> createState() =>
      _ALSubjectSelectionScreenState();
}

class _ALSubjectSelectionScreenState extends State<ALSubjectSelectionScreen> {
  String? selectedSubject;

  static const Map<String, List<_ALSubject>> subjectsByStream = {
    'physical_science': [
      _ALSubject(
        'combined_mathematics',
        'Combined Mathematics',
        Icons.calculate_rounded,
      ),
      _ALSubject('physics', 'Physics', Icons.bolt_rounded),
      _ALSubject('chemistry', 'Chemistry', Icons.science_rounded),
      _ALSubject(
        'ict',
        'Information & Communication Technology',
        Icons.computer_rounded,
      ),
    ],
    'biological_science': [
      _ALSubject('biology', 'Biology', Icons.biotech_rounded),
      _ALSubject('chemistry', 'Chemistry', Icons.science_rounded),
      _ALSubject('physics', 'Physics', Icons.bolt_rounded),
      _ALSubject(
        'agriculture',
        'Agricultural Science',
        Icons.grass_rounded,
      ),
    ],
    'commerce': [
      _ALSubject(
        'accounting',
        'Accounting',
        Icons.receipt_long_rounded,
      ),
      _ALSubject(
        'business_studies',
        'Business Studies',
        Icons.business_center_rounded,
      ),
      _ALSubject(
        'economics',
        'Economics',
        Icons.trending_up_rounded,
      ),
      _ALSubject(
        'business_statistics',
        'Business Statistics',
        Icons.bar_chart_rounded,
      ),
      _ALSubject(
        'ict',
        'Information & Communication Technology',
        Icons.computer_rounded,
      ),
    ],
    'arts': [
      _ALSubject('history', 'History', Icons.history_edu_rounded),
      _ALSubject('geography', 'Geography', Icons.public_rounded),
      _ALSubject(
        'political_science',
        'Political Science',
        Icons.account_balance_rounded,
      ),
      _ALSubject(
        'logic',
        'Logic & Scientific Method',
        Icons.psychology_rounded,
      ),
      _ALSubject(
        'media',
        'Communication & Media Studies',
        Icons.perm_media_rounded,
      ),
      _ALSubject(
        'economics',
        'Economics',
        Icons.trending_up_rounded,
      ),
      _ALSubject('sinhala', 'Sinhala', Icons.translate_rounded),
      _ALSubject('tamil', 'Tamil', Icons.translate_rounded),
      _ALSubject('english', 'English', Icons.translate_rounded),
      _ALSubject('buddhism', 'Buddhism', Icons.menu_book_rounded),
      _ALSubject('art', 'Art', Icons.palette_rounded),
      _ALSubject('dancing', 'Dancing', Icons.music_note_rounded),
      _ALSubject('music', 'Music', Icons.library_music_rounded),
      _ALSubject(
        'drama',
        'Drama & Theatre',
        Icons.theater_comedy_rounded,
      ),
    ],
    'engineering_technology': [
      _ALSubject(
        'engineering_technology',
        'Engineering Technology',
        Icons.engineering_rounded,
      ),
      _ALSubject(
        'science_for_technology',
        'Science for Technology',
        Icons.science_rounded,
      ),
      _ALSubject(
        'ict',
        'Information & Communication Technology',
        Icons.computer_rounded,
      ),
    ],
    'biosystems_technology': [
      _ALSubject(
        'bio_systems_technology',
        'Biosystems Technology',
        Icons.eco_rounded,
      ),
      _ALSubject(
        'science_for_technology',
        'Science for Technology',
        Icons.science_rounded,
      ),
      _ALSubject(
        'ict',
        'Information & Communication Technology',
        Icons.computer_rounded,
      ),
    ],
  };

  static const List<Color> _accents = [
    Color(0xFFB77AFF),
    Color(0xFF55B9FF),
    Color(0xFF39D5BD),
    Color(0xFFFF80B5),
    Color(0xFFFFC267),
    Color(0xFF91A2FF),
    Color(0xFF58DBEE),
    Color(0xFFA9DE70),
  ];

  String get streamName {
    switch (widget.selectedStream) {
      case 'physical_science':
        return 'Physical Science';
      case 'biological_science':
        return 'Biological Science';
      case 'commerce':
        return 'Commerce';
      case 'arts':
        return 'Arts';
      case 'engineering_technology':
        return 'Engineering Technology';
      case 'biosystems_technology':
        return 'Biosystems Technology';
      default:
        return 'A/L';
    }
  }

  String get mediumName {
    switch (widget.selectedMedium) {
      case 'sinhala':
        return 'Sinhala Medium';
      case 'tamil':
        return 'Tamil Medium';
      case 'english':
        return 'English Medium';
      default:
        return widget.selectedMedium;
    }
  }

  void continueToLanguage() {
    final subject = selectedSubject;
    if (subject == null) return;
    widget.onSubjectSelected?.call(subject);
  }

  @override
  Widget build(BuildContext context) {
    final subjects =
        subjectsByStream[widget.selectedStream] ?? const <_ALSubject>[];

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
                      final columns = constraints.maxWidth >= 700 ? 2 : 1;
                      final cardWidth =
                          (constraints.maxWidth - 36 - 12 * (columns - 1)) /
                              columns;

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(
                          18,
                          14,
                          18,
                          24,
                        ),
                        children: [
                          const ZingaccBrandBanner(),
                          const SizedBox(height: 22),
                          Wrap(
                            spacing: 9,
                            runSpacing: 9,
                            children: [
                              _chip(
                                'A/L',
                                Icons.school_rounded,
                                const Color(0xFFB77AFF),
                              ),
                              _chip(
                                mediumName,
                                Icons.language_rounded,
                                const Color(0xFF55B9FF),
                              ),
                              _chip(
                                streamName,
                                Icons.account_tree_rounded,
                                const Color(0xFF39D5BD),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Select Your Subject',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'ඉගෙනීමට අවශ්‍ය විෂය තෝරන්න',
                            style: TextStyle(
                              color: Color(0xFFC3D0EA),
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 22),
                          if (subjects.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFF101F43),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFF263960),
                                ),
                              ),
                              child: const Text(
                                'No subjects configured for this stream.',
                                style: TextStyle(
                                  color: Color(0xFFD4E1F7),
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              for (var index = 0;
                              index < subjects.length;
                              index++)
                                SizedBox(
                                  width: cardWidth,
                                  child: _subjectCard(
                                    subjects[index],
                                    _accents[index % _accents.length],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF14264B),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFF29436E),
                              ),
                            ),
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: Color(0xFF70CFFF),
                                  size: 23,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'This list is for choosing ONE subject '
                                        'to study in the app. It does not verify '
                                        'examination subject combinations, '
                                        'school availability, or university '
                                        'admission eligibility.',
                                    style: TextStyle(
                                      color: Color(0xFFD4E1F7),
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    12,
                    18,
                    18,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF07132F),
                    border: Border(
                      top: BorderSide(
                        color: Color(0xFF263960),
                      ),
                    ),
                  ),
                  child: FilledButton(
                    onPressed:
                    selectedSubject == null ? null : continueToLanguage,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF7546D8),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF263451),
                      disabledForegroundColor: const Color(0xFFABBCD8),
                      minimumSize: const Size.fromHeight(54),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_forward_rounded),
                        SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            'Continue to Explanation Language',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
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

  Widget _chip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 19, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
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

  Widget _subjectCard(_ALSubject item, Color accent) {
    final selected = selectedSubject == item.id;

    return Semantics(
      selected: selected,
      child: Material(
        color:
        selected ? accent.withValues(alpha: 0.18) : const Color(0xFF101F43),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(19),
          side: BorderSide(
            color: selected ? accent : const Color(0xFF263960),
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            setState(() {
              selectedSubject = item.id;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    item.icon,
                    color: accent,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      height: 1.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? accent : const Color(0xFF8093B7),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ALSubject {
  const _ALSubject(this.id, this.title, this.icon);

  final String id;
  final String title;
  final IconData icon;
}

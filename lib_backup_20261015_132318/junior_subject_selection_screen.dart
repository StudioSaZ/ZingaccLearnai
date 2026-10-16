import 'package:flutter/material.dart';
import 'zingacc_brand_banner.dart';

/// Grade 6–9 study categories.
/// Subject availability can vary by school and medium.
class JuniorSubjectSelectionScreen extends StatefulWidget {
  const JuniorSubjectSelectionScreen({
    super.key,
    required this.selectedLevel,
    required this.selectedMedium,
    required this.onSubjectSelected,
  });

  final String selectedLevel;
  final String selectedMedium;
  final ValueChanged<String> onSubjectSelected;

  @override
  State<JuniorSubjectSelectionScreen> createState() =>
      _JuniorSubjectSelectionScreenState();
}

class _JuniorSubjectSelectionScreenState
    extends State<JuniorSubjectSelectionScreen> {
  String? _selected;

  static const List<_JuniorSubject> _common = [
    _JuniorSubject(
      'mathematics',
      'Mathematics',
      Icons.calculate_outlined,
    ),
    _JuniorSubject(
      'science',
      'Science',
      Icons.science_outlined,
    ),
    _JuniorSubject(
      'english',
      'English Language',
      Icons.translate_outlined,
    ),
    _JuniorSubject(
      'history',
      'History',
      Icons.history_edu_outlined,
    ),
    _JuniorSubject(
      'geography',
      'Geography',
      Icons.public_outlined,
    ),
    _JuniorSubject(
      'civics',
      'Civic Education',
      Icons.groups_outlined,
    ),
    _JuniorSubject(
      'ict',
      'Information & Communication Technology',
      Icons.computer_outlined,
    ),
    _JuniorSubject(
      'practical_technical_skills',
      'Practical & Technical Skills',
      Icons.handyman_outlined,
    ),
    _JuniorSubject(
      'health',
      'Health & Physical Education',
      Icons.favorite_outline,
    ),
  ];

  static const List<_JuniorSubject> _religions = [
    _JuniorSubject(
      'buddhism',
      'Buddhism',
      Icons.menu_book_outlined,
    ),
    _JuniorSubject(
      'hinduism',
      'Hinduism / Saivanery',
      Icons.menu_book_outlined,
    ),
    _JuniorSubject(
      'christianity',
      'Christianity',
      Icons.menu_book_outlined,
    ),
    _JuniorSubject(
      'catholicism',
      'Catholicism',
      Icons.menu_book_outlined,
    ),
    _JuniorSubject(
      'islam',
      'Islam',
      Icons.menu_book_outlined,
    ),
  ];

  static const List<_JuniorSubject> _aesthetics = [
    _JuniorSubject(
      'art',
      'Art',
      Icons.palette_outlined,
    ),
    _JuniorSubject(
      'dancing',
      'Dancing',
      Icons.music_note_outlined,
    ),
    _JuniorSubject(
      'eastern_music',
      'Eastern Music',
      Icons.library_music_outlined,
    ),
    _JuniorSubject(
      'western_music',
      'Western Music',
      Icons.library_music_outlined,
    ),
    _JuniorSubject(
      'drama',
      'Drama',
      Icons.theater_comedy_outlined,
    ),
  ];

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

  String get _gradeName => 'Grade ${widget.selectedLevel.split('_').last}';

  String get _mediumName {
    switch (widget.selectedMedium) {
      case 'sinhala':
        return 'Sinhala Medium';
      case 'tamil':
        return 'Tamil Medium';
      default:
        return 'English Medium';
    }
  }

  List<_JuniorSubject> get _languages => [
    if (widget.selectedMedium != 'tamil')
      const _JuniorSubject(
        'sinhala',
        'Sinhala Language',
        Icons.translate_outlined,
      ),
    if (widget.selectedMedium != 'sinhala')
      const _JuniorSubject(
        'tamil',
        'Tamil Language',
        Icons.translate_outlined,
      ),
    if (widget.selectedMedium != 'sinhala')
      const _JuniorSubject(
        'second_language_sinhala',
        'Second Language: Sinhala',
        Icons.translate_outlined,
      ),
    if (widget.selectedMedium != 'tamil')
      const _JuniorSubject(
        'second_language_tamil',
        'Second Language: Tamil',
        Icons.translate_outlined,
      ),
  ];

  void _continue() {
    final subject = _selected;
    if (subject != null) {
      widget.onSubjectSelected(subject);
    }
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
                                _gradeName,
                                Icons.school_rounded,
                                const Color(0xFFB77AFF),
                              ),
                              _chip(
                                _mediumName,
                                Icons.language_rounded,
                                const Color(0xFF55B9FF),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Choose Your Subject',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'ඔබට දැන් ඉගෙනීමට අවශ්‍ය විෂය තෝරන්න.',
                            style: TextStyle(
                              color: Color(0xFFC3D0EA),
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                          _section(
                            heading: 'Main Subjects',
                            icon: Icons.school_outlined,
                            color: const Color(0xFF55B9FF),
                            items: [..._languages, ..._common],
                            cardWidth: cardWidth,
                          ),
                          _section(
                            heading: 'Religion (choose the subject you study)',
                            icon: Icons.menu_book_outlined,
                            color: const Color(0xFFFFC267),
                            items: _religions,
                            cardWidth: cardWidth,
                            colorOffset: 4,
                          ),
                          _section(
                            heading: 'Aesthetic Subjects',
                            icon: Icons.palette_outlined,
                            color: const Color(0xFFFF80B5),
                            items: _aesthetics,
                            cardWidth: cardWidth,
                            colorOffset: 3,
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
                    onPressed: _selected == null ? null : _continue,
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

  Widget _section({
    required String heading,
    required IconData icon,
    required Color color,
    required List<_JuniorSubject> items,
    required double cardWidth,
    int colorOffset = 0,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 26),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 23),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                heading,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  height: 1.4,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (var index = 0; index < items.length; index++)
              SizedBox(
                width: cardWidth,
                child: _subjectCard(
                  items[index],
                  _accents[(index + colorOffset) % _accents.length],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _subjectCard(_JuniorSubject subject, Color accent) {
    final selected = _selected == subject.id;

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
              _selected = subject.id;
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
                    subject.icon,
                    color: accent,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    subject.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
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

class _JuniorSubject {
  const _JuniorSubject(this.id, this.title, this.icon);

  final String id;
  final String title;
  final IconData icon;
}

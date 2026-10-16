import 'package:flutter/material.dart';
import 'zingacc_brand_banner.dart';

/// Grade 6-9 use JuniorSubjectSelectionScreen.
/// A/L uses ALStreamSelectionScreen -> ALSubjectSelectionScreen.
class SubjectSelectionScreen extends StatefulWidget {
  const SubjectSelectionScreen({
    super.key,
    required this.selectedLevel,
    required this.selectedMedium,
    this.onSubjectSelected,
  });
  final String selectedLevel;
  final String selectedMedium;
  final ValueChanged<String>? onSubjectSelected;
  @override
  State<SubjectSelectionScreen> createState() => _SubjectSelectionScreenState();
}

class _SubjectSelectionScreenState extends State<SubjectSelectionScreen> {
  String? _selectedSubject;
  static const List<_SubjectItem> _olSubjects = [
    _SubjectItem(
      'mathematics',
      'Mathematics',
      Icons.calculate_rounded,
    ),
    _SubjectItem('science', 'Science', Icons.science_rounded),
    _SubjectItem('english', 'English', Icons.language_rounded),
    _SubjectItem('sinhala', 'Sinhala', Icons.translate_rounded),
    _SubjectItem(
      'history',
      'History',
      Icons.account_balance_rounded,
    ),
    _SubjectItem('ict', 'ICT', Icons.computer_rounded),
    _SubjectItem('media', 'Media', Icons.perm_media_rounded),
    _SubjectItem('geography', 'Geography', Icons.public_rounded),
  ];
  static const List<_SubjectItem> _scholarshipSubjects = [
    _SubjectItem(
      'scholarship_paper_1',
      'Scholarship - Paper I',
      Icons.psychology_alt_rounded,
    ),
    _SubjectItem(
      'scholarship_paper_2',
      'Scholarship - Paper II',
      Icons.menu_book_rounded,
    ),
  ];
  static const List<Color> _cardColors = [
    Color(0xFFB77AFF),
    Color(0xFF39D5BD),
    Color(0xFF55B9FF),
    Color(0xFFFF80B5),
    Color(0xFFFFC267),
    Color(0xFF91A2FF),
    Color(0xFF58DBEE),
    Color(0xFFA9DE70),
  ];
  String _label(String sinhala, String english, String tamil) {
    final medium = widget.selectedMedium.toLowerCase();
    if (medium == 'sinhala' || medium == 'සිංහල') return sinhala;
    if (medium == 'tamil' || medium == 'தமிழ்') return tamil;
    return english;
  }

  String get _levelName {
    switch (widget.selectedLevel) {
      case 'grade_5_scholarship':
        return _label('5 ශ්‍රේණිය ශිෂ්‍යත්වය', 'Grade 5 Scholarship',
            'தரம் 5 புலமைப்பரிசில்');
      case 'grade_6':
        return _label('6 ශ්‍රේණිය', 'Grade 6', 'தரம் 6');
      case 'grade_7':
        return _label('7 ශ්‍රේණිය', 'Grade 7', 'தரம் 7');
      case 'grade_8':
        return _label('8 ශ්‍රේණිය', 'Grade 8', 'தரம் 8');
      case 'grade_9':
        return _label('9 ශ්‍රේණිය', 'Grade 9', 'தரம் 9');
      case 'ol':
        return 'O/L';
      case 'al':
        return 'A/L';
      default:
        return widget.selectedLevel.replaceAll('_', ' ');
    }
  }

  String get _mediumName {
    switch (widget.selectedMedium.toLowerCase()) {
      case 'sinhala':
      case 'සිංහල':
        return _label('සිංහල මාධ්‍යය', 'Sinhala Medium', 'சிங்கள மொழிமூலம்');
      case 'english':
        return _label(
            'ඉංග්‍රීසි මාධ්‍යය', 'English Medium', 'ஆங்கில மொழிமூலம்');
      case 'tamil':
      case 'தமிழ்':
        return _label('දෙමළ මාධ්‍යය', 'Tamil Medium', 'தமிழ் மொழிமூலம்');
      default:
        return widget.selectedMedium.replaceAll('_', ' ');
    }
  }

  String _subjectTitle(_SubjectItem item) {
    switch (item.id) {
      case 'mathematics':
        return _label('ගණිතය', 'Mathematics', 'கணிதம்');
      case 'science':
        return _label('විද්‍යාව', 'Science', 'அறிவியல்');
      case 'english':
        return _label('ඉංග්‍රීසි', 'English', 'ஆங்கிலம்');
      case 'sinhala':
        return _label('සිංහල', 'Sinhala', 'சிங்களம்');
      case 'history':
        return _label('ඉතිහාසය', 'History', 'வரலாறு');
      case 'ict':
        return _label('තොරතුරු හා සන්නිවේදන තාක්ෂණය', 'ICT',
            'தகவல் தொடர்பாடல் தொழில்நுட்பம்');
      case 'media':
        return _label('මාධ්‍ය අධ්‍යයනය', 'Media', 'ஊடகக் கல்வி');
      case 'geography':
        return _label('භූගෝල විද්‍යාව', 'Geography', 'புவியியல்');
      case 'scholarship_paper_1':
        return _label('ශිෂ්‍යත්වය - පළමු ප්‍රශ්න පත්‍රය',
            'Scholarship - Paper I', 'புலமைப்பரிசில் - வினாத்தாள் I');
      case 'scholarship_paper_2':
        return _label('ශිෂ්‍යත්වය - දෙවන ප්‍රශ්න පත්‍රය',
            'Scholarship - Paper II', 'புலமைப்பரிசில் - வினாத்தாள் II');
      default:
        return item.title;
    }
  }

  void _continue() {
    final subject = _selectedSubject;
    final callback = widget.onSubjectSelected;
    if (subject == null || callback == null) return;
    callback(subject);
  }

  @override
  Widget build(BuildContext context) {
    final subjects = widget.selectedLevel == 'grade_5_scholarship'
        ? _scholarshipSubjects
        : _olSubjects;
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
                                _levelName,
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
                          Text(
                            _label(
                              'ඔබේ විෂය තෝරන්න',
                              'Select Your Subject',
                              'உங்கள் பாடத்தைத் தேர்ந்தெடுக்கவும்',
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _label(
                              'ඔබට ඉගෙනීමට අවශ්‍ය විෂය තෝරන්න.',
                              'Choose the subject you want to study.',
                              'நீங்கள் படிக்க விரும்பும் பாடத்தைத் தேர்ந்தெடுக்கவும்.',
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Color(0xFFC3D0EA),
                            ),
                          ),
                          const SizedBox(height: 22),
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
                                    _cardColors[index % _cardColors.length],
                                  ),
                                ),
                            ],
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
                    onPressed: _selectedSubject == null ||
                        widget.onSubjectSelected == null
                        ? null
                        : _continue,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.arrow_forward_rounded),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            _label(
                              'පැහැදිලි කිරීමේ භාෂාව තෝරන්න',
                              'Continue to Explanation Language',
                              'விளக்க மொழியைத் தேர்ந்தெடுக்க தொடரவும்',
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
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

  Widget _subjectCard(_SubjectItem item, Color accent) {
    final selected = _selectedSubject == item.id;
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
              _selectedSubject = item.id;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    item.icon,
                    color: accent,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    _subjectTitle(item),
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.4,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? accent : const Color(0xFF8093B7),
                  size: 25,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubjectItem {
  const _SubjectItem(this.id, this.title, this.icon);
  final String id;
  final String title;
  final IconData icon;
}

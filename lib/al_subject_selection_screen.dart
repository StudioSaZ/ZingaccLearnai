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
      _ALSubject('combined_mathematics', 'Combined Mathematics', Icons.calculate_rounded),
      _ALSubject('physics', 'Physics', Icons.bolt_rounded),
      _ALSubject('chemistry', 'Chemistry', Icons.science_rounded),
      _ALSubject('ict', 'Information & Communication Technology', Icons.computer_rounded),
    ],
    'biological_science': [
      _ALSubject('biology', 'Biology', Icons.biotech_rounded),
      _ALSubject('chemistry', 'Chemistry', Icons.science_rounded),
      _ALSubject('physics', 'Physics', Icons.bolt_rounded),
      _ALSubject('agriculture', 'Agricultural Science', Icons.grass_rounded),
    ],
    'commerce': [
      _ALSubject('accounting', 'Accounting', Icons.receipt_long_rounded),
      _ALSubject('business_studies', 'Business Studies', Icons.business_center_rounded),
      _ALSubject('economics', 'Economics', Icons.trending_up_rounded),
      _ALSubject('business_statistics', 'Business Statistics', Icons.bar_chart_rounded),
      _ALSubject('ict', 'Information & Communication Technology', Icons.computer_rounded),
    ],
    'arts': [
      _ALSubject('history', 'History', Icons.history_edu_rounded),
      _ALSubject('geography', 'Geography', Icons.public_rounded),
      _ALSubject('political_science', 'Political Science', Icons.account_balance_rounded),
      _ALSubject('logic', 'Logic & Scientific Method', Icons.psychology_rounded),
      _ALSubject('media', 'Communication & Media Studies', Icons.perm_media_rounded),
      _ALSubject('economics', 'Economics', Icons.trending_up_rounded),
      _ALSubject('sinhala', 'Sinhala', Icons.translate_rounded),
      _ALSubject('tamil', 'Tamil', Icons.translate_rounded),
      _ALSubject('english', 'English', Icons.translate_rounded),
      _ALSubject('buddhism', 'Buddhism', Icons.menu_book_rounded),
      _ALSubject('art', 'Art', Icons.palette_rounded),
      _ALSubject('dancing', 'Dancing', Icons.music_note_rounded),
      _ALSubject('music', 'Music', Icons.library_music_rounded),
      _ALSubject('drama', 'Drama & Theatre', Icons.theater_comedy_rounded),
    ],
    'engineering_technology': [
      _ALSubject('engineering_technology', 'Engineering Technology', Icons.engineering_rounded),
      _ALSubject('science_for_technology', 'Science for Technology', Icons.science_rounded),
      _ALSubject('ict', 'Information & Communication Technology', Icons.computer_rounded),
    ],
    'biosystems_technology': [
      _ALSubject('bio_systems_technology', 'Biosystems Technology', Icons.eco_rounded),
      _ALSubject('science_for_technology', 'Science for Technology', Icons.science_rounded),
      _ALSubject('ict', 'Information & Communication Technology', Icons.computer_rounded),
    ],
  };

  static const Color _gold = Color(0xFFD4AF37); // Premium Gold

  String _label(String sinhala, String english, String tamil) {
    final medium = widget.selectedMedium.toLowerCase();
    if (medium == 'sinhala' || medium == 'සිංහල') return sinhala;
    if (medium == 'tamil' || medium == 'தமிழ்') return tamil;
    return english;
  }

  String get streamName {
    switch (widget.selectedStream) {
      case 'physical_science':
        return _label('භෞතික විද්‍යා (Maths)', 'Physical Science', 'பௌதிக விஞ்ஞானம் (Maths)');
      case 'biological_science':
        return _label('ජීව විද්‍යා (Bio)', 'Biological Science', 'உயிர் விஞ்ஞானம் (Bio)');
      case 'commerce':
        return _label('වාණිජ (Commerce)', 'Commerce', 'வர்த்தகம்');
      case 'arts':
        return _label('කලා (Arts)', 'Arts', 'கலை');
      case 'engineering_technology':
        return _label('ඉංජිනේරු තාක්ෂණවේදය (ET)', 'Engineering Technology', 'பொறியியல் தொழில்நுட்பம் (ET)');
      case 'biosystems_technology':
        return _label('ජෛව පද්ධති තාක්ෂණවේදය (BST)', 'Biosystems Technology', 'உயிர் முறைமைகள் தொழில்நுட்பம் (BST)');
      default:
        return 'A/L';
    }
  }

  String get mediumName {
    switch (widget.selectedMedium.toLowerCase()) {
      case 'sinhala':
      case 'සිංහල':
        return _label('සිංහල මාධ්‍යය', 'Sinhala Medium', 'சிங்கள மொழிமூலம்');
      case 'tamil':
      case 'தமிழ்':
        return _label('දෙමළ මාධ්‍යය', 'Tamil Medium', 'தமிழ் மொழிமூலம்');
      case 'english':
        return _label('ඉංග්‍රීසි මාධ්‍යය', 'English Medium', 'ஆங்கில மொழிமூலம்');
      default:
        return widget.selectedMedium;
    }
  }

  String _subjectTitle(String id, String fallback) {
    switch(id) {
      case 'combined_mathematics': return _label('සංයුක්ත ගණිතය', 'Combined Mathematics', 'இணைந்த கணிதம்');
      case 'physics': return _label('භෞතික විද්‍යාව', 'Physics', 'பௌதிகவியல்');
      case 'chemistry': return _label('රසායන විද්‍යාව', 'Chemistry', 'இரசாயனவியல்');
      case 'ict': return _label('තොරතුරු හා සන්නිවේදන තාක්ෂණය', 'ICT', 'தகவல் தொடர்பாடல் தொழில்நுட்பம்');
      case 'biology': return _label('ජීව විද්‍යාව', 'Biology', 'உயிரியல்');
      case 'agriculture': return _label('කෘෂිකර්ම විද්‍යාව', 'Agricultural Science', 'விவசாய விஞ்ஞானம்');
      case 'accounting': return _label('ගිණුම්කරණය', 'Accounting', 'கணக்கியல்');
      case 'business_studies': return _label('ව්‍යාපාර අධ්‍යයනය', 'Business Studies', 'வணிகக் கல்வி');
      case 'economics': return _label('ආර්ථික විද්‍යාව', 'Economics', 'பொருளியல்');
      case 'business_statistics': return _label('ව්‍යාපාර සංඛ්‍යානය', 'Business Statistics', 'வணிகப் புள்ளியியல்');
      case 'history': return _label('ඉතිහාසය', 'History', 'வரலாறு');
      case 'geography': return _label('භූගෝල විද්‍යාව', 'Geography', 'புவியியல்');
      case 'political_science': return _label('දේශපාලන විද්‍යාව', 'Political Science', 'அரசியல் விஞ்ஞானம்');
      case 'logic': return _label('තර්ක ශාස්ත්‍රය හා විද්‍යාත්මක ක්‍රමය', 'Logic & Scientific Method', 'அளவையியலும் விஞ்ஞான முறையும்');
      case 'media': return _label('සන්නිවේදනය හා මාධ්‍ය අධ්‍යයනය', 'Communication & Media Studies', 'தொடர்பாடலும் ஊடகக் கல்வியும்');
      case 'sinhala': return _label('සිංහල', 'Sinhala', 'சிங்களம்');
      case 'tamil': return _label('දෙමළ', 'Tamil', 'தமிழ்');
      case 'english': return _label('ඉංග්‍රීසි', 'English', 'ஆங்கிலம்');
      case 'buddhism': return _label('බෞද්ධ ධර්මය', 'Buddhism', 'பௌத்தம்');
      case 'art': return _label('චිත්‍ර කලාව', 'Art', 'சித்திரம்');
      case 'dancing': return _label('නර්තනය', 'Dancing', 'நடனம்');
      case 'music': return _label('සංගීතය', 'Music', 'சங்கீதம்');
      case 'drama': return _label('නාට්‍ය හා රංග කලාව', 'Drama & Theatre', 'நாடகம் மற்றும் அரங்கியல்');
      case 'engineering_technology': return _label('ඉංජිනේරු තාක්ෂණවේදය', 'Engineering Technology', 'பொறியியல் தொழில்நுட்பம்');
      case 'science_for_technology': return _label('තාක්ෂණවේදය සඳහා විද්‍යාව', 'Science for Technology', 'தொழில்நுட்பத்திற்கான விஞ்ஞானம்');
      case 'bio_systems_technology': return _label('ජෛව පද්ධති තාක්ෂණවේදය', 'Biosystems Technology', 'உயிர் முறைமைகள் தொழில்நுட்பம்');
      default: return fallback;
    }
  }

  void continueToLanguage() {
    final subject = selectedSubject;
    if (subject == null) return;
    widget.onSubjectSelected?.call(subject);
  }

  @override
  Widget build(BuildContext context) {
    final subjects = subjectsByStream[widget.selectedStream] ?? const <_ALSubject>[];

    const background = Color(0xFF0A1C14); // Deep Dark Green
    const panel = Color(0xFF112A20); // Dark Green Panel

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: _gold,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Zingacc Learn AI',
          style: TextStyle(fontWeight: FontWeight.w800, color: _gold),
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
                      // මෙතන කැඩිලා තිබුණු ගුණ කිරීමේ ලකුණ (*) නිවැරදි කරලා තියෙනවා
                      final cardWidth = (constraints.maxWidth - 36 - 12 * (columns - 1)) / columns;

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                        children: [
                          const ZingaccBrandBanner(),
                          const SizedBox(height: 22),
                          Wrap(
                            spacing: 9,
                            runSpacing: 9,
                            children: [
                              _chip('A/L', Icons.school_rounded, _gold),
                              _chip(mediumName, Icons.language_rounded, _gold),
                              _chip(streamName, Icons.account_tree_rounded, _gold),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _label('ඔබේ විෂය තෝරන්න', 'Select Your Subject', 'உங்கள் பாடத்தைத் தேர்ந்தெடுக்கவும்'),
                            style: const TextStyle(
                              color: _gold,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _label(
                              'ඉගෙනීමට අවශ්‍ය විෂය තෝරන්න.',
                              'Choose the subject you want to study.',
                              'நீங்கள் படிக்க விரும்பும் பாடத்தைத் தேர்ந்தெடுக்கவும்.',
                            ),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 22),
                          if (subjects.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: panel,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: _gold.withOpacity(0.4)),
                              ),
                              child: Text(
                                _label(
                                  'මෙම ධාරාව සඳහා විෂයයන් නොමැත.',
                                  'No subjects configured for this stream.',
                                  'இந்தத் துறைக்கு பாடங்கள் கட்டமைக்கப்படவில்லை.',
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              for (var index = 0; index < subjects.length; index++)
                                SizedBox(
                                  width: cardWidth,
                                  child: _subjectCard(
                                    subjects[index],
                                    _gold,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: panel,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: _gold.withOpacity(0.4)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_outline_rounded, color: _gold, size: 23),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _label(
                                      'මෙය ඔබගේ පහසුව සඳහා විෂයයන් තෝරාගැනීමට පමණක් සකස් කර ඇත. විභාග සඳහා විෂය සංයෝජන නිවැරදිදැයි ඔබ විසින් තහවුරු කරගත යුතුය.',
                                      'This list is for choosing ONE subject to study in the app. It does not verify examination subject combinations.',
                                      'இந்தப் பட்டியல் பயன்பாட்டில் படிப்பதற்கு ஒரு பாடத்தைத் தேர்ந்தெடுப்பதற்கானது. இது பரீட்சை பாட சேர்க்கைகளை சரிபார்க்காது.',
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white70,
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
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                  decoration: BoxDecoration(
                    color: background,
                    border: Border(top: BorderSide(color: _gold.withOpacity(0.3))),
                  ),
                  child: FilledButton(
                    onPressed: selectedSubject == null ? null : continueToLanguage,
                    style: FilledButton.styleFrom(
                      backgroundColor: _gold,
                      foregroundColor: background,
                      disabledBackgroundColor: panel,
                      disabledForegroundColor: Colors.white54,
                      minimumSize: const Size.fromHeight(54),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF112A20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
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
                color: Colors.white,
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
        color: selected ? accent.withOpacity(0.22) : const Color(0xFF112A20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(19),
          side: BorderSide(
            color: selected ? accent : accent.withOpacity(0.3),
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
                    color: accent.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(item.icon, color: accent, size: 25),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _subjectTitle(item.id, item.title),
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
                  selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: selected ? accent : Colors.white54,
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
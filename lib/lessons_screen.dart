import 'package:flutter/material.dart';
import 'lesson_learning_screen.dart';
import 'zingacc_brand_banner.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({
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
  bool get isSinhala => language == 'සිංහල';
  bool get isTamil => language == 'தமிழ்';
  String t(String si, String en, String ta) {
    if (isSinhala) return si;
    if (isTamil) return ta;
    return en;
  }

  String get levelName {
    switch (selectedLevel) {
      case 'grade_5_scholarship':
        return t(
          '5 ශ්‍රේණිය ශිෂ්‍යත්වය',
          'Grade 5 Scholarship',
          'தரம் 5 புலமைப்பரிசில்',
        );
      case 'grade_6':
        return t('6 ශ්‍රේණිය', 'Grade 6', 'தரம் 6');
      case 'grade_7':
        return t('7 ශ්‍රේණිය', 'Grade 7', 'தரம் 7');
      case 'grade_8':
        return t('8 ශ්‍රේණිය', 'Grade 8', 'தரம் 8');
      case 'grade_9':
        return t('9 ශ්‍රේණිය', 'Grade 9', 'தரம் 9');
      case 'ol':
        return t('සාමාන්‍ය පෙළ', 'O/L', 'சாதாரண தரம்');
      case 'al':
        return t('උසස් පෙළ', 'A/L', 'உயர் தரம்');
      default:
        return selectedLevel;
    }
  }

  String get mediumName {
    switch (selectedMedium) {
      case 'sinhala':
        return t(
          'සිංහල මාධ්‍යය',
          'Sinhala Medium',
          'சிங்கள மொழிமூலம்',
        );
      case 'tamil':
        return t(
          'දෙමළ මාධ්‍යය',
          'Tamil Medium',
          'தமிழ் மொழிமூலம்',
        );
      case 'english':
        return t(
          'ඉංග්‍රීසි මාධ්‍යය',
          'English Medium',
          'ஆங்கில மொழிமூலம்',
        );
      default:
        return selectedMedium;
    }
  }

  String get subjectName {
    if (selectedSubject == 'scholarship_paper_1') {
      return t(
        'ශිෂ්‍යත්වය — පළමු ප්‍රශ්න පත්‍රය',
        'Scholarship Paper 1',
        'புலமைப்பரிசில் — முதலாம் வினாத்தாள்',
      );
    }
    if (selectedSubject == 'scholarship_paper_2') {
      return t(
        'ශිෂ්‍යත්වය — දෙවන ප්‍රශ්න පත්‍රය',
        'Scholarship Paper 2',
        'புலமைப்பரிசில் — இரண்டாம் வினாத்தாள்',
      );
    }
    const names = <String, String>{
      'mathematics': 'Mathematics',
      'science': 'Science',
      'english': 'English Language',
      'first_language': 'First Language',
      'media': 'Media',
      'civic_education': 'Civic Education',
      'health_pe': 'Health & Physical Education',
      'practical_technical': 'Practical & Technical Skills',
      'business_accounting': 'Business & Accounting',
      'entrepreneurship': 'Entrepreneurship',
      'political_science': 'Political Science',
      'logic': 'Logic & Scientific Method',
      'sinhala': 'Sinhala Language',
      'tamil': 'Tamil Language',
      'history': 'History',
      'geography': 'Geography',
      'civics': 'Civic Education',
      'ict': 'Information & Communication Technology',
      'practical_technical_skills': 'Practical & Technical Skills',
      'health': 'Health & Physical Education',
      'buddhism': 'Buddhism',
      'hinduism': 'Saivanery / Hinduism',
      'christianity': 'Christianity',
      'catholicism': 'Catholicism',
      'islam': 'Islam',
      'art': 'Art',
      'dancing': 'Dancing',
      'eastern_music': 'Eastern Music',
      'western_music': 'Western Music',
      'drama': 'Drama & Theatre',
      'combined_mathematics': 'Combined Mathematics',
      'physics': 'Physics',
      'chemistry': 'Chemistry',
      'biology': 'Biology',
      'accounting': 'Accounting',
      'business_studies': 'Business Studies',
      'economics': 'Economics',
      'engineering_technology': 'Engineering Technology',
      'bio_systems_technology': 'Biosystems Technology',
      'science_for_technology': 'Science for Technology',
    };
    return names[selectedSubject] ?? selectedSubject;
  }

  // Existing Mathematics lesson lists preserved.
  static const Map<String, List<String>> _mathematicsLessons = {
    // Grade 6 core Modules 1–3 followed by NIE's further-learning module.
    'grade_6': [
      'Place Value',
      'Numbers and Mathematical Operations',
      'Number Line',
      'Angles',
      'Time',
      'Estimation and Rounding Off',
      'Factors and Multiples',
      'Types of Numbers and Number Patterns',
      'Let Us Play with Numbers (Further Learning)',
    ],
    'grade_7': [
      'Bilateral Symmetry',
      'Sets',
      'Mathematical Operations on Whole Numbers',
      'Factors and Multiples',
      'Indices',
      'Time',
      'Parallel Straight Lines',
      'Directed Numbers',
      'Angles',
      'Fractions',
      'Decimals',
      'Algebraic Expressions',
      'Mass',
      'Rectilinear Plane Figures',
      'Equations and Formulae',
      'Length',
      'Area',
      'Circles',
      'Volume',
      'Liquid Measurements',
      'Ratios',
      'Percentages',
      'Cartesian Plane',
      'Construction of Plane Figures',
      'Solids',
      'Data Representation and Interpretation',
      'Scale Diagrams',
      'Tessellation',
      'Likelihood of an Event',
    ],
    'grade_8': [
      'Number Patterns',
      'Perimeter',
      'Angles',
      'Directed Numbers',
      'Algebraic Expressions',
      'Solids',
      'Factors',
      'Square Root',
      'Mass',
      'Indices',
      'Symmetry',
      'Triangles',
      'Fractions - I',
      'Fractions - II',
      'Decimals',
      'Ratios',
      'Equations',
      'Percentages',
      'Sets',
      'Area',
      'Time',
      'Volume and Capacity',
      'Circle',
      'Location of a Place',
      'Number Line and Cartesian Plane',
      'Triangle Constructions',
      'Data Representation and Interpretation',
      'Scale Drawings',
      'Probability',
      'Tessellation',
    ],
    'grade_9': [
      'Rounding Off and Scientific Notation',
      'Number Base Two',
      'Number Patterns',
      'Fractions',
      'Percentages',
      'Algebraic Expressions',
      'Factors of Algebraic Expressions',
      'Angles Related to Straight Lines and Parallel Lines',
      'Liquid Measurements',
      'Direct Proportion',
      'Calculator',
      'Indices',
      'Loci and Constructions',
      'Equations',
      'Axioms',
      'Angles of a Triangle',
      'Formulae',
      'Circumference of a Circle',
      'Pythagoras Relationship',
      'Graphs',
      'Inequalities',
      'Sets',
      'Area',
      'Probability',
      'Angles of Polygons',
      'Algebraic Fractions',
      'Scale Drawings',
      'Data Representation and Prediction',
    ],
  };
  // Existing Science lesson lists preserved.
  static const Map<String, List<String>> _scienceLessons = {
    'grade_6': [
      'Wonders of the Living World',
      'Things Around Us',
      'Water as a Natural Resource',
      'Energy in Day to Day Life',
      'Light and Vision',
      'Sound and Hearing',
      'Magnets',
      'Electricity for a Comfortable Life',
      'Heat and Its Effects',
      'Food Related Interactions',
      'Climatic Changes',
    ],
    'grade_7': [
      'Plant Diversity',
      'Static Electricity',
      'Generation of Electricity',
      'Functions of Water',
      'Acids and Bases',
      'Animal Diversity',
      'Forms of Energy and Uses',
      'The Nature of the Earth',
      'Light',
      'The Correct Use of the Microscope',
      'Sound',
      'Biological Processes',
      'Atmosphere',
      'Heat and Temperature',
      'Soil',
      'Force and Motion',
      'Nutrients in Food',
      'Minerals and Rocks',
      'Sources of Energy',
    ],
    'grade_8': [
      'Importance of Microorganisms',
      'Animal Classification',
      'Diversity and Functions of Plant Parts',
      'Properties of Matter',
      'Sound',
      'Magnets',
      'Measurements Associated with Electricity',
      'Changes in Matter',
      'Human Organ Systems',
      'Electricity',
      'Main Biological Processes in Plants',
      'Life Cycles of Living Organisms',
      'Food Preservation',
      'Phenomena and Exploration Associated with Solar System',
      'Natural Disasters',
    ],
    'grade_9': [
      'Applications of Micro-organisms',
      'Eye and Ear',
      'Nature and Properties of Matter',
      'Basic Concepts Associated with Force',
      'Pressure Exerted by Solid',
      'The Human Circulatory System',
      'Plant Growth Substances',
      'Support and Movements of Organisms',
      'The Evolutionary Process',
      'Electrolysis',
      'Density',
      'Bio-diversity',
      'Artificial Environment and Green Concept',
      'Reflection and Refraction of Waves',
      'Simple Machines',
      'Nanotechnology and its Applications',
      'Lightning Accidents',
      'Natural Disasters',
      'Sustainable Use of Natural Resources',
    ],
  };
  List<String> get lessons {
    if (selectedSubject == 'mathematics') {
      return _mathematicsLessons[selectedLevel] ?? const [];
    }
    if (selectedSubject == 'science') {
      return _scienceLessons[selectedLevel] ?? const [];
    }
    return const [];
  }

  void _openLesson(BuildContext context, String lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonLearningScreen(
          selectedLevel: selectedLevel,
          selectedMedium: selectedMedium,
          selectedSubject: selectedSubject,
          language: language,
          lessonTitle: lesson,
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE3EEFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFCADCFF),
        ),
      ),
      child: Text(
        text,
        softWrap: true,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF1746A2),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _emptyLessonsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFD9DFFF),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x106C4DBA),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EBFF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.pending_actions_rounded,
              size: 38,
              color: Color(0xFF7546D8),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            t(
              'පාඩම් ලැයිස්තුව සත්‍යාපනය කරමින් පවතී',
              'Lesson list verification in progress',
              'பாடப் பட்டியல் சரிபார்க்கப்படுகிறது',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF20283A),
              fontSize: 17,
              fontWeight: FontWeight.w800,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            t(
              'නිල NIE / අධ්‍යාපන අමාත්‍යාංශ මූලාශ්‍රයෙන් සත්‍යාපනය කළ පසු මේ විෂයේ පාඩම් එක් කරමු.',
              'Lessons for this subject will be added after verification against official NIE / Ministry of Education sources.',
              'அதிகாரப்பூர்வ NIE / கல்வி அமைச்சு ஆதாரங்களுடன் சரிபார்த்த பிறகு இந்தப் பாடத்திற்கான பாடங்கள் சேர்க்கப்படும்.',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF536078),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  String _grade6ModuleName(int index) {
    if (index < 3) {
      return t('මොඩියුලය 1 • සංඛ්‍යා I', 'Module 1 • Number I',
          'தொகுதி 1 • எண்கள் I');
    }
    if (index < 5) {
      return t(
          'මොඩියුලය 2 • ජ්‍යාමිතිය හා මිනුම්',
          'Module 2 • Geometry and Measurement',
          'தொகுதி 2 • வடிவியலும் அளவீடும்');
    }
    return t('මොඩියුලය 3 • සංඛ්‍යා II', 'Module 3 • Number II',
        'தொகுதி 3 • எண்கள் II');
  }

  Widget _lessonCard(
      BuildContext context,
      String lesson,
      int index,
      ) {
    final courseContext = selectedLevel == 'grade_6' &&
        selectedSubject == 'mathematics' &&
        index < 8
        ? '${_grade6ModuleName(index)} • $levelName • $subjectName'
        : '$levelName • $subjectName';
    const accents = [
      Color(0xFF7546D8),
      Color(0xFF1769D8),
      Color(0xFF008A91),
      Color(0xFFC24179),
    ];
    const backgrounds = [
      Color(0xFFF0EBFF),
      Color(0xFFE8F1FF),
      Color(0xFFE2F7F5),
      Color(0xFFFFEAF2),
    ];
    final accent = accents[index % accents.length];
    final background = backgrounds[index % backgrounds.length];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openLesson(context, lesson),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFDDE5F5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: accent,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson,
                        style: const TextStyle(
                          color: Color(0xFF20283A),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        courseContext,
                        style: const TextStyle(
                          color: Color(0xFF536078),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  color: accent,
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = lessons;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text(t('පාඩම්', 'Lessons', 'பாடங்கள்')),
        backgroundColor: const Color(0xFF07132F),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          children: [
            const ZingaccBrandBanner(),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip(levelName),
                _chip(mediumName),
                _chip(subjectName),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              subjectName,
              style: const TextStyle(
                color: Color(0xFF20283A),
                fontSize: 23,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t(
                'පාඩමක් තෝරාගෙන ඉගෙනීම ආරම්භ කරන්න.',
                'Choose a lesson to start learning.',
                'கற்றலைத் தொடங்க ஒரு பாடத்தைத் தேர்ந்தெடுக்கவும்.',
              ),
              style: const TextStyle(
                color: Color(0xFF536078),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            if (items.isEmpty)
              _emptyLessonsCard()
            else
              ...List.generate(
                items.length,
                    (index) => _lessonCard(
                  context,
                  items[index],
                  index,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

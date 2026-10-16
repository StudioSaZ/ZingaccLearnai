import 'package:flutter/material.dart';
import 'ai_tutor_screen.dart';
import 'zingacc_brand_banner.dart';

/// Grade 6 Mathematics lessons from NIE Modules 1–3 and number enrichment.
/// AI Tutor accuracy and verification code are not changed here.
class LessonLearningScreen extends StatefulWidget {
  const LessonLearningScreen({
    super.key,
    required this.selectedLevel,
    required this.selectedMedium,
    required this.selectedSubject,
    required this.language,
    required this.lessonTitle,
  });

  final String selectedLevel;
  final String selectedMedium;
  final String selectedSubject;
  final String language;
  final String lessonTitle;

  @override
  State<LessonLearningScreen> createState() => _LessonLearningScreenState();
}

class _LessonLearningScreenState extends State<LessonLearningScreen> {
  int _step = 0;
  bool _quizSubmitted = false;
  late List<int?> _answers;

  bool get _isSinhala =>
      widget.language == 'සිංහල' || widget.language.toLowerCase() == 'sinhala';
  bool get _isTamil =>
      widget.language == 'தமிழ்' || widget.language.toLowerCase() == 'tamil';

  String _text(_Copy copy) => copy.pick(_isSinhala, _isTamil);

  _LessonPack? get _pack {
    for (final lesson in _grade6Lessons) {
      if (lesson.title.en == widget.lessonTitle) return lesson;
    }
    return null;
  }

  bool get _isSupported =>
      widget.selectedLevel == 'grade_6' &&
          (widget.selectedSubject == 'mathematics' ||
              widget.selectedSubject == 'maths' ||
              widget.selectedSubject == 'ගණිතය') &&
          _pack != null;

  String get _displayTitle =>
      _isSupported ? _text(_pack!.title) : widget.lessonTitle;

  String get _displayLevel {
    switch (widget.selectedLevel) {
      case 'grade_6':
        return _text(const _Copy('6 ශ්‍රේණිය', 'Grade 6', 'தரம் 6'));
      case 'grade_7':
        return _text(const _Copy('7 ශ්‍රේණිය', 'Grade 7', 'தரம் 7'));
      case 'grade_8':
        return _text(const _Copy('8 ශ්‍රේණිය', 'Grade 8', 'தரம் 8'));
      case 'grade_9':
        return _text(const _Copy('9 ශ්‍රේණිය', 'Grade 9', 'தரம் 9'));
      default:
        return widget.selectedLevel.replaceAll('_', ' ');
    }
  }

  String get _displaySubject => _text(
    const _Copy('ගණිතය', 'Mathematics', 'கணிதம்'),
  );

  List<String> get _stepNames => [
    _text(const _Copy('ඉගෙනීම', 'Learn', 'கற்றல்')),
    _text(const _Copy('උදාහරණ', 'Examples', 'உதாரணங்கள்')),
    _text(const _Copy('AI පැහැදිලි කිරීම', 'Ask AI', 'AI விளக்கம்')),
    _text(const _Copy('පුහුණුව', 'Practice', 'பயிற்சி')),
    _text(const _Copy('ප්‍රශ්නාවලිය', 'Quiz', 'வினாடி வினா')),
  ];

  static const List<Color> _stepColors = [
    Color(0xFF7546D8),
    Color(0xFF1769D8),
    Color(0xFF008A91),
    Color(0xFFC24179),
    Color(0xFFAD6200),
  ];

  Color get _accent => _stepColors[_step];

  @override
  void initState() {
    super.initState();
    _answers = List<int?>.filled(_pack?.quiz.length ?? 0, null);
  }

  void _openAI() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => AITutorScreen(
          selectedLevel: widget.selectedLevel,
          selectedMedium: widget.selectedMedium,
          selectedSubject: widget.selectedSubject,
          language: widget.language,
        ),
      ),
    );
  }

  void _next() {
    if (_step < 4) setState(() => _step++);
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDDE5F5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1007132F),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _heading(String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: _accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Color(0xFF20283A),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _textList(List<_Copy> items,
      {IconData icon = Icons.check_circle_rounded}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Icon(icon, size: 19, color: _accent),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _text(item),
                    style: const TextStyle(
                      color: Color(0xFF34425B),
                      fontSize: 15,
                      height: 1.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _learn() {
    final lesson = _pack!;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(
            _text(const _Copy(
                'අද ඉගෙනගන්නේ', 'What you will learn', 'இன்று கற்பது')),
            Icons.menu_book_rounded,
          ),
          const SizedBox(height: 18),
          _textList(lesson.learn),
          const Divider(height: 28),
          Text(
            _text(
                const _Copy('මතක තබාගන්න', 'Remember', 'நினைவில் கொள்ளுங்கள்')),
            style: TextStyle(
              color: _accent,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          _textList(lesson.remember, icon: Icons.lightbulb_rounded),
          const SizedBox(height: 4),
          Text(
            _text(const _Copy(
              'මෙම කරුණු නිල Grade 6 ගණිත මොඩියුලවල පාඩම් අරමුණු අනුව සකස් කර ඇත.',
              'These key points follow the lesson outcomes in the official Grade 6 Mathematics modules.',
              'இந்த முக்கியக் குறிப்புகள் அதிகாரப்பூர்வ 6ஆம் தரக் கணிதத் தொகுதிகளின் பாட இலக்குகளின் அடிப்படையில் அமைக்கப்பட்டுள்ளன.',
            )),
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _examples() {
    final lesson = _pack!;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(
            _text(const _Copy('පියවරෙන් පියවර බලමු', 'Worked examples',
                'படிப்படியாகப் பார்ப்போம்')),
            Icons.lightbulb_rounded,
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < lesson.examples.length; i++) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDDE5F5)),
              ),
              child: Text(
                _text(lesson.examples[i]),
                style: const TextStyle(
                  color: Color(0xFF34425B),
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _aiExplain() {
    return _card(
      child: Column(
        children: [
          _heading(
            _text(const _Copy('AI Tutor සමඟ අහන්න', 'Ask the AI Tutor',
                'AI Tutor-யிடம் கேளுங்கள்')),
            Icons.auto_awesome_rounded,
          ),
          const SizedBox(height: 18),
          Text(
            _text(const _Copy(
              'මේ පාඩමේ තේරෙන්නේ නැති කොටසක් හෝ අලුත් උදාහරණයක් තෝරාගත් භාෂාවෙන් අහන්න.',
              'Ask about any part of this lesson or request another example in your selected explanation language.',
              'இந்தப் பாடத்தின் எந்தப் பகுதியைப் பற்றியும் அல்லது புதிய உதாரணத்தையும் நீங்கள் தேர்ந்தெடுத்த மொழியில் கேளுங்கள்.',
            )),
            style: const TextStyle(
              color: Color(0xFF34425B),
              fontSize: 15,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _openAI,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: Text(_text(const _Copy(
                  'AI Tutor අරින්න', 'Open AI Tutor', 'AI Tutor திறக்கவும்'))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _practice() {
    final lesson = _pack!;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(
            _text(const _Copy('දැන් ඔබ උත්සාහ කරන්න', 'Try these',
                'இவற்றை முயற்சி செய்யுங்கள்')),
            Icons.edit_note_rounded,
          ),
          const SizedBox(height: 18),
          Text(
            _text(const _Copy(
              'පිළිතුරු පොතක ලියා, ඉන්පසු Quiz එකෙන් ඔබේ අවබෝධය පරීක්ෂා කරන්න.',
              'Write your answers in a notebook, then check your understanding with the quiz.',
              'உங்கள் பதில்களைப் புத்தகத்தில் எழுதி, பின்னர் வினாடி வினா மூலம் புரிதலைச் சரிபார்க்கவும்.',
            )),
            style: const TextStyle(color: Color(0xFF667085), height: 1.5),
          ),
          const SizedBox(height: 15),
          _textList(lesson.practice, icon: Icons.edit_rounded),
        ],
      ),
    );
  }

  Widget _quiz() {
    final lesson = _pack!;
    final score = List<int>.generate(
      lesson.quiz.length,
          (index) => _answers[index] == lesson.quiz[index].correctIndex ? 1 : 0,
    ).fold<int>(0, (total, value) => total + value);

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(
            _text(const _Copy('ඔබේ දැනුම පරීක්ෂා කරමු',
                'Check what you learned', 'கற்றதைச் சரிபார்ப்போம்')),
            Icons.quiz_rounded,
          ),
          const SizedBox(height: 18),
          for (var q = 0; q < lesson.quiz.length; q++)
            _quizQuestion(lesson.quiz[q], q),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _answers.any((answer) => answer == null)
                  ? null
                  : () => setState(() => _quizSubmitted = true),
              icon: const Icon(Icons.check_rounded),
              label: Text(_text(const _Copy('පිළිතුරු බලන්න', 'Check answers',
                  'பதில்களைச் சரிபார்க்கவும்'))),
            ),
          ),
          if (_quizSubmitted) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4D6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _text(const _Copy(
                    'ඔබේ ලකුණු: ', 'Your score: ', 'உங்கள் மதிப்பெண்: ')) +
                    score.toString() +
                    ' / ' +
                    lesson.quiz.length.toString(),
                style: const TextStyle(
                  color: Color(0xFF754300),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _quizQuestion(_QuizQuestion question, int questionIndex) {
    final selected = _answers[questionIndex];
    final correct = question.correctIndex;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDE5F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (questionIndex + 1).toString() + '. ' + _text(question.question),
            style: const TextStyle(
              color: Color(0xFF20283A),
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 7),
          for (var option = 0; option < question.options.length; option++)
            RadioListTile<int>(
              dense: true,
              contentPadding: EdgeInsets.zero,
              activeColor: _accent,
              value: option,
              groupValue: selected,
              onChanged: _quizSubmitted
                  ? null
                  : (value) => setState(() => _answers[questionIndex] = value),
              title: Text(
                _text(question.options[option]),
                style: const TextStyle(color: Color(0xFF34425B), height: 1.4),
              ),
            ),
          if (_quizSubmitted) ...[
            const Divider(),
            Text(
              _text(selected == correct
                  ? const _Copy('නිවැරදියි!', 'Correct!', 'சரி!')
                  : const _Copy('නිවැරදි පිළිතුර: ', 'Correct answer: ',
                  'சரியான பதில்: ')) +
                  (selected == correct
                      ? ''
                      : _text(question.options[correct])) +
                  '\n' +
                  _text(question.explanation),
              style: const TextStyle(
                color: Color(0xFF34425B),
                fontSize: 14,
                height: 1.55,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _notReady() {
    return _card(
      child: Column(
        children: [
          const Icon(Icons.pending_actions_rounded,
              size: 46, color: Color(0xFF7546D8)),
          const SizedBox(height: 12),
          Text(
            _text(const _Copy(
              'මෙම ශ්‍රේණිය සහ විෂය සඳහා සත්‍යාපිත පාඩම් අන්තර්ගතය තවම සකස් කර නැහැ. වැරදි කරුණු දක්වන්නේ නැහැ.',
              'Verified lesson content for this grade and subject is not ready yet. We will not show unverified material.',
              'இந்த வகுப்பு மற்றும் பாடத்திற்கான சரிபார்க்கப்பட்ட பாட உள்ளடக்கம் இன்னும் தயாராகவில்லை. சரிபார்க்கப்படாத தகவலைக் காட்டமாட்டோம்.',
            )),
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Color(0xFF34425B), fontSize: 15, height: 1.55),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _openAI,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: Text(_text(const _Copy(
                'AI Tutor අරින්න', 'Open AI Tutor', 'AI Tutor திறக்கவும்'))),
          ),
        ],
      ),
    );
  }

  Widget _currentStep() {
    if (!_isSupported) return _notReady();
    switch (_step) {
      case 0:
        return _learn();
      case 1:
        return _examples();
      case 2:
        return _aiExplain();
      case 3:
        return _practice();
      case 4:
        return _quiz();
      default:
        return _learn();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text(_displayTitle),
        backgroundColor: const Color(0xFF07132F),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List<Widget>.generate(_stepNames.length, (index) {
                    final selected = _step == index;
                    final color = _stepColors[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        selected: selected,
                        showCheckmark: false,
                        backgroundColor: color.withValues(alpha: 0.08),
                        selectedColor: color,
                        side: BorderSide(color: color.withValues(alpha: 0.25)),
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : color,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        label: Text(
                            (index + 1).toString() + '. ' + _stepNames[index]),
                        onSelected: (_) => setState(() => _step = index),
                      ),
                    );
                  }),
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    children: [
                      const ZingaccBrandBanner(),
                      const SizedBox(height: 20),
                      Text(
                        _displayTitle,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF20283A),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _displayLevel +
                            ' • ' +
                            _displaySubject +
                            (_isSupported ? ' • ' + _text(_pack!.module) : ''),
                        style: const TextStyle(
                            color: Color(0xFF536078),
                            fontSize: 13,
                            height: 1.4),
                      ),
                      const SizedBox(height: 18),
                      _currentStep(),
                      const SizedBox(height: 18),
                      if (_step < 4)
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _next,
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: Text(_text(const _Copy(
                                'ඊළඟ පියවර', 'Next step', 'அடுத்த படி'))),
                            style: FilledButton.styleFrom(
                              backgroundColor: _accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Copy {
  const _Copy(this.si, this.en, this.ta);
  final String si;
  final String en;
  final String ta;

  String pick(bool sinhala, bool tamil) => sinhala ? si : (tamil ? ta : en);
}

class _LessonPack {
  const _LessonPack({
    required this.title,
    required this.module,
    required this.learn,
    required this.remember,
    required this.examples,
    required this.practice,
    required this.quiz,
  });

  final _Copy title;
  final _Copy module;
  final List<_Copy> learn;
  final List<_Copy> remember;
  final List<_Copy> examples;
  final List<_Copy> practice;
  final List<_QuizQuestion> quiz;
}

class _QuizQuestion {
  const _QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final _Copy question;
  final List<_Copy> options;
  final int correctIndex;
  final _Copy explanation;
}

const List<_LessonPack> _grade6Lessons = [
  _LessonPack(
    title: _Copy('ස්ථානීය අගය', 'Place Value', 'ස්ථானப் பெறுமானம்'),
    module: _Copy(
        'මොඩියුලය 1 • සංඛ්‍යා I', 'Module 1 • Number I', 'தொகுதி 1 • எண்கள் I'),
    learn: [
      _Copy(
          'ඉලක්කමක ස්ථානය අනුව එහි අගය තීරණය වේ.',
          'A digit’s value depends on its position.',
          'ஒரு இலக்கத்தின் பெறுமானம் அதன் இடத்தைப் பொறுத்தது.'),
      _Copy(
          'එකක, දහය, සියය, දහස වැනි ස්ථාන වමේ සිට දකුණට පිළිවෙළින් කියවමු.',
          'Read place positions from right to left: ones, tens, hundreds, thousands, and so on.',
          'வலமிருந்து இடமாக ஒன்றுகள், பத்துகள், நூறுகள், ஆயிரங்கள் என இடங்களைப் படிக்கவும்.'),
      _Copy(
          'විශාල සංඛ්‍යා කියවීමට හා ලිවීමට ඉලක්කම් කාණ්ඩ කර බලන්න.',
          'Group digits to help read and write larger numbers.',
          'பெரிய எண்களைப் படிக்கவும் எழுதவும் இலக்கங்களைப் பிரித்து பார்க்கவும்.'),
    ],
    remember: [
      _Copy(
          '4,582 හි 5 ඉලක්කම සියයේ ස්ථානයේ නිසා එහි අගය 500 යි.',
          'In 4,582, the digit 5 is in the hundreds place, so its value is 500.',
          '4,582 இல் 5 நூறுகள் இடத்தில் இருப்பதால் அதன் பெறுமானம் 500.'),
    ],
    examples: [
      _Copy(
          '4,582 = 4,000 + 500 + 80 + 2. එබැවින් 4,582 හි 8 ඉලක්කමේ අගය 80 යි.',
          '4,582 = 4,000 + 500 + 80 + 2. So the value of 8 is 80.',
          '4,582 = 4,000 + 500 + 80 + 2. எனவே 8 இன் பெறுமானம் 80.'),
      _Copy(
          '6,241 හි 2 ඉලක්කම සියයේ ස්ථානයේ ඇත. එහි අගය 200 යි.',
          'In 6,241, 2 is in the hundreds place. Its value is 200.',
          '6,241 இல் 2 நூறுகள் இடத்தில் உள்ளது. அதன் பெறுமானம் 200.'),
    ],
    practice: [
      _Copy('7,356 හි 3 ඉලක්කමේ අගය ලියන්න.', 'Write the value of 3 in 7,356.',
          '7,356 இல் 3 இன் பெறுமானத்தை எழுதுங்கள்.'),
      _Copy(
          '5,204 සංඛ්‍යාව ප්‍රසාරිත ආකාරයෙන් ලියන්න.',
          'Write 5,204 in expanded form.',
          '5,204 ஐ விரிவாக்க வடிவில் எழுதுங்கள்.'),
    ],
    quiz: [
      _QuizQuestion(
          question: _Copy(
              '3,462 හි 4 ඉලක්කමේ අගය කීයද?',
              'What is the value of 4 in 3,462?',
              '3,462 இல் 4 இன் பெறுமானம் என்ன?'),
          options: [
            _Copy('4', '4', '4'),
            _Copy('40', '40', '40'),
            _Copy('400', '400', '400'),
            _Copy('4,000', '4,000', '4,000')
          ],
          correctIndex: 2,
          explanation: _Copy('4 සියයේ ස්ථානයේ ඇත.',
              '4 is in the hundreds place.', '4 நூறுகள் இடத்தில் உள்ளது.')),
      _QuizQuestion(
          question: _Copy(
              '2,305 හි දහයේ ස්ථානයේ ඇති ඉලක්කම කුමක්ද?',
              'Which digit is in the tens place in 2,305?',
              '2,305 இல் பத்துகள் இடத்தில் உள்ள இலக்கம் எது?'),
          options: [
            _Copy('2', '2', '2'),
            _Copy('3', '3', '3'),
            _Copy('0', '0', '0'),
            _Copy('5', '5', '5')
          ],
          correctIndex: 2,
          explanation: _Copy(
              'දකුණෙන් දෙවන ස්ථානය දහයේ ස්ථානයයි.',
              'The second position from the right is the tens place.',
              'வலமிருந்து இரண்டாவது இடம் பத்துகள் இடமாகும்.')),
      _QuizQuestion(
          question: _Copy(
              '6,000 + 200 + 30 + 1 යන ප්‍රසාරිත ආකාරයට ගැළපෙන්නේ කුමක්ද?',
              'Which number matches 6,000 + 200 + 30 + 1?',
              '6,000 + 200 + 30 + 1 என்பதற்கு ஏற்ற எண் எது?'),
          options: [
            _Copy('6,231', '6,231', '6,231'),
            _Copy('6,321', '6,321', '6,321'),
            _Copy('6,203', '6,203', '6,203'),
            _Copy('6,031', '6,031', '6,031')
          ],
          correctIndex: 0,
          explanation: _Copy(
              '6,000 + 200 + 30 + 1 = 6,231.',
              '6,000 + 200 + 30 + 1 = 6,231.',
              '6,000 + 200 + 30 + 1 = 6,231.')),
    ],
  ),
  _LessonPack(
    title: _Copy('සංඛ්‍යා සහ ගණිත කර්ම', 'Numbers and Mathematical Operations',
        'எண்களும் கணிதச் செய்கைகளும்'),
    module: _Copy(
        'මොඩියුලය 1 • සංඛ්‍යා I', 'Module 1 • Number I', 'தொகுதி 1 • எண்கள் I'),
    learn: [
      _Copy(
          'එකතු කිරීම, අඩු කිරීම, ගුණ කිරීම සහ බෙදීම භාවිතයෙන් සංඛ්‍යා ගණනය කරමු.',
          'Use addition, subtraction, multiplication, and division to calculate with numbers.',
          'கூட்டல், கழித்தல், பெருக்கல், வகுத்தல் ஆகியவற்றைப் பயன்படுத்திக் கணக்கிடுங்கள்.'),
      _Copy(
          'ගණනයට පෙර ප්‍රශ්නයේ දී ඇති තොරතුරු සහ සොයන දේ හඳුනාගන්න.',
          'Before calculating, identify the given information and what the question asks.',
          'கணக்கிடுவதற்கு முன் கொடுக்கப்பட்ட தகவல்களையும் கேட்கப்பட்டதையும் அடையாளம் காணுங்கள்.'),
      _Copy(
          '10, 100, 1,000 න් ගුණ කිරීමේදී හෝ බෙදීමේදී ස්ථානීය අගය ගැන සිතන්න.',
          'When multiplying or dividing by 10, 100, or 1,000, think about place value.',
          '10, 100, 1,000 ஆல் பெருக்கும்போதும் வகுக்கும்போதும் இடப் பெறுமானத்தை கவனியுங்கள்.'),
    ],
    remember: [
      _Copy(
          'බෙදීමෙන් පසු ඉතිරියක් තිබේදැයි පිළිතුර පරීක්ෂා කරන්න.',
          'Check whether division leaves a remainder.',
          'வகுத்தபின் மீதி உள்ளதா எனச் சரிபார்க்கவும்.'),
    ],
    examples: [
      _Copy(
          '348 + 276: එකක 8 + 6 = 14; 4 ලියා 1 ඉදිරියට ගෙන යමු. මුළු එකතුව 624 යි.',
          '348 + 276: 8 + 6 = 14, write 4 and carry 1. The total is 624.',
          '348 + 276: 8 + 6 = 14; 4 ஐ எழுதி 1 ஐ அடுத்த இடத்துக்கு எடுத்துச் செல்லுங்கள். விடை 624.'),
      _Copy(
          '27 × 100 = 2,700. 840 ÷ 10 = 84.',
          '27 × 100 = 2,700. 840 ÷ 10 = 84.',
          '27 × 100 = 2,700. 840 ÷ 10 = 84.'),
    ],
    practice: [
      _Copy('526 + 187 ගණනය කරන්න.', 'Calculate 526 + 187.',
          '526 + 187 ஐக் கணக்கிடுங்கள்.'),
      _Copy(
          '900 ÷ 10 සහ 36 × 100 ගණනය කරන්න.',
          'Calculate 900 ÷ 10 and 36 × 100.',
          '900 ÷ 10 மற்றும் 36 × 100 ஐக் கணக்கிடுங்கள்.'),
    ],
    quiz: [
      _QuizQuestion(
          question: _Copy('348 + 276 = ?', '348 + 276 = ?', '348 + 276 = ?'),
          options: [
            _Copy('514', '514', '514'),
            _Copy('624', '624', '624'),
            _Copy('634', '634', '634'),
            _Copy('724', '724', '724')
          ],
          correctIndex: 1,
          explanation: _Copy(
              'එකක, දහය සහ සියය ස්ථාන පිළිවෙළින් එකතු කළ විට 624 ලැබේ.',
              'Adding the ones, tens, and hundreds gives 624.',
              'ஒன்றுகள், பத்துகள், நூறுகளை கூட்டினால் 624 கிடைக்கும்.')),
      _QuizQuestion(
          question: _Copy('36 × 100 = ?', '36 × 100 = ?', '36 × 100 = ?'),
          options: [
            _Copy('360', '360', '360'),
            _Copy('3,006', '3,006', '3,006'),
            _Copy('3,600', '3,600', '3,600'),
            _Copy('36,000', '36,000', '36,000')
          ],
          correctIndex: 2,
          explanation: _Copy(
              '36 සියයෙන් ගුණ කළ විට 3,600 වේ.',
              '36 multiplied by 100 is 3,600.',
              '36 ஐ 100 ஆல் பெருக்கினால் 3,600.')),
      _QuizQuestion(
          question: _Copy('840 ÷ 10 = ?', '840 ÷ 10 = ?', '840 ÷ 10 = ?'),
          options: [
            _Copy('8.4', '8.4', '8.4'),
            _Copy('84', '84', '84'),
            _Copy('840', '840', '840'),
            _Copy('8,400', '8,400', '8,400')
          ],
          correctIndex: 1,
          explanation: _Copy(
              '840 දහයෙන් බෙදූ විට 84 ලැබේ.',
              '840 divided by 10 is 84.',
              '840 ஐ 10 ஆல் வகுத்தால் 84 கிடைக்கும்.')),
    ],
  ),
  _LessonPack(
    title: _Copy('සංඛ්‍යා රේඛාව', 'Number Line', 'எண் கோடு'),
    module: _Copy(
        'මොඩියුලය 1 • සංඛ්‍යා I', 'Module 1 • Number I', 'தொகுதி 1 • எண்கள் I'),
    learn: [
      _Copy(
          'සංඛ්‍යා රේඛාවක සංඛ්‍යා සමාන පරතරයකින් පිළිවෙළට සලකුණු කරයි.',
          'Numbers on a number line are marked in order at equal intervals.',
          'எண் கோட்டில் எண்கள் சம இடைவெளியில் வரிசையாகக் குறிக்கப்படுகின்றன.'),
      _Copy(
          'රේඛාවේ දකුණට යන විට සංඛ්‍යා වැඩි වේ; වමට යන විට අඩු වේ.',
          'Numbers increase to the right and decrease to the left.',
          'வலப்புறம் செல்லும்போது எண்கள் பெருகும்; இடப்புறம் செல்லும்போது குறையும்.'),
      _Copy(
          'ලකුණක් ඇති ස්ථානයෙන් අදාළ සංඛ්‍යාව හඳුනාගත හැක.',
          'Use the position of a mark to identify its number.',
          'ஒரு குறியின் இடத்தைப் பார்த்து அதற்குரிய எண்ணை அறியலாம்.'),
    ],
    remember: [
      _Copy(
          'සංඛ්‍යා රේඛාවක එක් ලකුණකින් ඊළඟ ලකුණට ඇති පරතරය සමාන විය යුතුය.',
          'The interval from one mark to the next must stay equal.',
          'ஒரு குறியிலிருந்து அடுத்த குறிவரை உள்ள இடைவெளி சமமாக இருக்க வேண்டும்.'),
    ],
    examples: [
      _Copy(
          '0, 1, 2, 3, 4 යන සලකුණු ඇති රේඛාවේ 2 සහ 4 අතර සංඛ්‍යාව 3 යි.',
          'On a line marked 0, 1, 2, 3, 4, the number between 2 and 4 is 3.',
          '0, 1, 2, 3, 4 எனக் குறிக்கப்பட்ட கோட்டில் 2க்கும் 4க்கும் இடையே 3 உள்ளது.'),
      _Copy(
          '5, 6, 7, 8 ලෙස යන රේඛාවේ 7, 6 ට දකුණින් ඇති නිසා 7 > 6 යි.',
          'On a line marked 5, 6, 7, 8, 7 is to the right of 6, so 7 > 6.',
          '5, 6, 7, 8 கோட்டில் 7 என்பது 6 இன் வலப்புறம்; எனவே 7 > 6.'),
    ],
    practice: [
      _Copy(
          '0 සිට 10 දක්වා සංඛ්‍යා රේඛාවක් ඇඳ 3 සහ 8 සලකුණු කරන්න.',
          'Draw a number line from 0 to 10 and mark 3 and 8.',
          '0 முதல் 10 வரை எண் கோடு வரைந்து 3 மற்றும் 8 ஐக் குறிக்கவும்.'),
      _Copy(
          'සෑම පියවරකම 2 බැගින් වැඩි වන 2, 4, 6, 8 රටාවේ ඊළඟ සංඛ්‍යාව ලියන්න.',
          'Write the next number in 2, 4, 6, 8 when each term increases by 2.',
          'ஒவ்வொரு முறையும் 2 அதிகரிக்கும் 2, 4, 6, 8 தொடரின் அடுத்த எண்ணை எழுதுங்கள்.'),
    ],
    quiz: [
      _QuizQuestion(
          question: _Copy(
              'සංඛ්‍යා රේඛාවේ 4 සහ 6 අතර ඇති පූර්ණ සංඛ්‍යාව කුමක්ද?',
              'Which whole number lies between 4 and 6 on a number line?',
              'எண் கோட்டில் 4க்கும் 6க்கும் இடையில் உள்ள முழு எண் எது?'),
          options: [
            _Copy('3', '3', '3'),
            _Copy('5', '5', '5'),
            _Copy('7', '7', '7'),
            _Copy('8', '8', '8')
          ],
          correctIndex: 1,
          explanation: _Copy(
              '4 ට පසු සහ 6 ට පෙර 5 පිහිටයි.',
              '5 comes after 4 and before 6.',
              '4 க்குப் பின், 6 க்கு முன் 5 வருகிறது.')),
      _QuizQuestion(
          question: _Copy(
              'සංඛ්‍යා රේඛාවේ දකුණට යන විට සංඛ්‍යා…',
              'As you move right on a number line, numbers…',
              'எண் கோட்டில் வலப்புறம் செல்லும்போது எண்கள்…'),
          options: [
            _Copy('අඩු වේ', 'decrease', 'குறையும்'),
            _Copy('වැඩි වේ', 'increase', 'அதிகரிக்கும்'),
            _Copy('වෙනස් නොවේ', 'do not change', 'மாறாது'),
            _Copy('අතුරුදන් වේ', 'disappear', 'மறையும்')
          ],
          correctIndex: 1,
          explanation: _Copy(
              'දකුණට ගමන් කරන විට අගය වැඩි වේ.',
              'The value increases as you move right.',
              'வலப்புறம் செல்லும்போது பெறுமானம் அதிகரிக்கும்.')),
      _QuizQuestion(
          question: _Copy(
              'සමාන පරතරය ඇති සලකුණු රේඛාවක 2, 3, 4, __. ඊළඟ සංඛ්‍යාව?',
              'On equally spaced marks: 2, 3, 4, __. What comes next?',
              'சம இடைவெளிக் குறிகளில் 2, 3, 4, __. அடுத்து எது?'),
          options: [
            _Copy('4', '4', '4'),
            _Copy('5', '5', '5'),
            _Copy('6', '6', '6'),
            _Copy('7', '7', '7')
          ],
          correctIndex: 1,
          explanation: _Copy(
              'සෑම පියවරකදීම 1 බැගින් වැඩි වේ.',
              'The number increases by 1 at each step.',
              'ஒவ்வொரு படியிலும் 1 அதிகரிக்கிறது.')),
    ],
  ),
  _LessonPack(
    title: _Copy('කෝණ', 'Angles', 'கோணங்கள்'),
    module: _Copy(
        'මොඩියුලය 2 • ජ්‍යාමිතිය හා මිනුම්',
        'Module 2 • Geometry and Measurement',
        'தொகுதி 2 • வடிவியலும் அளவீடும்'),
    learn: [
      _Copy(
          'එකම අග්‍රයකින් ආරම්භ වන රේඛා දෙකක් අතර විවෘත වීම කෝණයයි.',
          'An angle is the opening between two lines or arms that meet at one vertex.',
          'ஒரே உச்சியில் சந்திக்கும் இரு கோடுகள் அல்லது கைகளுக்கிடையிலான திறப்பே கோணம்.'),
      _Copy(
          'කෝණයක අග්‍රය සහ එහි දෙපස හඳුනා ගනිමු.',
          'Identify the vertex and the two arms of an angle.',
          'கோணத்தின் உச்சியையும் இரு பக்கங்களையும் அடையாளம் காணுங்கள்.'),
      _Copy(
          'විවෘත වීම වැඩි කෝණයක් හා අඩු කෝණයක් සසඳා හඳුනාගත හැක.',
          'Compare angles by looking at how wide their openings are.',
          'திறப்பின் அகலத்தைப் பார்த்து கோணங்களை ஒப்பிடலாம்.'),
    ],
    remember: [
      _Copy(
          'කෝණය සලකුණු කරන විට එහි අග්‍රය පැහැදිලිව පෙන්වන්න.',
          'When showing an angle, make its vertex clear.',
          'கோணத்தைச் சுட்டும்போது அதன் உச்சியைத் தெளிவாகக் காட்டுங்கள்.'),
    ],
    examples: [
      _Copy(
          'පොතක විවෘත කවරයේ හමුවන කොන අග්‍රයයි; කවරයේ දාර දෙක කෝණයේ දෙපස වේ.',
          'At the open corner of a book, the meeting point is the vertex and the two cover edges are its arms.',
          'திறந்த புத்தகத்தின் சந்திக்கும் மூலை உச்சி; புத்தகத்தின் இரு விளிம்புகளும் கோணத்தின் பக்கங்கள்.'),
      _Copy(
          'දොරක් ටිකක් විවෘත කළ විට ඇති කෝණයට වඩා එය තවත් විවෘත කළ විට කෝණය විශාල වේ.',
          'Opening a door wider makes the angle larger.',
          'கதவை அதிகம் திறந்தால் கோணம் பெரிதாகும்.'),
    ],
    practice: [
      _Copy(
          'පන්තියේ කෝණයක් පෙන්වන දේවල් දෙකක් සොයා අග්‍රය නම් කරන්න.',
          'Find two things in the classroom that show an angle and point out each vertex.',
          'வகுப்பறையில் கோணத்தைக் காட்டும் இரண்டு பொருட்களைக் கண்டுபிடித்து உச்சியைக் காட்டுங்கள்.'),
      _Copy(
          'කඩදාසියක කෝණ දෙකක් ඇඳ, වැඩි විවෘත වීම ඇති කෝණය වට කරන්න.',
          'Draw two angles on paper and circle the one with the wider opening.',
          'காகிதத்தில் இரண்டு கோணங்கள் வரைந்து, அகலமான திறப்பைச் சுற்றி வட்டமிடுங்கள்.'),
    ],
    quiz: [
      _QuizQuestion(
          question: _Copy(
              'කෝණයක දෙපස හමුවන පොදු ලක්ෂ්‍යය කුමක්ද?',
              'What is the common meeting point of the two arms of an angle called?',
              'கோணத்தின் இரு பக்கங்களும் சந்திக்கும் பொதுப் புள்ளி எது?'),
          options: [
            _Copy('අග්‍රය', 'Vertex', 'உச்சி'),
            _Copy('මධ්‍යය', 'Centre', 'மையம்'),
            _Copy('දාරය', 'Edge', 'விளிம்பு'),
            _Copy('වටය', 'Circle', 'வட்டம்')
          ],
          correctIndex: 0,
          explanation: _Copy(
              'කෝණයේ දෙපස හමුවන ලක්ෂ්‍යය අග්‍රයයි.',
              'The point where the arms meet is the vertex.',
              'கோணத்தின் பக்கங்கள் சந்திக்கும் புள்ளி உச்சி.')),
      _QuizQuestion(
          question: _Copy(
              'කෝණයේ විවෘත වීම වැඩි කළ විට…',
              'When the opening of an angle becomes wider…',
              'கோணத்தின் திறப்பு அகலமாகும்போது…'),
          options: [
            _Copy('කෝණය විශාල වේ', 'the angle becomes larger',
                'கோணம் பெரிதாகும்'),
            _Copy('කෝණය නැති වේ', 'the angle disappears', 'கோணம் மறையும்'),
            _Copy('අග්‍රය දෙකක් වේ', 'it has two vertices',
                'இரண்டு உச்சிகள் உண்டாகும்'),
            _Copy('දෙපස එකටම යයි', 'the arms join together',
                'பக்கங்கள் ஒன்றாகும்')
          ],
          correctIndex: 0,
          explanation: _Copy(
              'විවෘත වීම වැඩි වන විට කෝණයද විශාල වේ.',
              'A wider opening means a larger angle.',
              'திறப்பு அகலமானால் கோணமும் பெரிதாகும்.')),
      _QuizQuestion(
          question: _Copy('කෝණයකට අවශ්‍ය වන්නේ…', 'An angle needs…',
              'ஒரு கோணத்திற்கு தேவையானது…'),
          options: [
            _Copy(
                'එකම අග්‍රයකින් හමුවන දෙපසක්',
                'two arms meeting at one vertex',
                'ஒரே உச்சியில் சந்திக்கும் இரு பக்கங்கள்'),
            _Copy('වට දෙකක්', 'two circles', 'இரு வட்டங்கள்'),
            _Copy('සමාන්තර පැති හතරක්', 'four parallel sides',
                'நான்கு இணையான பக்கங்கள்'),
            _Copy('අංක තුනක්', 'three numbers', 'மூன்று எண்கள்')
          ],
          correctIndex: 0,
          explanation: _Copy(
              'කෝණයක දෙපස පොදු අග්‍රයකින් හමුවේ.',
              'The two arms of an angle meet at a common vertex.',
              'கோணத்தின் இரு பக்கங்களும் பொதுவான உச்சியில் சந்திக்கின்றன.')),
    ],
  ),
  _LessonPack(
    title: _Copy('කාලය', 'Time', 'நேரம்'),
    module: _Copy(
        'මොඩියුලය 2 • ජ්‍යාමිතිය හා මිනුම්',
        'Module 2 • Geometry and Measurement',
        'தொகுதி 2 • வடிவியலும் அளவீடும்'),
    learn: [
      _Copy(
          'ඔරලෝසුවේ කෙටි කටුවෙන් පැයත් දිග කටුවෙන් මිනිත්තුත් කියවමු.',
          'Read hours with the short hand and minutes with the long hand on an analogue clock.',
          'அனலாக் கடிகாரத்தில் குறுகிய முள் மணியையும் நீண்ட முள் நிமிடத்தையும் காட்டும்.'),
      _Copy(
          'පැය 1 = මිනිත්තු 60; මිනිත්තු 1 = තත්පර 60.',
          '1 hour = 60 minutes; 1 minute = 60 seconds.',
          '1 மணி = 60 நிமிடங்கள்; 1 நிமிடம் = 60 விநாடிகள்.'),
      _Copy(
          'කාල පරාසය සොයන්නට ආරම්භක වේලාවේ සිට අවසන් වේලාව දක්වා ගණන් කරමු.',
          'To find elapsed time, count from the start time to the finish time.',
          'கடந்த நேரத்தைக் காண தொடக்க நேரத்திலிருந்து முடிவு நேரம் வரை கணக்கிடுங்கள்.'),
    ],
    remember: [
      _Copy(
          'වේලාවක් කියවීමේදී පැය කටුව මිනිත්තු කටුවට වඩා කෙටි බව මතක තබාගන්න.',
          'Remember that the hour hand is shorter than the minute hand.',
          'மணி முள் நிமிட முளைவிடக் குறுகியது என்பதை நினைவில் கொள்ளுங்கள்.'),
    ],
    examples: [
      _Copy(
          '3:15 සිට 3:30 දක්වා මිනිත්තු 15 යි. 3:30 සිට 4:00 දක්වා මිනිත්තු 30 යි. එබැවින් මුළු කාලය 45 මිනිත්තු යි.',
          'From 3:15 to 3:30 is 15 minutes. From 3:30 to 4:00 is 30 minutes. The total is 45 minutes.',
          '3:15 முதல் 3:30 வரை 15 நிமிடங்கள். 3:30 முதல் 4:00 வரை 30 நிமிடங்கள். மொத்தம் 45 நிமிடங்கள்.'),
      _Copy(
          'පැය 2 = 2 × 60 = මිනිත්තු 120 යි.',
          '2 hours = 2 × 60 = 120 minutes.',
          '2 மணி = 2 × 60 = 120 நிமிடங்கள்.'),
    ],
    practice: [
      _Copy(
          '7:00 සිට 7:35 දක්වා කාලය මිනිත්තු කීයක්ද?',
          'How many minutes are there from 7:00 to 7:35?',
          '7:00 முதல் 7:35 வரை எத்தனை நிமிடங்கள்?'),
      _Copy('පැය 3ක් මිනිත්තු බවට හරවන්න.', 'Convert 3 hours to minutes.',
          '3 மணிநேரத்தை நிமிடங்களாக மாற்றுங்கள்.'),
    ],
    quiz: [
      _QuizQuestion(
          question: _Copy(
              'පැය 1ක මිනිත්තු කීයක් තිබේද?',
              'How many minutes are in 1 hour?',
              '1 மணியில் எத்தனை நிமிடங்கள்?'),
          options: [
            _Copy('30', '30', '30'),
            _Copy('60', '60', '60'),
            _Copy('100', '100', '100'),
            _Copy('120', '120', '120')
          ],
          correctIndex: 1,
          explanation: _Copy(
              'පැය 1ක මිනිත්තු 60 කි.',
              'There are 60 minutes in 1 hour.',
              '1 மணியில் 60 நிமிடங்கள் உள்ளன.')),
      _QuizQuestion(
          question: _Copy(
              '5:10 සිට 5:40 දක්වා කාලය කීයද?',
              'How long is it from 5:10 to 5:40?',
              '5:10 முதல் 5:40 வரை எவ்வளவு நேரம்?'),
          options: [
            _Copy('20 මිනිත්තු', '20 minutes', '20 நிமிடங்கள்'),
            _Copy('30 මිනිත්තු', '30 minutes', '30 நிமிடங்கள்'),
            _Copy('40 මිනිත්තු', '40 minutes', '40 நிமிடங்கள்'),
            _Copy('50 මිනිත්තු', '50 minutes', '50 நிமிடங்கள்')
          ],
          correctIndex: 1,
          explanation: _Copy('40 − 10 = මිනිත්තු 30 යි.',
              '40 − 10 = 30 minutes.', '40 − 10 = 30 நிமிடங்கள்.')),
      _QuizQuestion(
          question: _Copy(
              'පැය 2ක් මිනිත්තු කීයක්ද?',
              'How many minutes are in 2 hours?',
              '2 மணிகளில் எத்தனை நிமிடங்கள்?'),
          options: [
            _Copy('60', '60', '60'),
            _Copy('100', '100', '100'),
            _Copy('120', '120', '120'),
            _Copy('200', '200', '200')
          ],
          correctIndex: 2,
          explanation: _Copy('2 × 60 = 120 මිනිත්තු.', '2 × 60 = 120 minutes.',
              '2 × 60 = 120 நிமிடங்கள்.')),
    ],
  ),
  _LessonPack(
    title: _Copy('නිමානය හා වට කිරීම', 'Estimation and Rounding Off',
        'மதிப்பீடும் அண்மித்தலும்'),
    module: _Copy('මොඩියුලය 3 • සංඛ්‍යා II', 'Module 3 • Number II',
        'தொகுதி 3 • எண்கள் II'),
    learn: [
      _Copy(
          'නිමානයක් යනු නිශ්චිත ගණනයට පෙර ආසන්න පිළිතුරක් සොයාගැනීමයි.',
          'Estimation gives an approximate answer before or instead of an exact calculation.',
          'மதிப்பீடு என்பது சரியான கணக்குக்கு முன் அருகிலான விடையைப் பெறுவது.'),
      _Copy(
          'සංඛ්‍යාවක් ආසන්න දහයට, සියයට හෝ දහසට වට කළ හැක.',
          'A number can be rounded to the nearest ten, hundred, or thousand.',
          'ஒரு எண்ணை அருகிலுள்ள பத்து, நூறு அல்லது ஆயிரத்துக்கு அண்மித்தலாம்.'),
      _Copy(
          'වට කරන ස්ථානයට දකුණින් ඇති ඉලක්කම 5 හෝ වැඩි නම් ඉහළට වට කරමු; 4 හෝ අඩු නම් එතැනම තබමු.',
          'If the digit to the right is 5 or more, round up; if it is 4 or less, keep the rounding digit.',
          'அடுத்த வலப்புற இலக்கம் 5 அல்லது அதற்கு மேல் என்றால் மேலாகவும்; 4 அல்லது குறைவு என்றால் அப்படியே வைக்கவும்.'),
    ],
    remember: [
      _Copy(
          'නිමානය භාවිතයෙන් සැබෑ පිළිතුර සාධාරණදැයි පරීක්ෂා කළ හැක.',
          'Use an estimate to check whether an exact answer is reasonable.',
          'சரியான விடை பொருத்தமானதா என மதிப்பீட்டால் சரிபார்க்கலாம்.'),
    ],
    examples: [
      _Copy(
          '346 ආසන්න දහයට වට කළ විට 350 යි. දහයේ ස්ථානයට දකුණින් 6 ඇති නිසා ඉහළට වට කරමු.',
          '346 rounded to the nearest ten is 350 because the digit to its right is 6.',
          '346 ஐ அருகிலுள்ள பத்துக்கு அண்மித்தால் 350; அடுத்த இலக்கம் 6 என்பதால் மேலாக அண்மிக்கிறோம்.'),
      _Copy(
          '198 + 302 ≈ 200 + 300 = 500. මෙය එකතුවට ආසන්න නිමානයකි.',
          '198 + 302 ≈ 200 + 300 = 500. This is an estimate of the sum.',
          '198 + 302 ≈ 200 + 300 = 500. இது கூட்டுத்தொகைக்கான மதிப்பீடு.'),
    ],
    practice: [
      _Copy(
          '2,764 ආසන්න සියයට වට කරන්න.',
          'Round 2,764 to the nearest hundred.',
          '2,764 ஐ அருகிலுள்ள நூறுக்கு அண்மியுங்கள்.'),
      _Copy(
          '1,649 ආසන්න දහසට වට කර 1,649 + 2,310 හි එකතුව නිමානය කරන්න.',
          'Round 1,649 to the nearest thousand, then estimate 1,649 + 2,310.',
          '1,649 ஐ அருகிலுள்ள ஆயிரத்துக்கு அண்மித்து, 1,649 + 2,310 ஐ மதிப்பிடுங்கள்.'),
    ],
    quiz: [
      _QuizQuestion(
          question: _Copy(
              '346 ආසන්න දහයට වට කළ විට?',
              '346 rounded to the nearest ten is…',
              '346 ஐ அருகிலுள்ள பத்துக்கு அண்மித்தால்…'),
          options: [
            _Copy('340', '340', '340'),
            _Copy('345', '345', '345'),
            _Copy('350', '350', '350'),
            _Copy('400', '400', '400')
          ],
          correctIndex: 2,
          explanation: _Copy(
              'එකක ඉලක්කම 6 නිසා 34 දහය ඉහළට 35 දහය වේ.',
              'The ones digit is 6, so 34 tens rounds up to 35 tens.',
              'ஒன்றுகள் இலக்கம் 6; ஆகவே 34 பத்துகள் 35 பத்துகளாக மேலாக அண்மிக்கப்படும்.')),
      _QuizQuestion(
          question: _Copy(
              '1,649 ආසන්න දහසට වට කළ විට?',
              '1,649 rounded to the nearest thousand is…',
              '1,649 ஐ அருகிலுள்ள ஆயிரத்துக்கு அண்மித்தால்…'),
          options: [
            _Copy('1,000', '1,000', '1,000'),
            _Copy('1,500', '1,500', '1,500'),
            _Copy('2,000', '2,000', '2,000'),
            _Copy('3,000', '3,000', '3,000')
          ],
          correctIndex: 2,
          explanation: _Copy(
              'දහසට වට කිරීමේදී සියයේ ඉලක්කම 6 නිසා 2,000 වේ.',
              'The hundreds digit is 6, so it rounds to 2,000.',
              'நூறுகள் இலக்கம் 6 என்பதால் 2,000 ஆக அண்மிக்கப்படும்.')),
      _QuizQuestion(
          question: _Copy(
              '198 + 302 හි පහසු නිමානය කුමක්ද?',
              'What is a convenient estimate for 198 + 302?',
              '198 + 302 க்கான வசதியான மதிப்பீடு எது?'),
          options: [
            _Copy('300', '300', '300'),
            _Copy('400', '400', '400'),
            _Copy('500', '500', '500'),
            _Copy('600', '600', '600')
          ],
          correctIndex: 2,
          explanation: _Copy(
              '198 ≈ 200 සහ 302 ≈ 300; 200 + 300 = 500.',
              '198 ≈ 200 and 302 ≈ 300; 200 + 300 = 500.',
              '198 ≈ 200, 302 ≈ 300; 200 + 300 = 500.')),
    ],
  ),
  _LessonPack(
    title: _Copy(
        'සාධක හා ගුණාකාර', 'Factors and Multiples', 'காரணிகளும் மடங்குகளும்'),
    module: _Copy('මොඩියුලය 3 • සංඛ්‍යා II', 'Module 3 • Number II',
        'தொகுதி 3 • எண்கள் II'),
    learn: [
      _Copy(
          'සංඛ්‍යාවක් ඉතිරියක් නැතිව බෙදන සංඛ්‍යා එහි සාධක වේ.',
          'A factor divides a number exactly with no remainder.',
          'ஒரு எண்ணை மீதியின்றி வகுக்கும் எண் அதன் காரணி.'),
      _Copy(
          'එකම සංඛ්‍යාවෙන් ගුණ කර ලැබෙන සංඛ්‍යා එහි ගුණාකාර වේ.',
          'Multiples are the numbers obtained by multiplying a number by 1, 2, 3, and so on.',
          'ஒரு எண்ணை 1, 2, 3 எனப் பெருக்கும்போது கிடைப்பவை அதன் மடங்குகள்.'),
      _Copy(
          'සමාන කණ්ඩායම්වලට බෙදීමේදී සාධක හා ගුණාකාර උපකාරී වේ.',
          'Factors and multiples help when arranging equal groups.',
          'சமமான குழுக்களை அமைக்க காரணிகளும் மடங்குகளும் உதவும்.'),
    ],
    remember: [
      _Copy(
          'සංඛ්‍යාවක 1 සහ එම සංඛ්‍යාවම හැමවිටම එහි සාධක වේ.',
          '1 and the number itself are always factors of that number.',
          '1 மற்றும் அந்த எண்ணே எப்போதும் அதன் காரணிகள்.'),
    ],
    examples: [
      _Copy(
          '12 හි සාධක: 1, 2, 3, 4, 6, 12. මේ සියල්ලෙන් 12 ඉතිරියක් නැතිව බෙදේ.',
          'Factors of 12: 1, 2, 3, 4, 6, 12. Each divides 12 exactly.',
          '12 இன் காரணிகள்: 1, 2, 3, 4, 6, 12. இவை அனைத்தும் 12 ஐ மீதியின்றி வகுக்கும்.'),
      _Copy(
          '5 හි මුල් ගුණාකාර: 5, 10, 15, 20, 25. සෑම වරකම 5 බැගින් එකතු වේ.',
          'The first multiples of 5 are 5, 10, 15, 20, 25. Add 5 each time.',
          '5 இன் முதல் மடங்குகள்: 5, 10, 15, 20, 25. ஒவ்வொரு முறையும் 5 ஐ கூட்டுங்கள்.'),
    ],
    practice: [
      _Copy('18 හි සියලු සාධක ලියන්න.', 'Write all the factors of 18.',
          '18 இன் அனைத்து காரணிகளையும் எழுதுங்கள்.'),
      _Copy(
          '7 හි පළමු ගුණාකාර පහ ලියන්න.',
          'Write the first five multiples of 7.',
          '7 இன் முதல் ஐந்து மடங்குகளை எழுதுங்கள்.'),
    ],
    quiz: [
      _QuizQuestion(
          question: _Copy(
              'පහත කුමක් 12 හි සාධකයක්ද?',
              'Which of these is a factor of 12?',
              'இவற்றில் எது 12 இன் காரணி?'),
          options: [
            _Copy('5', '5', '5'),
            _Copy('7', '7', '7'),
            _Copy('3', '3', '3'),
            _Copy('10', '10', '10')
          ],
          correctIndex: 2,
          explanation: _Copy('12 ÷ 3 = 4; ඉතිරියක් නැත.',
              '12 ÷ 3 = 4 with no remainder.', '12 ÷ 3 = 4; மீதி இல்லை.')),
      _QuizQuestion(
          question: _Copy(
              '6 හි ඊළඟ ගුණාකාරය 18 ට පසු කුමක්ද?',
              'What is the next multiple of 6 after 18?',
              '18 க்குப் பின் வரும் 6 இன் அடுத்த மடங்கு எது?'),
          options: [
            _Copy('20', '20', '20'),
            _Copy('22', '22', '22'),
            _Copy('24', '24', '24'),
            _Copy('26', '26', '26')
          ],
          correctIndex: 2,
          explanation: _Copy(
              '6, 12, 18, 24 ලෙස 6 බැගින් වැඩි වේ.',
              'The multiples go 6, 12, 18, 24, increasing by 6.',
              '6, 12, 18, 24 என ஒவ்வொன்றும் 6 அதிகரிக்கிறது.')),
      _QuizQuestion(
          question: _Copy('12 හි සාධකයක් නොවන්නේ කුමක්ද?',
              'Which is not a factor of 12?', '12 இன் காரணி அல்லாதது எது?'),
          options: [
            _Copy('2', '2', '2'),
            _Copy('4', '4', '4'),
            _Copy('6', '6', '6'),
            _Copy('5', '5', '5')
          ],
          correctIndex: 3,
          explanation: _Copy(
              '12 ÷ 5 බෙදූ විට ඉතිරියක් ඇති වේ.',
              'Dividing 12 by 5 leaves a remainder.',
              '12 ஐ 5 ஆல் வகுத்தால் மீதி இருக்கும்.')),
    ],
  ),
  _LessonPack(
    title: _Copy('සංඛ්‍යා වර්ග හා සංඛ්‍යා රටා',
        'Types of Numbers and Number Patterns', 'எண் வகைகளும் எண் தொடர்களும்'),
    module: _Copy('මොඩියුලය 3 • සංඛ්‍යා II', 'Module 3 • Number II',
        'தொகுதி 3 • எண்கள் II'),
    learn: [
      _Copy(
          'ඉරට්ටේ සංඛ්‍යාවක් 2න් ඉතිරියක් නැතිව බෙදේ. එහි එකක ඉලක්කම 0, 2, 4, 6 හෝ 8 වේ.',
          'An even number is divisible by 2. Its ones digit is 0, 2, 4, 6, or 8.',
          'இரட்டை எண் 2 ஆல் மீதியின்றி வகுபடும். அதன் ஒன்றுகள் இலக்கம் 0, 2, 4, 6 அல்லது 8.'),
      _Copy(
          'ඔත්තේ සංඛ්‍යාවක් 2න් බෙදූ විට ඉතිරිය 1 වේ. එහි එකක ඉලක්කම 1, 3, 5, 7 හෝ 9 වේ.',
          'An odd number leaves a remainder of 1 when divided by 2. Its ones digit is 1, 3, 5, 7, or 9.',
          'ஒற்றை எண் 2 ஆல் வகுக்கும்போது மீதி 1 கிடைக்கும். அதன் ஒன்றுகள் இலக்கம் 1, 3, 5, 7 அல்லது 9.'),
      _Copy(
          'සංඛ්‍යා රටාවක නැවත සිදුවන හෝ නියමිතව වෙනස් වන ක්‍රමය හඳුනාගන්න.',
          'Look for the rule that repeats or changes regularly in a number pattern.',
          'எண் தொடரில் மீண்டும் வரும் அல்லது ஒழுங்காக மாறும் விதியைக் கண்டறியுங்கள்.'),
    ],
    remember: [
      _Copy(
          'රටාවක ඊළඟ සංඛ්‍යාව සොයන්නට අසල්වැසි පද අතර වෙනස බලන්න.',
          'To find the next term, compare the differences between neighboring terms.',
          'அடுத்த உறுப்பைக் காண அடுத்தடுத்த எண்களின் வித்தியாசத்தைப் பாருங்கள்.'),
    ],
    examples: [
      _Copy(
          '2, 4, 6, 8, ... සෑම පියවරකම 2 බැගින් වැඩි වේ. ඊළඟ සංඛ්‍යාව 10 යි.',
          '2, 4, 6, 8, ... increases by 2 each time. The next number is 10.',
          '2, 4, 6, 8, ... ஒவ்வொரு முறையும் 2 அதிகரிக்கிறது. அடுத்த எண் 10.'),
      _Copy(
          '15 ඔත්තේය, මන්ද එහි එකක ඉලක්කම 5 යි. 28 ඉරට්ටේය, මන්ද එහි එකක ඉලක්කම 8 යි.',
          '15 is odd because its ones digit is 5. 28 is even because its ones digit is 8.',
          '15 இன் ஒன்றுகள் இலக்கம் 5 என்பதால் ஒற்றை. 28 இன் ஒன்றுகள் இலக்கம் 8 என்பதால் இரட்டை.'),
    ],
    practice: [
      _Copy(
          'පහත සංඛ්‍යා ඔත්තේ හෝ ඉරට්ටේ ලෙස වෙන් කරන්න: 17, 24, 31, 40.',
          'Sort these as odd or even: 17, 24, 31, 40.',
          'இவற்றை ஒற்றை அல்லது இரட்டை எனப் பிரிக்கவும்: 17, 24, 31, 40.'),
      _Copy(
          '5, 10, 15, 20, __ යන රටාවේ ඊළඟ පදය සොයන්න.',
          'Find the next term: 5, 10, 15, 20, __.',
          '5, 10, 15, 20, __ தொடரின் அடுத்த உறுப்பைக் கண்டறியுங்கள்.'),
    ],
    quiz: [
      _QuizQuestion(
          question: _Copy('පහත කුමක් ඉරට්ටේ සංඛ්‍යාවක්ද?',
              'Which of these is an even number?', 'இவற்றில் எது இரட்டை எண்?'),
          options: [
            _Copy('13', '13', '13'),
            _Copy('21', '21', '21'),
            _Copy('28', '28', '28'),
            _Copy('35', '35', '35')
          ],
          correctIndex: 2,
          explanation: _Copy(
              '28 හි එකක ඉලක්කම 8 යි; එය 2න් බෙදේ.',
              'The ones digit of 28 is 8, and 28 is divisible by 2.',
              '28 இன் ஒன்றுகள் இலக்கம் 8; அது 2 ஆல் வகுபடும்.')),
      _QuizQuestion(
          question: _Copy(
              '3, 6, 9, 12, __. ඊළඟ සංඛ්‍යාව?',
              '3, 6, 9, 12, __. What comes next?',
              '3, 6, 9, 12, __. அடுத்து எது?'),
          options: [
            _Copy('13', '13', '13'),
            _Copy('14', '14', '14'),
            _Copy('15', '15', '15'),
            _Copy('16', '16', '16')
          ],
          correctIndex: 2,
          explanation: _Copy('සෑම පියවරකම 3 බැගින් එකතු වේ.',
              'Add 3 at each step.', 'ஒவ்வொரு படியிலும் 3 ஐ கூட்டுங்கள்.')),
      _QuizQuestion(
          question: _Copy('පහත කුමක් ඔත්තේ සංඛ්‍යාවක්ද?',
              'Which of these is an odd number?', 'இவற்றில் எது ஒற்றை எண்?'),
          options: [
            _Copy('14', '14', '14'),
            _Copy('26', '26', '26'),
            _Copy('32', '32', '32'),
            _Copy('47', '47', '47')
          ],
          correctIndex: 3,
          explanation: _Copy(
              '47 හි එකක ඉලක්කම 7 නිසා එය ඔත්තේය.',
              '47 ends in 7, so it is odd.',
              '47 இன் ஒன்றுகள் இலக்கம் 7; எனவே அது ஒற்றை.')),
    ],
  ),
  _LessonPack(
    title: _Copy(
      'සංඛ්‍යා සමඟ සෙල්ලම් කරමු (වැඩිදුර ඉගෙනුම)',
      'Let Us Play with Numbers (Further Learning)',
      'எண்களுடன் விளையாடுவோம் (மேலதிகக் கற்றல்)',
    ),
    module: _Copy(
      'වැඩිදුර ඉගෙනුම් මොඩියුලය • සංඛ්‍යා',
      'Further Learning Module • Numbers',
      'மேலதிகக் கற்றல் தொகுதி • எண்கள்',
    ),
    learn: [
      _Copy(
        'ඉඟි කියවා දී ඇති සංඛ්‍යාව හඳුනාගැනීමෙන් සංඛ්‍යා පිළිබඳ දැනුම භාවිත කරමු.',
        'Use number knowledge to identify a number from clues.',
        'குறிப்புகளைப் பயன்படுத்தி எண்ணைக் கண்டறிந்து எண் அறிவைப் பயன்படுத்துங்கள்.',
      ),
      _Copy(
        'ඉලක්කම් නැවත සකස් කර විශාලම හෝ කුඩාම සංඛ්‍යාව සොයමු.',
        'Rearrange digits to make the greatest or smallest number.',
        'இலக்கங்களை மறுவரிசைப்படுத்தி மிகப்பெரிய அல்லது மிகச்சிறிய எண்ணை உருவாக்குங்கள்.',
      ),
      _Copy(
        'සංඛ්‍යා රටාවක නීතිය සොයා ඊළඟ සංඛ්‍යාව අනුමාන කර පරීක්ෂා කරමු.',
        'Find the rule in a number pattern, predict the next number, and check it.',
        'எண் தொடரின் விதியைக் கண்டறிந்து அடுத்த எண்ணைக் கணித்து சரிபாருங்கள்.',
      ),
    ],
    remember: [
      _Copy(
        'පිළිතුර තීරණය කළ පසු එය ගණනය කිරීමෙන් හෝ ඉඟි සමඟ සසඳා නැවත පරීක්ෂා කරන්න.',
        'After choosing an answer, check it by calculating or comparing it with every clue.',
        'விடையைத் தேர்ந்தெடுத்த பின் கணக்கிட்டோ ஒவ்வொரு குறிப்புடனும் ஒப்பிட்டோ சரிபாருங்கள்.',
      ),
    ],
    examples: [
      _Copy(
        'ඉඟි: සංඛ්‍යාව ඉලක්කම් තුනකයි. සියයේ ඉලක්කම 4යි, දහයේ ඉලක්කම 2යි, එකක ඉලක්කම 6යි. එම සංඛ්‍යාව 426යි.',
        'Clues: The number has three digits. The hundreds digit is 4, tens digit 2, and ones digit 6. The number is 426.',
        'குறிப்புகள்: எண்ணில் மூன்று இலக்கங்கள் உள்ளன. நூறுகள் இலக்கம் 4, பத்துகள் இலக்கம் 2, ஒன்றுகள் இலக்கம் 6. அந்த எண் 426.',
      ),
      _Copy(
        '2, 5, 7 ඉලක්කම් එක් වර බැගින් යොදා විශාලම සංඛ්‍යාව සෑදූ විට 752 ලැබේ. කුඩාම සංඛ්‍යාව 257යි.',
        'Using 2, 5, and 7 once each, the greatest number is 752 and the smallest is 257.',
        '2, 5, 7 ஆகியவற்றை ஒவ்வொன்றும் ஒருமுறை பயன்படுத்தினால் மிகப்பெரிய எண் 752; மிகச்சிறிய எண் 257.',
      ),
      _Copy(
        '3, 6, 9, 12, ... රටාවේ සෑම පියවරකම 3 බැගින් එකතු වේ. ඊළඟ සංඛ්‍යාව 15යි.',
        'In 3, 6, 9, 12, ... add 3 each time. The next number is 15.',
        '3, 6, 9, 12, ... தொடரில் ஒவ்வொரு முறையும் 3 சேர்க்கப்படுகிறது. அடுத்த எண் 15.',
      ),
    ],
    practice: [
      _Copy(
        'සියයේ ඉලක්කම 5යි, දහයේ ඉලක්කම 0යි, එකක ඉලක්කම 8යි. සංඛ්‍යාව කුමක්ද?',
        'The hundreds digit is 5, the tens digit is 0, and the ones digit is 8. What is the number?',
        'நூறுகள் இலக்கம் 5, பத்துகள் இலக்கம் 0, ஒன்றுகள் இலக்கம் 8. எண் எது?',
      ),
      _Copy(
        '1, 4, 8 ඉලක්කම් එක් වර බැගින් යොදා විශාලම සංඛ්‍යාවත් කුඩාම සංඛ්‍යාවත් ලියන්න.',
        'Use 1, 4, and 8 once each to write the greatest and the smallest number.',
        '1, 4, 8 ஆகியவற்றை ஒவ்வொன்றும் ஒருமுறை பயன்படுத்தி மிகப்பெரிய மற்றும் மிகச்சிறிய எண்ணை எழுதுங்கள்.',
      ),
    ],
    quiz: [
      _QuizQuestion(
        question: _Copy(
          'සියයේ ඉලක්කම 3යි, දහයේ ඉලක්කම 7යි, එකක ඉලක්කම 1යි. සංඛ්‍යාව කුමක්ද?',
          'The hundreds digit is 3, the tens digit is 7, and the ones digit is 1. What is the number?',
          'நூறுகள் இலக்கம் 3, பத்துகள் இலக்கம் 7, ஒன்றுகள் இலக்கம் 1. எண் எது?',
        ),
        options: [
          _Copy('317', '317', '317'),
          _Copy('371', '371', '371'),
          _Copy('713', '713', '713'),
          _Copy('137', '137', '137'),
        ],
        correctIndex: 1,
        explanation: _Copy(
          '3 සියයේ, 7 දහයේ, 1 එකක ස්ථානයේ තැබූ විට 371 ලැබේ.',
          'Putting 3 in hundreds, 7 in tens, and 1 in ones gives 371.',
          '3 ஐ நூறுகள், 7 ஐ பத்துகள், 1 ஐ ஒன்றுகள் இடத்தில் வைத்தால் 371 கிடைக்கும்.',
        ),
      ),
      _QuizQuestion(
        question: _Copy(
          '2, 6, 9 ඉලක්කම් එක් වර බැගින් යොදා සෑදිය හැකි විශාලම සංඛ්‍යාව කුමක්ද?',
          'What is the greatest number you can make using 2, 6, and 9 once each?',
          '2, 6, 9 ஆகியவற்றை ஒவ்வொன்றும் ஒருமுறை பயன்படுத்தி உருவாக்கக்கூடிய மிகப்பெரிய எண் எது?',
        ),
        options: [
          _Copy('269', '269', '269'),
          _Copy('629', '629', '629'),
          _Copy('962', '962', '962'),
          _Copy('926', '926', '926'),
        ],
        correctIndex: 2,
        explanation: _Copy(
          'විශාලම ඉලක්කම වන 9 සියයේ ස්ථානයට, 6 දහයේ ස්ථානයට, 2 එකක ස්ථානයට තබමු.',
          'Put the largest digit, 9, in the hundreds place, then 6, then 2.',
          'மிகப்பெரிய இலக்கமான 9 ஐ நூறுகள் இடத்திலும், பின்னர் 6, 2 ஆகியவற்றையும் வையுங்கள்.',
        ),
      ),
      _QuizQuestion(
        question: _Copy(
          '4, 8, 12, 16, __. ඊළඟ සංඛ්‍යාව කුමක්ද?',
          '4, 8, 12, 16, __. What is the next number?',
          '4, 8, 12, 16, __. அடுத்த எண் எது?',
        ),
        options: [
          _Copy('18', '18', '18'),
          _Copy('19', '19', '19'),
          _Copy('20', '20', '20'),
          _Copy('24', '24', '24'),
        ],
        correctIndex: 2,
        explanation: _Copy(
          'සෑම පියවරකම 4 බැගින් එකතු වේ. 16 + 4 = 20.',
          'Add 4 each time. 16 + 4 = 20.',
          'ஒவ்வொரு முறையும் 4 சேர்க்கப்படுகிறது. 16 + 4 = 20.',
        ),
      ),
    ],
  ),
];

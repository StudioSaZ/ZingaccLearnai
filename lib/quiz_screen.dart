import 'package:flutter/material.dart';

import 'zingacc_brand_banner.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
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
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestion = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;
  String t(
      String sinhala,
      String english,
      String tamil,
      ) {
    if (widget.language == 'සිංහල') {
      return sinhala;
    }
    if (widget.language == 'தமிழ்') {
      return tamil;
    }
    return english;
  }

  String get _levelName {
    switch (widget.selectedLevel) {
      case 'grade_6':
        return 'Grade 6';
      case 'grade_7':
        return 'Grade 7';
      case 'grade_8':
        return 'Grade 8';
      case 'grade_9':
        return 'Grade 9';
      case 'ol':
        return 'O/L';
      case 'al':
        return 'A/L';
      default:
        return widget.selectedLevel.replaceAll('_', ' ');
    }
  }

  String get _mediumName {
    switch (widget.selectedMedium) {
      case 'sinhala':
        return 'Sinhala Medium';
      case 'english':
        return 'English Medium';
      case 'tamil':
        return 'Tamil Medium';
      default:
        return widget.selectedMedium.replaceAll('_', ' ');
    }
  }

  String get _subjectName {
    switch (widget.selectedSubject) {
      case 'mathematics':
      case 'maths':
        return 'Mathematics';
      case 'science':
        return 'Science';
      case 'english':
        return 'English';
      case 'sinhala':
        return 'Sinhala';
      case 'tamil':
        return 'Tamil';
      case 'history':
        return 'History';
      case 'geography':
        return 'Geography';
      case 'ict':
        return 'ICT';
      default:
        return widget.selectedSubject.replaceAll('_', ' ');
    }
  }

  bool get _hasVerifiedQuiz {
    final level = widget.selectedLevel.toLowerCase();
    final subject = widget.selectedSubject.toLowerCase();
    return level == 'grade_6' &&
        (subject == 'mathematics' || subject == 'maths' || subject == 'ගණිතය');
  }

  List<_QuizQuestion> get _questions {
    return [
      _QuizQuestion(
        question: t(
            '6,241 හි 2 ඉලක්කමේ අගය කීයද?',
            'What is the value of 2 in 6,241?',
            '6,241 இல் 2 இன் பெறுமானம் என்ன?'),
        options: [
          t('2', '2', '2'),
          t('20', '20', '20'),
          t('200', '200', '200'),
          t('2,000', '2,000', '2,000')
        ],
        correctIndex: 2,
        explanation: t(
            '2 සියයේ ස්ථානයේ ඇති නිසා එහි අගය 200 යි.',
            '2 is in the hundreds place, so its value is 200.',
            '2 நூறுகள் இடத்தில் இருப்பதால் அதன் பெறுமானம் 200.'),
      ),
      _QuizQuestion(
        question: t('27 × 100 = ?', '27 × 100 = ?', '27 × 100 = ?'),
        options: [
          t('270', '270', '270'),
          t('2,070', '2,070', '2,070'),
          t('2,700', '2,700', '2,700'),
          t('27,000', '27,000', '27,000')
        ],
        correctIndex: 2,
        explanation: t(
            '27 සියයෙන් ගුණ කළ විට 2,700 වේ.',
            '27 multiplied by 100 is 2,700.',
            '27 ஐ 100 ஆல் பெருக்கினால் 2,700.'),
      ),
      _QuizQuestion(
        question: t(
            'සංඛ්‍යා රේඛාවක දකුණට යන විට සංඛ්‍යා…',
            'As you move right on a number line, numbers…',
            'எண் கோட்டில் வலப்புறம் செல்லும்போது எண்கள்…'),
        options: [
          t('අඩු වේ', 'decrease', 'குறையும்'),
          t('වැඩි වේ', 'increase', 'அதிகரிக்கும்'),
          t('වෙනස් නොවේ', 'stay the same', 'மாறாது'),
          t('අතුරුදන් වේ', 'disappear', 'மறையும்')
        ],
        correctIndex: 1,
        explanation: t(
            'දකුණට ගමන් කරන විට සංඛ්‍යා අගය වැඩි වේ.',
            'Numbers increase as you move to the right.',
            'வலப்புறம் செல்லும்போது எண்களின் பெறுமானம் அதிகரிக்கும்.'),
      ),
      _QuizQuestion(
        question: t(
            'කෝණයක දෙපස හමුවන ලක්ෂ්‍යය හඳුන්වන්නේ කෙසේද?',
            'What is the point where the arms of an angle meet called?',
            'கோணத்தின் இரு பக்கங்களும் சந்திக்கும் புள்ளி எவ்வாறு அழைக்கப்படுகிறது?'),
        options: [
          t('අග්‍රය', 'Vertex', 'உச்சி'),
          t('මධ්‍යය', 'Centre', 'மையம்'),
          t('දාරය', 'Edge', 'விளிம்பு'),
          t('පැත්ත', 'Side', 'பக்கம்')
        ],
        correctIndex: 0,
        explanation: t(
            'කෝණයේ දෙපස හමුවන පොදු ලක්ෂ්‍යය අග්‍රයයි.',
            'The common point where the arms meet is the vertex.',
            'கோணத்தின் பக்கங்கள் சந்திக்கும் பொதுப் புள்ளி உச்சி.'),
      ),
      _QuizQuestion(
        question: t(
            '5:10 සිට 5:40 දක්වා කාලය කීයද?',
            'How long is it from 5:10 to 5:40?',
            '5:10 முதல் 5:40 வரை எவ்வளவு நேரம்?'),
        options: [
          t('20 මිනිත්තු', '20 minutes', '20 நிமிடங்கள்'),
          t('30 මිනිත්තු', '30 minutes', '30 நிமிடங்கள்'),
          t('40 මිනිත්තු', '40 minutes', '40 நிமிடங்கள்'),
          t('50 මිනිත්තු', '50 minutes', '50 நிமிடங்கள்')
        ],
        correctIndex: 1,
        explanation: t('40 − 10 = මිනිත්තු 30 යි.', '40 − 10 = 30 minutes.',
            '40 − 10 = 30 நிமிடங்கள்.'),
      ),
      _QuizQuestion(
        question: t(
            '198 + 302 හි පහසු නිමානය කුමක්ද?',
            'What is a convenient estimate for 198 + 302?',
            '198 + 302 க்கான வசதியான மதிப்பீடு எது?'),
        options: [
          t('300', '300', '300'),
          t('400', '400', '400'),
          t('500', '500', '500'),
          t('600', '600', '600')
        ],
        correctIndex: 2,
        explanation: t(
            '198 ≈ 200 සහ 302 ≈ 300; එබැවින් 200 + 300 = 500.',
            '198 ≈ 200 and 302 ≈ 300, so 200 + 300 = 500.',
            '198 ≈ 200, 302 ≈ 300; ஆகவே 200 + 300 = 500.'),
      ),
      _QuizQuestion(
        question: t(
            '18 ට පසු එන 6 හි ඊළඟ ගුණාකාරය කුමක්ද?',
            'What is the next multiple of 6 after 18?',
            '18 க்குப் பின் வரும் 6 இன் அடுத்த மடங்கு எது?'),
        options: [
          t('20', '20', '20'),
          t('22', '22', '22'),
          t('24', '24', '24'),
          t('26', '26', '26')
        ],
        correctIndex: 2,
        explanation: t(
            '6, 12, 18, 24 ලෙස 6 බැගින් වැඩි වේ.',
            'The multiples are 6, 12, 18, 24, increasing by 6.',
            '6, 12, 18, 24 என ஒவ்வொன்றும் 6 அதிகரிக்கிறது.'),
      ),
      _QuizQuestion(
        question: t('පහත කුමක් ඔත්තේ සංඛ්‍යාවක්ද?',
            'Which of these is an odd number?', 'இவற்றில் எது ஒற்றை எண்?'),
        options: [
          t('14', '14', '14'),
          t('26', '26', '26'),
          t('32', '32', '32'),
          t('47', '47', '47')
        ],
        correctIndex: 3,
        explanation: t(
            '47 හි එකක ඉලක්කම 7 නිසා එය ඔත්තේය.',
            '47 ends in 7, so it is odd.',
            '47 இன் ஒன்றுகள் இலக்கம் 7; எனவே அது ஒற்றை.'),
      ),
    ];
  }

  void _selectAnswer(int index) {
    if (_answered) {
      return;
    }
    final question = _questions[_currentQuestion];
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (index == question.correctIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (!_answered) {
      return;
    }
    // අර කැඩිලා තිබුණු අඩු කිරීමේ ලකුණ (-) මෙතන නිවැරදි කරලා තියෙනවා
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
        _answered = false;
      });
      return;
    }
    _showResult();
  }

  void _restartQuiz() {
    Navigator.of(context).pop();
    setState(() {
      _currentQuestion = 0;
      _score = 0;
      _selectedAnswer = null;
      _answered = false;
    });
  }

  void _showResult() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF112A20), // Dark Green Background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFFD4AF37), width: 2), // Gold Border
          ),
          title: Column(
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFFD4AF37), // Gold Icon
                size: 54,
              ),
              const SizedBox(height: 10),
              Text(
                t(
                  'ප්‍රශ්නාවලිය අවසන්! 🎉',
                  'Quiz Complete! 🎉',
                  'வினாடி வினா முடிந்தது! 🎉',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t(
                  'ඔබගේ ලකුණු',
                  'Your Score',
                  'உங்கள் மதிப்பெண்',
                ),
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                '$_score / ${_questions.length}',
                style: const TextStyle(
                  color: Color(0xFFD4AF37), // Gold Score
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _resultMessage(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                t(
                  'Dashboard වෙත',
                  'Back',
                  'திரும்பு',
                ),
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            FilledButton.icon(
              onPressed: _restartQuiz,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37), // Gold Button
                foregroundColor: const Color(0xFF0A1C14), // Dark Green Text
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                t(
                  'නැවත කරන්න',
                  'Try Again',
                  'மீண்டும் முயற்சி',
                ),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  String _resultMessage() {
    if (_score == _questions.length) {
      return t(
        'විශිෂ්ටයි! සියලුම පිළිතුරු නිවැරදියි.',
        'Excellent! You answered every question correctly.',
        'சிறப்பு! எல்லா கேள்விகளுக்கும் சரியாக பதிலளித்துள்ளீர்கள்.',
      );
    }
    if (_score >= 6) {
      return t(
        'හොඳ වැඩක්! තව ටිකක් පුහුණු වුණොත් තවත් හොඳයි.',
        'Good work! A little more practice will make it even better.',
        'நல்ல முயற்சி! இன்னும் சிறிது பயிற்சி செய்தால் மேலும் சிறப்பாகும்.',
      );
    }
    return t(
      'පාඩම නැවත බලලා තවත් වරක් උත්සාහ කරන්න.',
      'Review the lesson and try the quiz again.',
      'பாடத்தை மீண்டும் பார்த்து வினாடி வினாவை மீண்டும் முயற்சி செய்யுங்கள்.',
    );
  }

  Color _optionColor(
      int index,
      _QuizQuestion question,
      ) {
    if (!_answered) {
      return const Color(0xFF0A1C14); // Very Dark Green
    }
    if (index == question.correctIndex) {
      return const Color(0xFF0F472B); // Success Green
    }
    if (index == _selectedAnswer && index != question.correctIndex) {
      return const Color(0xFF6B1F27); // Error Red
    }
    return const Color(0xFF0A1C14);
  }

  Color _optionBorderColor(
      int index,
      _QuizQuestion question,
      ) {
    const gold = Color(0xFFD4AF37);
    if (!_answered) {
      return gold.withOpacity(0.5); // Gold border
    }
    if (index == question.correctIndex) {
      return const Color(0xFF24E69A); // Success Border
    }
    if (index == _selectedAnswer && index != question.correctIndex) {
      return const Color(0xFFFF7182); // Error Border
    }
    return gold.withOpacity(0.2);
  }

  IconData? _optionIcon(
      int index,
      _QuizQuestion question,
      ) {
    if (!_answered) {
      return null;
    }
    if (index == question.correctIndex) {
      return Icons.check_circle_rounded;
    }
    if (index == _selectedAnswer && index != question.correctIndex) {
      return Icons.cancel_rounded;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF0A1C14); // Deep Dark Green
    const panel = Color(0xFF112A20); // Dark Green Panel
    const gold = Color(0xFFD4AF37); // Premium Gold

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: gold, // Gold Title
        elevation: 0,
        title: Text(
          t(
            'ප්‍රශ්නාවලිය',
            'Quiz',
            'வினாடி வினா',
          ),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: _hasVerifiedQuiz
            ? _buildQuiz(
          panel: panel,
          gold: gold,
        )
            : _buildComingSoon(
          panel: panel,
          gold: gold,
        ),
      ),
    );
  }

  Widget _buildQuiz({
    required Color panel,
    required Color gold,
  }) {
    final question = _questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / _questions.length;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 700;
        return ListView(
          padding: EdgeInsets.fromLTRB(
            wide ? 30 : 15,
            12,
            wide ? 30 : 15,
            30,
          ),
          children: [
            const ZingaccBrandBanner(compact: true),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ContextChip(
                  icon: Icons.school_rounded,
                  text: _levelName,
                ),
                _ContextChip(
                  icon: Icons.language_rounded,
                  text: _mediumName,
                ),
                _ContextChip(
                  icon: Icons.menu_book_rounded,
                  text: _subjectName,
                ),
                _ContextChip(
                  icon: Icons.translate_rounded,
                  text: widget.language,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFE5C058), // Light Gold
                    Color(0xFFB58E29), // Dark Gold
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1C14).withValues(
                        alpha: 0.18,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.quiz_rounded,
                      color: Color(0xFF0A1C14),
                      size: 31,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t(
                            '6 ශ්‍රේණිය ගණිතය — මොඩියුල 1–3 ප්‍රශ්නාවලිය',
                            'Grade 6 Mathematics — Modules 1–3 Quiz',
                            'தரம் 6 கணிதம் — தொகுதிகள் 1–3 வினாடி வினா',
                          ),
                          style: const TextStyle(
                            color: Color(0xFF0A1C14),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t(
                            'ඔබගේ දැනුම පරීක්ෂා කරන්න',
                            'Test your understanding',
                            'உங்கள் புரிதலைச் சோதியுங்கள்',
                          ),
                          style: const TextStyle(
                              color: Color(0xFF0A1C14),
                              fontSize: 13,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${t(
                      'ප්‍රශ්නය',
                      'Question',
                      'கேள்வி',
                    )} ${_currentQuestion + 1} / ${_questions.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    color: gold,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 9,
                backgroundColor: panel,
                valueColor: AlwaysStoppedAnimation<Color>(gold),
              ),
            ),
            const SizedBox(height: 17),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: gold.withOpacity(0.3),
                ),
              ),
              child: Text(
                question.question,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 14),
            ...List.generate(
              question.options.length,
                  (index) {
                final letters = ['A', 'B', 'C', 'D'];
                final icon = _optionIcon(
                  index,
                  question,
                );
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(17),
                    child: InkWell(
                      onTap: () => _selectAnswer(index),
                      borderRadius: BorderRadius.circular(17),
                      child: AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 180,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: _optionColor(
                            index,
                            question,
                          ),
                          borderRadius: BorderRadius.circular(17),
                          border: Border.all(
                            color: _optionBorderColor(
                              index,
                              question,
                            ),
                            width: 1.4,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: gold.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                letters[index],
                                style: TextStyle(
                                  color: gold,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                question.options[index],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  height: 1.35,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (icon != null) ...[
                              const SizedBox(width: 8),
                              Icon(
                                icon,
                                color: Colors.white,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            if (_answered) ...[
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: gold.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_rounded,
                      color: Color(0xFFD4AF37), // Gold Icon
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        question.explanation,
                        style: const TextStyle(
                          color: Colors.white,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _nextQuestion,
                  style: FilledButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: const Color(0xFF0A1C14),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: Icon(
                    // අර කැඩිලා තිබුණු අඩු කිරීමේ ලකුණ (-) මෙතන නිවැරදි කරලා තියෙනවා
                    _currentQuestion == _questions.length - 1
                        ? Icons.emoji_events_rounded
                        : Icons.arrow_forward_rounded,
                  ),
                  label: Text(
                    // අර කැඩිලා තිබුණු අඩු කිරීමේ ලකුණ (-) මෙතන නිවැරදි කරලා තියෙනවා
                    _currentQuestion == _questions.length - 1
                        ? t(
                      'ප්‍රතිඵල බලන්න',
                      'View Result',
                      'முடிவைப் பார்க்க',
                    )
                        : t(
                      'ඊළඟ ප්‍රශ්නය',
                      'Next Question',
                      'அடுத்த கேள்வி',
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildComingSoon({
    required Color panel,
    required Color gold,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Container(
          // අර කැඩිලා තිබුණු අඩු කිරීමේ ලකුණ (-) මෙතන නිවැරදි කරලා තියෙනවා
          width: MediaQuery.sizeOf(context).width < 564
              ? MediaQuery.sizeOf(context).width - 44
              : 520,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: gold.withOpacity(0.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ZingaccBrandBanner(compact: true),
              const SizedBox(height: 16),
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFF9D976),
                      Color(0xFFD4AF37), // Gold
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.quiz_rounded,
                  color: Color(0xFF0A1C14), // Dark Green
                  size: 40,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                t(
                  'ප්‍රශ්නාවලි සකස් කරමින් පවතී',
                  'Quiz content is being prepared',
                  'வினாடி வினா உள்ளடக்கம் தயாராகிறது',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                t(
                  'නිල පාඩම් අන්තර්ගතය තහවුරු කළ පසු මෙම මට්ටම සහ විෂය සඳහා ප්‍රශ්නාවලි එක් කරනු ලැබේ.',
                  'Quizzes for this level and subject will be added after the official lesson content is verified.',
                  'அதிகாரப்பூர்வ பாட உள்ளடக்கம் சரிபார்க்கப்பட்ட பின் இந்த நிலை மற்றும் பாடத்திற்கான வினாடி வினாக்கள் சேர்க்கப்படும்.',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ContextChip(
                    icon: Icons.school_rounded,
                    text: _levelName,
                  ),
                  _ContextChip(
                    icon: Icons.language_rounded,
                    text: _mediumName,
                  ),
                  _ContextChip(
                    icon: Icons.menu_book_rounded,
                    text: _subjectName,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: gold,
                  side: BorderSide(
                    color: gold.withOpacity(0.5),
                  ),
                ),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                ),
                label: Text(
                  t(
                    'ආපසු යන්න',
                    'Go Back',
                    'திரும்பிச் செல்லவும்',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizQuestion {
  const _QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
}

class _ContextChip extends StatelessWidget {
  const _ContextChip({
    required this.icon,
    required this.text,
  });
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4AF37);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1C14), // Deep Dark Green
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: gold.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: gold, // Gold Icon
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
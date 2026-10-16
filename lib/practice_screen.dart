import 'package:flutter/material.dart';

import 'zingacc_brand_banner.dart';

/// Practice page for the learning path selected on the Dashboard.
///
/// Grade 6 Mathematics practice covers the verified content in Modules 1–3.
/// Other grades and subjects receive an honest "coming soon" message.
class PracticeScreen extends StatefulWidget {
  const PracticeScreen({
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
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  static const Color _navy = Color(0xFF071633);
  static const Color _blue = Color(0xFF175CD3);
  static const Color _purple = Color(0xFF6C4DBA);
  static const Color _page = Color(0xFFF7F8FC);
  static const Color _ink = Color(0xFF1D2939);
  static const Color _muted = Color(0xFF667085);

  int _currentQuestion = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;
  bool _showingResult = false;

  String t(String sinhala, String english, String tamil) {
    final language = widget.language.trim().toLowerCase();
    if (language == 'සිංහල' || language == 'sinhala') {
      return sinhala;
    }
    if (language == 'தமிழ்' || language == 'tamil') {
      return tamil;
    }
    return english;
  }

  bool get _supportsPractice {
    final level = widget.selectedLevel.trim().toLowerCase();
    final subject = widget.selectedSubject.trim().toLowerCase();
    return level == 'grade_6' &&
        (subject == 'mathematics' || subject == 'maths' || subject == 'ගණිතය');
  }

  List<_PracticeQuestion> get _questions => [
    _PracticeQuestion(
      question: t(
        '4,582 හි 5 ඉලක්කමේ අගය කීයද?',
        'What is the value of 5 in 4,582?',
        '4,582 இல் 5 இன் பெறுமானம் என்ன?',
      ),
      options: [
        t('5', '5', '5'),
        t('50', '50', '50'),
        t('500', '500', '500'),
        t('5,000', '5,000', '5,000'),
      ],
      correctIndex: 2,
      explanation: t(
        '5 සියයේ ස්ථානයේ ඇති නිසා එහි අගය 500 යි.',
        '5 is in the hundreds place, so its value is 500.',
        '5 நூறுகள் இடத்தில் இருப்பதால் அதன் பெறுமானம் 500.',
      ),
    ),
    _PracticeQuestion(
      question: t('348 + 276 = ?', '348 + 276 = ?', '348 + 276 = ?'),
      options: [
        t('514', '514', '514'),
        t('614', '614', '614'),
        t('624', '624', '624'),
        t('634', '634', '634'),
      ],
      correctIndex: 2,
      explanation: t(
        'එකක, දහය සහ සියය ස්ථාන එකතු කළ විට 624 ලැබේ.',
        'Adding the ones, tens, and hundreds gives 624.',
        'ஒன்றுகள், பத்துகள், நூறுகளை கூட்டினால் 624 கிடைக்கும்.',
      ),
    ),
    _PracticeQuestion(
      question: t(
        'සංඛ්‍යා රේඛාවේ 4 සහ 6 අතර ඇති සංඛ්‍යාව කුමක්ද?',
        'Which number lies between 4 and 6 on a number line?',
        'எண் கோட்டில் 4க்கும் 6க்கும் இடையில் உள்ள எண் எது?',
      ),
      options: [
        t('3', '3', '3'),
        t('5', '5', '5'),
        t('7', '7', '7'),
        t('8', '8', '8'),
      ],
      correctIndex: 1,
      explanation: t(
        '4 ට පසු සහ 6 ට පෙර 5 පිහිටයි.',
        '5 comes after 4 and before 6.',
        '4 க்குப் பின், 6 க்கு முன் 5 வருகிறது.',
      ),
    ),
    _PracticeQuestion(
      question: t(
        'කෝණයක දෙපස හමුවන පොදු ලක්ෂ්‍යය කුමක්ද?',
        'What is the point where the two arms of an angle meet called?',
        'கோணத்தின் இரு பக்கங்களும் சந்திக்கும் புள்ளி எது?',
      ),
      options: [
        t('අග්‍රය', 'Vertex', 'உச்சி'),
        t('මධ්‍යය', 'Centre', 'மையம்'),
        t('දාරය', 'Edge', 'விளிம்பு'),
        t('වටය', 'Circle', 'வட்டம்'),
      ],
      correctIndex: 0,
      explanation: t(
        'කෝණයේ දෙපස හමුවන ලක්ෂ්‍යය අග්‍රයයි.',
        'The point where the arms meet is the vertex.',
        'கோணத்தின் பக்கங்கள் சந்திக்கும் புள்ளி உச்சி.',
      ),
    ),
    _PracticeQuestion(
      question: t(
        'පැය 1ක මිනිත්තු කීයක් තිබේද?',
        'How many minutes are in 1 hour?',
        '1 மணியில் எத்தனை நிமிடங்கள்?',
      ),
      options: [
        t('30', '30', '30'),
        t('60', '60', '60'),
        t('100', '100', '100'),
        t('120', '120', '120'),
      ],
      correctIndex: 1,
      explanation: t(
        'පැය 1ක මිනිත්තු 60 කි.',
        'There are 60 minutes in 1 hour.',
        '1 மணியில் 60 நிமிடங்கள் உள்ளன.',
      ),
    ),
    _PracticeQuestion(
      question: t(
        '346 ආසන්න දහයට වට කළ විට ලැබෙන්නේ කුමක්ද?',
        'What is 346 rounded to the nearest ten?',
        '346 ஐ அருகிலுள்ள பத்துக்கு அண்மித்தால் என்ன?',
      ),
      options: [
        t('340', '340', '340'),
        t('345', '345', '345'),
        t('350', '350', '350'),
        t('400', '400', '400'),
      ],
      correctIndex: 2,
      explanation: t(
        'එකක ඉලක්කම 6 නිසා ඉහළට වට කර 350 ලැබේ.',
        'The ones digit is 6, so round up to 350.',
        'ஒன்றுகள் இலக்கம் 6 என்பதால் மேலாக அண்மித்து 350 கிடைக்கும்.',
      ),
    ),
    _PracticeQuestion(
      question: t('පහත කුමක් 12 හි සාධකයක්ද?', 'Which is a factor of 12?',
          'இவற்றில் எது 12 இன் காரணி?'),
      options: [
        t('5', '5', '5'),
        t('7', '7', '7'),
        t('3', '3', '3'),
        t('10', '10', '10'),
      ],
      correctIndex: 2,
      explanation: t(
        '12 ÷ 3 = 4; එබැවින් 3, 12 හි සාධකයකි.',
        '12 ÷ 3 = 4, so 3 is a factor of 12.',
        '12 ÷ 3 = 4; எனவே 3 என்பது 12 இன் காரணி.',
      ),
    ),
    _PracticeQuestion(
      question: t(
        '3, 6, 9, 12, __. ඊළඟට එන්නේ කුමක්ද?',
        '3, 6, 9, 12, __. What comes next?',
        '3, 6, 9, 12, __. அடுத்து எது?',
      ),
      options: [
        t('13', '13', '13'),
        t('14', '14', '14'),
        t('15', '15', '15'),
        t('16', '16', '16'),
      ],
      correctIndex: 2,
      explanation: t(
        'සෑම පියවරකම 3 බැගින් එකතු වේ. ඊළඟ පදය 15 යි.',
        'Add 3 each time. The next term is 15.',
        'ஒவ்வொரு முறையும் 3 ஐ கூட்டுங்கள். அடுத்த உறுப்பு 15.',
      ),
    ),
  ];

  void _selectAnswer(int index) {
    if (_answered ||
        index < 0 ||
        index >= _questions[_currentQuestion].options.length) {
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

  void _restartPractice() {
    setState(() {
      _currentQuestion = 0;
      _score = 0;
      _selectedAnswer = null;
      _answered = false;
      _showingResult = false;
    });
  }

  void _showResult() {
    if (_showingResult || !mounted) {
      return;
    }
    _showingResult = true;

    final percentage = ((_score / _questions.length) * 100).round();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          t(
            'පුහුණුව අවසන්! 🎉',
            'Practice complete! 🎉',
            'பயிற்சி முடிந்தது! 🎉',
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              size: 66,
              color: Colors.amber,
            ),
            const SizedBox(height: 12),
            Text(
              t('ඔබගේ ලකුණු', 'Your score', 'உங்கள் மதிப்பெண்'),
              style: const TextStyle(
                color: _muted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$_score / ${_questions.length}',
              style: const TextStyle(
                color: _ink,
                fontSize: 34,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '$percentage%',
              style: const TextStyle(
                color: _blue,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _resultMessage(),
              textAlign: TextAlign.center,
              style: const TextStyle(height: 1.45),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            child: Text(
              t('Dashboard වෙත', 'Back to Dashboard', 'Dashboard-க்கு'),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (mounted) {
                _restartPractice();
              }
            },
            child: Text(
              t('නැවත කරන්න', 'Try again', 'மீண்டும் முயற்சி'),
            ),
          ),
        ],
      ),
    ).then((_) {
      if (mounted && _showingResult) {
        setState(() => _showingResult = false);
      }
    });
  }

  String _resultMessage() {
    if (_score == _questions.length) {
      return t(
        'ඉතා හොඳයි! සියලු ප්‍රශ්න නිවැරදියි.',
        'Excellent! You got every question right.',
        'மிகச் சிறப்பு! எல்லா கேள்விகளுக்கும் சரியாகப் பதிலளித்தீர்கள்.',
      );
    }
    if (_score >= 6) {
      return t(
        'හොඳ වැඩක්! වැරදුණු පිළිතුරු නැවත බලලා තවත් පුහුණු වෙන්න.',
        'Good work! Review the missed answers and practise once more.',
        'நல்ல முயற்சி! தவறிய பதில்களை மீண்டும் பார்த்து மேலும் பயிற்சி செய்யுங்கள்.',
      );
    }
    return t(
      'හොඳ උත්සාහයක්! පැහැදිලි කිරීම් නැවත බලලා තවත් වරක් උත්සාහ කරන්න.',
      'Nice effort! Review the explanations and try once more.',
      'நல்ல முயற்சி! விளக்கங்களை மீண்டும் பார்த்து இன்னொரு முறை முயற்சி செய்யுங்கள்.',
    );
  }

  Color _optionFill(int index, _PracticeQuestion question) {
    if (!_answered) {
      return Colors.white;
    }
    if (index == question.correctIndex) {
      return const Color(0xFFE9F8EE);
    }
    if (index == _selectedAnswer) {
      return const Color(0xFFFFEEEE);
    }
    return Colors.white;
  }

  Color _optionBorder(int index, _PracticeQuestion question) {
    if (!_answered) {
      return const Color(0xFFD8DDE8);
    }
    if (index == question.correctIndex) {
      return const Color(0xFF20A464);
    }
    if (index == _selectedAnswer) {
      return const Color(0xFFD92D20);
    }
    return const Color(0xFFD8DDE8);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _page,
      appBar: AppBar(
        title: Text(t('පුහුණුව', 'Practice', 'பயிற்சி')),
        centerTitle: true,
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: _supportsPractice ? _buildPractice() : _buildComingSoon(),
      ),
    );
  }

  Widget _buildPractice() {
    final question = _questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / _questions.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ZingaccBrandBanner(compact: true),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.school_rounded,
                    text: _levelName(),
                  ),
                  _InfoChip(
                    icon: Icons.language_rounded,
                    text: _mediumName(),
                  ),
                  _InfoChip(
                    icon: Icons.calculate_rounded,
                    text: _subjectName(),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                t(
                  '6 ශ්‍රේණිය ගණිතය — මොඩියුල 1–3 පුහුණුව',
                  'Grade 6 Mathematics — Modules 1–3 Practice',
                  'தரம் 6 கணிதம் — தொகுதிகள் 1–3 பயிற்சி',
                ),
                style: const TextStyle(
                  color: _ink,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t(
                  'ප්‍රශ්නය ${_currentQuestion + 1} / ${_questions.length}',
                  'Question ${_currentQuestion + 1} of ${_questions.length}',
                  'கேள்வி ${_currentQuestion + 1} / ${_questions.length}',
                ),
                style: const TextStyle(
                  color: _muted,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 9,
                  backgroundColor: const Color(0xFFE4E7EC),
                  valueColor: const AlwaysStoppedAnimation<Color>(_purple),
                  semanticsLabel: t(
                    'පුහුණුවේ ප්‍රගතිය',
                    'Practice progress',
                    'பயிற்சி முன்னேற்றம்',
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE7EAF1)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x10000000),
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  question.question,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 19,
                    height: 1.55,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              for (var index = 0; index < question.options.length; index++)
                _answerOption(question, index),
              if (_answered) ...[
                const SizedBox(height: 6),
                _answerFeedback(question),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _nextQuestion,
                  icon: Icon(
                    _currentQuestion == _questions.length - 1
                        ? Icons.emoji_events_rounded
                        : Icons.arrow_forward_rounded,
                  ),
                  label: Text(
                    _currentQuestion == _questions.length - 1
                        ? t('ප්‍රතිඵල බලන්න', 'See result', 'முடிவைப் பார்க்க')
                        : t('ඊළඟ ප්‍රශ්නය', 'Next question', 'அடுத்த கேள்வி'),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: _blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _answerOption(_PracticeQuestion question, int index) {
    final isCorrect = index == question.correctIndex;
    final isChosen = index == _selectedAnswer;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _answered ? null : () => _selectAnswer(index),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: const BoxConstraints(minHeight: 62),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _optionFill(index, question),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _optionBorder(index, question),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _answered && isCorrect
                        ? const Color(0xFFD7F2E0)
                        : const Color(0xFFF0F2F7),
                  ),
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: const TextStyle(
                      color: _ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.options[index],
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 16,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_answered && isCorrect)
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF20A464))
                else if (_answered && isChosen)
                  const Icon(Icons.cancel_rounded, color: Color(0xFFD92D20)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _answerFeedback(_PracticeQuestion question) {
    final correct = _selectedAnswer == question.correctIndex;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: correct ? const Color(0xFFEAF8EF) : const Color(0xFFFFF5E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: correct ? const Color(0xFFB7E4C7) : const Color(0xFFFFD7A8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                correct ? Icons.check_circle_rounded : Icons.lightbulb_rounded,
                color:
                correct ? const Color(0xFF16834A) : const Color(0xFFB54708),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  correct
                      ? t('නිවැරදියි! 🎉', 'Correct! 🎉', 'சரி! 🎉')
                      : t('නිවැරදි පිළිතුර', 'Correct answer', 'சரியான பதில்'),
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (!correct) ...[
            const SizedBox(height: 8),
            Text(
              question.options[question.correctIndex],
              style: const TextStyle(
                color: _ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 9),
          Text(
            question.explanation,
            style: const TextStyle(
              color: _ink,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoon() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            children: [
              const ZingaccBrandBanner(compact: true),
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(icon: Icons.school_rounded, text: _levelName()),
                  _InfoChip(icon: Icons.language_rounded, text: _mediumName()),
                  _InfoChip(
                      icon: Icons.menu_book_rounded, text: _subjectName()),
                ],
              ),
              const SizedBox(height: 26),
              const Icon(
                Icons.auto_stories_rounded,
                size: 68,
                color: _purple,
              ),
              const SizedBox(height: 18),
              Text(
                t(
                  'මෙම විෂයට පුහුණු ප්‍රශ්න සූදානම් කරමින් පවතී',
                  'Practice questions for this subject are being prepared',
                  'இந்தப் பாடத்திற்கான பயிற்சி கேள்விகள் தயாராகின்றன',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 22,
                  height: 1.35,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                t(
                  'දැනට තහවුරු කළ පුහුණුව 6 ශ්‍රේණියේ ගණිත මොඩියුල 1–3 සඳහායි. වෙනත් ශ්‍රේණි සහ විෂයයන් සඳහා පුහුණුව සකස් කරමින් පවතී.',
                  'Verified practice is currently available for Grade 6 Mathematics Modules 1–3. Practice for other grades and subjects is being prepared.',
                  'தற்போது சரிபார்க்கப்பட்ட பயிற்சி தரம் 6 கணிதத் தொகுதிகள் 1–3 க்கு உள்ளது. பிற வகுப்புகள் மற்றும் பாடங்களுக்கான பயிற்சி தயாராகிறது.',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 15,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(t('ආපසු යන්න', 'Go back', 'திரும்பிச் செல்ல')),
                style: FilledButton.styleFrom(
                  backgroundColor: _blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _levelName() {
    final level = widget.selectedLevel.trim().toLowerCase();
    switch (level) {
      case 'grade_5_scholarship':
        return t('5 ශ්‍රේණි ශිෂ්‍යත්වය', 'Grade 5 Scholarship',
            'தரம் 5 புலமைப்பரிசில்');
      case 'grade_6':
        return t('6 ශ්‍රේණිය', 'Grade 6', 'தரம் 6');
      case 'grade_7':
        return t('7 ශ්‍රේණිය', 'Grade 7', 'தரம் 7');
      case 'grade_8':
        return t('8 ශ්‍රේණිය', 'Grade 8', 'தரம் 8');
      case 'grade_9':
        return t('9 ශ්‍රේණිය', 'Grade 9', 'தரம் 9');
      case 'ol':
        return 'O/L';
      case 'al':
        return 'A/L';
      default:
        return widget.selectedLevel.trim().replaceAll('_', ' ');
    }
  }

  String _mediumName() {
    final medium = widget.selectedMedium.trim().toLowerCase();
    switch (medium) {
      case 'sinhala':
        return t('සිංහල මාධ්‍යය', 'Sinhala medium', 'சிங்கள மொழிமூலம்');
      case 'english':
        return t('ඉංග්‍රීසි මාධ්‍යය', 'English medium', 'ஆங்கில மொழிமூலம்');
      case 'tamil':
        return t('දෙමළ මාධ්‍යය', 'Tamil medium', 'தமிழ் மொழிமூலம்');
      default:
        return widget.selectedMedium.trim();
    }
  }

  String _subjectName() {
    final subject = widget.selectedSubject.trim().toLowerCase();
    if (subject == 'mathematics' || subject == 'maths' || subject == 'ගණිතය') {
      return t('ගණිතය', 'Mathematics', 'கணிதம்');
    }
    if (subject == 'science' || subject == 'විද්‍යාව') {
      return t('විද්‍යාව', 'Science', 'அறிவியல்');
    }
    if (subject == 'english' || subject == 'english_language') {
      return t('ඉංග්‍රීසි භාෂාව', 'English Language', 'ஆங்கில மொழி');
    }
    return widget.selectedSubject.trim().replaceAll('_', ' ');
  }
}

class _PracticeQuestion {
  const _PracticeQuestion({
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
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE0E5EF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: _PracticeScreenState._blue),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _PracticeScreenState._ink,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

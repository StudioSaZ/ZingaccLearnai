import 'package:flutter/material.dart';

// Starter reference library. Entries are general examples, not a certified
// complete syllabus. Expand with verified, grade-specific curriculum content.
class FormulaLibraryScreen extends StatefulWidget {
  const FormulaLibraryScreen(
      {super.key,
        required this.selectedLevel,
        required this.selectedSubject,
        required this.language});
  final String selectedLevel;
  final String selectedSubject;
  final String language;
  @override
  State<FormulaLibraryScreen> createState() => _FormulaLibraryScreenState();
}

class _Category {
  const _Category(this.key, this.si, this.en, this.ta);
  final String key, si, en, ta;
}

class _Entry {
  const _Entry(
      this.subject,
      this.enTitle,
      this.siTitle,
      this.taTitle,
      this.enBody,
      this.siBody,
      this.taBody,
      this.enExample,
      this.siExample,
      this.taExample);
  final String subject, enTitle, siTitle, taTitle;
  final String enBody, siBody, taBody;
  final String enExample, siExample, taExample;
}

class _QuickCheck {
  const _QuickCheck(this.siQuestion, this.enQuestion, this.taQuestion,
      this.options, this.correct, this.siWhy, this.enWhy, this.taWhy);
  final String siQuestion, enQuestion, taQuestion;
  final List<String> options;
  final int correct;
  final String siWhy, enWhy, taWhy;
}

class _LessonPractice extends StatefulWidget {
  const _LessonPractice({required this.check, required this.language});
  final _QuickCheck check;
  final String language;
  @override
  State<_LessonPractice> createState() => _LessonPracticeState();
}

class _LessonPracticeState extends State<_LessonPractice> {
  int? selected;
  bool submitted = false;
  bool get si =>
      widget.language == 'සිංහල' || widget.language.toLowerCase() == 'sinhala';
  bool get ta =>
      widget.language == 'தமிழ்' || widget.language.toLowerCase() == 'tamil';
  String t(String s, String e, String a) => si ? s : (ta ? a : e);

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4AF37);
    const panel = Color(0xFF112A20);
    final q = widget.check;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: gold.withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
            t('දැන් ඔබ උත්සාහ කරන්න', 'Try it yourself',
                'நீங்களே முயற்சி செய்யுங்கள்'),
            style: const TextStyle(
                color: gold,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        const SizedBox(height: 10),
        Text(t(q.siQuestion, q.enQuestion, q.taQuestion),
            style: const TextStyle(color: Colors.white, fontSize: 15)),
        const SizedBox(height: 8),
        ...List.generate(
            q.options.length,
                (i) => RadioListTile<int>(
              dense: true,
              contentPadding: EdgeInsets.zero,
              activeColor: gold,
              title: Text(q.options[i],
                  style: const TextStyle(color: Colors.white)),
              value: i,
              groupValue: selected,
              onChanged:
              submitted ? null : (v) => setState(() => selected = v),
            )),
        const SizedBox(height: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: const Color(0xFF0A1C14),
          ),
          onPressed: selected == null || submitted
              ? null
              : () => setState(() => submitted = true),
          child: Text(t('පිළිතුර පරීක්ෂා කරන්න', 'Check answer',
              'விடையைச் சரிபார்க்கவும்'), style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        if (submitted) ...[
          const SizedBox(height: 10),
          Text(
              selected == q.correct
                  ? t('නිවැරදියි! ඉතා හොඳයි.', 'Correct! Well done.',
                  'சரி! மிக நன்று.')
                  : t(
                  'හොඳ උත්සාහයක්. නිවැරදි පිළිතුර බලමු.',
                  'Good try. Review the correct answer.',
                  'நல்ல முயற்சி. சரியான விடையைப் பார்ப்போம்.'),
              style: TextStyle(
                  color: selected == q.correct
                      ? Colors.greenAccent
                      : Colors.orangeAccent,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
              '${t('නිවැරදි පිළිතුර', 'Correct answer', 'சரியான விடை')}: ${q.options[q.correct]}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(t(q.siWhy, q.enWhy, q.taWhy),
              style: const TextStyle(color: Colors.white70, height: 1.5)),
          TextButton(
              onPressed: () => setState(() {
                selected = null;
                submitted = false;
              }),
              child: Text(t(
                  'නැවත උත්සාහ කරන්න', 'Try again', 'மீண்டும் முயற்சி செய்க'),
                  style: const TextStyle(color: gold))),
        ],
      ]),
    );
  }
}

class _FormulaLibraryScreenState extends State<FormulaLibraryScreen> {
  final TextEditingController _search = TextEditingController();
  String _category = 'all';
  bool get _si =>
      widget.language == 'සිංහල' || widget.language.toLowerCase() == 'sinhala';
  bool get _ta =>
      widget.language == 'தமிழ்' || widget.language.toLowerCase() == 'tamil';
  String _t(String si, String en, String ta) => _si ? si : (_ta ? ta : en);

  static const Map<String, _QuickCheck> _gradeFiveChecks = {
    'ස්ථානීය අගය': _QuickCheck(
        '7,364 හි 3 ඉලක්කමේ ස්ථානීය අගය කීයද?',
        'What is the place value of 3 in 7,364?',
        '7,364 இல் 3 இன் இடமதிப்பு என்ன?',
        const ['3', '30', '300', '3000'],
        2,
        '3 සියස් ස්ථානයේ ඇති නිසා අගය 300යි.',
        '3 is in the hundreds place, so its value is 300.',
        '3 நூறுகள் இடத்தில் உள்ளது. எனவே மதிப்பு 300.'),
    'එකතු කිරීම': _QuickCheck(
        '248 + 137 කීයද?',
        'What is 248 + 137?',
        '248 + 137 எவ்வளவு?',
        const ['375', '385', '395', '285'],
        1,
        '248 + 100 = 348; තවත් 37 එකතු කළ විට 385යි.',
        '248 + 100 = 348; adding 37 gives 385.',
        '248 + 100 = 348; மேலும் 37 சேர்த்தால் 385.'),
    'අඩු කිරීම': _QuickCheck(
        '502 − 178 කීයද?',
        'What is 502 − 178?',
        '502 − 178 எவ்வளவு?',
        const ['324', '334', '424', '314'],
        0,
        '502 − 100 = 402; 402 − 78 = 324.',
        '502 − 100 = 402; 402 − 78 = 324.',
        '502 − 100 = 402; 402 − 78 = 324.'),
    'ගුණ කිරීම': _QuickCheck(
        '6 × 4 කීයද?',
        'What is 6 × 4?',
        '6 × 4 எவ்வளவு?',
        const ['10', '20', '24', '28'],
        2,
        '6 බැගින් කණ්ඩායම් 4ක්: 6 + 6 + 6 + 6 = 24.',
        'Four groups of 6: 6 + 6 + 6 + 6 = 24.',
        '6 கொண்ட நான்கு குழுக்கள்: 6 + 6 + 6 + 6 = 24.'),
    'බෙදීම': _QuickCheck(
        '24 ÷ 6 කීයද?',
        'What is 24 ÷ 6?',
        '24 ÷ 6 எவ்வளவு?',
        const ['3', '4', '5', '6'],
        1,
        '24ක් 6 බැගින් බෙදූ විට කණ්ඩායම් 4ක් ලැබේ.',
        '24 divided into groups of 6 makes 4 groups.',
        '24 ஐ 6 வீதம் பிரித்தால் 4 குழுக்கள் கிடைக்கும்.'),
    'භාග': _QuickCheck(
        '1/2 + 1/4 කීයද?',
        'What is 1/2 + 1/4?',
        '1/2 + 1/4 எவ்வளவு?',
        const ['1/4', '2/6', '3/4', '1'],
        2,
        '1/2 = 2/4. එබැවින් 2/4 + 1/4 = 3/4.',
        '1/2 = 2/4, so 2/4 + 1/4 = 3/4.',
        '1/2 = 2/4. ஆகவே 2/4 + 1/4 = 3/4.'),
    'මුදල් ගණනය': _QuickCheck(
        'රු. 100කින් රු. 65ක් වැය කළොත් ඉතිරිය කීයද?',
        'What remains from Rs. 100 after spending Rs. 65?',
        '100 ரூபாயில் 65 ரூபாய் செலவிட்டால் மீதி என்ன?',
        const ['රු. 25', 'රු. 35', 'රු. 45', 'රු. 65'],
        1,
        '100 − 65 = 35.',
        '100 − 65 = 35.',
        '100 − 65 = 35.'),
    'කාලය': _QuickCheck(
        'පෙ.ව. 9:15ට පැයකට පසු වේලාව කීයද?',
        'What time is one hour after 9:15 a.m.?',
        'காலை 9:15 க்கு ஒரு மணி நேரத்திற்குப் பின் நேரம் என்ன?',
        const ['9:45', '10:00', '10:15', '11:15'],
        2,
        '9:15ට පැයක් එකතු කළ විට 10:15 වේ.',
        'One hour after 9:15 is 10:15.',
        '9:15 உடன் ஒரு மணி நேரம் சேர்த்தால் 10:15.'),
    'දිග මැනීම': _QuickCheck(
        'මීටර 2ක් සෙන්ටිමීටර කීයද?',
        'How many centimetres are in 2 metres?',
        '2 மீட்டரில் எத்தனை சென்டிமீட்டர்?',
        const ['20', '100', '200', '2000'],
        2,
        'මීටර 1 = සෙන්ටිමීටර 100. ඒ නිසා මීටර 2 = 200.',
        '1 metre = 100 centimetres; 2 metres = 200.',
        '1 மீட்டர் = 100 சென்டிமீட்டர்; 2 மீட்டர் = 200.'),
    'ස්කන්ධය මැනීම': _QuickCheck(
        'කිලෝග්‍රෑම් 3ක් ග්‍රෑම් කීයද?',
        'How many grams are in 3 kilograms?',
        '3 கிலோகிராமில் எத்தனை கிராம்?',
        const ['30', '300', '3000', '30000'],
        2,
        'කිලෝග්‍රෑම් 1 = ග්‍රෑම් 1000. එබැවින් 3 = 3000.',
        '1 kilogram = 1000 grams; 3 kilograms = 3000 grams.',
        '1 கிலோகிராம் = 1000 கிராம்; 3 கிலோகிராம் = 3000 கிராம்.'),
    'පරිමිතිය': _QuickCheck(
        'දිග 5 cm සහ පළල 3 cm සෘජුකෝණාස්‍රයක පරිමිතිය කීයද?',
        'Perimeter of a rectangle 5 cm long and 3 cm wide?',
        'நீளம் 5 cm அகலம் 3 cm கொண்ட செவ்வகத்தின் சுற்றளவு என்ன?',
        const ['8 cm', '15 cm', '16 cm', '30 cm'],
        2,
        'පරිමිතිය = 5 + 3 + 5 + 3 = 16 cm.',
        'Perimeter = 5 + 3 + 5 + 3 = 16 cm.',
        'சுற்றளவு = 5 + 3 + 5 + 3 = 16 cm.'),
    'සංඛ්‍යා රටා': _QuickCheck(
        '2, 4, 6, 8, ... ඊළඟ සංඛ්‍යාව කීයද?',
        'What comes next: 2, 4, 6, 8, ...?',
        '2, 4, 6, 8, ... அடுத்த எண் என்ன?',
        const ['9', '10', '11', '12'],
        1,
        'සෑම වාරයකම 2ක් එකතු වේ. 8 + 2 = 10.',
        'Add 2 each time. 8 + 2 = 10.',
        'ஒவ்வொரு முறையும் 2 சேர்க்கிறோம். 8 + 2 = 10.'),
    'වචන ගැටලු': _QuickCheck(
        'පොතක පිටු 120ක් ඇත. පිටු 35ක් සහ 28ක් කියවූ විට ඉතිරි කීයද?',
        'A book has 120 pages. After reading 35 and 28, how many remain?',
        'ஒரு புத்தகத்தில் 120 பக்கங்கள். 35 மற்றும் 28 பக்கங்கள் படித்தால் மீதி எத்தனை?',
        const ['47', '57', '63', '85'],
        1,
        'කියවූ පිටු = 35 + 28 = 63. ඉතිරි = 120 − 63 = 57.',
        'Read 35 + 28 = 63 pages; 120 − 63 = 57 remain.',
        'படித்தது 35 + 28 = 63; மீதி 120 − 63 = 57.'),
  };

  static const Map<String, _QuickCheck> _moreGradeFiveChecks = {
    'ජීවීන් හඳුනාගැනීම': _QuickCheck(
        'ජීවියෙකුට පොදුවේ ඇති ලක්ෂණයක් කුමක්ද?',
        'Which is a common characteristic of living things?',
        'உயிரினங்களின் பொதுவான பண்பு எது?',
        const [
          'වර්ධනය / Growth / வளர்ச்சி',
          'කිසිදා වෙනස් නොවීම / Never changing',
          'සෑමවිටම පියාසර කිරීම / Always flying',
          'සියල්ලම ජලයේ සිටීම / All live in water'
        ],
        0,
        'ජීවීන් වර්ධනය වේ.',
        'Living things grow.',
        'உயிரினங்கள் வளர்கின்றன.'),
    'ජල චක්‍රය': _QuickCheck(
        'ජලය වාෂ්ප බවට පත්වීම හඳුන්වන්නේ කුමක්ද?',
        'What is the change from liquid water to vapour called?',
        'நீர் நீராவியாக மாறுவது என்ன?',
        const [
          'ඝනීභවනය / Condensation',
          'වාෂ්පීකරණය / Evaporation',
          'හිමවීම / Freezing',
          'ද්‍රවීකරණය / Melting'
        ],
        1,
        'උෂ්ණත්වය නිසා ජලය වාෂ්ප බවට පත්වීම වාෂ්පීකරණයයි.',
        'Evaporation changes liquid water to water vapour.',
        'நீர் நீராவியாக மாறுவது ஆவியாதல்.'),
    'සෞඛ්‍ය පුරුදු': _QuickCheck(
        'කෑමට පෙර කළ යුතු හොඳ පුරුද්ද කුමක්ද?',
        'What is a good habit before eating?',
        'சாப்பிடுவதற்கு முன் நல்ல பழக்கம் எது?',
        const [
          'අත් සේදීම / Wash hands',
          'අත් නොසේදීම / Skip washing',
          'අපිරිසිදු ජලය පානය / Drink dirty water',
          'කෑම බිම දැමීම / Drop food'
        ],
        0,
        'සබන් සහ පිරිසිදු ජලයෙන් අත් සේදීම රෝග පැතිරීම අඩු කරයි.',
        'Washing hands with soap and clean water reduces spread of germs.',
        'சோப்பும் சுத்தமான நீரும் கொண்டு கைகளைக் கழுவுவது கிருமிகள் பரவுவதை குறைக்கும்.'),
    'දිශා හඳුනාගැනීම': _QuickCheck(
        'උතුරට විරුද්ධ දිශාව කුමක්ද?',
        'Which direction is opposite to north?',
        'வடக்கிற்கு எதிரான திசை எது?',
        const [
          'නැගෙනහිර / East',
          'බටහිර / West',
          'දකුණ / South',
          'උතුර / North'
        ],
        2,
        'උතුරට විරුද්ධ දිශාව දකුණයි.',
        'South is opposite to north.',
        'வடக்கிற்கு எதிரான திசை தெற்கு.'),
    'සරල සිතියම්': _QuickCheck(
        'සිතියමක සංකේතවල අර්ථ දක්වන්නේ කුමක්ද?',
        'What explains the symbols on a map?',
        'வரைபடக் குறியீடுகளை விளக்குவது எது?',
        const [
          'සිතියම් සංකේත විස්තරය / Key',
          'මාතෘකාව පමණක් / Title only',
          'පිටු අංකය / Page number',
          'වර්ණයක් පමණක් / One colour'
        ],
        0,
        'සිතියම් සංකේත විස්තරයෙන් සංකේතවල අර්ථ පැහැදිලි වේ.',
        'A map key or legend explains symbols.',
        'வரைபட விளக்கக்குறிப்பு குறியீடுகளின் பொருளை விளக்கும்.'),
    'අතීතය සහ වර්තමානය': _QuickCheck(
        'ඊයේ සිදුවූ දෙයක් අයත් වන්නේ කුමන කාලයටද?',
        'Yesterday belongs to which time?',
        'நேற்று எந்தக் காலத்தைச் சேர்ந்தது?',
        const [
          'අනාගතය / Future',
          'අතීතය / Past',
          'වර්තමානය / Present',
          'කාලයක් නොවේ / None'
        ],
        1,
        'ඊයේ දැනටමත් ගෙවී ගිය නිසා එය අතීතයට අයත් වේ.',
        'Yesterday has already happened, so it is in the past.',
        'நேற்று ஏற்கனவே நடந்ததால் அது இறந்த காலம்.'),
    'ප්‍රදේශයේ උරුමය': _QuickCheck(
        'පැරණි ස්මාරකයක් ආරක්ෂා කළ යුත්තේ ඇයි?',
        'Why should we protect a historical monument?',
        'வரலாற்றுச் சின்னத்தை ஏன் பாதுகாக்க வேண்டும்?',
        const [
          'ඉතිහාසය දැනගැනීමට / Preserve history',
          'විනාශ කිරීමට / Destroy it',
          'කුණු දැමීමට / Litter',
          'අමතක කිරීමට / Forget it'
        ],
        0,
        'ස්මාරක මගින් අතීතය ගැන ඉගෙනගත හැකි නිසා ඒවා ආරක්ෂා කළ යුතුයි.',
        'Monuments help us learn about the past and should be protected.',
        'நினைவுச் சின்னங்கள் கடந்தகாலத்தை அறிய உதவுகின்றன.'),
    'කියවීමේ අවබෝධය': _QuickCheck(
        '“මල්ලි පාසලට ගියේය.” යන වාක්‍යයේ පාසලට ගියේ කවුද?',
        'In “The younger brother went to school”, who went?',
        '“தம்பி பள்ளிக்குச் சென்றான்” - சென்றது யார்?',
        const [
          'අම්මා / Mother',
          'මල්ලි / Younger brother',
          'ගුරුවරයා / Teacher',
          'අක්කා / Sister'
        ],
        1,
        'වාක්‍යයේ ක්‍රියාව කළේ මල්ලි ය.',
        'The sentence says the younger brother went.',
        'வாக்கியத்தில் தம்பிதான் சென்றான்.'),
    'වාක්‍ය ගොඩනැගීම': _QuickCheck(
        'සම්පූර්ණ වාක්‍යයක් තෝරන්න.',
        'Choose a complete sentence.',
        'முழுமையான வாக்கியத்தைத் தேர்ந்தெடுக்கவும்.',
        const [
          'පොත / Book',
          'අද පාසල / Today school',
          'මම පොතක් කියවමි. / I read a book.',
          'ලස්සන / Beautiful'
        ],
        2,
        '“මම පොතක් කියවමි.” යන්න සම්පූර්ණ අදහසක් දක්වයි.',
        '“I read a book” expresses a complete thought.',
        '“நான் ஒரு புத்தகம் படிக்கிறேன்” முழுமையான கருத்தைத் தருகிறது.'),
    'සරල දෙමළ වාක්‍ය': _QuickCheck(
        '“வணக்கம்” යන දෙමළ වචනයේ අර්ථය කුමක්ද?',
        'What does “வணக்கம்” mean?',
        '“வணக்கம்” என்பதன் பொருள் என்ன?',
        const [
          'ආයුබෝවන් / Hello',
          'ස්තුතියි / Thank you',
          'නැහැ / No',
          'පොත / Book'
        ],
        0,
        '“வணக்கம்” යනු ආචාර කිරීමට භාවිත කරන වචනයකි.',
        '“வணக்கம்” is a greeting meaning hello.',
        '“வணக்கம்” என்பது வாழ்த்துச் சொல்.'),
    'දෛනික ඉංග්‍රීසි වචන': _QuickCheck(
        '“Water” යන ඉංග්‍රීසි වචනයේ අර්ථය කුමක්ද?',
        'What does “Water” mean?',
        '“Water” என்பதன் பொருள் என்ன?',
        const ['ගස / Tree', 'ජලය / Water', 'ගෙය / House', 'ආහාර / Food'],
        1,
        'Water යන්නෙහි සිංහල අර්ථය ජලයයි.',
        'Water means the liquid we drink.',
        'Water என்பது தண்ணீர்.'),
    'සරල වර්තමාන කාලය': _QuickCheck(
        'නිවැරදි වාක්‍යය තෝරන්න: “She ___ to school.”',
        'Choose: “She ___ to school.”',
        '“She ___ to school.” சரியான சொல்லைத் தேர்ந்தெடுக்கவும்.',
        const ['go', 'going', 'goes', 'gone'],
        2,
        'She සමඟ සරල වර්තමාන කාලයේ goes යොදයි.',
        'With she in the simple present, use goes.',
        'She உடன் simple present இல் goes பயன்படுத்தப்படும்.'),
    'තාලය සහ චලනය': _QuickCheck(
        'නර්තනයේ චලන එකම වේගයකින් පවත්වාගැනීමට උදව් වන්නේ කුමක්ද?',
        'What helps keep dance movements in time?',
        'நடன அசைவுகளை நேரத்திற்கு ஏற்ப வைத்திருப்பது எது?',
        const [
          'තාලය / Beat',
          'අහඹු නිශ්ශබ්දතාව / Random silence',
          'ඇස් වසාගැනීම / Closing eyes',
          'සංගීතය නොඇසීම / Not listening'
        ],
        0,
        'තාලයට ගැළපෙන ලෙස චලනය කිරීම නර්තනයට වැදගත්ය.',
        'Following a beat helps coordinate movement.',
        'தாளத்தைப் பின்பற்றுவது அசைவுகளை ஒழுங்குபடுத்தும்.'),
    'දේශීය නර්තන සම්ප්‍රදාය': _QuickCheck(
        'ශ්‍රී ලංකාවේ සාම්ප්‍රදායික නර්තන සම්ප්‍රදායක් කුමක්ද?',
        'Which is a Sri Lankan traditional dance tradition?',
        'இலங்கையின் பாரம்பரிய நடன மரபு எது?',
        const [
          'උඩරට නර්තනය / Kandyan dance',
          'බැඩ්මින්ටන් / Badminton',
          'පිහිනීම / Swimming',
          'චෙස් / Chess'
        ],
        0,
        'උඩරට නර්තනය ශ්‍රී ලංකාවේ ප්‍රධාන සාම්ප්‍රදායික නර්තන සම්ප්‍රදායකි.',
        'Kandyan dance is a traditional Sri Lankan dance form.',
        'கண்டிய நடனம் இலங்கையின் பாரம்பரிய நடன வகை.'),
    'උස් සහ පහත් හඬ': _QuickCheck(
        'උස් හඬක් හා පහත් හඬක් අතර වෙනස කුමක්ද?',
        'What distinguishes high and low pitch?',
        'உயர்ந்த மற்றும் தாழ்ந்த சுரத்தை வேறுபடுத்துவது எது?',
        const [
          'හඬේ උස / Pitch',
          'පොතේ බර / Book weight',
          'පාට / Colour',
          'දුර / Distance'
        ],
        0,
        'ස්වර උස වෙනස් වන්නේ ශබ්දයේ සංඛ්‍යාතය අනුවය.',
        'Pitch is related to sound frequency.',
        'சுருதி ஒலியின் அதிர்வெண்ணுடன் தொடர்புடையது.'),
    'රිද්ම රටා': _QuickCheck(
        'තාලයක නැවත නැවත එන ස්පන්දන රටාවක් හඳුන්වන්නේ කුමක්ද?',
        'What is a repeating pattern of beats called?',
        'மீண்டும் வரும் தாளத் துடிப்பின் வடிவம் எது?',
        const [
          'රිද්ම රටාව / Rhythm pattern',
          'වර්ණ රටාව / Colour pattern',
          'අකුරු පෙළ / Letters',
          'සිතියම / Map'
        ],
        0,
        'නැවත නැවත එන තාල ස්පන්දන රටාව රිද්ම රටාවකි.',
        'A repeated pattern of beats is a rhythm pattern.',
        'மீண்டும் வரும் தாளத் துடிப்பு ஒழுங்கு ஒரு லய வடிவம்.'),
    'හැඩතල හා වර්ණ': _QuickCheck(
        'පහත කවරක් මූලික හැඩතලයක්ද?',
        'Which is a basic shape?',
        'அடிப்படை வடிவம் எது?',
        const [
          'වෘත්තය / Circle',
          'සුවඳ / Smell',
          'ශබ්දය / Sound',
          'වේගය / Speed'
        ],
        0,
        'වෘත්තය මූලික ජ්‍යාමිතික හැඩතලයකි.',
        'A circle is a basic geometric shape.',
        'வட்டம் ஒரு அடிப்படை வடிவம்.'),
    'අභිනයෙන් රඟපෑම': _QuickCheck(
        'කතා නොකර මුහුණේ ඉරියව්වෙන් සතුට පෙන්විය හැකිද?',
        'Can facial expression show happiness without speech?',
        'பேசாமல் முகபாவத்தால் மகிழ்ச்சியைக் காட்ட முடியுமா?',
        const [
          'ඔව් / Yes',
          'නැහැ / No',
          'සෑමවිටම බැහැ / Never',
          'අදාළ නැහැ / Not relevant'
        ],
        0,
        'මුහුණේ ඉරියව් සහ ශරීර චලන මගින් හැඟීම් පෙන්විය හැක.',
        'Facial expressions and gestures can communicate emotion.',
        'முகபாவமும் அசைவுகளும் உணர்ச்சியைக் காட்டும்.'),
    'අන් අයට උපකාර කිරීම': _QuickCheck(
        'මිතුරෙකුගේ පොත් වැටුණොත් හොඳ ක්‍රියාව කුමක්ද?',
        'What is a kind action if a friend drops books?',
        'நண்பரின் புத்தகங்கள் விழுந்தால் நல்ல செயல் எது?',
        const [
          'උදව් කිරීම / Help',
          'සිනාසීම / Laugh',
          'නොසලකා හැරීම / Ignore',
          'පොත් සඟවීම / Hide'
        ],
        0,
        'අන් අයට අවශ්‍ය විට උපකාර කිරීම හොඳ සමාජ පුරුද්දකි.',
        'Helping others is a positive social habit.',
        'பிறருக்கு உதவுவது நல்ல சமூகப் பழக்கம்.'),
    'පෞද්ගලික පිරිසිදුකම': _QuickCheck(
        'දත් පිරිසිදු කිරීමට හොඳ පුරුද්ද කුමක්ද?',
        'What is a good dental hygiene habit?',
        'பல் சுகாதாரத்திற்கு நல்ல பழக்கம் எது?',
        const [
          'දත් නිතර මැදීම / Brush regularly',
          'දත් නොමැදීම / Never brush',
          'සීනි පමණක් කෑම / Only sugar',
          'දත් බුරුසුව බෙදාගැනීම / Share brush'
        ],
        0,
        'දත් නිතර පිරිසිදු කිරීම මුඛ සෞඛ්‍යයට වැදගත්ය.',
        'Regular toothbrushing supports oral health.',
        'பற்களைத் தொடர்ந்து துலக்குவது வாய்ச் சுகாதாரத்திற்கு நல்லது.'),
    'තාක්ෂණය ආරක්ෂිතව භාවිතය': _QuickCheck(
        'අන්තර්ජාලයේ නොදන්නා අයෙකු මුරපදය ඉල්ලුවොත් කළ යුත්තේ කුමක්ද?',
        'What should you do if a stranger online asks for your password?',
        'இணையத்தில் அந்நியர் கடவுச்சொல் கேட்டால் என்ன செய்ய வேண்டும்?',
        const [
          'මුරපදය නොදීම / Do not share',
          'මුරපදය දීම / Share it',
          'සෑම තැනම දැමීම / Post it',
          'මිතුරන්ට බෙදීම / Tell everyone'
        ],
        0,
        'මුරපදය රහසිගතව තබා විශ්වාසවන්ත වැඩිහිටියෙකුට කියන්න.',
        'Keep passwords private and tell a trusted adult.',
        'கடவுச்சொல்லை ரகசியமாக வைத்து நம்பகமான பெரியவரிடம் சொல்லவும்.'),
    'කරුණාව සහ ගෞරවය': _QuickCheck(
        'අනෙක් අය කතා කරන විට ගෞරවයෙන් කළ යුත්තේ කුමක්ද?',
        'How do you show respect when someone is speaking?',
        'ஒருவர் பேசும்போது மரியாதை காட்டுவது எப்படி?',
        const [
          'සවන් දීම / Listen',
          'බාධා කිරීම / Interrupt',
          'අපහාස කිරීම / Insult',
          'හැරී යාම / Walk away'
        ],
        0,
        'අන් අයට සවන් දීම ගෞරවය පෙන්වයි.',
        'Listening attentively shows respect.',
        'கவனமாகக் கேட்பது மரியாதையைக் காட்டும்.'),
  };

  static const _categories = <_Category>[
    _Category('mathematics', 'ගණිතය', 'Mathematics', 'கணிதம்'),
    _Category('science', 'විද්‍යාව', 'Science', 'விஞ்ஞானம்'),
    _Category('history', 'ඉතිහාසය', 'History', 'வரலாறு'),
    _Category('geography', 'භූගෝල විද්‍යාව', 'Geography', 'புவியியல்'),
    _Category('ict', 'තොරතුරු තාක්ෂණය', 'ICT', 'தகவல் தொழில்நுட்பம்'),
    _Category('english', 'ඉංග්‍රීසි', 'English', 'ஆங்கிலம்'),
    _Category('sinhala', 'සිංහල', 'Sinhala', 'சிங்களம்'),
    _Category('tamil', 'දෙමළ', 'Tamil', 'தமிழ்'),
    _Category('civics', 'පුරවැසි අධ්‍යාපනය', 'Civics', 'குடியியல்'),
    _Category('commerce', 'වාණිජ්‍යය', 'Commerce', 'வணிகம்'),
    _Category('media', 'මාධ්‍ය අධ්‍යයනය', 'Media', 'ஊடகக் கல்வி'),
    _Category('health', 'සෞඛ්‍යය', 'Health', 'சுகாதாரம்'),
    _Category('dancing', 'නර්තනය', 'Dancing', 'நடனம்'),
    _Category('music', 'සංගීතය', 'Music', 'இசை'),
    _Category('art', 'චිත්‍ර කලාව', 'Art', 'சித்திரம்'),
    _Category('drama', 'නාට්‍ය හා රංග කලාව', 'Drama', 'நாடகம்'),
    _Category(
        'religion', 'ආගමික අධ්‍යාපනය', 'Religious Studies', 'சமயக் கல்வி'),
  ];

  static const _primaryEntries = <_Entry>[
    _Entry(
        'mathematics',
        'Place value',
        'ස්ථානීය අගය',
        'இடமதிப்பு',
        'A digit’s value depends on its place.',
        'ඉලක්කමක අගය එය පිහිටි ස්ථානය අනුව වෙනස් වේ.',
        'ஓர் இலக்கத்தின் மதிப்பு அதன் இடத்தைப் பொறுத்தது.',
        'In 4,582, 5 means 500.',
        '4,582 හි 5 න් 500 නිරූපණය වේ.',
        '4,582 இல் 5 என்பது 500.'),
    _Entry(
        'mathematics',
        'Addition',
        'එකතු කිරීම',
        'கூட்டல்',
        'Add units, tens and hundreds in columns.',
        'එකස්ථාන, දසස්ථාන, සියස්ථාන පිළිවෙළට එකතු කරන්න.',
        'ஒன்றுகள், பத்துகள், நூறுகளை வரிசையாகக் கூட்டுக.',
        '248 + 137 = 385.',
        '248 + 137 = 385.',
        '248 + 137 = 385.'),
    _Entry(
        'mathematics',
        'Subtraction',
        'අඩු කිරීම',
        'கழித்தல்',
        'Subtract by place value; regroup when needed.',
        'ස්ථානීය අගය අනුව අඩු කරන්න. අවශ්‍ය විට ණයට ගන්න.',
        'இடமதிப்பின்படி கழிக்கவும்; தேவைப்பட்டால் மாற்றிக் கொள்ளவும்.',
        '502 − 178 = 324.',
        '502 − 178 = 324.',
        '502 − 178 = 324.'),
    _Entry(
        'mathematics',
        'Multiplication',
        'ගුණ කිරීම',
        'பெருக்கல்',
        'Multiplication is repeated addition of equal groups.',
        'සමාන කණ්ඩායම් නැවත නැවත එකතු කිරීම ගුණ කිරීමකි.',
        'சமமான குழுக்களை மீண்டும் மீண்டும் கூட்டுவது பெருக்கல்.',
        '6 × 4 = 24.',
        '6 × 4 = 24.',
        '6 × 4 = 24.'),
    _Entry(
        'mathematics',
        'Division',
        'බෙදීම',
        'வகுத்தல்',
        'Division shares equally or makes equal groups.',
        'බෙදීමෙන් සමාන කොටස් හෝ කණ්ඩායම් සාදයි.',
        'வகுத்தல் சமமான பங்குகளாகப் பிரிக்கிறது.',
        '24 ÷ 6 = 4.',
        '24 ÷ 6 = 4.',
        '24 ÷ 6 = 4.'),
    _Entry(
        'mathematics',
        'Fractions',
        'භාග',
        'பின்னங்கள்',
        'A fraction describes part of a whole.',
        'භාගයකින් සම්පූර්ණයක කොටසක් දැක්වේ.',
        'ஒரு பின்னம் முழுமையின் ஒரு பகுதியைக் குறிக்கும்.',
        '1/2 + 1/4 = 3/4.',
        '1/2 + 1/4 = 3/4.',
        '1/2 + 1/4 = 3/4.'),
    _Entry(
        'mathematics',
        'Money',
        'මුදල් ගණනය',
        'பணக் கணக்கு',
        'Add prices and subtract from the money paid to find change.',
        'මිල එකතු කර ගෙවූ මුදලින් අඩු කළ විට ඉතිරි මුදල ලැබේ.',
        'விலைகளை கூட்டி கொடுத்த பணத்திலிருந்து கழித்தால் மீதிப் பணம் கிடைக்கும்.',
        'Rs. 100 − Rs. 65 = Rs. 35.',
        'රු.100 − රු.65 = රු.35.',
        'ரூ.100 − ரூ.65 = ரூ.35.'),
    _Entry(
        'mathematics',
        'Time',
        'කාලය',
        'நேரம்',
        '60 minutes make one hour.',
        'මිනිත්තු 60ක් පැයක් වේ.',
        '60 நிமிடங்கள் ஒரு மணி நேரம்.',
        '2:15 + 30 min = 2:45.',
        '2:15 + මිනිත්තු 30 = 2:45.',
        '2:15 + 30 நிமிடம் = 2:45.'),
    _Entry(
        'mathematics',
        'Length',
        'දිග මැනීම',
        'நீளம்',
        '100 centimetres make one metre.',
        'සෙන්ටිමීටර 100ක් මීටරයක් වේ.',
        '100 சென்டிமீட்டர் ஒரு மீட்டர்.',
        '2 m = 200 cm.',
        'මීටර 2 = සෙ.මී. 200.',
        '2 மீ = 200 செ.மீ.'),
    _Entry(
        'mathematics',
        'Mass',
        'ස්කන්ධය මැනීම',
        'நிறை',
        '1000 grams make one kilogram.',
        'ග්‍රෑම් 1000ක් කිලෝග්‍රෑම් එකක් වේ.',
        '1000 கிராம் ஒரு கிலோகிராம்.',
        '2 kg = 2000 g.',
        'කි.ග්‍රෑ. 2 = ග්‍රෑ. 2000.',
        '2 கி.கி. = 2000 கி.'),
    _Entry(
        'mathematics',
        'Perimeter',
        'පරිමිතිය',
        'சுற்றளவு',
        'Perimeter is the total distance around a shape.',
        'හැඩයක වටේ සියලු පැතිවල දිග එකතුව පරිමිතියයි.',
        'வடிவத்தின் எல்லாப் பக்க நீளங்களின் கூட்டுத்தொகை சுற்றளவு.',
        'Rectangle 5 cm by 3 cm: perimeter = 16 cm.',
        'දිග 5 cm, පළල 3 cm නම් පරිමිතිය = 16 cm.',
        '5 செ.மீ × 3 செ.மீ செவ்வகம்: சுற்றளவு = 16 செ.மீ.'),
    _Entry(
        'mathematics',
        'Patterns',
        'සංඛ්‍යා රටා',
        'எண் கோலங்கள்',
        'Find the rule and continue the sequence.',
        'රටාවේ නියමය සොයා ඊළඟ සංඛ්‍යාව ලියන්න.',
        'விதியை கண்டறிந்து தொடரை நீட்டிக்கவும்.',
        '2, 4, 6, 8, next is 10.',
        '2, 4, 6, 8, ඊළඟ අගය 10.',
        '2, 4, 6, 8, அடுத்து 10.'),
    _Entry(
        'mathematics',
        'Word problems',
        'වචන ගැටලු',
        'சொற்கணக்குகள்',
        'Identify what is given, what is asked and the operation.',
        'දී ඇති දත්ත, සෙවිය යුතු දේ සහ ගණිත ක්‍රියාව හඳුනාගන්න.',
        'கொடுக்கப்பட்டவை, கேட்கப்படுவது, கணக்குச் செயல் ஆகியவற்றைக் கண்டறிக.',
        '120 pages − (35 + 28) = 57 pages.',
        'පිටු 120 − (35 + 28) = ඉතිරි පිටු 57.',
        '120 பக்கங்கள் − (35 + 28) = 57 பக்கங்கள்.'),
    _Entry(
        'science',
        'Living things',
        'ජීවීන් හඳුනාගැනීම',
        'உயிரினங்கள்',
        'Living things need suitable conditions to grow and survive.',
        'ජීවීන්ට වර්ධනය වීමට සහ ජීවත් වීමට සුදුසු තත්ත්ව අවශ්‍යයි.',
        'உயிரினங்கள் வளரவும் வாழவும் பொருத்தமான சூழல் தேவை.',
        'A seed needs water and suitable conditions to germinate.',
        'බීජයක් ප්‍රරෝහණයට ජලය සහ සුදුසු තත්ත්ව අවශ්‍ය වේ.',
        'விதை முளைக்க நீரும் பொருத்தமான சூழலும் தேவை.'),
    _Entry(
        'science',
        'Water cycle',
        'ජල චක්‍රය',
        'நீர்ச் சுழற்சி',
        'Water evaporates, condenses into clouds and returns as rain.',
        'ජලය වාෂ්ප වී වලාකුළු සාදන අතර වැසි ලෙස නැවත පොළොවට පැමිණේ.',
        'நீர் ஆவியாகி மேகமாகி மழையாகத் திரும்புகிறது.',
        'Sun heats water → evaporation → clouds → rain.',
        'හිරු රශ්මිය → වාෂ්පීකරණය → වලාකුළු → වැසි.',
        'சூரிய வெப்பம் → ஆவியாதல் → மேகம் → மழை.'),
    _Entry(
        'science',
        'Healthy habits',
        'සෞඛ්‍ය පුරුදු',
        'ஆரோக்கியப் பழக்கங்கள்',
        'Clean water, handwashing and balanced meals help health.',
        'පිරිසිදු ජලය, අත් සේදීම සහ සමබර ආහාර සෞඛ්‍යයට උපකාරී වේ.',
        'தூய நீர், கைகழுவுதல், சமச்சீர் உணவு ஆரோக்கியத்திற்கு உதவும்.',
        'Wash hands before eating.',
        'කෑමට පෙර අත් සෝදන්න.',
        'சாப்பிடும் முன் கைகளை கழுவுக.'),
    _Entry(
        'geography',
        'Directions',
        'දිශා හඳුනාගැනීම',
        'திசைகள்',
        'The four main directions are north, south, east and west.',
        'ප්‍රධාන දිශා හතර උතුර, දකුණ, නැගෙනහිර, බටහිර වේ.',
        'நான்கு திசைகள் வடக்கு, தெற்கு, கிழக்கு, மேற்கு.',
        'On a standard north-up map, east is to the right.',
        'උතුර ඉහළින් ඇති සිතියමක නැගෙනහිර දකුණු පැත්තේ වේ.',
        'வடக்கு மேலுள்ள வரைபடத்தில் கிழக்கு வலப்பக்கம்.'),
    _Entry(
        'geography',
        'Simple maps',
        'සරල සිතියම්',
        'எளிய வரைபடங்கள்',
        'A map uses symbols to show places.',
        'ස්ථාන පෙන්වීමට සිතියමක සංකේත භාවිත කරයි.',
        'இடங்களைக் காட்ட வரைபடத்தில் குறியீடுகள் பயன்படுத்தப்படுகின்றன.',
        'Use a key to understand map symbols.',
        'සිතියම් සංකේත තේරුම් ගැනීමට සංකේත විස්තරය බලන්න.',
        'வரைபடக் குறியீடுகளை அறிய விளக்கக் குறிப்பைப் பார்க்கவும்.'),
    _Entry(
        'history',
        'Past and present',
        'අතීතය සහ වර්තමානය',
        'கடந்த காலமும் நிகழ்காலமும்',
        'Compare how life has changed over time.',
        'කාලයත් සමඟ ජීවන රටාව වෙනස් වූ ආකාරය සසඳන්න.',
        'காலப்போக்கில் வாழ்க்கை மாறிய விதத்தை ஒப்பிடுக.',
        'Compare old and new transport methods.',
        'පැරණි සහ නව ප්‍රවාහන ක්‍රම සසඳන්න.',
        'பழைய மற்றும் புதிய போக்குவரத்தை ஒப்பிடுக.'),
    _Entry(
        'history',
        'Local heritage',
        'ප්‍රදේශයේ උරුමය',
        'உள்ளூர் மரபுரிமை',
        'Buildings, stories and objects can help us learn about the past.',
        'ගොඩනැගිලි, කතා සහ භාණ්ඩ අතීතය දැනගැනීමට උපකාරී වේ.',
        'கட்டடங்கள், கதைகள், பொருட்கள் கடந்த காலத்தை அறிய உதவும்.',
        'Ask what evidence supports a story about an old place.',
        'පැරණි ස්ථානයක් ගැන කතාවකට ඇති සාක්ෂි විමසන්න.',
        'பழைய இடம் பற்றிய கதைக்கான ஆதாரத்தை கேளுங்கள்.'),
    _Entry(
        'sinhala',
        'Reading comprehension',
        'කියවීමේ අවබෝධය',
        'வாசிப்புப் புரிதல்',
        'Read a short passage and answer using its information.',
        'කෙටි ඡේදය කියවා එහි ඇති තොරතුරු අනුව පිළිතුරු දෙන්න.',
        'சிறு பந்தியை வாசித்து அதிலுள்ள தகவலின்படி பதிலளிக்கவும்.',
        'Find who, where, when and why.',
        'කවුද, කොහේද, කවදාද, ඇයි යන කරුණු සොයන්න.',
        'யார், எங்கே, எப்போது, ஏன் என்பதை அறிக.'),
    _Entry(
        'sinhala',
        'Sentence building',
        'වාක්‍ය ගොඩනැගීම',
        'வாக்கியம் அமைத்தல்',
        'A clear sentence communicates a complete idea.',
        'පැහැදිලි වාක්‍යයකින් සම්පූර්ණ අදහසක් ප්‍රකාශ වේ.',
        'தெளிவான வாக்கியம் முழுமையான கருத்தைத் தெரிவிக்கும்.',
        'ළමයා පොත කියවයි.',
        'ළමයා පොත කියවයි.',
        'சிறுவன் புத்தகத்தை வாசிக்கிறான்.'),
    _Entry(
        'tamil',
        'Simple sentences',
        'සරල දෙමළ වාක්‍ය',
        'எளிய வாக்கியங்கள்',
        'Learn to form a short meaningful sentence.',
        'අර්ථවත් කෙටි වාක්‍යයක් ගොඩනගන හැටි ඉගෙනගන්න.',
        'பொருளுள்ள சிறு வாக்கியங்களை அமைக்கக் கற்கவும்.',
        'நான் படிக்கிறேன்.',
        'நான் படிக்கிறேன். (මම ඉගෙන ගනිමි.)',
        'நான் படிக்கிறேன்.'),
    _Entry(
        'english',
        'Everyday vocabulary',
        'දෛනික ඉංග්‍රීසි වචන',
        'அன்றாட ஆங்கிலச் சொற்கள்',
        'Learn common words and use them in sentences.',
        'දෛනික වචන ඉගෙනගෙන වාක්‍යවල යොදන්න.',
        'அன்றாடச் சொற்களைக் கற்று வாக்கியங்களில் பயன்படுத்துக.',
        'Book, school, water.',
        'Book = පොත, school = පාසල, water = ජලය.',
        'Book = புத்தகம், school = பாடசாலை, water = நீர்.'),
    _Entry(
        'english',
        'Simple present tense',
        'සරල වර්තමාන කාලය',
        'எளிய நிகழ்காலம்',
        'Use the simple present for habits and general facts.',
        'පුරුදු සහ සාමාන්‍ය සත්‍ය සඳහා සරල වර්තමාන කාලය භාවිත වේ.',
        'வழக்கங்களுக்கும் பொதுவான உண்மைகளுக்கும் எளிய நிகழ்காலம் பயன்படும்.',
        'She reads every day.',
        'She reads every day. = ඇය දිනපතා කියවයි.',
        'She reads every day. = அவள் தினமும் வாசிக்கிறாள்.'),
    _Entry(
        'dancing',
        'Beat and movement',
        'තාලය සහ චලනය',
        'தாளமும் அசைவும்',
        'Move or clap steadily to a repeated beat.',
        'නැවත නැවත ඇසෙන තාලයට අත්පුඩි ගසා හෝ චලනය වන්න.',
        'தொடரும் தாளத்திற்கேற்ப கைதட்டி அல்லது அசையவும்.',
        'Clap four equal beats.',
        'සමාන තාල හතරකට අත්පුඩි ගසන්න.',
        'நான்கு சம தாளங்களுக்கு கைதட்டுக.'),
    _Entry(
        'dancing',
        'Traditional dance',
        'දේශීය නර්තන සම්ප්‍රදාය',
        'பாரம்பரிய நடனம்',
        'Sri Lanka has several traditional dance traditions.',
        'ශ්‍රී ලංකාවේ විවිධ සාම්ප්‍රදායික නර්තන සම්ප්‍රදායයන් ඇත.',
        'இலங்கையில் பல பாரம்பரிய நடன மரபுகள் உள்ளன.',
        'Explore Kandyan, Low Country and Sabaragamuwa dance.',
        'උඩරට, පහතරට සහ සබරගමු නර්තන ගැන දැනගන්න.',
        'கண்டிய, தாழ்நாட்டு, சபரகமுவ நடனங்களை அறிக.'),
    _Entry(
        'music',
        'High and low sounds',
        'උස් සහ පහත් හඬ',
        'உயர் தாழ் ஒலிகள்',
        'Sounds can have higher or lower pitch.',
        'හඬක ස්වර උස වැඩි හෝ අඩු විය හැකිය.',
        'ஒலியின் சுருதி உயரமாகவோ தாழ்வாகவோ இருக்கலாம்.',
        'Sing one low note and one high note.',
        'පහළ ස්වරයක් හා ඉහළ ස්වරයක් ගායනා කරන්න.',
        'ஒரு தாழ்ந்த சுரமும் உயர்ந்த சுரமும் பாடுக.'),
    _Entry(
        'music',
        'Rhythm patterns',
        'රිද්ම රටා',
        'இலய வடிவங்கள்',
        'A rhythm is a pattern of sound and silence over time.',
        'රිද්මය යනු කාලය තුළ ශබ්ද සහ නිශ්ශබ්දතාවයේ රටාවකි.',
        'இலயம் என்பது ஒலி மற்றும் அமைதியின் கால வடிவம்.',
        'Clap, clap, pause, clap.',
        'අත්පුඩි, අත්පුඩි, විරාමය, අත්පුඩි.',
        'கைதட்டு, கைதட்டு, இடைவேளை, கைதட்டு.'),
    _Entry(
        'art',
        'Shapes and colours',
        'හැඩතල හා වර්ණ',
        'வடிவங்களும் நிறங்களும்',
        'Identify basic shapes and use colours creatively.',
        'මූලික හැඩතල හඳුනාගෙන වර්ණ භාවිත කරන්න.',
        'அடிப்படை வடிவங்களை அறிந்து நிறங்களைப் பயன்படுத்துக.',
        'Draw a circle, square and triangle.',
        'වෘත්තයක්, සමචතුරස්‍රයක් හා ත්‍රිකෝණයක් අඳින්න.',
        'வட்டம், சதுரம், முக்கோணம் வரைக.'),
    _Entry(
        'drama',
        'Acting with expression',
        'අභිනයෙන් රඟපෑම',
        'பாவனையுடன் நடிப்பு',
        'Use voice, face and movement to show a feeling.',
        'හඬ, මුහුණ සහ චලනයෙන් හැඟීමක් පෙන්වන්න.',
        'குரல், முகம், அசைவால் உணர்வை வெளிப்படுத்துக.',
        'Show happiness and surprise without words.',
        'වචන නැතිව සතුට සහ පුදුමය පෙන්වන්න.',
        'சொற்களின்றி மகிழ்ச்சியும் வியப்பும் காட்டுக.'),
    _Entry(
        'civics',
        'Helping others',
        'අන් අයට උපකාර කිරීම',
        'பிறருக்கு உதவுதல்',
        'Help others respectfully and safely.',
        'අන් අයට ගෞරවයෙන් හා ආරක්ෂිතව උපකාර කරන්න.',
        'பிறருக்கு மரியாதையுடனும் பாதுகாப்பாகவும் உதவுக.',
        'Help keep the classroom tidy.',
        'පන්ති කාමරය පිරිසිදුව තබාගැනීමට උදව් කරන්න.',
        'வகுப்பறையைச் சுத்தமாக வைத்திருக்க உதவுக.'),
    _Entry(
        'health',
        'Personal hygiene',
        'පෞද්ගලික පිරිසිදුකම',
        'தனிநபர் சுகாதாரம்',
        'Regular handwashing helps reduce spread of germs.',
        'නිතිපතා අත් සේදීමෙන් විෂබීජ පැතිරීම අඩු කළ හැකිය.',
        'கைகளை முறையாகக் கழுவுவது கிருமிகள் பரவுவதை குறைக்கும்.',
        'Wash hands with soap before eating.',
        'කෑමට පෙර සබන් යොදා අත් සෝදන්න.',
        'உணவுக்கு முன் சவர்க்காரத்தால் கைகளைக் கழுவுக.'),
    _Entry(
        'ict',
        'Using technology safely',
        'තාක්ෂණය ආරක්ෂිතව භාවිතය',
        'தொழில்நுட்பப் பாதுகாப்பு',
        'Do not share passwords or private details with strangers.',
        'මුරපද හෝ පෞද්ගලික තොරතුරු නොදන්නා අයට නොදෙන්න.',
        'கடவுச்சொல் அல்லது தனிப்பட்ட தகவலை அந்நியரிடம் பகிர வேண்டாம்.',
        'Ask a trusted adult before opening an unfamiliar link.',
        'නොදන්නා සබැඳියක් විවෘත කිරීමට පෙර විශ්වාසවන්ත වැඩිහිටියෙකුගෙන් අසන්න.',
        'அறியாத இணைப்பைத் திறக்கும் முன் நம்பகமான பெரியவரிடம் கேளுங்கள்.'),
    _Entry(
        'religion',
        'Kindness and respect',
        'කරුණාව සහ ගෞරවය',
        'அன்பும் மரியாதையும்',
        'Learn to treat people kindly and respectfully.',
        'අන් අයට කරුණාවෙන් හා ගෞරවයෙන් සැලකීමට ඉගෙනගන්න.',
        'பிறரிடம் அன்புடனும் மரியாதையுடனும் நடக்கக் கற்கவும்.',
        'Listen politely when another person speaks.',
        'අනෙකෙකු කතා කරන විට ආචාරශීලීව සවන් දෙන්න.',
        'பிறர் பேசும்போது மரியாதையாகக் கேளுங்கள்.'),
  ];

  static const _entries = <_Entry>[
    _Entry(
        'mathematics',
        'Triangle angles',
        'ත්‍රිකෝණයක කෝණ',
        'முக்கோணக் கோணங்கள்',
        'Interior angles sum to 180°.',
        'අභ්‍යන්තර කෝණ එකතුව 180° කි.',
        'உட்கோணங்களின் கூட்டுத்தொகை 180° ஆகும்.',
        '50° + 60° + 70° = 180°',
        '50° + 60° + 70° = 180°',
        '50° + 60° + 70° = 180°'),
    _Entry(
        'mathematics',
        'Area of a rectangle',
        'සෘජුකෝණාස්‍රයක වර්ගඵලය',
        'செவ்வகத்தின் பரப்பளவு',
        'Area = length × width.',
        'වර්ගඵලය = දිග × පළල.',
        'பரப்பளவு = நீளம் × அகலம்.',
        '5 cm × 3 cm = 15 cm²',
        '5 cm × 3 cm = 15 cm²',
        '5 cm × 3 cm = 15 cm²'),
    _Entry(
        'science',
        'Newton’s second law',
        'නිව්ටන්ගේ දෙවන නියමය',
        'நியூட்டனின் இரண்டாம் விதி',
        'Net force = mass × acceleration (F = ma).',
        'සම්ප්‍රයුක්ත බලය = ස්කන්ධය × ත්වරණය (F = ma).',
        'நிகர விசை = திணிவு × முடுக்கம் (F = ma).',
        '5 kg × 4 m/s² = 20 N',
        '5 kg × 4 m/s² = 20 N',
        '5 kg × 4 m/s² = 20 N'),
    _Entry(
        'science',
        'Balanced equations',
        'තුලිත රසායනික සමීකරණ',
        'சமப்படுத்தப்பட்ட வேதிச் சமன்பாடுகள்',
        'Atoms of each element must balance on both sides.',
        'දෙපස එක් එක් මූලද්‍රව්‍යයේ පරමාණු ගණන සමාන විය යුතුය.',
        'இருபுறமும் ஒவ்வொரு தனிமத்தின் அணுக்களின் எண்ணிக்கை சமமாக இருக்க வேண்டும்.',
        '2Mg + O₂ → 2MgO',
        '2Mg + O₂ → 2MgO',
        '2Mg + O₂ → 2MgO'),
    _Entry(
        'history',
        'Historical timelines',
        'ඉතිහාස කාලරේඛා',
        'வரலாற்றுக் காலவரிசை',
        'Place events in chronological order and distinguish dates from interpretations.',
        'සිදුවීම් කාල අනුපිළිවෙළට පෙළගස්වා දින සහ අර්ථකථන වෙන්කර හඳුනාගන්න.',
        'நிகழ்வுகளைக் காலவரிசைப்படுத்தி தேதிகளையும் விளக்கங்களையும் வேறுபடுத்துக.',
        'Create a timeline with event, date, place and evidence.',
        'සිද්ධිය, දිනය, ස්ථානය හා සාක්ෂි සඳහන් කාලරේඛාවක් සකසන්න.',
        'நிகழ்வு, தேதி, இடம், ஆதாரம் ஆகியவற்றுடன் காலவரிசை அமைக்கவும்.'),
    _Entry(
        'history',
        'Primary and secondary sources',
        'ප්‍රාථමික හා ද්විතීයික මූලාශ්‍ර',
        'முதன்மை மற்றும் இரண்டாம் நிலை ஆதாரங்கள்',
        'A primary source comes directly from the period or event studied.',
        'ප්‍රාථමික මූලාශ්‍රයක් අධ්‍යයනය කරන යුගයෙන් හෝ සිද්ධියෙන් සෘජුව ලැබේ.',
        'முதன்மை ஆதாரம் ஆய்வு செய்யும் காலத்திலிருந்தோ நிகழ்விலிருந்தோ நேரடியாகக் கிடைக்கிறது.',
        'An inscription can be a primary source.',
        'ශිලා ලේඛනයක් ප්‍රාථමික මූලාශ්‍රයක් විය හැකිය.',
        'கல்வெட்டு ஒரு முதன்மை ஆதாரமாக இருக்கலாம்.'),
    _Entry(
        'geography',
        'Map scale',
        'සිතියම් පරිමාණය',
        'வரைபட அளவுகோல்',
        'Map scale compares map distance with real distance.',
        'සිතියම් පරිමාණයෙන් සිතියමේ දුර හා සැබෑ දුර සසඳයි.',
        'வரைபட அளவுகோல் வரைபடத் தூரத்தையும் உண்மைத் தூரத்தையும் ஒப்பிடுகிறது.',
        'At 1:100,000, 1 cm represents 1 km.',
        '1:100,000 පරිමාණයේදී 1 cm මඟින් 1 km නිරූපණය වේ.',
        '1:100,000 அளவில் 1 செ.மீ. என்பது 1 கி.மீ.'),
    _Entry(
        'ict',
        'Algorithm',
        'ඇල්ගොරිතමය',
        'படிமுறை',
        'An algorithm is a finite sequence of clear steps for a task.',
        'ඇල්ගොරිතමයක් යනු කාර්යයක් සඳහා පැහැදිලි පියවර සීමිත සංඛ්‍යාවක අනුපිළිවෙළකි.',
        'ஒரு படிமுறை என்பது பணியை நிறைவேற்ற தெளிவான வரையறுக்கப்பட்ட படிகளின் வரிசை.',
        'Input → process → output.',
        'ආදානය → සැකසීම → ප්‍රතිදානය.',
        'உள்ளீடு → செயலாக்கம் → வெளியீடு.'),
    _Entry(
        'english',
        'Parts of speech',
        'පද වර්ග',
        'சொல் வகைகள்',
        'A noun names a person, place, thing or idea.',
        'නාම පදයක් පුද්ගලයෙකු, ස්ථානයක්, වස්තුවක් හෝ අදහසක් නම් කරයි.',
        'பெயர்ச்சொல் நபர், இடம், பொருள் அல்லது கருத்தைக் குறிக்கும்.',
        '“School” is a noun.',
        '“School” යනු නාම පදයකි.',
        '“School” என்பது பெயர்ச்சொல்.'),
    _Entry(
        'sinhala',
        'Nouns',
        'නාම පද',
        'பெயர்ச்சொற்கள்',
        'Nouns identify people, places, objects and concepts.',
        'නාම පද මඟින් පුද්ගලයන්, ස්ථාන, වස්තු හා සංකල්ප හඳුන්වයි.',
        'பெயர்ச்சொற்கள் மனிதர்கள், இடங்கள், பொருட்கள், கருத்துகளைக் குறிக்கும்.',
        'Example: පාසල.',
        'උදාහරණය: පාසල.',
        'எடுத்துக்காட்டு: பாடசாலை.'),
    _Entry(
        'tamil',
        'Nouns',
        'නාම පද',
        'பெயர்ச்சொற்கள்',
        'A noun identifies a person, place or thing.',
        'නාම පදයක් පුද්ගලයෙකු, ස්ථානයක් හෝ වස්තුවක් හඳුන්වයි.',
        'பெயர்ச்சொல் ஒரு நபர், இடம் அல்லது பொருளைக் குறிக்கும்.',
        'Example: மரம் (tree).',
        'උදාහරණය: மரம் (ගස).',
        'எடுத்துக்காட்டு: மரம்.'),
    _Entry(
        'civics',
        'Rights and responsibilities',
        'අයිතිවාසිකම් හා වගකීම්',
        'உரிமைகளும் பொறுப்புகளும்',
        'Learn the difference between a right and a responsibility.',
        'අයිතිවාසිකමක් සහ වගකීමක් අතර වෙනස හඳුනාගන්න.',
        'உரிமைக்கும் பொறுப்புக்கும் உள்ள வேறுபாட்டை அறிக.',
        'Respecting others is a responsibility.',
        'අන් අයට ගරු කිරීම වගකීමකි.',
        'பிறரை மதிப்பது ஒரு பொறுப்பாகும்.'),
    _Entry(
        'commerce',
        'Profit and loss',
        'ලාභය හා අලාභය',
        'இலாபமும் நட்டமும்',
        'Profit = selling price − cost price (when selling price is higher).',
        'ලාභය = විකුණුම් මිල − ගැනුම් මිල (විකුණුම් මිල වැඩි නම්).',
        'இலாபம் = விற்பனை விலை − அடக்க விலை (விற்பனை விலை அதிகமானால்).',
        'Rs. 150 − Rs. 100 = Rs. 50 profit.',
        'රු.150 − රු.100 = රු.50 ලාභය.',
        'ரூ.150 − ரூ.100 = ரூ.50 இலாபம்.'),
    _Entry(
        'media',
        'Media literacy',
        'මාධ්‍ය සාක්ෂරතාව',
        'ஊடக அறிவாற்றல்',
        'Check the author, evidence, date and purpose before sharing a claim.',
        'ප්‍රකාශයක් බෙදාගැනීමට පෙර කර්තෘ, සාක්ෂි, දිනය හා අරමුණ පරීක්ෂා කරන්න.',
        'ஒரு தகவலைப் பகிரும் முன் ஆசிரியர், ஆதாரம், தேதி, நோக்கம் ஆகியவற்றைச் சரிபார்க்கவும்.',
        'Compare a claim with reliable sources.',
        'ප්‍රකාශයක් විශ්වාසදායක මූලාශ්‍ර සමඟ සසඳන්න.',
        'தகவலை நம்பகமான ஆதாரங்களுடன் ஒப்பிடுக.'),
    _Entry(
        'health',
        'Balanced diet',
        'සමබර ආහාර වේල',
        'சமச்சீர் உணவு',
        'A balanced diet provides different nutrients in suitable amounts.',
        'සමබර ආහාර වේලක විවිධ පෝෂක සුදුසු ප්‍රමාණවලින් අඩංගු වේ.',
        'சமச்சீர் உணவில் பல்வேறு ஊட்டச்சத்துகள் பொருத்தமான அளவில் உள்ளன.',
        'Include varied food groups.',
        'විවිධ ආහාර කාණ්ඩ ඇතුළත් කරන්න.',
        'பல்வேறு உணவுக் குழுக்களைச் சேர்க்கவும்.'),
    _Entry(
        'dancing',
        'Rhythm and beat',
        'රිද්මය හා තාලය',
        'இலயமும் தாளமும்',
        'A beat is a recurring pulse; rhythm is the pattern of long and short sounds or movements.',
        'තාල ස්පන්දනය නැවත නැවත ඇතිවන ස්ථිර ස්පන්දනයකි. රිද්මය යනු ශබ්ද හෝ චලන කාල රටාවයි.',
        'தாளத் துடிப்பு தொடர்ந்து வரும் அடிப்படைத் துடிப்பாகும்; இலயம் ஒலி அல்லது அசைவின் கால வடிவமாகும்.',
        'Clap a steady beat, then practise a movement pattern.',
        'සමාන කාල පරතරයකින් අත්පුඩි ගසා, ඒ මත චලන රටාවක් පුහුණු වන්න.',
        'சீரான தாளத்தில் கைதட்டி அசைவு வடிவத்தைப் பயிற்சி செய்க.'),
    _Entry(
        'dancing',
        'Posture and expression',
        'ඉරියව් හා අභිනය',
        'உடல்நிலையும் அபிநயமும்',
        'Dance communicates through body position, gesture and facial expression.',
        'නර්තනයේදී ශරීර ඉරියව්, හස්ත චලන සහ මුහුණේ අභිනය මඟින් අදහස් ප්‍රකාශ වේ.',
        'நடனத்தில் உடல்நிலை, கை அசைவுகள், முகபாவங்கள் மூலம் கருத்துகள் வெளிப்படுகின்றன.',
        'Practise the same gesture with different expressions.',
        'එකම හස්ත චලනය විවිධ මුහුණේ අභිනයන් සමඟ පුහුණු වන්න.',
        'ஒரே கை அசைவை வெவ்வேறு முகபாவங்களுடன் பயிற்சி செய்க.'),
    _Entry(
        'music',
        'Beat and tempo',
        'තාල ස්පන්දනය හා වේගය',
        'தாளத் துடிப்பும் வேகமும்',
        'Tempo describes how fast or slow the beat is.',
        'තාල ස්පන්දනයේ වේගය සංගීතයේ වේගය ලෙස හඳුන්වයි.',
        'தாளத் துடிப்பின் வேகம் இசையின் வேகத்தைக் குறிக்கிறது.',
        'Clap slowly, then faster while keeping a steady beat.',
        'සමාන තාලයක් පවත්වා සෙමින් හා ඉක්මනින් අත්පුඩි ගසන්න.',
        'சீரான தாளத்தில் மெதுவாகவும் வேகமாகவும் கைதட்டுக.'),
    _Entry(
        'music',
        'Pitch and melody',
        'ස්වර උස හා තනු',
        'சுருதியும் மெட்டும்',
        'Pitch tells how high or low a sound is; a melody is a sequence of notes.',
        'ස්වර උස මඟින් හඬක උස් පහත් බව ද, තනුව මඟින් ස්වර අනුපිළිවෙළක් ද දැක්වේ.',
        'சுருதி ஒலியின் உயர்வு தாழ்வைக் குறிக்கும்; மெட்டு என்பது இசைச் சுரங்களின் வரிசை.',
        'Sing three notes from low to high.',
        'පහළ ස්වරයක සිට ඉහළට ස්වර තුනක් ගායනා කරන්න.',
        'தாழ்ந்த சுரத்திலிருந்து உயர்ந்த சுரம் வரை மூன்று சுரங்களைப் பாடுக.'),
    _Entry(
        'art',
        'Primary colours',
        'මූලික වර්ණ',
        'முதன்மை நிறங்கள்',
        'In traditional painting, red, yellow and blue are taught as primary pigment colours.',
        'සාම්ප්‍රදායික චිත්‍ර කලාවේ රතු, කහ හා නිල් මූලික වර්ණ ලෙස ඉගැන්වේ.',
        'பாரம்பரிய ஓவியத்தில் சிவப்பு, மஞ்சள், நீலம் முதன்மை நிறங்களாகக் கற்பிக்கப்படுகின்றன.',
        'Mix yellow and blue paint to explore green.',
        'කහ හා නිල් තීන්ත මිශ්‍ර කර කොළ වර්ණය නිරීක්ෂණය කරන්න.',
        'மஞ்சள் மற்றும் நீல வண்ணங்களை கலந்து பச்சையை ஆராய்க.'),
    _Entry(
        'drama',
        'Character and dialogue',
        'චරිතය හා දෙබස්',
        'பாத்திரமும் உரையாடலும்',
        'A character acts in a story; dialogue is spoken exchange between characters.',
        'චරිතයක් කතාවක ක්‍රියා කරන අයෙකි; දෙබස් යනු චරිත අතර කථන හුවමාරුවයි.',
        'பாத்திரம் கதையில் செயல்படும் நபர்; உரையாடல் பாத்திரங்களுக்கு இடையிலான பேச்சாகும்.',
        'Act out a short two-person conversation.',
        'දෙදෙනෙකු අතර කෙටි සංවාදයක් රඟ දක්වන්න.',
        'இருவர் பேசும் சிறிய உரையாடலை நடித்துக் காட்டுக.'),
    _Entry(
        'religion',
        'Learning from sources',
        'මූලාශ්‍ර මඟින් ඉගෙනීම',
        'ஆதாரங்களிலிருந்து கற்றல்',
        'Distinguish a teaching, its source and its interpretation.',
        'ඉගැන්වීමක්, එහි මූලාශ්‍රය හා එහි අර්ථකථනය වෙන්කර හඳුනාගන්න.',
        'ஒரு போதனை, அதன் ஆதாரம், அதன் விளக்கம் ஆகியவற்றை வேறுபடுத்துக.',
        'Identify the lesson and the source cited by the textbook.',
        'පෙළපොතේ සඳහන් ඉගැන්වීම හා මූලාශ්‍රය හඳුනාගන්න.',
        'பாடநூலில் கூறிய போதனையையும் ஆதாரத்தையும் கண்டறிக.'),
  ];

  bool get _isGradeFive {
    final level = widget.selectedLevel.toLowerCase().trim();
    return level == 'grade_5_scholarship' ||
        level == 'grade_5' ||
        level == 'grade5' ||
        level == '5' ||
        level == 'scholarship' ||
        level.contains('scholarship') ||
        level.contains('ශිෂ්‍යත්ව') ||
        level.contains('5 ශ්‍රේණි');
  }

  String _normalizeSubject(String value) {
    final s = value.toLowerCase();
    if (s == 'maths') return 'mathematics';
    if (s == 'civic_education') return 'civics';
    if (s == 'health_pe') return 'health';
    if (s == 'physics' || s == 'chemistry' || s == 'biology') return 'science';
    if (s == 'buddhism' ||
        s == 'hinduism' ||
        s == 'christianity' ||
        s == 'catholicism' ||
        s == 'islam') return 'religion';
    return s;
  }

  @override
  void initState() {
    super.initState();
    final initial = _normalizeSubject(widget.selectedSubject);
    if (_categories.any((c) => c.key == initial)) _category = initial;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF0A1C14); // Deep Dark Green
    const panel = Color(0xFF112A20); // Dark Green Panel
    const gold = Color(0xFFD4AF37); // Premium Gold

    final query = _search.text.trim().toLowerCase();
    final library = _isGradeFive ? _primaryEntries : _entries;
    final shown = library.where((e) {
      if (_category != 'all' && e.subject != _category) return false;
      if (query.isEmpty) return true;
      return [
        e.siTitle,
        e.enTitle,
        e.taTitle,
        e.siBody,
        e.enBody,
        e.taBody,
        e.siExample,
        e.enExample,
        e.taExample
      ].any((v) => v.toLowerCase().contains(query));
    }).toList();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
          backgroundColor: background,
          foregroundColor: gold,
          centerTitle: true,
          elevation: 0,
          title: Text(_t(
              'දැනුම් පුස්තකාලය', 'Knowledge Library', 'அறிவுக் களஞ்சியம்'),
              style: const TextStyle(fontWeight: FontWeight.bold, color: gold))),
      body: SafeArea(
          child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: ListView(padding: const EdgeInsets.all(16), children: [
                  Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: panel,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: gold.withOpacity(0.4))),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                _t(
                                    _isGradeFive
                                        ? '5 ශ්‍රේණිය • ගණිතය • පරිසරය • භාෂා • කලා'
                                        : 'සූත්‍ර • ඉතිහාසය • සංගීතය • නර්තනය • තවත් විෂයයන්',
                                    _isGradeFive
                                        ? 'Grade 5 • Maths • Environment • Languages • Arts'
                                        : 'Formulas • History • Music • Dancing • More subjects',
                                    _isGradeFive
                                        ? 'தரம் 5 • கணிதம் • சூழல் • மொழிகள் • கலை'
                                        : 'சூத்திரங்கள் • வரலாறு • இசை • நடனம் • மேலும் பல'),
                                style: const TextStyle(
                                    color: gold,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 7),
                            Text(
                                _t(
                                    _isGradeFive
                                        ? '5 ශ්‍රේණියට ගැළපෙන ආරම්භක පාඩම්. සම්පූර්ණ නිල විෂය නිර්දේශය නොවේ.'
                                        : 'මෙය ආරම්භක පුස්තකාලයකි. සියලු ශ්‍රේණිවල සම්පූර්ණ විෂය නිර්දේශය තවම ඇතුළත් නැත.',
                                    _isGradeFive
                                        ? 'Grade 5 starter lessons, not the complete official syllabus.'
                                        : 'Starter library: not yet a complete grade-by-grade syllabus.',
                                    _isGradeFive
                                        ? 'தரம் 5 தொடக்கப் பாடங்கள்; முழு அதிகாரப்பூர்வப் பாடத்திட்டம் அல்ல.'
                                        : 'இது தொடக்க நூலகம்; எல்லா தரங்களின் முழுப் பாடத்திட்டமும் இன்னும் சேர்க்கப்படவில்லை.'),
                                style:
                                const TextStyle(color: Colors.white70, height: 1.4)),
                          ])),
                  const SizedBox(height: 16),
                  TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          prefixIcon:
                          const Icon(Icons.search, color: gold),
                          hintText: _t(
                              'මාතෘකාවක් සොයන්න', 'Search topics', 'தலைப்பைத் தேடுக'),
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: panel,
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: gold.withOpacity(0.3))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: gold, width: 1.5)))),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                      value: _category,
                      dropdownColor: panel,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: panel,
                          labelText: _t('විෂය', 'Subject', 'பாடம்'),
                          labelStyle: const TextStyle(color: gold),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: gold.withOpacity(0.3))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: gold, width: 1.5))),
                      items: [
                        DropdownMenuItem(
                            value: 'all',
                            child: Text(_t('සියලු විෂයයන්', 'All subjects',
                                'அனைத்துப் பாடங்கள்'))),
                        ..._categories.map((c) => DropdownMenuItem(
                            value: c.key,
                            child: Text(_t(c.si, c.en, c.ta),
                                overflow: TextOverflow.ellipsis))),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _category = v);
                      }),
                  const SizedBox(height: 14),
                  Text(
                      _t('මාතෘකා: ${shown.length}', 'Topics: ${shown.length}',
                          'தலைப்புகள்: ${shown.length}'),
                      style: const TextStyle(color: gold, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (shown.isEmpty)
                    Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                            _t(
                                'මෙම සෙවීමට තවම අන්තර්ගතයක් නැත.',
                                'No starter content matches this search.',
                                'இந்தத் தேடலுக்கான உள்ளடக்கம் இன்னும் இல்லை.'),
                            style: const TextStyle(color: Colors.white70))),
                  ...shown.map((e) => Card(
                      color: panel,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: gold.withOpacity(0.3))),
                      child: ExpansionTile(
                        iconColor: gold,
                        collapsedIconColor: Colors.white70,
                        title: Text(_t(e.siTitle, e.enTitle, e.taTitle),
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            _t('විස්තරය සහ උදාහරණය', 'Explanation and example',
                                'விளக்கமும் எடுத்துக்காட்டும்'),
                            style: const TextStyle(color: Colors.white54)),
                        children: [
                          Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_t(e.siBody, e.enBody, e.taBody),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            height: 1.5,
                                            fontSize: 15)),
                                    const SizedBox(height: 10),
                                    Text(
                                        _t('මතක තබාගන්න', 'Remember',
                                            'நினைவில் கொள்ளுங்கள்'),
                                        style: const TextStyle(
                                            color: gold,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(
                                        _t(
                                            'මුලින් අදහස තේරුම් ගන්න. ඉන්පසු පහත උදාහරණය පරීක්ෂා කර ඔබම ප්‍රශ්නය විසඳන්න.',
                                            'Understand the idea first, then study the example and solve the practice question yourself.',
                                            'முதலில் கருத்தைப் புரிந்துகொண்டு, எடுத்துக்காட்டைப் பார்த்து பயிற்சியை நீங்களே செய்யுங்கள்.'),
                                        style: const TextStyle(
                                            color: Colors.white70, height: 1.5)),
                                    const SizedBox(height: 10),
                                    Text(_t('උදාහරණය:', 'Example:', 'எடுத்துக்காட்டு:'),
                                        style: const TextStyle(
                                            color: gold,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(_t(e.siExample, e.enExample, e.taExample),
                                        style: const TextStyle(
                                            color: Colors.white, height: 1.5)),
                                    if (_isGradeFive &&
                                        (_gradeFiveChecks.containsKey(e.siTitle) ||
                                            _moreGradeFiveChecks
                                                .containsKey(e.siTitle))) ...[
                                      const SizedBox(height: 16),
                                      _LessonPractice(
                                          check: _gradeFiveChecks[e.siTitle] ??
                                              _moreGradeFiveChecks[e.siTitle]!,
                                          language: widget.language),
                                    ],
                                  ]))
                        ],
                      ))),
                ]),
              ))),
    );
  }
}
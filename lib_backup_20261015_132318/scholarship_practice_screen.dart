import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// Original practice questions, not official examination questions.
// No Firebase, Coins or other app services are modified by this screen.
class ScholarshipPracticeScreen extends StatefulWidget {
  const ScholarshipPracticeScreen({super.key, required this.language});
  final String language;

  @override
  State<ScholarshipPracticeScreen> createState() =>
      _ScholarshipPracticeScreenState();
}

class QuizQuestion {
  const QuizQuestion(
      this.topic,
      this.si,
      this.en,
      this.ta,
      this.optionsSi,
      this.optionsEn,
      this.optionsTa,
      this.correct,
      this.whySi,
      this.whyEn,
      this.whyTa);
  final String topic, si, en, ta;
  final List<String> optionsSi, optionsEn, optionsTa;
  final int correct;
  final String whySi, whyEn, whyTa;
}

class _ScholarshipPracticeScreenState extends State<ScholarshipPracticeScreen> {
  static const Color _bg = Color(0xFF06112D);
  static const Color _panel = Color(0xFF102653);
  static const Color _cyan = Color(0xFF16D9FF);
  static const List<String> _topics = <String>[
    'all',
    'patterns',
    'arithmetic',
    'fractions',
    'time',
    'measurement',
    'environment',
    'language',
    'reasoning'
  ];

  // All question content is authored and reviewed as practice material.
  static const List<QuizQuestion> _bank = <QuizQuestion>[
    QuizQuestion(
        'patterns',
        '3, 7, 11, 15, ... ඊළඟ සංඛ්‍යාව?',
        'Next number: 3, 7, 11, 15, ...?',
        '3, 7, 11, 15, ... அடுத்த எண்?',
        <String>['17', '18', '19', '20'],
        <String>['17', '18', '19', '20'],
        <String>['17', '18', '19', '20'],
        2,
        'සෑම වරකම 4ක් එකතු වේ. 15 + 4 = 19.',
        'Add 4 each time: 15 + 4 = 19.',
        'ஒவ்வொரு முறையும் 4 கூட்டவும்: 15 + 4 = 19.'),
    QuizQuestion(
        'patterns',
        '2, 4, 8, 16, ... ඊළඟ සංඛ්‍යාව?',
        'Next number: 2, 4, 8, 16, ...?',
        '2, 4, 8, 16, ... அடுத்த எண்?',
        <String>['24', '30', '32', '34'],
        <String>['24', '30', '32', '34'],
        <String>['24', '30', '32', '34'],
        2,
        'සෑම වරකම 2න් ගුණ කරයි. 16 × 2 = 32.',
        'Multiply by 2 each time.',
        'ஒவ்வொரு முறையும் 2 ஆல் பெருக்கவும்.'),
    QuizQuestion(
        'patterns',
        '5, 10, 20, 40, ... ඊළඟ සංඛ්‍යාව?',
        'Next number: 5, 10, 20, 40, ...?',
        '5, 10, 20, 40, ... அடுத்த எண்?',
        <String>['45', '60', '80', '100'],
        <String>['45', '60', '80', '100'],
        <String>['45', '60', '80', '100'],
        2,
        'සෑම වරකම දෙගුණ වේ. 40 × 2 = 80.',
        'Each number doubles.',
        'ஒவ்வொரு எண்ணும் இரட்டிப்பாகிறது.'),
    QuizQuestion(
        'patterns',
        '1, 4, 9, 16, ... ඊළඟ සංඛ්‍යාව?',
        'Next number: 1, 4, 9, 16, ...?',
        '1, 4, 9, 16, ... அடுத்த எண்?',
        <String>['20', '24', '25', '36'],
        <String>['20', '24', '25', '36'],
        <String>['20', '24', '25', '36'],
        2,
        'මේවා 1², 2², 3², 4² වේ. ඊළඟට 5² = 25.',
        'These are square numbers; 5² = 25.',
        'இவை வர்க்க எண்கள்; 5² = 25.'),
    QuizQuestion(
        'patterns',
        '30, 27, 24, 21, ... ඊළඟ සංඛ්‍යාව?',
        'Next number: 30, 27, 24, 21, ...?',
        '30, 27, 24, 21, ... அடுத்த எண்?',
        <String>['15', '17', '18', '19'],
        <String>['15', '17', '18', '19'],
        <String>['15', '17', '18', '19'],
        2,
        'සෑම වරකම 3ක් අඩු වේ. 21 − 3 = 18.',
        'Subtract 3 each time.',
        'ஒவ்வொரு முறையும் 3 ஐக் கழிக்கவும்.'),
    QuizQuestion(
        'patterns',
        '1, 2, 4, 7, 11, ... ඊළඟ සංඛ්‍යාව?',
        'Next number: 1, 2, 4, 7, 11, ...?',
        '1, 2, 4, 7, 11, ... அடுத்த எண்?',
        <String>['14', '15', '16', '17'],
        <String>['14', '15', '16', '17'],
        <String>['14', '15', '16', '17'],
        2,
        'එකතු කරන අගයන් 1, 2, 3, 4, 5 ලෙස වැඩිවේ. 11 + 5 = 16.',
        'The increases are 1, 2, 3, 4, 5; 11 + 5 = 16.',
        'கூட்டப்படும் எண்கள் 1, 2, 3, 4, 5; 11 + 5 = 16.'),
    QuizQuestion(
        'arithmetic',
        'පැන්සල් 48ක් ළමයින් 8 දෙනෙකුට සමානව බෙදුවොත් එක් අයෙකුට කීයක්ද?',
        '48 pencils shared equally among 8 children: how many each?',
        '48 பென்சில்களை 8 பிள்ளைகளுக்குச் சமமாகப் பகிர்ந்தால் ஒவ்வொருவருக்கும் எத்தனை?',
        <String>['4', '5', '6', '8'],
        <String>['4', '5', '6', '8'],
        <String>['4', '5', '6', '8'],
        2,
        '48 ÷ 8 = 6.',
        '48 ÷ 8 = 6.',
        '48 ÷ 8 = 6.'),
    QuizQuestion(
        'arithmetic',
        '125 + 75 − 40 = ?',
        '125 + 75 − 40 = ?',
        '125 + 75 − 40 = ?',
        <String>['150', '155', '160', '170'],
        <String>['150', '155', '160', '170'],
        <String>['150', '155', '160', '170'],
        2,
        '125 + 75 = 200; 200 − 40 = 160.',
        '125 + 75 = 200; 200 − 40 = 160.',
        '125 + 75 = 200; 200 − 40 = 160.'),
    QuizQuestion(
        'arithmetic',
        'පොත් 7ක මිල රු. 35 බැගින් නම් මුළු මිල කීයද?',
        'Seven books cost Rs 35 each. Total cost?',
        '7 புத்தகங்கள் ஒவ்வொன்றும் ரூ.35 என்றால் மொத்த விலை?',
        <String>['210', '225', '245', '275'],
        <String>['210', '225', '245', '275'],
        <String>['210', '225', '245', '275'],
        2,
        '7 × 35 = රු. 245.',
        '7 × 35 = Rs 245.',
        '7 × 35 = Rs 245.'),
    QuizQuestion(
        'arithmetic',
        '360 ÷ 9 = ?',
        '360 ÷ 9 = ?',
        '360 ÷ 9 = ?',
        <String>['30', '35', '40', '45'],
        <String>['30', '35', '40', '45'],
        <String>['30', '35', '40', '45'],
        2,
        '9 × 40 = 360.',
        '9 × 40 = 360.',
        '9 × 40 = 360.'),
    QuizQuestion(
        'arithmetic',
        'රු. 500කින් රු. 185ක් වැය කළා. ඉතිරි මුදල?',
        'Rs 185 spent from Rs 500. How much remains?',
        'ரூ.500 இல் ரூ.185 செலவிட்டால் மீதி?',
        <String>['305', '310', '315', '325'],
        <String>['305', '310', '315', '325'],
        <String>['305', '310', '315', '325'],
        2,
        '500 − 185 = රු. 315.',
        '500 − 185 = Rs 315.',
        '500 − 185 = Rs 315.'),
    QuizQuestion(
        'arithmetic',
        '18 + 6 × 3 = ?',
        '18 + 6 × 3 = ?',
        '18 + 6 × 3 = ?',
        <String>['24', '54', '36', '72'],
        <String>['24', '54', '36', '72'],
        <String>['24', '54', '36', '72'],
        2,
        'පළමුව ගුණ කරන්න: 6 × 3 = 18. එවිට 18 + 18 = 36.',
        'Multiply first: 6 × 3 = 18; 18 + 18 = 36.',
        'Multiply first: 6 × 3 = 18; 18 + 18 = 36.'),
    QuizQuestion(
        'fractions',
        '1/2 + 1/4 = ?',
        '1/2 + 1/4 = ?',
        '1/2 + 1/4 = ?',
        <String>['1/4', '1/2', '3/4', '1'],
        <String>['1/4', '1/2', '3/4', '1'],
        <String>['1/4', '1/2', '3/4', '1'],
        2,
        '1/2 = 2/4. එවිට 2/4 + 1/4 = 3/4.',
        '1/2 = 2/4, so the sum is 3/4.',
        '1/2 = 2/4, so the sum is 3/4.'),
    QuizQuestion(
        'fractions',
        '20න් 1/4ක් කීයද?',
        'What is one quarter of 20?',
        '20 இன் கால் பங்கு எவ்வளவு?',
        <String>['4', '6', '5', '8'],
        <String>['4', '6', '5', '8'],
        <String>['4', '6', '5', '8'],
        2,
        '20 ÷ 4 = 5.',
        '20 ÷ 4 = 5.',
        '20 ÷ 4 = 5.'),
    QuizQuestion(
        'fractions',
        '3/4 − 1/4 = ?',
        '3/4 − 1/4 = ?',
        '3/4 − 1/4 = ?',
        <String>['1/4', '3/4', '1/2', '1'],
        <String>['1/4', '3/4', '1/2', '1'],
        <String>['1/4', '3/4', '1/2', '1'],
        2,
        '3/4 − 1/4 = 2/4 = 1/2.',
        '3/4 − 1/4 = 2/4 = 1/2.',
        '3/4 − 1/4 = 2/4 = 1/2.'),
    QuizQuestion(
        'fractions',
        '30න් 1/3ක් කීයද?',
        'What is one third of 30?',
        '30 இன் மூன்றில் ஒரு பங்கு?',
        <String>['5', '9', '10', '15'],
        <String>['5', '9', '10', '15'],
        <String>['5', '9', '10', '15'],
        2,
        '30 ÷ 3 = 10.',
        '30 ÷ 3 = 10.',
        '30 ÷ 3 = 10.'),
    QuizQuestion(
        'fractions',
        '1/5 + 2/5 = ?',
        '1/5 + 2/5 = ?',
        '1/5 + 2/5 = ?',
        <String>['1/5', '2/5', '3/5', '4/5'],
        <String>['1/5', '2/5', '3/5', '4/5'],
        <String>['1/5', '2/5', '3/5', '4/5'],
        2,
        'හර සමාන නිසා ලව එකතු කරන්න: 1 + 2 = 3.',
        'Add numerators when denominators match: 3/5.',
        'Add numerators when denominators match: 3/5.'),
    QuizQuestion(
        'fractions',
        '24න් 3/8ක් කීයද?',
        'What is three eighths of 24?',
        '24 இன் எட்டில் மூன்று பங்கு?',
        <String>['6', '8', '9', '12'],
        <String>['6', '8', '9', '12'],
        <String>['6', '8', '9', '12'],
        2,
        '24 ÷ 8 × 3 = 9.',
        '24 ÷ 8 × 3 = 9.',
        '24 ÷ 8 × 3 = 9.'),
    QuizQuestion(
        'time',
        'පෙ.ව. 9:20ට ආරම්භ වී විනාඩි 50ක් පැවති වැඩක් අවසන් වන්නේ?',
        'Activity begins 9:20 a.m. and lasts 50 minutes. End time?',
        'காலை 9:20க்கு தொடங்கி 50 நிமிடங்கள் நீடித்தால் முடியும் நேரம்?',
        <String>['9:50', '10:00', '10:10', '10:20'],
        <String>['9:50', '10:00', '10:10', '10:20'],
        <String>['9:50', '10:00', '10:10', '10:20'],
        2,
        '9:20 + විනාඩි 50 = 10:10.',
        '9:20 + 50 minutes = 10:10.',
        '9:20 + 50 minutes = 10:10.'),
    QuizQuestion(
        'time',
        'පැය 2යි විනාඩි 30ක් = විනාඩි කීයද?',
        '2 hours 30 minutes equals how many minutes?',
        '2 மணி 30 நிமிடம் என்பது எத்தனை நிமிடங்கள்?',
        <String>['120', '130', '150', '180'],
        <String>['120', '130', '150', '180'],
        <String>['120', '130', '150', '180'],
        2,
        '2 × 60 + 30 = 150.',
        '2 × 60 + 30 = 150.',
        '2 × 60 + 30 = 150.'),
    QuizQuestion(
        'time',
        'පෙ.ව. 8:45 සිට පෙ.ව. 9:30 දක්වා කාලය කීයද?',
        'Time between 8:45 a.m. and 9:30 a.m.?',
        'காலை 8:45 முதல் 9:30 வரை எத்தனை நிமிடங்கள்?',
        <String>['30', '35', '45', '55'],
        <String>['30', '35', '45', '55'],
        <String>['30', '35', '45', '55'],
        2,
        '8:45 සිට 9:00 දක්වා 15යි; 9:00 සිට 9:30 දක්වා 30යි. මුළු 45යි.',
        '15 + 30 = 45 minutes.',
        '15 + 30 = 45 minutes.'),
    QuizQuestion(
        'time',
        'දින 3ක පැය ගණන කීයද?',
        'How many hours in 3 days?',
        '3 நாட்களில் எத்தனை மணிநேரம்?',
        <String>['48', '60', '72', '84'],
        <String>['48', '60', '72', '84'],
        <String>['48', '60', '72', '84'],
        2,
        '3 × 24 = පැය 72.',
        '3 × 24 = 72 hours.',
        '3 × 24 = 72 hours.'),
    QuizQuestion(
        'time',
        'විනාඩි 90ක් යනු පැය සහ විනාඩි කීයද?',
        '90 minutes equals how many hours and minutes?',
        '90 நிமிடங்கள் எத்தனை மணி மற்றும் நிமிடம்?',
        <String>['1:00', '1:15', '1:30', '2:00'],
        <String>['1:00', '1:15', '1:30', '2:00'],
        <String>['1:00', '1:15', '1:30', '2:00'],
        2,
        'විනාඩි 60 + 30 = පැය 1යි විනාඩි 30යි.',
        '60 + 30 = 1 hour 30 minutes.',
        '60 + 30 = 1 hour 30 minutes.'),
    QuizQuestion(
        'time',
        'ප.ව. 2:15ට ආරම්භ වී පැය 2ක් පැවති වැඩක් අවසන් වන්නේ?',
        'An activity starts 2:15 p.m. and lasts 2 hours. End time?',
        'பிற்பகல் 2:15க்கு தொடங்கி 2 மணி நேரம் நீடித்தால் முடியும் நேரம்?',
        <String>['3:15', '3:45', '4:15', '4:45'],
        <String>['3:15', '3:45', '4:15', '4:45'],
        <String>['3:15', '3:45', '4:15', '4:45'],
        2,
        '2:15 + පැය 2 = ප.ව. 4:15.',
        '2:15 p.m. + 2 hours = 4:15 p.m.',
        '2:15 p.m. + 2 hours = 4:15 p.m.'),
    QuizQuestion(
        'measurement',
        'මීටර් 3ක් = සෙන්ටිමීටර් කීයද?',
        '3 metres = how many centimetres?',
        '3 மீட்டர் = எத்தனை சென்டிமீட்டர்?',
        <String>['30', '150', '300', '3000'],
        <String>['30', '150', '300', '3000'],
        <String>['30', '150', '300', '3000'],
        2,
        '1 m = 100 cm. 3 × 100 = 300 cm.',
        '1 m = 100 cm; 3 m = 300 cm.',
        '1 m = 100 cm; 3 m = 300 cm.'),
    QuizQuestion(
        'measurement',
        'දිග 8 cm, පළල 5 cm වූ සෘජුකෝණාස්‍රයක පරිමිතිය?',
        'Perimeter of a rectangle 8 cm by 5 cm?',
        '8 செ.மீ. நீளம், 5 செ.மீ. அகலம் கொண்ட செவ்வகத்தின் சுற்றளவு?',
        <String>['13', '26', '26 cm', '40 cm'],
        <String>['13', '26', '26 cm', '40 cm'],
        <String>['13', '26', '26 cm', '40 cm'],
        2,
        'පරිමිතිය = 2 × (8 + 5) = 26 cm.',
        'Perimeter = 2 × (8 + 5) = 26 cm.',
        'Perimeter = 2 × (8 + 5) = 26 cm.'),
    QuizQuestion(
        'measurement',
        'කිලෝග්‍රෑම් 2යි ග්‍රෑම් 500ක් = ග්‍රෑම් කීයද?',
        '2 kg 500 g = how many grams?',
        '2 கி.கி. 500 கிராம் = எத்தனை கிராம்?',
        <String>['500', '1500', '2500', '3000'],
        <String>['500', '1500', '2500', '3000'],
        <String>['500', '1500', '2500', '3000'],
        2,
        '2 kg = 2000 g; 2000 + 500 = 2500 g.',
        '2 kg = 2000 g; total 2500 g.',
        '2 kg = 2000 g; total 2500 g.'),
    QuizQuestion(
        'measurement',
        'පැත්ත 6 cm වූ සමචතුරස්‍රයක පරිමිතිය?',
        'Perimeter of a square with side 6 cm?',
        '6 செ.மீ. பக்கமுள்ள சதுரத்தின் சுற்றளவு?',
        <String>['12', '18', '24', '36'],
        <String>['12', '18', '24', '36'],
        <String>['12', '18', '24', '36'],
        2,
        'පරිමිතිය = 4 × 6 = 24 cm.',
        'Perimeter = 4 × 6 = 24 cm.',
        'Perimeter = 4 × 6 = 24 cm.'),
    QuizQuestion(
        'measurement',
        'ලීටර් 4ක් = මිලිලීටර් කීයද?',
        '4 litres = how many millilitres?',
        '4 லிட்டர் = எத்தனை மில்லிலிட்டர்?',
        <String>['400', '2000', '4000', '40000'],
        <String>['400', '2000', '4000', '40000'],
        <String>['400', '2000', '4000', '40000'],
        2,
        '1 L = 1000 mL; 4 L = 4000 mL.',
        '1 L = 1000 mL; 4 L = 4000 mL.',
        '1 L = 1000 mL; 4 L = 4000 mL.'),
    QuizQuestion(
        'measurement',
        'දිග 7 cm, පළල 4 cm වූ සෘජුකෝණාස්‍රයක වර්ගඵලය?',
        'Area of a rectangle 7 cm by 4 cm?',
        '7 செ.மீ. நீளம், 4 செ.மீ. அகலம் கொண்ட செவ்வகத்தின் பரப்பளவு?',
        <String>['11', '22', '28', '44'],
        <String>['11', '22', '28', '44'],
        <String>['11', '22', '28', '44'],
        2,
        'වර්ගඵලය = 7 × 4 = 28 cm².',
        'Area = 7 × 4 = 28 cm².',
        'Area = 7 × 4 = 28 cm².'),
    QuizQuestion(
        'environment',
        'පහත කුමන ද්‍රව්‍යය චුම්බකයකට ආකර්ෂණය වේද?',
        'Which material is attracted by a magnet?',
        'காந்தத்தால் ஈர்க்கப்படும் பொருள் எது?',
        <String>['ලී', 'වීදුරු', 'යකඩ', 'කඩදාසි'],
        <String>['Wood', 'Glass', 'Iron', 'Paper'],
        <String>['மரம்', 'கண்ணாடி', 'இரும்பு', 'காகிதம்'],
        2,
        'යකඩ චුම්බකයට ආකර්ෂණය වේ.',
        'Iron is attracted to a magnet.',
        'இரும்பு காந்தத்தால் ஈர்க்கப்படும்.'),
    QuizQuestion(
        'environment',
        'ශාකයක් ප්‍රභාසංශ්ලේෂණය සඳහා වාතයෙන් ලබාගන්නා වායුව?',
        'Gas a plant takes from air for photosynthesis?',
        'ஒளிச்சேர்க்கைக்கு தாவரம் காற்றிலிருந்து பெறும் வாயு?',
        <String>['ඔක්සිජන්', 'නයිට්‍රජන්', 'කාබන් ඩයොක්සයිඩ්', 'හීලියම්'],
        <String>['Oxygen', 'Nitrogen', 'Carbon dioxide', 'Helium'],
        <String>['ஆக்சிஜன்', 'நைட்ரஜன்', 'கார்பன் டைஆக்சைடு', 'ஹீலியம்'],
        2,
        'ශාක ප්‍රභාසංශ්ලේෂණයේදී කාබන් ඩයොක්සයිඩ් භාවිත කරයි.',
        'Plants use carbon dioxide in photosynthesis.',
        'தாவரங்கள் ஒளிச்சேர்க்கையில் கார்பன் டைஆக்சைடைப் பயன்படுத்துகின்றன.'),
    QuizQuestion(
        'environment',
        'ජලය සාමාන්‍ය වායුගෝලීය පීඩනයේදී උතුරන උෂ්ණත්වය?',
        'Boiling point of water at normal atmospheric pressure?',
        'சாதாரண வளிமண்டல அழுத்தத்தில் நீர் கொதிக்கும் வெப்பநிலை?',
        <String>['0°C', '50°C', '100°C', '150°C'],
        <String>['0°C', '50°C', '100°C', '150°C'],
        <String>['0°C', '50°C', '100°C', '150°C'],
        2,
        'සාමාන්‍ය වායුගෝලීය පීඩනයේදී ජලය 100°C දී උතුරයි.',
        'Water boils at 100°C at normal atmospheric pressure.',
        'சாதாரண வளிமண்டல அழுத்தத்தில் நீர் 100°C இல் கொதிக்கிறது.'),
    QuizQuestion(
        'environment',
        'සූර්යයාගෙන් පෘථිවියට ලැබෙන ප්‍රධාන ශක්තිය?',
        'Main energy received by Earth from the Sun?',
        'சூரியனிலிருந்து பூமிக்கு கிடைக்கும் முக்கிய ஆற்றல்?',
        <String>['ශබ්දය', 'චුම්බකය', 'ආලෝකය හා තාපය', 'විදුලි ධාරාව'],
        <String>['Sound', 'Magnetism', 'Light and heat', 'Electric current'],
        <String>['ஒலி', 'காந்தம்', 'ஒளியும் வெப்பமும்', 'மின்னோட்டம்'],
        2,
        'සූර්යයා ආලෝකය සහ තාපය ලබා දෙයි.',
        'The Sun supplies light and heat.',
        'சூரியன் ஒளியையும் வெப்பத்தையும் வழங்குகிறது.'),
    QuizQuestion(
        'environment',
        'බීජයක් පැළවීමට සාමාන්‍යයෙන් අවශ්‍ය නොවන දෙය කුමක්ද?',
        'Which is generally not necessary for a seed to germinate?',
        'விதை முளைக்க பொதுவாகத் தேவையற்றது எது?',
        <String>['ජලය', 'වාතය', 'සූර්යාලෝකය', 'සුදුසු උෂ්ණත්වය'],
        <String>['Water', 'Air', 'Sunlight', 'Suitable temperature'],
        <String>['நீர்', 'காற்று', 'சூரிய ஒளி', 'ஏற்ற வெப்பநிலை'],
        2,
        'බොහෝ බීජ පැළවීමට ජලය, ඔක්සිජන් සහ සුදුසු උෂ්ණත්වය අවශ්‍යය; සෘජු සූර්යාලෝකය අනිවාර්ය නැත.',
        'Most seeds need water, oxygen and suitable warmth; direct sunlight is not essential.',
        'பெரும்பாலான விதைகளுக்கு நீர், ஆக்சிஜன், ஏற்ற வெப்பநிலை தேவை; நேரடி சூரிய ஒளி அவசியமில்லை.'),
    QuizQuestion(
        'environment',
        'මිනිස් සිරුරේ රුධිරය පොම්ප කරන අවයවය?',
        'Which organ pumps blood around the body?',
        'உடலில் இரத்தத்தைச் செலுத்தும் உறுப்பு எது?',
        <String>['පෙනහළු', 'අක්මාව', 'හෘදය', 'වකුගඩු'],
        <String>['Lungs', 'Liver', 'Heart', 'Kidney'],
        <String>['நுரையீரல்', 'கல்லீரல்', 'இதயம்', 'சிறுநீரகம்'],
        2,
        'හෘදය රුධිරය ශරීරය පුරා පොම්ප කරයි.',
        'The heart pumps blood through the body.',
        'இதயம் உடல் முழுவதும் இரத்தத்தைச் செலுத்துகிறது.'),
    QuizQuestion(
        'language',
        '“ලස්සන” යන වචනයේ විරුද්ධ පදය කුමක්ද?',
        'Which word is the opposite of “beautiful”?',
        '“அழகான” என்பதன் எதிர்ச்சொல் எது?',
        <String>['හොඳ', 'අලුත්', 'කැත', 'උස'],
        <String>['Good', 'New', 'Ugly', 'Tall'],
        <String>['நல்ல', 'புதிய', 'அழகற்ற', 'உயரமான'],
        2,
        '“ලස්සන” යන්නෙහි විරුද්ධ අර්ථය “කැත” යන්නයි.',
        'The opposite of beautiful is ugly.',
        'அழகான என்பதன் எதிர்ச்சொல் அழகற்ற.'),
    QuizQuestion(
        'language',
        '“ගස” යන නාම පදයේ බහු වචනය කුමක්ද?',
        'Which is the plural of “tree”?',
        '“மரம்” என்பதன் பன்மை எது?',
        <String>['ගසට', 'ගසේ', 'ගස්', 'ගසක්'],
        <String>['To the tree', 'Of the tree', 'Trees', 'A tree'],
        <String>['மரத்திற்கு', 'மரத்தின்', 'மரங்கள்', 'ஒரு மரம்'],
        2,
        '“ගස” යන ඒක වචනයේ බහු වචනය “ගස්” වේ.',
        'The plural of tree is trees.',
        'மரம் என்பதன் பன்மை மரங்கள்.'),
    QuizQuestion(
        'language',
        '“පොත” යන වචනය කුමන පද වර්ගයට අයත්ද?',
        'What part of speech is “book”?',
        '“புத்தகம்” என்பது எந்தச் சொல் வகை?',
        <String>['ක්‍රියා පදය', 'විශේෂණ පදය', 'නාම පදය', 'නිපාතය'],
        <String>['Verb', 'Adjective', 'Noun', 'Particle'],
        <String>['வினைச்சொல்', 'உரிச்சொல்', 'பெயர்ச்சொல்', 'இடைச்சொல்'],
        2,
        '“පොත” යනු දෙයක නමක් නිසා නාම පදයකි.',
        'Book names a thing, so it is a noun.',
        'புத்தகம் ஒரு பொருளின் பெயர்; அது பெயர்ச்சொல்.'),
    QuizQuestion(
        'language',
        '“දුවයි” යන වචනය කුමන පද වර්ගයට අයත්ද?',
        'What part of speech is “runs”?',
        '“ஓடுகிறது” என்பது எந்தச் சொல் வகை?',
        <String>['නාම පදය', 'විශේෂණ පදය', 'ක්‍රියා පදය', 'සර්වනාමය'],
        <String>['Noun', 'Adjective', 'Verb', 'Pronoun'],
        <String>['பெயர்ச்சொல்', 'உரிச்சொல்', 'வினைச்சொல்', 'பதிலிடுபெயர்'],
        2,
        '“දුවයි” යන්න ක්‍රියාවක් දක්වයි.',
        'Runs describes an action, so it is a verb.',
        'ஓடுகிறது ஒரு செயலைக் குறிக்கிறது; அது வினைச்சொல்.'),
    QuizQuestion(
        'language',
        '“වේගවත්” යන වචනයේ සමීප අර්ථය?',
        'Which word is closest in meaning to “fast”?',
        '“வேகமான” என்பதற்கு நெருங்கிய பொருள்?',
        <String>['මන්දගාමී', 'නිහඬ', 'ඉක්මන්', 'කුඩා'],
        <String>['Slow', 'Quiet', 'Quick', 'Small'],
        <String>['மெதுவான', 'அமைதியான', 'விரைவான', 'சிறிய'],
        2,
        '“වේගවත්” සහ “ඉක්මන්” සමීප අර්ථ දරයි.',
        'Fast and quick have similar meanings.',
        'வேகமான மற்றும் விரைவான என்பவை ஒத்த பொருளுடையவை.'),
    QuizQuestion(
        'language',
        '“ඔහු පාසලට යයි.” වාක්‍යයේ ක්‍රියා පදය කුමක්ද?',
        'In “He goes to school”, which is the verb?',
        '“அவன் பள்ளிக்குச் செல்கிறான்” என்ற வாக்கியத்தில் வினைச்சொல் எது?',
        <String>['ඔහු', 'පාසලට', 'යයි', 'වාක්‍යය'],
        <String>['He', 'To school', 'Goes', 'Sentence'],
        <String>['அவன்', 'பள்ளிக்கு', 'செல்கிறான்', 'வாக்கியம்'],
        2,
        '“යයි” යන්න සිදු කරන ක්‍රියාව දක්වයි.',
        'Goes expresses the action.',
        'செல்கிறான் செயலைக் குறிக்கிறது.'),
    QuizQuestion(
        'reasoning',
        'අනෙක් සංඛ්‍යාවලට වෙනස් සංඛ්‍යාව තෝරන්න: 6, 12, 18, 25',
        'Odd one out: 6, 12, 18, 25',
        'வேறுபட்ட எண்ணைத் தேர்ந்தெடுக்கவும்: 6, 12, 18, 25',
        <String>['6', '12', '25', '18'],
        <String>['6', '12', '25', '18'],
        <String>['6', '12', '25', '18'],
        2,
        '6, 12, 18 යන සංඛ්‍යා 6හි ගුණාකාර වේ; 25 එසේ නොවේ.',
        '6, 12, 18 are multiples of 6; 25 is not.',
        '6, 12, 18 are multiples of 6; 25 is not.'),
    QuizQuestion(
        'reasoning',
        'සඳුදාට දින 3කට පසු කුමන දිනයද?',
        'What day is three days after Monday?',
        'திங்கட்கிழமைக்கு மூன்று நாட்கள் பிறகு எந்த நாள்?',
        <String>['අඟහරුවාදා', 'බදාදා', 'බ්‍රහස්පතින්දා', 'සිකුරාදා'],
        <String>['Tuesday', 'Wednesday', 'Thursday', 'Friday'],
        <String>['செவ்வாய்', 'புதன்', 'வியாழன்', 'வெள்ளி'],
        2,
        'අඟහරුවාදා 1, බදාදා 2, බ්‍රහස්පතින්දා 3.',
        'Tuesday 1, Wednesday 2, Thursday 3.',
        'செவ்வாய் 1, புதன் 2, வியாழன் 3.'),
    QuizQuestion(
        'reasoning',
        'පේළියක අමාල් ඉදිරියෙන් 4 වැනියා හා පසුපසින් 5 වැනියා නම් ළමයින් ගණන?',
        'Amal is 4th from the front and 5th from the back. Total children?',
        'அமல் முன்புறத்திலிருந்து 4ஆம் இடத்திலும் பின்னிருந்து 5ஆம் இடத்திலும் இருந்தால் மொத்தம் எத்தனை பேர்?',
        <String>['7', '10', '8', '9'],
        <String>['7', '10', '8', '9'],
        <String>['7', '10', '8', '9'],
        2,
        '4 + 5 − 1 = 8. අමාල් දෙවරක් ගණන් වී ඇති නිසා 1ක් අඩු කරයි.',
        '4 + 5 − 1 = 8, because Amal is counted twice.',
        '4 + 5 − 1 = 8, because Amal is counted twice.'),
    QuizQuestion(
        'reasoning',
        'සියලු රෝස මල් මල් වේ. එසේ නම් නිසැකවම සත්‍ය වන්නේ?',
        'All roses are flowers. Which must be true?',
        'எல்லா ரோஜாக்களும் மலர்கள். கண்டிப்பாக உண்மையானது எது?',
        <String>[
          'සියලු මල් රෝස වේ',
          'කිසිදු රෝසක් මලක් නොවේ',
          'සෑම රෝසක්ම මලකි',
          'සියලු මල් රතුය'
        ],
        <String>[
          'All flowers are roses',
          'No rose is a flower',
          'Every rose is a flower',
          'All flowers are red'
        ],
        <String>[
          'எல்லா மலர்களும் ரோஜாக்கள்',
          'எந்த ரோஜாவும் மலரல்ல',
          'ஒவ்வொரு ரோஜாவும் ஒரு மலர்',
          'எல்லா மலர்களும் சிவப்பு'
        ],
        2,
        'දෙන ලද තොරතුර අනුව සෑම රෝසක්ම මලකි.',
        'The statement guarantees every rose is a flower.',
        'The statement guarantees every rose is a flower.'),
    QuizQuestion(
        'reasoning',
        'පෙට්ටි 3ක සමානව බෝල 21ක් තිබේ. එක් පෙට්ටියක බෝල ගණන?',
        '21 balls are shared equally in 3 boxes. How many per box?',
        '21 பந்துகள் 3 பெட்டிகளில் சமமாக இருந்தால் ஒவ்வொன்றிலும் எத்தனை?',
        <String>['5', '6', '7', '8'],
        <String>['5', '6', '7', '8'],
        <String>['5', '6', '7', '8'],
        2,
        '21 ÷ 3 = 7.',
        '21 ÷ 3 = 7.',
        '21 ÷ 3 = 7.'),
    QuizQuestion(
        'reasoning',
        'A, C, E, G, ... ඊළඟ ඉංග්‍රීසි අකුර කුමක්ද?',
        'Next letter: A, C, E, G, ...?',
        'A, C, E, G, ... அடுத்த எழுத்து?',
        <String>['H', 'J', 'I', 'K'],
        <String>['H', 'J', 'I', 'K'],
        <String>['H', 'J', 'I', 'K'],
        2,
        'එක් අකුරක් මඟහැර යයි: A, C, E, G, I.',
        'Skip one letter each time: I.',
        'Skip one letter each time: I.'),
  ];

  final Random _random = Random();
  final Set<int> _weakQuestions = <int>{};
  final Map<int, int> _answers = <int, int>{};
  List<int> _order = <int>[];
  String _topic = 'all';
  String _mode = 'practice';
  bool _started = false;
  bool _finished = false;
  bool _checked = false;
  int _position = 0;
  int _secondsLeft = 0;
  int _durationSeconds = 0;
  Timer? _timer;

  bool get _si =>
      widget.language == 'සිංහල' || widget.language.toLowerCase() == 'sinhala';
  bool get _ta =>
      widget.language == 'தமிழ்' || widget.language.toLowerCase() == 'tamil';
  String _t(String si, String en, String ta) => _si ? si : (_ta ? ta : en);
  String _questionText(QuizQuestion q) => _t(q.si, q.en, q.ta);
  String _explanation(QuizQuestion q) => _t(q.whySi, q.whyEn, q.whyTa);
  List<String> _options(QuizQuestion q) =>
      _si ? q.optionsSi : (_ta ? q.optionsTa : q.optionsEn);

  String _topicName(String topic) {
    switch (topic) {
      case 'patterns':
        return _t('සංඛ්‍යා රටා', 'Number patterns', 'எண் வடிவங்கள்');
      case 'arithmetic':
        return _t('ගණනය', 'Arithmetic', 'கணக்கீடு');
      case 'fractions':
        return _t('භාග', 'Fractions', 'பின்னங்கள்');
      case 'time':
        return _t('කාලය', 'Time', 'நேரம்');
      case 'measurement':
        return _t('මිනුම්', 'Measurement', 'அளவீடு');
      case 'environment':
        return _t('පරිසරය', 'Environment', 'சுற்றுச்சூழல்');
      case 'language':
        return _t('භාෂා හැකියාව', 'Language skills', 'மொழித் திறன்');
      case 'reasoning':
        return _t('තර්කන හැකියාව', 'Reasoning', 'தர்க்கத் திறன்');
      default:
        return _t('සියලු මාතෘකා', 'All topics', 'அனைத்து தலைப்புகள்');
    }
  }

  void _begin(String mode) {
    _timer?.cancel();
    final pool = List<int>.generate(_bank.length, (i) => i);
    if (mode == 'weak') {
      pool.removeWhere((i) => !_weakQuestions.contains(i));
    } else if (mode == 'practice' && _topic != 'all') {
      pool.removeWhere((i) => _bank[i].topic != _topic);
    }
    pool.shuffle(_random);
    final limit = mode == 'mock60' || mode == 'mock75'
        ? pool.length
        : min(10, pool.length);
    if (pool.isEmpty) return;
    setState(() {
      _mode = mode;
      _order = pool.take(limit).toList();
      _answers.clear();
      _position = 0;
      _checked = false;
      _started = true;
      _finished = false;
      _durationSeconds = mode == 'mock60'
          ? 60 * 60
          : mode == 'mock75'
          ? 75 * 60
          : 0;
      _secondsLeft = _durationSeconds;
    });
    if (_durationSeconds > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (_secondsLeft <= 1) {
          setState(() {
            _secondsLeft = 0;
            _finish();
          });
        } else {
          setState(() => _secondsLeft--);
        }
      });
    }
  }

  void _finish() {
    _timer?.cancel();
    _finished = true;
    for (final id in _order) {
      if (_answers[id] != _bank[id].correct) {
        _weakQuestions.add(id);
      } else {
        _weakQuestions.remove(id);
      }
    }
  }

  void _next() {
    setState(() {
      if (_mode == 'practice' || _mode == 'weak') {
        if (!_checked) {
          _checked = true;
          return;
        }
        _checked = false;
      }
      if (_position + 1 >= _order.length) {
        _finish();
      } else {
        _position++;
      }
    });
  }

  void _returnHome() {
    _timer?.cancel();
    setState(() {
      _started = false;
      _finished = false;
      _checked = false;
      _answers.clear();
      _order = <int>[];
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _panelBox(Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
        color: _panel, borderRadius: BorderRadius.circular(18)),
    child: child,
  );

  Widget _home() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _panelBox(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_t('ආරම්භ කරමු!', 'Let us begin!', 'தொடங்குவோம்!'),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
            _t(
                'විෂය කරුණු, තර්කනය සහ ගණනය පුහුණු වන්න. මෙය නිල ශිෂ්‍යත්ව පත්‍රයක් නොවේ.',
                'Practise knowledge, reasoning and calculations. These are not official examination papers.',
                'அறிவு, தர்க்கம், கணக்கீடு ஆகியவற்றைப் பயிற்சி செய்யுங்கள். இவை அதிகாரப்பூர்வ வினாத்தாள்கள் அல்ல.'),
            style: const TextStyle(color: Color(0xFFD0E1FF), height: 1.5)),
        const SizedBox(height: 10),
        Text(
            _t(
                'ප්‍රශ්න ගබඩාව: ${_bank.length} | දුර්වල ප්‍රශ්න: ${_weakQuestions.length}',
                'Question bank: ${_bank.length} | Review questions: ${_weakQuestions.length}',
                'வினாக்கள்: ${_bank.length} | மீள்பயிற்சி: ${_weakQuestions.length}'),
            style: const TextStyle(color: _cyan)),
      ])),
      const SizedBox(height: 18),
      Text(
          _t('මාතෘකාව තෝරන්න', 'Choose a topic', 'தலைப்பைத் தேர்ந்தெடுக்கவும்'),
          style: const TextStyle(color: Colors.white, fontSize: 17)),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: _topic,
        dropdownColor: _panel,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
            filled: true,
            fillColor: _panel,
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
        items: _topics
            .map((topic) => DropdownMenuItem<String>(
            value: topic, child: Text(_topicName(topic))))
            .toList(),
        onChanged: (v) => setState(() => _topic = v ?? 'all'),
      ),
      const SizedBox(height: 16),
      FilledButton.icon(
          onPressed: () => _begin('practice'),
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(_t(
              'පුහුණුව අරඹන්න (ප්‍රශ්න 10ක් දක්වා)',
              'Start practice (up to 10 questions)',
              'பயிற்சி தொடங்கு (10 வினாக்கள் வரை)'))),
      const SizedBox(height: 10),
      OutlinedButton.icon(
          onPressed: _weakQuestions.isEmpty ? null : () => _begin('weak'),
          icon: const Icon(Icons.replay_rounded),
          label: Text(_t(
              'වැරදුණු ප්‍රශ්න නැවත පුහුණු වන්න',
              'Practise missed questions',
              'தவறிய வினாக்களை மீண்டும் பயிற்சி செய்க'))),
      const SizedBox(height: 20),
      Text(
          _t('කාලසීමා ආදර්ශ පරීක්ෂණ', 'Timed mock tests',
              'நேர வரையறைப் பயிற்சித் தேர்வுகள்'),
          style: const TextStyle(
              color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text(
          _t(
              'මෙම ආදර්ශ පරීක්ෂණ දෙකම අපේ ප්‍රශ්න ගබඩාවේ ප්‍රශ්න 48ම භාවිත කරයි. නිල පත්‍ර I/II ආකෘතියක් ලෙස නොසලකන්න.',
              'Both mock tests use all 48 questions in this bank. They do not reproduce official Paper I or II formats.',
              'இரண்டு மாதிரித் தேர்வுகளும் இந்தத் தொகுப்பின் 48 வினாக்களையும் பயன்படுத்துகின்றன. இவை அதிகாரப்பூர்வ தாள் I/II வடிவங்கள் அல்ல.'),
          style: const TextStyle(color: Color(0xFFC9D9F5))),
      const SizedBox(height: 10),
      OutlinedButton.icon(
          onPressed: () => _begin('mock60'),
          icon: const Icon(Icons.timer_outlined),
          label: Text(_t('විනාඩි 60 ආදර්ශ පරීක්ෂණය', '60-minute mock test',
              '60 நிமிட மாதிரித் தேர்வு'))),
      const SizedBox(height: 8),
      OutlinedButton.icon(
          onPressed: () => _begin('mock75'),
          icon: const Icon(Icons.timer_outlined),
          label: Text(_t('විනාඩි 75 ආදර්ශ පරීක්ෂණය', '75-minute mock test',
              '75 நிமிட மாதிரித் தேர்வு'))),
      const SizedBox(height: 12),
      Text(
          _t(
              'ප්‍රගතිය මෙම තිරය විවෘතව තිබෙන තෙක් පමණක් තබාගනී. යෙදුම නැවත ආරම්භ කළොත් දුර්වල ප්‍රශ්න ලැයිස්තුව නැති වේ.',
              'Progress is stored in memory only and resets when the app restarts.',
              'முன்னேற்றம் தற்காலிகமாக மட்டுமே சேமிக்கப்படும்; செயலியை மீண்டும் தொடங்கினால் அழியும்.'),
          style: const TextStyle(color: Color(0xFF98B2DD), fontSize: 12)),
    ]);
  }

  Widget _questionView() {
    final id = _order[_position];
    final q = _bank[id];
    final selected = _answers[id];
    final practice = _mode == 'practice' || _mode == 'weak';
    final correct = selected == q.correct;
    final mm = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final ss = (_secondsLeft % 60).toString().padLeft(2, '0');
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(
            child: Text(
                '${_position + 1} / ${_order.length} · ${_topicName(q.topic)}',
                style: const TextStyle(
                    color: _cyan, fontWeight: FontWeight.bold))),
        if (_durationSeconds > 0)
          Text('$mm:$ss',
              style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 19,
                  fontWeight: FontWeight.bold)),
      ]),
      const SizedBox(height: 10),
      LinearProgressIndicator(
          value: (_position + 1) / _order.length,
          backgroundColor: _panel,
          color: _cyan),
      const SizedBox(height: 16),
      _panelBox(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_questionText(q),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.4)),
        const SizedBox(height: 16),
        ...List.generate(
            4,
                (i) => RadioListTile<int>(
              value: i,
              groupValue: selected,
              activeColor: _cyan,
              title: Text(_options(q)[i],
                  style:
                  const TextStyle(color: Colors.white, fontSize: 16)),
              onChanged: practice && _checked
                  ? null
                  : (v) => setState(() => _answers[id] = v!),
            )),
      ])),
      if (practice && _checked) ...[
        const SizedBox(height: 14),
        Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color:
                correct ? const Color(0xFF164A3B) : const Color(0xFF49321E),
                borderRadius: BorderRadius.circular(14)),
            child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                  correct
                      ? _t('නිවැරදියි! හොඳයි ✓', 'Correct! Well done ✓',
                      'சரி! மிக நன்று ✓')
                      : _t('තවත් ඉගෙන ගනිමු', 'Let us learn more',
                      'மேலும் கற்போம்'),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              const SizedBox(height: 8),
              Text(
                  '${_t('නිවැරදි පිළිතුර', 'Correct answer', 'சரியான விடை')}: ${_options(q)[q.correct]}',
                  style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              Text(_explanation(q),
                  style: const TextStyle(
                      color: Colors.white, fontSize: 15, height: 1.5)),
            ])),
      ],
      const SizedBox(height: 18),
      FilledButton(
          onPressed: practice && selected == null ? null : _next,
          child: Text(practice && !_checked
              ? _t('පිළිතුර පරීක්ෂා කරන්න', 'Check answer',
              'விடையைச் சரிபார்க்கவும்')
              : _position + 1 == _order.length
              ? _t('ප්‍රතිඵල බලන්න', 'See results',
              'முடிவுகளைப் பார்க்கவும்')
              : _t('ඊළඟ ප්‍රශ්නය', 'Next question', 'அடுத்த வினா'))),
      const SizedBox(height: 8),
      TextButton(
          onPressed: _returnHome,
          child: Text(_t('පුහුණුවෙන් ඉවත් වන්න', 'Exit practice',
              'பயிற்சியிலிருந்து வெளியேறு'))),
    ]);
  }

  Widget _results() {
    final score =
        _order.where((id) => _answers[id] == _bank[id].correct).length;
    final total = _order.length;
    final percent = total == 0 ? 0 : (100 * score / total).round();
    final weakTopics = <String, int>{};
    for (final id in _order) {
      if (_answers[id] != _bank[id].correct) {
        weakTopics.update(_bank[id].topic, (v) => v + 1, ifAbsent: () => 1);
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _panelBox(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_t('ඔබගේ ප්‍රතිඵලය', 'Your result', 'உங்கள் முடிவு'),
            style: const TextStyle(color: Colors.white, fontSize: 22)),
        const SizedBox(height: 8),
        Text('$score / $total  ($percent%)',
            style: const TextStyle(
                color: _cyan, fontSize: 34, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
            weakTopics.isEmpty
                ? _t(
                'හොඳයි! මෙම වාරයේ සියල්ල නිවැරදියි.',
                'Great! All answers are correct this round.',
                'நன்று! இந்தச் சுற்றில் எல்லா விடைகளும் சரி.')
                : '${_t('නැවත පුහුණු කළ යුතු මාතෘකා', 'Topics to review', 'மீள்பயிற்சித் தலைப்புகள்')}: '
                '${weakTopics.entries.map((e) => '${_topicName(e.key)} (${e.value})').join(', ')}',
            style: const TextStyle(color: Colors.white, height: 1.5)),
      ])),
      const SizedBox(height: 14),
      Text(
          _t('පිළිතුරු සහ පැහැදිලි කිරීම්', 'Answers and explanations',
              'விடைகளும் விளக்கங்களும்'),
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      ...List.generate(_order.length, (index) {
        final id = _order[index];
        final q = _bank[id];
        final selected = _answers[id];
        final ok = selected == q.correct;
        return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _panelBox(
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${index + 1}. ${_questionText(q)}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                      ok
                          ? _t('නිවැරදියි ✓', 'Correct ✓', 'சரி ✓')
                          : _t('නැවත බලමු', 'Review', 'மீண்டும் பார்க்கவும்'),
                      style: TextStyle(
                          color: ok ? Colors.greenAccent : Colors.orangeAccent)),
                  if (selected != null)
                    Text(
                        '${_t('ඔබේ පිළිතුර', 'Your answer', 'உங்கள் விடை')}: ${_options(q)[selected]}',
                        style: const TextStyle(color: Color(0xFFC9D9F5))),
                  Text(
                      '${_t('නිවැරදි පිළිතුර', 'Correct answer', 'சரியான விடை')}: ${_options(q)[q.correct]}',
                      style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 5),
                  Text(_explanation(q),
                      style:
                      const TextStyle(color: Color(0xFFC9D9F5), height: 1.5)),
                ])));
      }),
      const SizedBox(height: 10),
      FilledButton.icon(
          onPressed: _returnHome,
          icon: const Icon(Icons.home_outlined),
          label: Text(
              _t('ප්‍රධාන මෙනුවට', 'Back to menu', 'முதன்மைப் பட்டியலுக்கு'))),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        title: Text(_t('5 ශ්‍රේණිය ශිෂ්‍යත්ව පුහුණුව',
            'Grade 5 Scholarship Practice', 'தரம் 5 புலமைப்பரிசில் பயிற்சி')),
      ),
      body: SafeArea(
          child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView(padding: const EdgeInsets.all(16), children: [
                  Container(
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            Color(0xFF7B24FF),
                            Color(0xFF1769FF),
                            Color(0xFF16D9FF)
                          ]),
                          borderRadius: BorderRadius.circular(18)),
                      child: const Row(children: [
                        Icon(Icons.school_rounded, color: Colors.white, size: 32),
                        SizedBox(width: 12),
                        Expanded(
                            child: Text('Zingacc Learn AI',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold))),
                      ])),
                  const SizedBox(height: 18),
                  !_started
                      ? _home()
                      : _finished
                      ? _results()
                      : _questionView(),
                ]),
              ))),
    );
  }
}

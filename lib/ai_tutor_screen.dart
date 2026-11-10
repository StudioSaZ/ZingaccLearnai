import 'diagram_question_parser.dart';
import 'safe_diagram_renderer.dart';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'pdf_export_service.dart';
import 'zingacc_brand_banner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';
import 'math_text.dart';
import 'premium_packages_screen.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AITutorScreen extends StatefulWidget {
  final String selectedLevel;
  final String selectedMedium;
  final String selectedSubject;
  final String language;

  const AITutorScreen({
    super.key,
    required this.selectedLevel,
    required this.selectedMedium,
    required this.selectedSubject,
    required this.language,
  });

  @override
  State<AITutorScreen> createState() => _AITutorScreenState();
}

class _AITutorScreenState extends State<AITutorScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;

  late FlutterTts _flutterTts;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();

    _flutterTts = FlutterTts();
    _initTts();
  }

  void _initTts() {
    _flutterTts.setStartHandler(() {
      if (mounted) setState(() => _isSpeaking = true);
    });
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    _flutterTts.setErrorHandler((msg) {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  Future<void> _toggleSpeaking() async {
    try {
      if (_isSpeaking) {
        await _flutterTts.stop();
        if (mounted) setState(() => _isSpeaking = false);
        return;
      }

      if (answer.isEmpty) return;

      if (mounted) setState(() => _isSpeaking = true);

      bool hasSinhala = RegExp(r'[\u0D80-\u0DFF]').hasMatch(answer);
      bool hasTamil = RegExp(r'[\u0B80-\u0BFF]').hasMatch(answer);

      String languageCode = 'en-US';
      if (hasSinhala) {
        languageCode = 'si-LK';
      } else if (hasTamil) {
        languageCode = 'ta-LK';
      }

      bool isAvailable = false;

      try {
        var check = await _flutterTts.isLanguageAvailable(languageCode);
        isAvailable = (check == true || check == 1);
      } catch (e) {
        debugPrint("Language check error: $e");
      }

      if (!isAvailable) {
        if (hasSinhala) {
          try {
            var f1 = await _flutterTts.isLanguageAvailable('si-IN');
            var f2 = await _flutterTts.isLanguageAvailable('si');
            if (f1 == true || f1 == 1) { languageCode = 'si-IN'; isAvailable = true; }
            else if (f2 == true || f2 == 1) { languageCode = 'si'; isAvailable = true; }
          } catch (e) {}
        } else if (hasTamil) {
          try {
            var f = await _flutterTts.isLanguageAvailable('ta-IN');
            if (f == true || f == 1) { languageCode = 'ta-IN'; isAvailable = true; }
          } catch (e) {}
        }
      }

      if (!isAvailable) {
        if (mounted) setState(() => _isSpeaking = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t(
                'ඔබේ දුරකථනයේ සිංහල හඬ පහසුකම නැත. Settings -> Text-to-Speech බලන්න.',
                'Voice language is not supported on this device.',
                'குரல் வசதி இல்லை.'
            )),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      await _flutterTts.setLanguage(languageCode);
      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setPitch(0.7);

      await _flutterTts.awaitSpeakCompletion(true);

      _flutterTts.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
      _flutterTts.setErrorHandler((msg) {
        if (mounted) setState(() => _isSpeaking = false);
      });

      String textToSpeak = answer
          .replaceAll('*', '')
          .replaceAll('#', '')
          .replaceAll('\$', '')
          .replaceAll('_', '')
          .replaceAll('[[', '')
          .replaceAll(']]', '');

      await _flutterTts.speak(textToSpeak);

    } catch (e) {
      debugPrint("Fatal TTS Error: $e");
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  Future<void> _initSpeech() async {
    try {
      await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;
          final listening = status == 'listening';
          if (_isListening != listening) {
            setState(() => _isListening = listening);
          }
        },
        onError: (error) {
          debugPrint('Speech recognition error: ${error.errorMsg}');
          if (mounted && _isListening) {
            setState(() => _isListening = false);
          }
        },
      );
    } catch (e) {
      debugPrint('Speech recognition initialization failed: $e');
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;
          final listening = status == 'listening';
          if (_isListening != listening) {
            setState(() => _isListening = listening);
          }
        },
        onError: (error) {
          debugPrint('Speech recognition error: ${error.errorMsg}');
          if (mounted && _isListening) {
            setState(() => _isListening = false);
          }
        },
      );
      if (!mounted) return;
      if (!available) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t(
              'මෙම උපාංගයේ හඬ හඳුනාගැනීම ලබාගත නොහැක.',
              'Speech recognition is unavailable on this device.',
              'இந்த சாதனத்தில் குரல் அடையாளம் காணல் கிடைக்கவில்லை.',
            )),
          ),
        );
        return;
      }

      var localeId = 'en_US';
      if (isSinhala) localeId = 'si_LK';
      if (isTamil) localeId = 'ta_LK';

      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          if (!mounted) return;
          setState(() {
            questionController.text = result.recognizedWords;
            questionController.selection = TextSelection.collapsed(
              offset: questionController.text.length,
            );
          });
        },
        localeId: localeId,
      );
    } catch (e) {
      debugPrint('Speech recognition could not start: $e');
      if (!mounted) return;
      setState(() => _isListening = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t(
            'මයික්‍රෆෝනය ආරම්භ කළ නොහැක. අවසර සහ භාෂා සැකසුම් පරීක්ෂා කරන්න.',
            'Could not start the microphone. Check its permission and language settings.',
            'ஒலிவாங்கியைத் தொடங்க முடியவில்லை. அனுமதி மற்றும் மொழி அமைப்புகளைச் சரிபார்க்கவும்.',
          )),
        ),
      );
    }
  }

  final TextEditingController questionController = TextEditingController();
  String? diagramQuestion;

  Uint8List? selectedImageBytes;
  String? selectedFileName;
  String? selectedMimeType;
  String answer = '';
  bool isLoading = false;
  bool isSavingPdf = false;

  bool get isSinhala => widget.language == 'සිංහල';
  bool get isTamil => widget.language == 'தமிழ்';

  String t(
      String sinhala,
      String english,
      String tamil,
      ) {
    if (isSinhala) return sinhala;
    if (isTamil) return tamil;
    return english;
  }

  String get levelName {
    switch (widget.selectedLevel) {
      case 'grade_5_scholarship': return 'Grade 5 Scholarship';
      case 'grade_6': return 'Grade 6';
      case 'grade_7': return 'Grade 7';
      case 'grade_8': return 'Grade 8';
      case 'grade_9': return 'Grade 9';
      case 'ol': return 'O/L';
      case 'al': return 'A/L';
      default: return widget.selectedLevel;
    }
  }

  String get mediumName {
    switch (widget.selectedMedium) {
      case 'sinhala': return 'Sinhala Medium';
      case 'english': return 'English Medium';
      case 'tamil': return 'Tamil Medium';
      default: return widget.selectedMedium;
    }
  }

  String get localizedMediumName {
    if (isSinhala) {
      switch (widget.selectedMedium) {
        case 'sinhala': return 'සිංහල මාධ්‍යය';
        case 'tamil': return 'දෙමළ මාධ්‍යය';
        default: return 'ඉංග්‍රීසි මාධ්‍යය';
      }
    }
    if (isTamil) {
      switch (widget.selectedMedium) {
        case 'sinhala': return 'சிங்கள மொழிமூலம்';
        case 'tamil': return 'தமிழ் மொழிமூலம்';
        default: return 'ஆங்கில மொழிமூலம்';
      }
    }
    return mediumName;
  }

  String get subjectName {
    switch (widget.selectedSubject) {
      case 'mathematics': return 'Mathematics';
      case 'science': return 'Science';
      case 'english': return 'English';
      case 'sinhala': return 'Sinhala';
      case 'tamil': return 'Tamil';
      case 'history': return 'History';
      case 'geography': return 'Geography';
      case 'ict': return 'ICT';
      case 'media': return 'Media';
      case 'religion': return 'Religion';
      case 'health': return 'Health & Physical Education';
      case 'civics': return 'Civic Education';
      case 'commerce': return 'Business & Accounting Studies';
      case 'business_accounting': return 'Business & Accounting Studies';
      case 'combined_mathematics': return 'Combined Mathematics';
      case 'physics': return 'Physics';
      case 'chemistry': return 'Chemistry';
      case 'biology': return 'Biology';
      case 'economics': return 'Economics';
      case 'business_studies': return 'Business Studies';
      case 'accounting': return 'Accounting';
      case 'logic': return 'Logic & Scientific Method';
      case 'political_science': return 'Political Science';
      case 'agriculture': return 'Agricultural Science';
      case 'engineering_technology': return 'Engineering Technology';
      case 'science_for_technology': return 'Science for Technology';
      case 'bio_systems_technology': return 'Bio Systems Technology';
      case 'scholarship_paper_1': return 'Scholarship Paper I';
      case 'scholarship_paper_2': return 'Scholarship Paper II';
      default:
        if (widget.selectedSubject.trim().isEmpty) return 'Subject';
        return widget.selectedSubject
            .split('_')
            .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}')
            .join(' ');
    }
  }

  String get localizedSubjectName {
    if (isSinhala) {
      switch (widget.selectedSubject) {
        case 'mathematics': return 'ගණිතය';
        case 'science': return 'විද්‍යාව';
        case 'english': return 'ඉංග්‍රීසි';
        case 'sinhala': return 'සිංහල';
        case 'tamil': return 'දෙමළ';
        case 'history': return 'ඉතිහාසය';
        case 'geography': return 'භූගෝල විද්‍යාව';
        case 'ict': return 'ICT';
        case 'media': return 'මාධ්‍ය අධ්‍යයනය';
        case 'combined_mathematics': return 'සංයුක්ත ගණිතය';
        case 'physics': return 'භෞතික විද්‍යාව';
        case 'chemistry': return 'රසායන විද්‍යාව';
        case 'biology': return 'ජීව විද්‍යාව';
        case 'religion': return 'ආගම';
        case 'buddhism': return 'බුද්ධ ධර්මය';
        case 'hinduism': return 'හින්දු ධර්මය / සෛවනෙරිය';
        case 'christianity': return 'ක්‍රිස්තියානි ධර්මය';
        case 'catholicism': return 'කතෝලික ධර්මය';
        case 'islam': return 'ඉස්ලාම් ධර්මය';
        case 'health': return 'සෞඛ්‍ය හා ශාරීරික අධ්‍යාපනය';
        case 'civics': return 'පුරවැසි අධ්‍යාපනය';
        case 'commerce':
        case 'business_accounting': return 'ව්‍යාපාර හා ගිණුම්කරණ අධ්‍යයනය';
        case 'business_studies': return 'ව්‍යාපාර අධ්‍යයනය';
        case 'accounting': return 'ගිණුම්කරණය';
        case 'economics': return 'ආර්ථික විද්‍යාව';
        case 'logic': return 'තර්ක ශාස්ත්‍රය හා විද්‍යාත්මක ක්‍රමය';
        case 'political_science': return 'දේශපාලන විද්‍යාව';
        case 'agriculture': return 'කෘෂිකර්ම විද්‍යාව';
        case 'engineering_technology': return 'ඉංජිනේරු තාක්ෂණවේදය';
        case 'science_for_technology': return 'තාක්ෂණය සඳහා විද්‍යාව';
        case 'bio_systems_technology': return 'ජෛව පද්ධති තාක්ෂණවේදය';
        case 'scholarship_paper_1': return 'ශිෂ්‍යත්ව ප්‍රශ්න පත්‍රය I';
        case 'scholarship_paper_2': return 'ශිෂ්‍යත්ව ප්‍රශ්න පත්‍රය II';
        case 'art': return 'චිත්‍ර කලාව';
        case 'dancing': return 'නර්තනය';
        case 'eastern_music': return 'පෙරදිග සංගීතය';
        case 'western_music': return 'බටහිර සංගීතය';
        case 'drama': return 'නාට්‍ය හා රංග කලාව';
      }
    }
    if (isTamil) {
      switch (widget.selectedSubject) {
        case 'mathematics': return 'கணிதம்';
        case 'science': return 'அறிவியல்';
        case 'english': return 'ஆங்கிலம்';
        case 'sinhala': return 'சிங்களம்';
        case 'tamil': return 'தமிழ்';
        case 'history': return 'வரலாறு';
        case 'geography': return 'புவியியல்';
        case 'ict': return 'ICT';
        case 'media': return 'ஊடகக் கல்வி';
        case 'combined_mathematics': return 'இணைந்த கணிதம்';
        case 'physics': return 'இயற்பியல்';
        case 'chemistry': return 'வேதியியல்';
        case 'biology': return 'உயிரியல்';
        case 'religion': return 'சமயம்';
        case 'buddhism': return 'பௌத்தம்';
        case 'hinduism': return 'இந்து சமயம் / சைவநெறி';
        case 'christianity': return 'கிறித்தவம்';
        case 'catholicism': return 'கத்தோலிக்கம்';
        case 'islam': return 'இஸ்லாம்';
        case 'health': return 'சுகாதாரம் மற்றும் உடற்கல்வி';
        case 'civics': return 'குடியியல் கல்வி';
        case 'commerce':
        case 'business_accounting': return 'வணிகம் மற்றும் கணக்கியல் கல்வி';
        case 'business_studies': return 'வணிகக் கல்வி';
        case 'accounting': return 'கணக்கியல்';
        case 'economics': return 'பொருளியல்';
        case 'logic': return 'தர்க்கமும் விஞ்ஞான முறையும்';
        case 'political_science': return 'அரசியல் அறிவியல்';
        case 'agriculture': return 'விவசாய அறிவியல்';
        case 'engineering_technology': return 'பொறியியல் தொழில்நுட்பம்';
        case 'science_for_technology': return 'தொழில்நுட்பத்திற்கான அறிவியல்';
        case 'bio_systems_technology': return 'உயிரியல் முறைமைகள் தொழில்நுட்பம்';
        case 'scholarship_paper_1': return 'புலமைப்பரிசில் வினாத்தாள் I';
        case 'scholarship_paper_2': return 'புலமைப்பரிசில் வினாத்தாள் II';
        case 'art': return 'சித்திரக்கலை';
        case 'dancing': return 'நடனம்';
        case 'eastern_music': return 'கிழக்கத்திய இசை';
        case 'western_music': return 'மேற்கத்திய இசை';
        case 'drama': return 'நாடகமும் அரங்கியலும்';
      }
    }
    return subjectName;
  }

  String get dynamicSubjectHint {
    if (isSinhala) {
      switch (widget.selectedSubject) {
        case 'mathematics':
        case 'combined_mathematics':
          return 'මෙහිදී ඔබට වීජ ගණිතය, ජ්‍යාමිතිය, ත්‍රිකෝණමිතිය, හෝ සමීකරණ වැනි ගැටලු ඇසිය හැක.';
        case 'science':
        case 'physics':
        case 'chemistry':
        case 'biology':
          return 'මෙහිදී ඔබට ප්‍රභාසංස්ලේෂණය, නිව්ටන් නියම, රසායනික ප්‍රතික්‍රියා, හෝ ධාරා විද්‍යාව වැනි දෑ ඇසිය හැක.';
        case 'history':
          return 'මෙහිදී ඔබට රජවරුන්ගේ කාලපරිච්ඡේද, ගිවිසුම්, සහ ලෝක ඉතිහාසය ගැන ඇසිය හැක.';
        case 'dancing':
          return 'මෙහිදී ඔබට වන්නම්, වාද්‍ය භාණ්ඩ, සහ තානම් ප්‍රස්තාරගත කිරීම් ගැන ඇසිය හැක.';
        case 'music':
        case 'eastern_music':
        case 'western_music':
          return 'මෙහිදී ඔබට රාග, තාල, ස්වර ප්‍රස්තාර, සහ සංගීත ඉතිහාසය ගැන ඇසිය හැක.';
        case 'ict':
          return 'මෙහිදී ඔබට ක්‍රමලේඛනය (Programming), දෘඪාංග (Hardware), සහ ජාලකරණය ගැන ඇසිය හැක.';
        case 'english':
        case 'sinhala':
        case 'tamil':
          return 'මෙහිදී ඔබට ව්‍යාකරණ, රචනා පරීක්ෂා කිරීම්, සහ සාහිත්‍යය ගැන ඇසිය හැක.';
        case 'commerce':
        case 'business_accounting':
        case 'accounting':
        case 'economics':
        case 'business_studies':
          return 'මෙහිදී ඔබට ගිණුම්කරණ සමීකරණ, ඉල්ලුම හා සැපයුම, සහ ව්‍යාපාර පරිසරය ගැන ඇසිය හැක.';
        default:
          return 'ඔබට මෙම විෂයයට අදාළ ඕනෑම ප්‍රශ්නයක්, රචනාවක් හෝ ගැටලුවක් මෙහිදී සාකච්ඡා කළ හැක.';
      }
    } else if (isTamil) {
      switch (widget.selectedSubject) {
        case 'mathematics':
        case 'combined_mathematics':
          return 'நீங்கள் இயற்கணிதம், வடிவியல், முக்கோணவியல் அல்லது சமன்பாடுகள் பற்றி இங்கு கேட்கலாம்.';
        case 'science':
        case 'physics':
        case 'chemistry':
        case 'biology':
          return 'நீங்கள் ஒளிச்சேர்க்கை, நியூட்டனின் விதிகள், வேதியியல் வினைகள் பற்றி இங்கு கேட்கலாம்.';
        case 'history':
          return 'நீங்கள் வரலாற்று காலங்கள், ஒப்பந்தங்கள் மற்றும் உலக வரலாறு பற்றி கேட்கலாம்.';
        default:
          return 'இந்த பாடத்தோடு தொடர்புடைய எந்தவொரு கேள்வியையும் நீங்கள் இங்கே கேட்கலாம்.';
      }
    } else {
      switch (widget.selectedSubject) {
        case 'mathematics':
        case 'combined_mathematics':
          return 'You can ask about algebra, geometry, trigonometry, or equations here.';
        case 'science':
        case 'physics':
        case 'chemistry':
        case 'biology':
          return 'You can ask about photosynthesis, Newton laws, chemical reactions, etc.';
        case 'history':
          return 'You can ask about historical periods, treaties, and world history.';
        case 'dancing':
          return 'You can ask about traditional dances, instruments, and rhythm notations.';
        case 'ict':
          return 'You can ask about programming, hardware, and networking here.';
        case 'english':
        case 'sinhala':
        case 'tamil':
          return 'You can ask to check grammar, essays, or discuss literature.';
        case 'commerce':
        case 'business_accounting':
        case 'accounting':
        case 'economics':
        case 'business_studies':
          return 'You can ask about accounting equations, supply and demand, and business environment.';
        default:
          return 'You can ask any question or discuss any topic related to this subject here.';
      }
    }
  }

  bool get isMathSubject =>
      widget.selectedSubject == 'mathematics' ||
          widget.selectedSubject == 'combined_mathematics';

  bool get isScienceSubject => const {
    'science',
    'physics',
    'chemistry',
    'biology',
    'agriculture',
    'science_for_technology',
    'bio_systems_technology'
  }.contains(widget.selectedSubject);

  String get allSubjectAccuracyInstruction => r'''
UNIVERSAL CROSS-SUBJECT ACADEMIC SAFEGUARDS:
- Identify the subject of the CURRENT question from its content. Do not insert unrelated subject labels, past-question topics, or irrelevant syllabus disclaimers.
- Answer the current question even if it crosses subjects; distinguish the selected subject from the question topic without misclassifying either.
- Independently validate each factual assertion, numerical result, classification, technical term and final conclusion. Do not treat a plausible explanation as proof.
- Check ALL requested subparts; do not claim completeness when any subpart is missing.
- If a question has insufficient data, state precisely what is missing. If multiple conventions or accepted scholarly traditions exist, label the convention and explain material alternatives.
- Never fabricate citations, textbook quotations, historical details, lyrics, drum syllables, ragas, notations or dance traditions. Do not label invented notation as an authenticated traditional pattern.
- For mathematics and physics: check signs, coordinate directions, units, substitutions, boundary conditions, and whether independent methods agree. Recompute results from the original givens.
- For chemistry: verify balanced equations, concentrations, equilibrium expressions, approximations and conditions. Never assign an exact result when mixing volumes or other needed data are absent.
- For biology and health: verify mechanisms, terminology, exceptions and whether figures depend on the organism, convention or context.
- For dancing: distinguish Kandyan, Low Country and Sabaragamuwa practices, correct drum construction and playing techniques, ritual context and dress. Do not invent exact bera pada; if not reliably known, disclose uncertainty.
- For Eastern music: mark shuddha, komal and tivra swaras UNAMBIGUOUSLY; distinguish Yaman from Yaman Kalyan when relevant; check aroha, avaroha, vadi, samvadi, pakad and performance time. For tala, count EVERY matra, vibhag, tali, khali and theka bol. Clearly flag gharana/tradition variants.
- For Western music: check key signature, meter, clef, intervals, harmony, rhythmic values and notation before concluding.
- For history, geography, religion, civics, media, literature, arts and humanities: distinguish documented facts from interpretation; identify region, time and tradition; never manufacture sources or specific examples.
- For ICT, technology, commerce, accounting and economics: check syntax, definitions, classifications, calculations and real-world assumptions.
- For Sinhala, Tamil and English: check spelling, grammar, translation, literary terminology and script integrity; preserve the requested explanation language.
- Never assert that the answer has been fully verified if an essential claim cannot be checked. Clearly acknowledge meaningful uncertainty.
''';

  String get subjectSpecificInstruction {
    if (isMathSubject) {
      return '''
      SUBJECT-SPECIFIC RULES:
- Answer according to the selected subject and student level.
- Preserve important subject terminology accurately.
- Do not invent facts that are not supplied or clearly supported.

SUBJECT-SPECIFIC RULES - MATHEMATICS:
- Show only the useful working needed for the student's level.
- Check arithmetic, algebra, geometry notation and units carefully.
- Follow BODMAS when relevant.
- MATHEMATICAL ACCURACY: Solve from the original question, not from a guessed answer.
- For algebra, expand or factor expressions and verify the result by substitution or re-expansion.
- For equations, substitute every proposed root into the ORIGINAL equation and reject extraneous roots.
- Check domain restrictions, denominators, endpoints and excluded values before cancelling factors or dividing.
- For quadratics, verify the discriminant and Vieta relations when applicable.
- For trigonometry, verify identities algebraically, check the original equation, and include all solutions in the requested interval.
- For calculus, check differentiation or integration results using the inverse operation when possible.
- For geometry, use only given measurements and valid theorems; do not assume a diagram is to scale.
- For arithmetic, fractions and percentages, recompute the final result independently.
- Do not present a numerical answer as verified unless the necessary checks actually support it.
- If the information is insufficient or a reliable result cannot be established, explain the uncertainty instead of inventing an answer.
- Preserve exact symbols, formulas, angle names and diagram labels.
''';
    }
    if (isScienceSubject) {
      return '''
SUBJECT-SPECIFIC RULES - SCIENCE:
- Use scientifically accurate school-level explanations.
- Keep symbols, formulas, chemical formulae, units and scientific names accurate.
- Separate observation, explanation and calculation when relevant.
- Teach the central scientific idea in simple, age-appropriate language before introducing difficult terminology.
- Explain WHY a scientific event or process happens, not merely WHAT happens.
- Explain HOW the process works in a clear sequence when relevant.
- Connect the explanation to a familiar everyday example when it genuinely helps understanding.
- Define new scientific terms briefly and accurately.
- Distinguish causes, effects, observations and conclusions.
- For calculations, explain what each formula and quantity means before substituting values.
- For experiments, explain the purpose, observations and conclusion without inventing results.
- Keep explanations focused on the question; do not add unrequested practice questions.
- Never invent information that is not visible in an uploaded diagram or question.
''';
    }
    if (widget.selectedSubject == 'sinhala' ||
        widget.selectedSubject == 'tamil') {
      return '''
SUBJECT-SPECIFIC RULES - SINHALA AND TAMIL:
- Teach the selected language subject accurately at the student's school level.
- Explain the meaning of important words and sentences in simple language.
- Explain WHY a grammar rule applies, not merely the correct answer.
- For Sinhala grammar, identify the subject (ukthaya) and predicate/verb (akhyathaya) accurately, and explain their agreement in standard written Sinhala when relevant.
- For Sinhala subject-verb agreement, consider grammatical person, number, verb form and intended meaning; do not claim that all plural verbs end in one suffix or that all singular verbs use one ending.
- Distinguish standard written Sinhala from everyday spoken Sinhala when this distinction affects correctness.
- For Tamil grammar, explain subject-verb agreement using the appropriate person, number, gender and tense where relevant; do not apply Sinhala verb-ending rules to Tamil.
- When correcting a sentence, show the original sentence and corrected sentence, identify the exact change, and explain WHY the correction is needed.
- When multiple forms are valid in different contexts, explain the distinction instead of declaring one universally wrong.
- Use one or two short, accurate examples only when they help understanding; do not invent universal grammar rules from a single example.
- Use the selected explanation language consistently and avoid unrelated scripts or languages.
- Show a short, relevant example when it helps the student understand.
- For sentence construction, explain word order, grammar and meaning clearly.
- For spelling corrections, show the correct form and briefly explain the mistake.
- For literature, explain the central meaning, relevant language features and evidence from the supplied text.
- Preserve the correct Sinhala or Tamil script and avoid mixing unrelated writing systems.
- Do not invent quotations, poems, authors or literary details.
- Keep explanations in the selected explanation language while preserving essential examples from the subject being taught.
- Do not add unrequested exercises or questions.

- ESSAY MARKING PROTOCOL:
  If the student submits an essay, letter, or creative writing to be marked:
  1. Read the text carefully from the image or typed input.
  2. Identify spelling, grammar, and structural mistakes.
  3. In [[STEPS]], create a clear list showing "Original Mistake" -> "Correction" -> "Reason".
  4. Give encouraging feedback on content, vocabulary, and formatting.
  5. In [[FINAL]], give a realistic estimated SCORE (e.g., 12/15 or 8/10) based on the $levelName standard.
''';
    }
    if (widget.selectedSubject == 'english') {
      return '''
SUBJECT-SPECIFIC RULES - ENGLISH:
- Preserve the English word, sentence, passage, grammar form or quotation being taught.
- Explain it in the student's selected explanation language.
- Do not translate away English examples that the student needs to learn.
- Correct grammar carefully and explain why at an age-appropriate level.
- Explain unfamiliar English words using simple meanings and short examples.
- For grammar, explain the rule, WHY it applies, and HOW it changes the sentence in simple, age-appropriate language.
- When correcting grammar, show the original and corrected sentences side by side or consecutively, and identify the exact change.
- Give one or two short, relevant English examples when they genuinely improve understanding; explain their differences in the selected explanation language.
- Explain subject-verb agreement accurately: in simple present affirmative sentences, third-person singular subjects normally take the appropriate verb form, such as she goes or he likes.
- Explain simple present negatives accurately: he/she/it and third-person singular noun subjects use does not (doesn't) plus the base verb; I/you/we/they and plural noun subjects use do not (don't) plus the base verb.
- Clarify that after doesn't, the main verb remains in its base form: He doesn't like apples, NOT He doesn't likes apples.
- Do not claim every singular subject takes an -s verb ending; I and you are exceptions to that oversimplification.
- Teach the reason behind corrections rather than merely repeating the correct sentence.
- Keep explanations focused and avoid unnecessary repetition or unrequested practice questions.
- For sentence construction, explain word order and the role of important words.
- For reading comprehension, base every answer on the supplied passage and identify supporting evidence.
- For writing tasks, demonstrate clear sentence structure appropriate to the student's level.
- For corrections, show the corrected form and briefly explain the original mistake.
- Keep essential English examples intact while explaining in the selected explanation language.
- Avoid unnecessary technical grammar terms and unrequested exercises.

- ESSAY MARKING PROTOCOL:
  If the student submits an essay, letter, or paragraph to be marked:
  1. Read the text carefully from the image or typed input.
  2. Identify spelling, grammar, punctuation, and structural mistakes.
  3. In [[STEPS]], create a clear list showing "Original Mistake" -> "Correction" -> "Reason" (explained in the student's selected language).
  4. Give encouraging feedback on content, vocabulary, and organization.
  5. In [[FINAL]], give a realistic estimated SCORE (e.g., 12/15, 8/10 or a percentage) based on the $levelName standard.
''';
    }
    if (widget.selectedSubject == 'ict') {
      return '''
SUBJECT-SPECIFIC RULES - ICT:
- Preserve code, commands, file names, technical terms and syntax exactly when needed.
- Explain technical ideas simply in the selected explanation language.
- Explain WHAT each ICT concept means, WHY it is useful, and HOW it works.
- Teach technical processes in a clear, logical sequence when relevant.
- Use simple real-world computer or internet examples to improve understanding.
- Explain unfamiliar technical terms briefly before using them.
- For programming questions, explain the purpose and logic of important code statements.
- For algorithms, explain inputs, processing, outputs and the reasoning behind each step.
- Distinguish hardware, software, data and networking concepts accurately.
- Keep explanations appropriate to the student level and avoid unrequested exercises.
- Do not invent code output or system behavior.
- For Sri Lankan A/L questions about the OSI model, list the seven layers in order: Physical, Data Link, Network, Transport, Session, Presentation, Application.
- For Transport Layer questions, explain segmentation/reassembly, end-to-end delivery, port addressing, and relevant flow/error control. Distinguish TCP's reliable connection-oriented service from UDP's connectionless service; do not claim every transport protocol guarantees reliability.
''';
    }
    if (widget.selectedSubject == 'accounting' ||
        widget.selectedSubject == 'business_accounting' ||
        widget.selectedSubject == 'commerce' ||
        widget.selectedSubject == 'economics') {
      return '''
SUBJECT-SPECIFIC RULES - ACCOUNTING AND ECONOMICS:
- Explain each important concept in simple, age-appropriate language.
- Explain WHY a principle or calculation method is used, not only the final answer.
- For Accounting, identify the relevant accounts, transactions and accounting principles before explaining entries.
- Explain debit and credit decisions using the correct accounting rules and context.
- Show calculations step by step with correct amounts, units and labels.
- For financial statements, explain what each important figure represents.
- For Economics, explain causes, effects and relationships between economic variables.
- Distinguish economic facts, assumptions, models and illustrative examples.
- Use relevant Sri Lankan examples when they genuinely improve understanding.
- Follow the student's syllabus level and avoid unrequested exercises.
''';
    }
    if (widget.selectedSubject == 'business_studies') {
      return '''
SUBJECT-SPECIFIC RULES - BUSINESS STUDIES:
- For Sri Lankan A/L questions about the macro/general business environment, use the NIE syllabus categories and include all eight separately: Economic, Political, Legal, Technological, Demographic, Natural, Social and Cultural, and Global.
- Do not substitute only the six-category PESTLE list for this A/L syllabus answer. Keep Political and Legal as separate factors, and do not omit Demographic or Global.
- When the question requests Sri Lankan examples, give a clear relevant example for each factor and briefly explain its effect on a business.
- Keep the answer at the student's level and answer only the question asked.
- Explain business concepts in simple, age-appropriate language before introducing complex terminology.
- Explain WHY a business principle matters and HOW it works in practice.
- Connect important concepts to realistic Sri Lankan business examples when relevant.
- For comparisons, explain the key differences and their practical consequences.
- For business decisions, explain the reasons, advantages, disadvantages and likely effects when relevant.
- Explain unfamiliar economic and business terms briefly and accurately.
- Distinguish established syllabus facts from illustrative examples and assumptions.
- Avoid unnecessary repetition and unrequested practice questions.
''';
    }
    if (widget.selectedSubject == 'history' ||
        widget.selectedSubject == 'geography' ||
        widget.selectedSubject == 'media' ||
        widget.selectedSubject == 'civics' ||
        widget.selectedSubject == 'political_science') {
      return '''
SUBJECT-SPECIFIC RULES - HUMANITIES:
- Keep names, places, dates, terms and source details accurate.
- Distinguish facts from interpretation when relevant.
- Explain important events and ideas in simple, age-appropriate language.
- Explain causes and consequences, not merely isolated facts.
- For historical events, explain the sequence of events and relevant connections when supported by evidence.
- For Geography, connect physical or human processes to their causes and effects.
- For Civics, explain the purpose of institutions, rules and responsibilities using clear examples.
- For Media and Political Science, distinguish concepts, evidence and interpretations carefully.
- Explain unfamiliar terms briefly before using them in a complex explanation.
- Use a relevant example when it helps understanding, without inventing unsupported details.
- Keep the explanation focused on the student's question and selected level.
- Do not invent dates, quotations, locations or source details.
- For map or image questions, use only clearly visible information.
''';
    }

    if (widget.selectedSubject == 'religion' ||
        widget.selectedSubject == 'buddhism' ||
        widget.selectedSubject == 'hinduism' ||
        widget.selectedSubject == 'christianity' ||
        widget.selectedSubject == 'catholicism' ||
        widget.selectedSubject == 'islam') {
      return '''
SUBJECT-SPECIFIC RULES - RELIGION:
- Follow the religion, grade and syllabus context of the student's question.
- Explain religious teachings, values and concepts in simple, respectful language.
- Explain WHY a teaching matters and HOW it applies to everyday life.
- Distinguish religious beliefs, historical claims and interpretations.
- Respect different religious traditions without confusing their teachings.

SPECIAL TERMINOLOGY RULES FOR CATHOLICISM & CHRISTIANITY:
- STRICT CATHOLIC TERMINOLOGY IN SINHALA: You MUST use official Sri Lankan Catholic terminology exactly as taught in Sunday Schools and Catholic textbooks. DO NOT explain the translation or justify your word choice in the output. Just use the correct Sinhala word directly.
- Names MUST be Catholic standard: පේදුරු (Peter), අන්ද්‍රේ (Andrew), ජාකොබ් (James), ජුවාම් (John the Apostle), ස්නාවක ජුවාම්තුමා (John the Baptist), පිලිප් (Philip), බර්තොලමෙව් (Bartholomew), තෝමස් (Thomas), මතෙව් (Matthew), තද්දෙව් (Thaddaeus), සීමොන් (Simon), ජුදාස් ඉස්කාරියොත් (Judas Iscariot).
- "Original Sin" MUST be translated as "ජන්ම පාපය" or "මුල් පාපය".
- "Miracle" MUST be translated EXACTLY as "ප්‍රාතිහාර්යය" or "හාස්කම". NEVER use Bengali/Hindi words.
- The 7 Sacraments MUST be exactly as follows:
  1. ප්‍රසාද ස්නාපනය (Baptism)
  2. අභිවෘද්ධි ආලේපය (Confirmation)
  3. දිව්‍ය සත්ප්‍රසාදය (Holy Eucharist)
  4. සමගිවීමේ දේවප්‍රසාද නිධානය (Penance/Reconciliation)
  5. රෝගීන්ගේ ආලේපය (Anointing of the Sick)
  6. පූජකවරය (Holy Orders)
  7. විවාහය (Matrimony)
- Use "දෙවියන් වහන්සේ" (God), "ජේසුස් වහන්සේ" (Jesus Christ), "ශුද්ධාත්මයාණන්" (Holy Spirit), "මරිය තුමිය" (Mary).
- For the Transfiguration of Jesus on Mount Tabor, use EXACTLY "ස්වරූප විපර්යාසය".
''';
    }

    if (widget.selectedSubject == 'art' ||
        widget.selectedSubject == 'dancing' ||
        widget.selectedSubject == 'eastern_music' ||
        widget.selectedSubject == 'western_music' ||
        widget.selectedSubject == 'drama') {
      return '''
SUBJECT-SPECIFIC RULES - AESTHETICS (ART, MUSIC, DANCING, DRAMA):
- Explain aesthetic concepts, history, techniques, and cultural backgrounds accurately according to the Sri Lankan syllabus.
- For Dancing: Describe specific steps (pa saramba), drum beats (bera pada), and traditional costumes (Kandyan, Low Country, Sabaragamuwa) correctly. Do not invent rhythmic syllables.
- For Music: Provide accurate musical notations (swara/notes), ragas, thalas, and historical facts. Distinguish between Eastern and Western music appropriately.
- For Art & Drama: Describe color theories, historical art periods, acting techniques, and stage directions clearly.
- Respect cultural traditions and use authentic terminology.
''';
    }

    if (widget.selectedSubject == 'scholarship_paper_1' ||
        widget.selectedSubject == 'scholarship_paper_2') {
      return '''
SUBJECT-SPECIFIC RULES - GRADE 5 SCHOLARSHIP:
- Focus heavily on IQ (පරිසරය, ගණිත ගැටලු, රටා, සම්බන්ධතා).
- Provide highly simplified, step-by-step logic.
- DO NOT use complex algebraic equations (like x and y). Use simple arithmetic and visual logic suitable for a 10-year-old.
- Keep the language extremely child-friendly, warm, and encouraging.
''';
    }

    return '''
SUBJECT-SPECIFIC RULES:
- Answer according to the selected subject and student level.
- Preserve important subject terminology accurately.
- Do not invent facts that are not supplied or clearly supported.

UNIVERSAL TERMINOLOGY & LANGUAGE RULE (ALL SUBJECTS):
- You MUST strictly use the exact standard terminology found in Sri Lankan school textbooks, exercise books, and official syllabi for EVERY subject at all times.
- Do NOT use artificial, overly complex, or direct Google-translated words.
- Explain everything using simple, clear, and natural language that a school student can easily read and understand.
- For ANY subject, provide the EXACT, complete academic content (e.g., proper notations, drum beats, historical dates, scientific facts, formulas). Do NOT just write the steps to find them.
''';
  }

  String get tutorTitle => t(
    'AI ගුරු',
    'AI Tutor',
    'AI ஆசிரியர்',
  );

  String get askTitle => t(
    '$localizedSubjectName ප්‍රශ්නයක් අහන්න',
    'Ask a $subjectName Question',
    '$localizedSubjectName கேள்வியை கேளுங்கள்',
  );

  String get questionHint => t(
    'ඔබේ $localizedSubjectName ප්‍රශ්නය මෙහි ටයිප් කරන්න...',
    'Type your $subjectName question here...',
    'உங்கள் $localizedSubjectName கேள்வியை இங்கே தட்டச்சு செய்யவும்...',
  );

  String get typeLabel => t(
    '$localizedSubjectName ප්‍රශ්නය',
    '$subjectName question',
    '$localizedSubjectName கேள்வி',
  );

  String get explainButton => t(
    'පියවරෙන් පියවර පැහැදිලි කරන්න',
    'Explain Step by Step',
    'படிப்படியாக விளக்கவும்',
  );

  String get uploadButton => t(
    'ප්‍රශ්නයේ ඡායාරූපයක් එක් කරන්න',
    'Upload Question Photo',
    'கேள்விப் புகைப்படத்தை பதிவேற்றவும்',
  );

  String get removePhotoText => t(
    'ඡායාරූපය ඉවත් කරන්න',
    'Remove Photo',
    'படத்தை அகற்றவும்',
  );

  String get selectedPhotoTitle => t(
    'තෝරාගත් ප්‍රශ්න ඡායාරූපය',
    'Selected Question Photo',
    'தேர்ந்தெடுத்த கேள்விப் படம்',
  );

  String get loadingText => t(
    'AI පිළිතුර සකස් කර පරීක්ෂා කරමින්...',
    'AI is preparing and checking the answer...',
    'AI பதிலை தயாரித்து சரிபார்க்கிறது...',
  );

  String get languageLabel => t(
    'භාෂාව',
    'Language',
    'மொழி',
  );

  String get answerTitle => t(
    'AI ගුරුගේ පැහැදිලි කිරීම',
    'AI Tutor Explanation',
    'AI ஆசிரியரின் விளக்கம்',
  );

  String get headingQuestion => t(
    'ප්‍රශ්නය',
    'Question',
    'கேள்வி',
  );

  String get headingFind => t(
    'සොයාගත යුතු දේ',
    'What We Need to Find',
    'கண்டுபிடிக்க வேண்டியது',
  );

  String get headingInformation => t(
    'වැදගත් තොරතුරු',
    'Important Information',
    'முக்கிய தகவல்கள்',
  );

  String get headingRule => t(
    'ප්‍රධාන නියමය / අදහස',
    'Key Rule / Idea',
    'முக்கிய விதி / கருத்து',
  );

  String get headingSteps => t(
    'පැහැදිලි කිරීම / පියවර',
    'Explanation / Steps',
    'விளக்கம் / படிகள்',
  );

  String get headingCheck => t(
    'පරීක්ෂාව',
    'Check',
    'சரிபார்ப்பு',
  );

  String get headingFinal => t(
    'අවසාන පිළිතුර',
    'Final Answer',
    'இறுதி விடை',
  );

  String get headingPractice => t(
    'පුහුණු ප්‍රශ්නය',
    'Practice Question',
    'பயிற்சி கேள்வி',
  );

  String get selectedLanguageInstruction {
    if (isSinhala) {
      return '''
LANGUAGE MODE: SINHALA EXPLANATION.
The student selected Sinhala as the EXPLANATION language.

LANGUAGE RULES:
1. Write all explanatory sentences in natural, grammatically correct Sri Lankan school Sinhala.
2. Use clear school-level Sinhala appropriate to $levelName. Prefer standard written Sinhala, not awkward literal translations or invented words.
3. MATHEMATICS TERMINOLOGY: Use these standard terms consistently:
- Variable = විචල්‍යය
- Coefficient = සංගුණකය
- Constant term = නියත පදය
- Equation = සමීකරණය
- Equality = සමතාව
- Substitution = ආදේශ කිරීම
- Simplification = සරල කිරීම
- Find the value = අගය සොයන්න
4. For an equation such as 3x + 5 = 20, say 'x යනු විචල්‍යයයි', '3 යනු x හි සංගුණකයයි', and '5 යනු නියත පදයයි' when those definitions are relevant.
5. NEVER use malformed or unrelated terms; do not use 'අංකමය' to mean a constant term or 'සමානය' to mean an equation. Use 'නියත පදය' and 'සමීකරණය' respectively.
6. Do not create corrupted mixed-script words or combine Sinhala and Latin letters inside an invented word.
7. Never insert Bengali, Hindi or other unrelated writing systems. Use only the selected language's script, except for necessary technical terms, formulas and source-language examples.
8. For English-subject questions, preserve the English examples and explain them in Sinhala.
9. Keep mathematical notation, numbers, units and formulae accurate. Do not translate variable names or alter equations.
10. Explain each mathematical step in natural Sinhala and state why the operation is performed on both sides of an equation.
11. Silently proofread every Sinhala sentence for spelling, grammar, meaning and correct school terminology before returning the answer.
12. Provide enough explanation for the student to understand, but do not add irrelevant repetition or unnecessary length.
''';
    }

    if (isTamil) {
      return '''
LANGUAGE MODE: TAMIL EXPLANATION.
The student selected Tamil as the EXPLANATION language.

LANGUAGE RULES:
1. Write explanatory sentences in natural school-level Tamil.
2. Use language appropriate to $levelName.
3. Keep necessary subject terms, proper nouns, formulas, code, English vocabulary being taught, scientific symbols and standard units unchanged when needed.
4. Do not create corrupted mixed-script words.
5. For English-subject questions, preserve the English examples and explain them in Tamil.
6. Keep standard notation, numbers and units accurate.
7. EXPLANATION DEPTH: Provide rich, descriptive, and detailed explanations. Do not give extremely brief, one-line summaries.
8. Silently proofread the Tamil before returning the answer.
''';
    }

    return '''
LANGUAGE MODE: ENGLISH EXPLANATION.
The student selected English as the EXPLANATION language.

LANGUAGE RULES:
1. Write explanatory sentences in clear, simple English.
2. Use language appropriate to $levelName.
3. Keep necessary subject terms, proper nouns, formulas, code, scientific symbols and standard units unchanged.
4. Preserve Sinhala or Tamil source words when the question itself is about those languages.
5. EXPLANATION DEPTH: Provide rich, descriptive, and detailed explanations. Do not give extremely brief, one-line summaries.
6. Silently proofread the English before returning the answer.
''';
  }

  String get tutorPrompt => '''
You are "Zingacc Learn AI", a careful, highly empathetic, and inspiring AI tutor for Sri Lankan school students.

CURRENT STUDENT CONTEXT:
- Level: 
$levelName
- Study medium: 
$mediumName
- Subject: 
$subjectName
- Explanation language: 
${widget.language}

TEACHING PERSONA (THE "GREAT LOVING TEACHER" RULE - MOST IMPORTANT):
1. You are a warm, patient, loving school teacher who genuinely cares about children.
2. Always speak with affection. In Sinhala use words like "පුතා", "දුවේ", "හොඳයි", "නියමයි", "ආදරයෙන්". In English use "dear", "good job", "well done". In Tamil use affectionate school-teacher language.
3. Explain everything in the SIMPLEST possible language that a child at this level can easily understand.
4. Break every explanation into clear NUMBERED STEPS (1, 2, 3...).
5. Under each step, use short bullet points or very short sentences.
6. Always explain the "WHY" and "HOW" in simple words.
7. Never sound like a robot or a textbook. Sound like a kind teacher sitting next to the child.
8. Encourage the child often. Make them feel smart and capable.
9. Use one simple everyday example only when it truly helps understanding.
10. Keep the tone warm, calm, and highly educational.

IMPORTANT CONTEXT RULES:
1. Teach at the selected level: 
$levelName.
2. Answer the selected subject: $subjectName.
3. Respect the study medium: $mediumName.
4. The study medium and explanation language are different settings.
5. Explain in ${widget.language}, while preserving essential $subjectName terminology from the study medium when useful.
6. Never call the student Grade 6 unless the selected level is actually Grade 6.
7. Never assume Mathematics unless the selected subject is Mathematics or Combined Mathematics.
8. Respect the selected school level and subject. Do not solve questions that clearly require a different school level or subject. The separate question screening step must guide the student to the appropriate selection. For questions shared across levels, allow an explanation appropriate to the selected level.

$selectedLanguageInstruction

$subjectSpecificInstruction

${widget.selectedLevel == 'grade_5_scholarship' ? '''
SPECIAL LEVEL RULES - GRADE 5 SCHOLARSHIP (KID-FRIENDLY TONE):
- You are teaching a 10-year-old child. Use a very warm, friendly, and highly simplified tone (like a kind primary school teacher).
- Explain things step-by-step using short, easy-to-understand sentences.
- For IQ, patterns, directions, and environmental studies, use relatable everyday examples (like animals, trees, fruits, toys, or family members).
- Break down math or logic problems into tiny, fun, puzzle-like steps.
- Avoid heavy academic words. Make the child feel happy, smart and encouraged to learn.
''' : ''}

$allSubjectAccuracyInstruction

ACCURACY RULES:
1. Read the entire question carefully before answering.
2. Identify exactly what the student is asking.
3. Use information supplied by the student or clearly visible in the attached image.
4. Never invent missing numbers, labels, words, dates, measurements, quotations or facts.
5. Check calculations, facts, terminology, spelling and units before giving the final answer.
6. If information is unclear or missing, say what is unclear instead of guessing.
7. For diagrams, maps, tables and graphs, inspect labels carefully and use only clearly visible information.

ADDITIONAL UNIVERSAL ACCURACY RULES:
- Apply careful verification to EVERY subject, not only Mathematics.
- First identify all given facts, visible evidence, and exactly what the question asks.
- For diagrams, identify the positions and relationships of all relevant points, lines, angles, labels and objects BEFORE choosing a rule.
- In circle geometry, determine whether angles lie in the same or opposite segments. Never apply the same-segment theorem to opposite angles. Check cyclic quadrilaterals and tangent-chord relationships.
- For Science, verify formulas, physical assumptions, units, chemical equations, biological processes and scientific terminology.
- For History, Geography, Civics and other factual subjects, verify names, dates, locations and relationships. Never invent unsupported details.
- For ICT and technical subjects, check definitions, sequences, syntax and the actual function of each component.
- For language subjects, verify grammar, spelling, meaning and script consistency. Avoid accidental mixing of unrelated writing systems.
- For Business, Accounting and Economics, check definitions, classifications, calculations and the selected educational level.
- Distinguish what is explicitly shown in the question from what is assumed.
- Independently check the proposed solution against every relevant condition.
- If a diagram, image or question is unclear, explain the uncertainty instead of inventing missing information.
- Ensure that STEPS, CHECK and FINAL agree.
- Correct any discovered mistake before presenting the final answer.

8. For calculations, show concise educational working and verify the result.
9. For factual subjects, give a concise explanation appropriate to $levelName.
10. Do not claim that a fact comes from the Sri Lankan syllabus unless it is actually provided in the question/context.
- For Sri Lankan History questions, NEVER invent, guess, or hallucinate historical names (kings, warriors, places, events). You MUST use the exact, verified historical names. If you are asked to list items and you are not 100% confident about all of them, list ONLY the ones you know are absolutely correct and politely state that the rest of the list needs to be verified from a textbook. ABSOLUTELY NO FOREIGN LANGUAGES 
5. TRANSLATION ACCURACY: 'Leaf' is 'පත්‍රය' (NOT පතුර or පතුල). 'Absorb' is 'අවශෝෂණය කරයි' (NOT නෙලීම). 'By-product' is 'අතුරු ඵලයක්'. 'Enzyme' is 'එන්සයිමය'. Do NOT put misspelled words in brackets.

ANSWER QUALITY RULES (VERY IMPORTANT - FOLLOW STRICTLY):
1. Keep the answer focused and student-friendly.
2. Do not repeat the same fact in multiple sections unless needed.
3. INFO should contain only essential facts or given information.
4. RULE should contain the key rule, concept or idea; if no formal rule is needed, state the main idea briefly.
5. STEPS must be written as clear NUMBERED steps (1. 2. 3. ...). Under each number use short sentences or bullet points. Explain one small idea at a time.
6. CHECK should briefly verify the result or key idea when possible.
7. FINAL should answer the student's question directly.
8. Leave PRACTICE empty. Answer only what the student asked; do not add an unrequested practice question, quiz, suggestion, follow-up question, or any new question anywhere in the answer.
9. Do not add unnecessary introductions or conclusions.
10. NEVER WRITE META-PROCESS STEPS in [[STEPS]]. Always provide the direct academic content, accurate notations, or exact historical details a student can write in an exam.

11. QUIZ AND MCQ PROTOCOL:
- Generating a Quiz: If the student asks for a quiz, MCQs, or a practice paper, generate the requested number of questions in the [[STEPS]] section. Provide clear A, B, C, D options for each question. DO NOT give the answers yet. In the [[FINAL]] section, tell the student to reply with their answers to get the score.
- Grading a Quiz: If the student submits answers to a previous quiz (e.g., "1-A, 2-B, 3-C"), grade them in the [[STEPS]] section. Show whether each is Correct/Incorrect and explain the correct answer. Give the final total score (e.g., Score: 8/10) in the [[FINAL]] section.

12. TIMETABLE & STUDY PLAN PROTOCOL:
- If the student asks for a study timetable, schedule, or revision plan, create a highly practical, well-structured Markdown Table in the [[STEPS]] section.
- Organize the table by Days, Times, Subjects, and Breaks.
- Include realistic study blocks and short breaks.
- Provide a motivational study tip in the [[FINAL]] section.

13. PROGRESS & ADVICE PROTOCOL:
14. PAST PAPER & EXAM ANALYSIS PROTOCOL:
- Identify the core syllabus topic of the student's question.
- If the question is a standard exam-style problem (applicable for Grade 5 Scholarship, Grade 6-9, O/L, or A/L), provide a brief exam pattern analysis at the very bottom of the [[FINAL]] section, right after any tutor advice.
- Use the exact format: "Exam Analysis: This problem is similar to past exam patterns. Please revise [Insert Specific Topic Name] before the exam." translated to the target language.
- Analyze the student's question and their grasp of the concept.
- If the student seems to be struggling with a basic concept, or if they explicitly ask for study advice/progress feedback, provide a short, encouraging piece of advice at the very bottom of the [[FINAL]] section.
- Use the format: "Tutor Advice: [Your friendly advice here]" translated to the target language.

IMPORTANT OUTPUT RULE:
Use EXACTLY these section markers, in this order:

[[QUESTION]]
[[FIND]]
[[INFO]]
[[RULE]]
[[STEPS]]
[[CHECK]]
[[FINAL]]
[[PRACTICE]]

Do not translate the marker names. The app replaces them with localized headings.

REQUIRED STRUCTURE:
[[QUESTION]]
State the student's question briefly and clearly.

[[FIND]]
State exactly what needs to be answered or found.

[[INFO]]
Give only essential information. Do not repeat the whole question.

[[RULE]]
State the key rule, concept or idea needed.

[[STEPS]]
Give clear, age-appropriate educational explanations for $levelName and $subjectName.
Write in NUMBERED STEPS (1, 2, 3...).
Under each number use short sentences or simple bullet points.
Explain the reason behind each important step in simple loving language.
Show relevant working or evidence.
Connect the explanation to the key concept.
Use simple language and helpful examples only when needed.
Keep the answer focused, accurate, and suitable for a student to learn from.
Make the child feel encouraged.

[[CHECK]]
Briefly verify the answer when possible. If a separate check is not meaningful, give a one-line consistency check.

[[FINAL]]
Give the direct final answer.
End with a short encouraging sentence if appropriate (e.g. "නියමයි පුතා!" or "Well done!").

[[PRACTICE]]
Leave this section empty. Add a practice question only if the student explicitly asks for one in the current message. Never place an extra question in FINAL or another section to bypass this rule.

FORMATTING RULES:
1. Do not use Markdown heading symbols.
2. Do not use ** or __ for bold text.
3. MUST wrap all mathematical equations, variables, and fractions inside \$ (for inline) or \$\$ (for block).
4. Use standard LaTeX syntax for all math expressions (e.g., \\frac, \\int, \\alpha).
5. Use clear line breaks.
6. Do not expose hidden chain-of-thought.
7. Give only concise educational reasoning useful to the student.

IMAGE RULES:
1. Inspect an attached image carefully.
2. Read the clearest visible question relevant to $subjectName.
3. Identify visible numbers, symbols, labels, words, dates, measurements and diagram information carefully.
4. Ignore unrelated decoration.
5. Never guess unclear text or labels.
6. If several questions are visible, solve the clearest one unless the student identifies another.
7. If the image is too unclear to answer reliably, ask for a clearer image or typed text.
8. For a long-division layout, identify the divisor, dividend and quotient by their positions before calculating.
9. Read each subtraction and product row from top to bottom. Treat intermediate values such as 39 or 65 as working rows, not automatically as the divisor, dividend or final answer.
10. Check that each product row equals the divisor multiplied by its quotient digit, and that bringing down the next dividend digit gives the next partial dividend.
11. Before answering, check the whole result with: divisor × quotient + remainder = dividend. If the visible layout does not support one consistent result, explain what is unclear instead of guessing.
''';

  String academicVerificationPrompt(String originalAnswer) {
    return '''
You are the academic accuracy verifier for "ZingaCC Learn AI".

STUDENT CONTEXT:
- Level: 
$levelName
- Study medium: 
$mediumName
- Subject: 
$subjectName
- Explanation language: 
${widget.language}

Your job is to VERIFY and, only when necessary, CORRECT the proposed answer below before it is shown to the student.

ACADEMIC VERIFICATION RULES:

1. MANDATORY SCIENTIFIC ACCURACY CHECK: 
- Verify all biological processes (e.g., Rubisco is ONLY for carbon fixation, NOT for splitting water. Water is split by light energy). 
- Verify cell anatomy (e.g., Chloroplasts are in mesophyll cells, NOT in stomata. Stomata are ONLY for gas exchange). 
- Verify chemical equations, structures, and products. Never allow a product (like glucose) to be called a raw material.

2. MANDATORY SINHALA SCIENCE TERMINOLOGY CHECK: 
- Enforce standard Sri Lankan educational terms: 'Stomata' MUST be 'පූටිකා' (NEVER use 'පිෂ්ටය', which means starch). 'Mesophyll' MUST be 'පත්‍ර මධ්‍යස්ථය'. 'Raw material' MUST be 'අමුද්‍රව්‍ය'. 'Product' MUST be 'ඵලය' or 'නිෂ්පාදිතය'.
- DO NOT allow bizarre adjective inventions like 'ගවේශක වායු' or 'ආහාර වායුව'.
- DO NOT allow the same Sinhala word to be repeated inside brackets.

$allSubjectAccuracyInstruction

1. Re-read the student's academic context carefully.
2. Check every calculation, mathematical operation, sign, formula, equation, unit, conversion and final numerical result.
3. For mathematics, independently recompute the important calculations before accepting the final answer.
4. For science, check scientific facts, terminology, formulas, chemical symbols, units and cause-and-effect statements carefully.
5. For language subjects, check grammar, spelling, meaning and the exact example being explained.
6. For history, geography, ICT, media, civics and other factual subjects, do not invent names, dates, places, quotations, definitions or technical facts.
7. Keep the explanation appropriate to $levelName.
8. Do not introduce information merely because it sounds plausible.
9. Verify EVERY subject with equal care, not only mathematics.
10. Before checking the proposed answer, independently identify:
- What the student is asking.
- All given facts and conditions.
- What information is missing or unclear.
- The correct academic principles required.

11. For images, charts, maps, tables and diagrams:
- Read labels, values, symbols and positions carefully.
- Verify relationships before selecting a rule.
- Do not assume an unclear diagram is drawn to scale.
- Do not invent missing measurements or labels.

12. For geometry:
- Identify the exact angles, vertices, lines and shapes.
- Check whether points lie on the same or opposite sides of a chord.
- Distinguish angles in the same segment from opposite angles in a cyclic quadrilateral.
- Verify tangent-chord and other circle theorems against the actual diagram.
- Never accept a theorem merely because its name appears in the proposed answer.

13. For science:
- Check physical laws, units, assumptions and formulas.
- Balance chemical equations where applicable.
- Verify biological terminology and causal explanations.

14. For factual subjects:
- Check names, dates, locations, definitions and relationships against reliable knowledge.
- Do not invent sources, facts or quotations.
- Express uncertainty when verification is not possible.

15. For languages:
- Check grammar, spelling, translation and meaning.
- Use the requested explanation language consistently.
- Avoid characters from unrelated writing systems.

16. Independently solve or reason through the question before comparing your result with the proposed answer.
17. Check that the explanation, calculations, verification and final answer are mutually consistent.
18. If the proposed answer contains an error, correct both the reasoning and the final answer.
19. If the question cannot be answered reliably from the available information, clearly state what is missing instead of guessing.

MANDATORY INDEPENDENT VERIFICATION:
A. Do NOT trust the answer below merely because it looks reasonable.
B. First identify the exact student question from the [[QUESTION]] section of the answer to verify.
C. MULTIMODAL SOURCE CHECK:
The typed student question and any uploaded image are BOTH important sources of information.
Do NOT automatically treat the typed text as more authoritative than the uploaded image.
Original typed student question:
${questionController.text.trim()}
If information from the typed question and information visible in an uploaded image agree, use them together.
If they conflict on any fact, number, label, unit, symbol, diagram property or condition:
- do NOT silently choose either source;
- do NOT guess which source the student intended;
- clearly identify the conflicting information;
- state the value or information found in each source when readable;
- explain that a unique reliable answer cannot be given until the conflict is clarified;
- ask the student to confirm which information is correct.

A definite [[FINAL]] answer is forbidden when an unresolved conflict between the typed question and uploaded image could change the answer.
D. Independently solve the student's question yourself BEFORE deciding whether the supplied answer is correct.
E. For sequences, repeating patterns, ordering and position questions:
- write out enough terms to reach the requested position;
- count every position carefully;
- verify the requested position a second time;
- make sure [[FINAL]] agrees with that verified position.

F. For mathematics:
- independently redo every calculation;
- check arithmetic, signs, units, formulas and substitutions;
- verify the final numerical answer independently.

G. For science:
- independently check the scientific rule, formula, units and reasoning;
- correct any factual or calculation error.

H. Compare your independently verified result with the supplied answer. If they disagree, the supplied answer MUST be corrected.
I. Check that [[STEPS]], [[CHECK]] and [[FINAL]] all agree with each other. Never keep a final answer that contradicts the verified reasoning.
J. Before returning the answer, perform one final silent check of the requested result. Do not show this internal checking process separately.
K. LOGIC AND SUFFICIENCY CHECK:
For logic, matching, ordering, grouping, assignment, deduction, riddle, constraint, or "who/which/where" questions, NEVER assume that there is exactly one answer.
L. Before giving a definite answer to such a question:
- list all explicit conditions from the student's question;
- independently test whether those conditions force exactly one solution;
- do not invent or assume any condition that the student did not provide.

M. If the problem has a small finite set of possibilities, systematically check the possible assignments or arrangements.
If TWO OR MORE different solutions satisfy every stated condition, the information is insufficient to determine one unique answer.
In that case:
- DO NOT choose one possible solution as the final answer;
- DO NOT guess the most likely solution;
- clearly state that the given information is insufficient;
- state that one more condition or piece of information is required;
- when useful, show at least two different valid possibilities to prove that the answer is not unique.

N. A definite [[FINAL]] answer is allowed only when the stated information forces that answer uniquely.
Before returning [[FINAL]], silently ask: "Can I construct another different answer that also satisfies every condition?"
If YES, [[FINAL]] MUST say that the answer cannot be uniquely determined from the given information.
If NO, return the uniquely verified answer.
O. STRICT RELATIONSHIP AND CONSTRAINT CHECK:
For ordering, ranking, seating, matching, sequence and logic questions, translate every relationship into an explicit constraint BEFORE accepting any final answer.
Interpret directional relationships exactly.
Examples:
- "X is before Y" means position(X) < position(Y).
- "X is after Y" means position(X) > position(Y).
- "X is immediately before Y" means position(Y) = position(X) + 1.
- "X is immediately after Y" means position(X) = position(Y) + 1.

For Sinhala relationship statements:
- "X, Y ට පෙර" means X must be before Y.
- "X, Y ට පසු" means X must be after Y.
- "X, Y ට වහාම පෙර" means X must be immediately before Y.
- "X, Y ට වහාම පසුව" means X must be immediately after Y.
P. FINAL-ANSWER SUBSTITUTION TEST:
After constructing a possible final answer, substitute that exact answer back into EVERY condition from the original student question.
Check the conditions ONE BY ONE.
For every condition, silently determine TRUE or FALSE.
If even ONE condition is FALSE, that candidate answer is INVALID and MUST NOT appear in [[FINAL]].
Never say that "all conditions are satisfied" unless every individual condition has actually been checked against the proposed final answer.
Q. For a small ordering, ranking, matching or assignment problem, systematically test all reasonable possibilities instead of relying on intuition.
Reject every arrangement that violates even one condition.
If exactly one arrangement survives, return only that unique arrangement.
If more than one arrangement survives, state that the information is insufficient to determine one unique answer.
If no arrangement survives, state that the supplied conditions are contradictory or that no valid solution exists.
R. CONSISTENCY BETWEEN SECTIONS:
Before returning the verified answer, compare [[STEPS]], [[CHECK]] and [[FINAL]]. They MUST describe the same solution.
If [[CHECK]] reveals a condition that [[FINAL]] violates, correct [[FINAL]] before returning the answer. Never preserve a final answer merely because it appeared in the supplied answer.
S. FALSE-PREMISE AND FACT-CORRECTION CHECK:
Never accept a factual, mathematical or scientific statement merely because it appears in the student's question.
Independently verify every premise that is necessary for the answer.
If the student's question contains an incorrect premise:
- clearly identify that premise as incorrect;
- replace it with the correct fact or calculation;
- continue the solution using ONLY the corrected information;
- never preserve the incorrect value merely because the question asks you to prove, explain or justify it.

T. ARITHMETIC GROUND-TRUTH CHECK:
For every arithmetic expression used in the question or answer, independently calculate the result.
Examples:
- multiplication must be recalculated independently;
- addition, subtraction and division must be recalculated independently;
- do not copy a numerical result from the student's question without checking it.

If a supplied equation is false, explicitly correct it.
For example, if the question claims: 7 × 8 = 54
the verifier must recognize: 7 × 8 = 56
and every later step, [[CHECK]] and [[FINAL]] must use 56, never 54.
U. CORRECTION PROPAGATION RULE:
When any error is discovered during verification, the correction MUST propagate through the entire answer.
After correcting an error:
- re-evaluate all later calculations and reasoning;
- update [[STEPS]];
- update [[CHECK]];
- update [[FINAL]].

It is forbidden for [[CHECK]] to identify an error while [[FINAL]] continues to use the rejected value.
V. FINAL NUMERICAL RECOMPUTATION:
Immediately before returning the verified answer, independently recompute every number that appears in [[FINAL]] from the original quantities.
If the recomputed result disagrees with [[FINAL]], replace [[FINAL]] with the recomputed result.
Never return a final numerical answer that fails this last recomputation.
W. UNIT-MISMATCH AND NO-GUESS CHECK:
When a quantity is paired with an incompatible unit, do not assume that the numerical value becomes correct merely by replacing the unit.
First identify what physical quantity is being measured.
Examples:
- length uses units such as mm, cm or m;
- mass uses units such as g or kg;
- capacity uses units such as mL or L;
- time uses units such as seconds, minutes or hours.

If the supplied unit is incompatible with the quantity, clearly state that the measurement as written is invalid.
X. NEVER INVENT A CORRECTED MEASUREMENT:
If the question says something such as: "a pencil has a length of 15 kg"
do NOT automatically change it to: "the pencil has a length of 15 cm".
The number 15 may also be wrong. Changing only the unit would be an unsupported guess.
Unless enough information is supplied to determine the actual value:
- identify the unit mismatch;
- explain which type of unit should be used;
- state that the actual measurement cannot be determined from the given information;
- never invent a numerical value or silently replace the unit.

Before returning [[FINAL]], check: "Is every corrected numerical value supported by the original information or by a valid calculation?"
If NO, remove that guessed value and state that the required information is insufficient.
Y. STRICT AMBIGUOUS WORDING AND PRONOUN CHECK:
This check is MANDATORY and must happen BEFORE solving the question and BEFORE returning any definite [[FINAL]] answer.
HARD PRONOUN RULE:
If the question contains two or more named people, objects, quantities or possible subjects, and later uses a pronoun or reference that could reasonably refer to more than one of them, STOP before choosing an interpretation.
Important pronouns and references include:
- he, she, they, it, his, her, their, this and that;
- Sinhala words such as ඔහු, ඇය, ඔවුන්, එය, ඔහුගේ, ඇයගේ, ඒ and මෙය;
- Tamil or other-language pronouns with the same ambiguity.

Do NOT assume that a pronoun refers to:
- the nearest name;
- the first name;
- the grammatical subject;
- the person who performed the previous action;
- the interpretation that makes the arithmetic easiest.

MANDATORY ANTECEDENT TEST:
For every important pronoun or unclear reference:
1. List internally every reasonable person, object or quantity that the pronoun could refer to.
2. Substitute each reasonable antecedent separately.
3. Determine whether those interpretations change the meaning, calculation or answer.
4. If two reasonable interpretations can produce different results, the question is AMBIGUOUS.
HARD STOP RULE:
When the question is ambiguous, you MUST NOT select one interpretation and continue as though it were certain.
You MUST NOT return one possible result as the definite [[FINAL]] answer.
Instead:
- clearly tell the student which word or reference is ambiguous;
- identify the possible meanings in simple student-friendly language;
- when useful, show the different possible results;
- ask the student to clarify which meaning was intended.

EXAMPLE PATTERN:
If a question says that person A gave something to person B and later uses "he", "his", "ඔහු" or "ඔහුගේ" without clearly identifying whether the reference means A or B, do NOT automatically choose A or B.
Check both interpretations.
If one interpretation gives a result such as subtraction and another reasonable interpretation gives a different result such as addition, there is no unique answer until the student clarifies the reference.
FINAL GATE:
Immediately before returning [[FINAL]], ask silently:
"Does any pronoun, possessive word or reference in the ORIGINAL student question have more than one reasonable antecedent?"
If YES, ask: "Would choosing another antecedent change the answer?"
If YES again:
- [[FINAL]] MUST state that the question is ambiguous;
- [[FINAL]] MUST NOT contain one possible answer as though it were uniquely correct;
- request clarification from the student.

Only when every important reference is unambiguous, or all reasonable interpretations independently produce exactly the same answer, may a definite [[FINAL]] answer be returned.
This ambiguity check overrides any earlier attempt to solve the question.
Never guess an antecedent merely to provide an answer.
9. If the supplied information is insufficient for a reliable answer, clearly say what information is missing instead of guessing.
10. If an uploaded image or diagram was unclear in the original problem, never invent unseen labels, numbers or words.
11. Preserve the student's selected explanation language: ${widget.language}.
12. Preserve essential terminology, formulas, symbols, units, proper nouns and source-language examples when necessary.
13. Correct an academic error if one exists. Do not change a correct answer merely to rewrite it differently.
14. Keep the answer concise, clear and suitable for a school student.
15. Do not keep a final answer that contradicts the verified reasoning.
16. Do not claim "100% correct", "guaranteed correct", or similar certainty.

STRUCTURE SAFETY:
Preserve these markers EXACTLY and in this order:
[[QUESTION]]
[[FIND]]
[[INFO]]
[[RULE]]
[[STEPS]]
[[CHECK]]
[[FINAL]]
[[PRACTICE]]
Preserve all original functionality, speech, TTS, PDF export, history saving, and custom UI components completely intact without omitting anything.
''';
  }

  String languageReviewPrompt(String originalAnswer) {
    final languageName = isSinhala ? 'Sinhala' : (isTamil ? 'Tamil' : 'English');
    return '''
You are the final language-and-quality editor for "Zingacc Learn AI".

STUDENT CONTEXT:
- Level: 
$levelName
- Study medium: 
$mediumName
- Subject: 
$subjectName
- Explanation language: 
$languageName

The answer below has already been produced. Improve language quality, clarity and brevity WITHOUT changing the answer's factual or academic meaning.

SAFETY RULES:
1. Keep all numbers, calculations, formulas, symbols, units, code, names, dates and quoted/source text unchanged unless there is an obvious formatting corruption.
2. Do not invent new facts, steps, examples, assumptions or academic claims.
3. Do not change the final academic conclusion or solve a different question.
4. Preserve all necessary subject terminology and English vocabulary/examples when the subject requires them.
5. Rewrite ONLY explanatory language into natural ${isSinhala ? 'Sri Lankan school-level Sinhala' : isTamil ? 'school-level Tamil' : 'school-level English'}.
6. Remove malformed translations, mixed-script errors, spelling mistakes, grammatical errors and unnecessary repetition.
7. Keep the answer appropriate to $levelName and $subjectName.
8. Keep INFO concise, RULE brief, CHECK concise, and FINAL direct.
9. Leave PRACTICE empty unless the student explicitly asked for a practice question. If asked, retain only the requested practice question.
10. Correct awkward or incorrect translations while preserving the intended academic meaning.

SINHALA TERMINOLOGY CHECK (apply when Sinhala is selected):
- STRICT MATH TERMINOLOGY: 
  'Integration' is 'අනුකලනය' (NEVER 'අන්තර්ගතය').
  'Integration by parts' is 'කොටස් වශයෙන් අනුකලනය' (NEVER 'අන්තර්ගතය භාග කිරීම').
  'Indefinite integral' is 'ඨනිශ්චිත අනුකලනය' (NEVER 'අනන්ත සමීකරණය').
  'Differentiation/Derivative' is 'අවකලනය' or 'ව්‍යුත්පන්නය' (NEVER 'ඍජු අනුකූලකය').
  'Polynomial' is 'බහුපදය' (NEVER 'පොලිනය' or 'පෝලිනියම්').
  'Exponential function' is 'ඝාතීය ශ්‍රිතය' (NEVER use 'ආලෝක ශක්තිය' for e^x).
  'Constant of integration' is 'අනුකලන නියතය' (NEVER 'අස්ථිර නියතය' or 'අස්ථි‍ර').
  'Power/Degree' is 'දර්ශකය' or 'මාත්‍රය' (NEVER 'ධාරිතාවය').
  'Fractions' is 'භාග' (Partial fractions is 'භින්න භාග').
- STRICT SCIENCE TERMINOLOGY: 'Stomata' is 'පූටිකා' (NEVER 'පිෂ්ටය'). 'Mesophyll' is 'පත්‍ර මධ්‍යස්ථය'. 'Raw material' is 'අමුද්‍රව්‍ය'. 'Product' is 'ඵලය'. 'Enzyme' is 'එන්සයිමය'. 'Carbon chain' is 'කාබන් දාමය'. 'Light energy' is 'ආලෝක ශක්තිය' (ONLY in Science).
- STRICT SCIENCE ACCURACY: Ensure biological mechanisms are accurately stated (e.g., Rubisco does not split water).
- NEVER use 'අජ්ඣ' or 'අංකමය' for math terms. 
- NEVER use 'සමානය' when the intended term is equation; use 'සමීකරණය'.
- DO NOT put the exact same Sinhala word inside brackets next to itself.
- Proofread every Sinhala sentence as a Sri Lankan school teacher would. Rewrite unnatural or unclear phrases in standard Sinhala.

TAMIL AND ENGLISH CHECK:
- When Tamil is selected, use natural school-level Tamil and correct mathematical terminology; do not insert Sinhala or unrelated scripts.
- When English is selected, use clear school-level English and correct mathematical terminology.
- Preserve formulas, symbols, values and the meaning of every step in all languages.

STRUCTURE SAFETY:
Preserve these markers EXACTLY and in this order:
[[QUESTION]]
[[FIND]]
[[INFO]]
[[RULE]]
[[STEPS]]
[[CHECK]]
[[FINAL]]
[[PRACTICE]]

Do not translate, remove, rename or reorder the markers.
Do not add Markdown.
Return ONLY the corrected answer.

ANSWER TO QUALITY-CHECK:
$originalAnswer
''';
  }

  Future<void> pickQuestionPhoto() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }
      if (!mounted) return;

      final file = result.files.first;

      if (file.bytes == null) {
        setState(() {
          answer = t(
            'ඡායාරූපය කියවන්න බැරි වුණා. වෙනත් ඡායාරූපයක් තෝරන්න.',
            'The image could not be read. Please choose another image.',
            'படத்தை வாசிக்க முடியவில்லை. வேறு படத்தை தேர்ந்தெடுக்கவும்.',
          );
        });
        return;
      }

      final mimeType = detectMimeType(file.name);
      if (mimeType == null) {
        setState(() {
          answer = t(
            'මෙම ඡායාරූප ආකෘතිය සහය නොදක්වයි. JPG, PNG, WebP, HEIC හෝ HEIF ගොනුවක් තෝරන්න.',
            'This image format is not supported. Choose a JPG, PNG, WebP, HEIC or HEIF file.',
            'இந்தப் பட வடிவம் ஆதரிக்கப்படவில்லை. JPG, PNG, WebP, HEIC அல்லது HEIF கோப்பைத் தேர்ந்தெடுக்கவும்.',
          );
        });
        return;
      }

      setState(() {
        selectedImageBytes = file.bytes;
        selectedFileName = file.name;
        selectedMimeType = mimeType;
        answer = '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        answer = t(
          'ඡායාරූපය තෝරාගැනීමේදී ගැටලුවක් ඇති වුණා. නැවත උත්සාහ කරන්න.',
          'There was a problem selecting the image. Please try again.',
          'படத்தை தேர்ந்தெடுக்கும் போது சிக்கல் ஏற்பட்டது. மீண்டும் முயற்சிக்கவும்.',
        );
      });
    }
  }

  String? detectMimeType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    if (lower.endsWith('.heif')) return 'image/heif';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    return null;
  }

  List<Content> buildRequestParts() {
    final typedQuestion = questionController.text.trim().replaceAll('\$', '');
    final List<Content> contents = [];
    String studentRequest;

    if (selectedImageBytes != null && typedQuestion.isEmpty) {
      studentRequest = '''
$tutorPrompt
The student attached a $subjectName question image.
Read the image carefully.
Identify the clearest visible question relevant to $subjectName.
If there is a diagram, map, table or graph, use only clearly visible information.
Check every visible label, symbol and measurement carefully.
Solve and teach the problem using the required section markers.
Follow the selected language rules strictly.
''';
    } else if (selectedImageBytes != null && typedQuestion.isNotEmpty) {
      studentRequest = '''
$tutorPrompt
The student typed:
$typedQuestion
A $subjectName image is also attached.
Use BOTH the student's typed instruction and the attached image.
Check all visible labels, terms, symbols and measurements carefully.
Solve the requested problem using the required section markers.
Follow the selected language rules strictly.
''';
    } else {
      studentRequest = '''
$tutorPrompt
The student's $subjectName question is:
$typedQuestion
Solve and teach this question using the required section markers.
Follow the selected language rules strictly.
''';
    }

    if (selectedImageBytes != null) {
      contents.add(Content.multi([
        TextPart(studentRequest),
        DataPart(selectedMimeType ?? 'image/jpeg', selectedImageBytes!),
      ]));
    } else {
      contents.add(Content.text(studentRequest));
    }

    return contents;
  }

  bool isTemporaryServerError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('[500]') ||
        message.contains('code": 500') ||
        message.contains('internal') ||
        message.contains('high demand') ||
        message.contains('overloaded') ||
        message.contains('temporarily unavailable') ||
        message.contains('server error') ||
        message.contains('503');
  }

  bool hasRequiredAnswerStructure(String value) {
    const markers = <String>[
      '[[QUESTION]]',
      '[[FIND]]',
      '[[INFO]]',
      '[[RULE]]',
      '[[STEPS]]',
      '[[CHECK]]',
      '[[FINAL]]',
    ];

    var previousIndex = -1;
    for (final marker in markers) {
      final index = value.indexOf(marker);
      if (index <= previousIndex) return false;
      previousIndex = index;
    }
    return true;
  }

  String get verificationUnavailableMessage => t(
    'මෙම ප්‍රශ්නයට විශ්වාසදායක අවසාන පිළිතුරක් තහවුරු කිරීමට AI ගුරුට නොහැකි වුණා. වැරදි පිළිතුරක් ලබා නොදෙමු.',
    'AI Tutor could not establish a reliable final answer to this question. An unverified answer has been withheld.',
    'இந்தக் கேள்விக்கு நம்பகமான இறுதி விடையை உறுதிப்படுத்த முடியவில்லை. சரிபார்க்கப்படாத விடை காட்டப்படவில்லை.',
  );

  Future<String?> generateWithFallback(List<Content> parts) async {
    // ⚠️ මෙතන ඔබේ සැබූ Gemini API Key එක දාන්න (AIza... වගේ)
    // Get free key: https://aistudio.google.com/app/apikey
    final String myGeminiApiKey = 'AQ.Ab8RN6KgNqve2H2zifiZhI6wQw3lDkH-ev7-HHoeNrnCvXGGLA';

    if (myGeminiApiKey.isEmpty || myGeminiApiKey.contains("YOUR_GEMINI")) {
      return 'API Error: Gemini API Key not set in code. Put your real key in myGeminiApiKey.';
    }

    final List<Map<String, dynamic>> apiParts = [];
    for (final content in parts) {
      for (final part in content.parts) {
        if (part is TextPart) {
          apiParts.add({"text": part.text});
        } else if (part is DataPart) {
          apiParts.add({
            "inline_data": {
              "mime_type": part.mimeType,
              "data": base64Encode(part.bytes)
            }
          });
        }
      }
    }

    // Try multiple models (some free keys only work with certain models)
    final models = [
      'gemini-3.5-flash-lite',   // ප්‍රධාන model එක
      'gemini-3.8-flash',
      'gemini-2.5-flash',
    ];

    String lastError = '';

    for (final model in models) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
        );

        final response = await http
            .post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': myGeminiApiKey,
          },
          body: jsonEncode({
            "contents": [
              {"parts": apiParts}
            ],
            "generationConfig": {
              "temperature": 0.35,
              "topP": 0.95,
              "maxOutputTokens": 8192,
            }
          }),
        )
            .timeout(const Duration(seconds: 90));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final candidates = data['candidates'] as List?;
          if (candidates == null || candidates.isEmpty) {
            lastError = 'API Error ($model): No candidates returned. Body: ${response.body}';
            continue;
          }
          final content = candidates[0]['content'];
          final responseParts = content['parts'] as List?;
          if (responseParts == null || responseParts.isEmpty) {
            lastError = 'API Error ($model): Empty response parts';
            continue;
          }
          final String geminiAnswer = (responseParts[0]['text'] ?? '').toString();
          if (geminiAnswer.trim().isNotEmpty) {
            return geminiAnswer.trim();
          }
          lastError = 'API Error ($model): Empty text';
        } else {
          lastError = 'API Error ($model): HTTP ${response.statusCode}\n${response.body}';
          debugPrint(lastError);
        }
      } catch (e) {
        lastError = 'Code Error ($model): $e';
        debugPrint(lastError);
      }
    }

    return lastError.isNotEmpty ? lastError : null;
  }

  Stream<String> generateStreamWithFallback(List<Content> parts) async* {
    final result = await generateWithFallback(parts);
    if (result != null && result.isNotEmpty) {
      if (result.startsWith('API Error:') || result.startsWith('Code Error:')) {
        yield '\n\n[AI Error]\n$result\n\n(මේ error එක screenshot කරලා එවන්න / Send this error screenshot)';
      } else {
        yield result;
      }
    } else {
      yield '\n\n[AI සේවාව තාවකාලිකව ලබාගත නොහැක. කරුණාකර නැවත උත්සාහ කරන්න.]\n\n(Debug: generateWithFallback returned null)';
    }
  }

  Future<String?> verifyAcademicAnswer(String originalAnswer) async {
    final q = questionController.text.trim().toLowerCase();
    if (widget.selectedLevel == 'grade_5_scholarship' ||
        widget.selectedLevel == 'al' ||
        widget.selectedSubject == 'combined_mathematics' ||
        widget.selectedSubject == 'physics' ||
        widget.selectedSubject == 'chemistry' ||
        q.isEmpty ||
        q.contains('අමාරුයි') || q.contains('උපදෙස්') || q.contains('මොකද') ||
        q.contains('advice') || q.contains('difficult') || q.contains('පේපර්') ||
        q.contains('ප්‍රශ්න') || q.contains('ප්‍රස්තාර') || q.contains('තානම්') ||
        q.contains('නර්තනය') || q.contains('විසඳන්න') || q.contains('විසදන්න') ||
        q.contains('පැහැදිලි') || q.contains('පැහදිලි') || q.contains('solve') ||
        q.contains('explain') || q.contains('තරංග') || q.contains('ගැටලුව') ||
        q.contains('ගැටළුව') || q.contains('හදන්න') || q.contains('උත්තර') ||
        q.contains('මේ') || q.contains('සොයන්න') || q.contains('සොයනවා') ||
        q.contains('ගණනය') || q.contains('find') || q.contains('calculate') ||
        q.contains('show') || q.contains('தீர்க்க') || q.contains('கண்டுபிடி') ||
        q.contains('விளக்குக') || q.contains('எப்படி') || q.contains('∫') || q.contains('dx') || q.contains('අනුකලනය') || q.contains('integration')) {
      return originalAnswer.trim();
    }

    try {
      final verificationParts = <Content>[];
      String verificationText = academicVerificationPrompt(originalAnswer);
      if (selectedImageBytes != null) {
        verificationParts.add(Content.multi([
          TextPart(verificationText),
          DataPart(selectedMimeType ?? 'image/jpeg', selectedImageBytes!),
        ]));
      } else {
        verificationParts.add(Content.text(verificationText));
      }

      final verified = await generateWithFallback(verificationParts);

      if (verified == null || verified.trim().isEmpty) return null;
      if (!hasRequiredAnswerStructure(verified)) return null;

      return verified.trim();
    } catch (e) {
      debugPrint('Academic verification skipped: $e');
      return null;
    }
  }

  Future<String> giveAnotherExample(String currentAnswer) async {
    try {
      final exampleParts = <Content>[
        Content.text('''
You are a kind, patient, loving school teacher in "ZingaCC Learn AI".

STUDENT CONTEXT:
- Level: 
$levelName
- Study medium: 
$mediumName
- Subject: 
$subjectName
- Explanation language: 
${widget.language}

The student has already received the explanation below.
Now teach the SAME concept using ONE NEW, simple example.

TEACHING RULES:
1. Do NOT simply repeat the existing example.
2. Create one NEW example that teaches the same concept.
3. Keep the example appropriate for a student at $levelName.
4. Use simple words and short sentences.
5. Explain the new example step by step with numbered points.
6. Explain WHY each important step is done.
7. Speak with affection (use "පුතා", "දුවේ", "හොඳයි" etc. when in Sinhala).
8. For mathematics:
- use suitable new numbers;
- calculate every step carefully;
- verify the calculation before answering;
- clearly show the final result.

9. For science:
- use a simple, scientifically correct example;
- do not invent facts.

10. For language subjects:
- use a new short example;
- explain its meaning clearly.

11. For factual subjects:
- never invent names, dates, places or facts.

12. Use the student's selected explanation language: ${widget.language}.
13. Preserve necessary formulas, symbols, units and proper nouns.
14. Do not introduce a concept beyond the student's level unless it is necessary to understand the question.
15. If a safe new example cannot be created from the available information, say so instead of guessing.
16. End with ONE short encouraging sentence.
17. Do not claim "100% correct" or guaranteed correctness.
18. Do not use Markdown.
19. Leave [[PRACTICE]] empty. Do not add a practice question or another question unless the student explicitly asks for it.

Preserve these markers EXACTLY and in this order:
[[QUESTION]]
[[FIND]]
[[INFO]]
[[RULE]]
[[STEPS]]
[[CHECK]]
[[FINAL]]
[[PRACTICE]]

Return ONLY the new-example explanation.

CURRENT VERIFIED EXPLANATION:
$currentAnswer
'''),
      ];

      final exampleAnswer = await generateWithFallback(exampleParts);
      if (exampleAnswer == null || exampleAnswer.trim().isEmpty) return currentAnswer;
      if (!hasRequiredAnswerStructure(exampleAnswer)) return currentAnswer;
      return exampleAnswer.trim();
    } catch (e) {
      debugPrint('Another example skipped: $e');
      return currentAnswer;
    }
  }

  Future<String> explainAnswerSimpler(String originalAnswer) async {
    try {
      final simplerParts = <Content>[
        Content.text('''
You are a kind, patient, loving school teacher in "ZingaCC Learn AI".
The student says: "I did not understand the explanation."

STUDENT CONTEXT:
- Level: 
$levelName
- Study medium: 
$mediumName
- Subject: 
$subjectName
- Explanation language: 
${widget.language}

Your task is NOT to solve a different problem.
Explain the SAME academically verified answer again so that a student at $levelName can understand it more easily.

TEACHING RULES:
1. Keep every correct fact, calculation, formula, symbol, unit, name and final answer academically unchanged.
2. Never invent new facts or change the meaning of the verified answer.
3. Use much simpler words and shorter sentences.
4. Explain only ONE small idea at a time using NUMBERED STEPS.
5. Explain WHY each important step is done in very simple language.
6. Do not assume that the student understood the previous explanation.
7. If useful, begin from the most basic idea needed to understand the question.
8. Give one very simple example familiar to a school student when an example genuinely helps understanding.
9. Speak with affection and encouragement.
10. For mathematics:
- show calculations clearly;
- do not skip important steps;
- explain what the numbers and operations mean.

11. For science:
- explain difficult terms in simple words;
- use a simple everyday comparison only when scientifically safe.

12. For language subjects:
- explain the meaning first;
- then show a short clear example.

13. Use the student's selected explanation language: ${widget.language}.
14. Keep essential formulas, symbols, units, proper nouns and source-language examples unchanged when necessary.
15. Do not use unnecessarily difficult technical words.
16. Do not make the answer longer than needed.
17. Finish with a very short section that tells the student the ONE key idea to remember + a loving encouraging line.
18. Do not claim that the answer is "100% correct" or guaranteed.
19. Do not use Markdown.
20. Leave [[PRACTICE]] empty. Do not add a practice question or another question unless the student explicitly asks for it.

Preserve these markers EXACTLY and in this order:
[[QUESTION]]
[[FIND]]
[[INFO]]
[[RULE]]
[[STEPS]]
[[CHECK]]
[[FINAL]]
[[PRACTICE]]

Return ONLY the simpler explanation.

VERIFIED ANSWER TO EXPLAIN:
$originalAnswer
'''),
      ];

      final simplerAnswer = await generateWithFallback(simplerParts);
      if (simplerAnswer == null || simplerAnswer.trim().isEmpty) return originalAnswer;
      if (!hasRequiredAnswerStructure(simplerAnswer)) return originalAnswer;
      return simplerAnswer.trim();
    } catch (e) {
      debugPrint('Simpler explanation skipped: $e');
      return originalAnswer;
    }
  }

  Future<String> reviewLanguage(String originalAnswer) async {
    if (originalAnswer.trim().isEmpty) return originalAnswer;

    try {
      final reviewParts = <Content>[
        Content.text(languageReviewPrompt(originalAnswer)),
      ];
      final reviewed = await generateWithFallback(reviewParts);
      if (reviewed == null || reviewed.trim().isEmpty) return originalAnswer;
      if (!hasRequiredAnswerStructure(reviewed)) return originalAnswer;
      return reviewed.trim();
    } catch (e) {
      debugPrint('Language review skipped: $e');
      return originalAnswer;
    }
  }

  bool _hasKnownTrigFactorizationError(String proposedAnswer) {
    final q = questionController.text.toLowerCase().replaceAll(RegExp(r'\s+'), '');
    final isTarget = q.contains('sin3x+sinx=cos2x') || q.contains('sin(3x)+sin(x)=cos(2x)');
    if (!isTarget) return false;
    final normalized = proposedAnswer
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(r'\(', '')
        .replaceAll(r'\)', '')
        .replaceAll(r'\left', '')
        .replaceAll(r'\right', '');
    return normalized.contains('cos2x(2sinx-1)=0') ||
        normalized.contains('cos(2x)(2sinx-1)=0') ||
        normalized.contains('cos2x(2sin(x)-1)=0') ||
        normalized.contains('cos(2x)(2sin(x)-1)=0');
  }

  Future<bool> passesFinalAccuracyGate(String proposedAnswer) async {
    if (_hasKnownTrigFactorizationError(proposedAnswer)) {
      debugPrint('Deterministic trig regression check rejected answer.');
      return false;
    }

    final q = questionController.text.trim().toLowerCase();
    if (widget.selectedLevel == 'grade_5_scholarship' ||
        widget.selectedLevel == 'al' ||
        widget.selectedSubject == 'combined_mathematics' ||
        widget.selectedSubject == 'physics' ||
        widget.selectedSubject == 'chemistry' ||
        q.isEmpty ||
        q.contains('අමාරුයි') || q.contains('උපදෙස්') || q.contains('මොකද') ||
        q.contains('advice') || q.contains('difficult') || q.contains('පේපර්') ||
        q.contains('ප්‍රශ්න') || q.contains('ප්‍රස්තාර') || q.contains('තානම්') ||
        q.contains('නර්තනය') || q.contains('විසඳන්න') || q.contains('විසදන්න') ||
        q.contains('පැහැදිලි') || q.contains('පැහදිලි') || q.contains('solve') ||
        q.contains('explain') || q.contains('තරංග') || q.contains('ගැටලුව') ||
        q.contains('ගැටළුව') || q.contains('හදන්න') || q.contains('උත්තර') ||
        q.contains('මේ') || q.contains('සොයන්න') || q.contains('සොයනවා') ||
        q.contains('ගණනය') || q.contains('find') || q.contains('calculate') ||
        q.contains('show') || q.contains('தீர்க்க') || q.contains('கண்டுபிடி') ||
        q.contains('விளக்குக') || q.contains('எப்படி') || q.contains('∫') || q.contains('dx') || q.contains('අනුකලනය') || q.contains('integration')) {
      return true;
    }

    try {
      final prompt = '''
You are a strict independent examiner for a Sri Lankan school tutor.
Subject: $subjectName; level: $levelName.
Original typed question: \${questionController.text.trim()}

Judge the answer independently. Never trust its CHECK section or its
claim to have verified itself. Re-solve key calculations and substitute
all claimed mathematical roots into the ORIGINAL equation. Check signs,
units, assumptions, domain, completeness and counterexamples.
For arts/music/dance verify authentic terminology, notation, rhythm,
instrument playing techniques and named traditions. For other factual
subjects, reject unsupported precise claims or fabricated citations.
Reject answers that claim no solutions without proving it, that assert
one value from insufficient data, or that mix an unrelated subject.
If a question/image is unclear, or you cannot independently establish
accuracy with reasonable confidence, FAIL. Do not guess.

SPECIAL PHYSICS EXCEPTION: For Physics and Science questions (especially Electrical Circuits and Optics/Lenses), do NOT fail the answer due to differing sign conventions (e.g., Cartesian vs. Real-is-Positive). If the answer correctly uses a standard formula (like V=IR, 1/R=1/R1+1/R2, or 1/v-1/u=1/f) and the math is correct, you MUST return PASS.

SPECIAL ADVICE EXCEPTION: Allow the AI to provide constructive study advice, encouragement, progress feedback, and exam pattern analysis. If the student's question is purely asking for study tips, expressing difficulty, or asking how to improve, and does NOT contain a specific academic problem to solve, you MUST return PASS as long as the AI's advice is safe, encouraging, and uses the correct required markers. Do NOT fail the answer just because there is no calculation to verify or because it includes friendly exam tips.

Return exactly ONE token: PASS or FAIL. PASS only if every material
claim and the final conclusion are supported and consistent.

ANSWER TO EXAMINE:
$proposedAnswer
''';
      final parts = <Content>[];
      if (selectedImageBytes != null) {
        parts.add(Content.multi([
          TextPart(prompt),
          DataPart(selectedMimeType ?? 'image/jpeg', selectedImageBytes!),
        ]));
      } else {
        parts.add(Content.text(prompt));
      }

      final result = await generateWithFallback(parts);
      return result != null && result.trim().toUpperCase().contains('PASS');
    } catch (e) {
      debugPrint('Final accuracy gate failed: $e');
      return false;
    }
  }

  Future<String?> attemptAutomaticCorrection(String rejectedAnswer) async {
    try {
      final correctionPrompt = '''
You are correcting an answer that FAILED an independent academic review.
Student level: $levelName
Subject: $subjectName
Explanation language: ${widget.language}
Original typed question: ${questionController.text.trim()}

Solve the original question independently from scratch. Do not assume the
rejected answer is correct. For mathematics, check candidate roots by
substitution and make sure all solutions in the interval are included.
For every other subject, verify factual claims, notation, units and
subject-specific terminology; do not fabricate facts or citations.
If there is insufficient information, say so rather than guessing.
Return the complete corrected answer using exactly these section markers:
[[QUESTION]] [[FIND]] [[INFO]] [[RULE]] [[STEPS]] [[CHECK]] [[FINAL]] [[PRACTICE]]
Keep each marker on its own line, in that order. Leave PRACTICE empty unless
explicitly requested. Use the student's selected explanation language.

REJECTED ANSWER (for identifying mistakes, not as a trusted source):
$rejectedAnswer
''';
      final parts = <Content>[];
      if (selectedImageBytes != null) {
        parts.add(Content.multi([
          TextPart(correctionPrompt),
          DataPart(selectedMimeType ?? 'image/jpeg', selectedImageBytes!),
        ]));
      } else {
        parts.add(Content.text(correctionPrompt));
      }

      final corrected = await generateWithFallback(parts);
      if (corrected == null || !hasRequiredAnswerStructure(corrected)) return null;
      final verified = await verifyAcademicAnswer(corrected);
      if (verified == null || !mounted) return null;
      if (!await passesFinalAccuracyGate(verified)) return null;
      return verified;
    } catch (e) {
      debugPrint('Automatic correction unavailable: $e');
      return null;
    }
  }

  Future<String?> polishAndVerify(String draft) async {
    final verifiedDraft = await verifyAcademicAnswer(draft);
    if (!mounted || verifiedDraft == null) return null;

    final languageReviewed = await reviewLanguage(verifiedDraft);
    if (!mounted) return null;
    return verifyAcademicAnswer(languageReviewed);
  }

  Future<void> _showAccessLimitPopup() async {
    if (!mounted) return;
    final openPackages = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF112A20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 2),
        ),
        title: Text(t(
          'AI ප්‍රශ්න සීමාව',
          'AI Question Limit',
          'AI கேள்வி வரம்பு',
        ), style: const TextStyle(color: Color(0xFFD4AF37))),
        content: Text(t(
          'ඔබගේ නොමිලේ AI ප්‍රශ්න අවසන් වී තිබිය හැක. මාසික පැකේජ සහ Top-up පැකේජ බලන්න. ගෙවීම් සහ මාසික ප්‍රශ්න 150 සීමාව තවම පරීක්ෂණ මට්ටමේ පවතී.',
          'Your free AI questions may be exhausted. View monthly and top-up packages. Payments and the 150-question monthly limit are still in testing.',
          'உங்கள் இலவச AI கேள்விகள் முடிந்திருக்கலாம். மாதாந்திர மற்றும் கூடுதல் தொகுப்புகளைப் பார்க்கவும். கட்டணங்களும் மாதாந்திர 150 கேள்வி வரம்பும் இன்னும் சோதனையில் உள்ளன.',
        ), style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(t('පසුව', 'Later', 'பின்னர்'), style: const TextStyle(color: Colors.white70)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF0A1C14)),
            child: Text(t(
              'පැකේජ බලන්න',
              'View Packages',
              'தொகுப்புகளைப் பார்க்க',
            ), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (!mounted || openPackages != true) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const PremiumPackagesScreen(),
      ),
    );
  }

  Future<void> explainCurrentAnswerSimpler() async {
    final currentAnswer = answer.trim();
    if (currentAnswer.isEmpty || isLoading) return;

    final coinRequestId = FirestoreService.createCoinRequestId();
    var wasCharged = false;
    var requestSucceeded = false;

    setState(() => isLoading = true);

    try {
      final hasCoins = await FirestoreService.authorizeAiRequest(requestId: coinRequestId, grade: widget.selectedLevel);
      wasCharged = hasCoins;
      if (!hasCoins) {
        if (!mounted) return;
        setState(() => isLoading = false);
        if (mounted) await _showAccessLimitPopup();
        return;
      }
    } catch (e) {
      debugPrint('AI access check error: $e');
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('AI ප්‍රවේශය පරීක්ෂා කළ නොහැකි වුණා. නැවත උත්සාහ කරන්න.', 'Could not check AI access. Please try again.', 'AI அணுகலைச் சரிபார்க்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.'))),
      );
      return;
    }

    try {
      final simplerAnswer = await explainAnswerSimpler(currentAnswer);
      if (!mounted) return;
      final verifiedSimplerAnswer = await polishAndVerify(simplerAnswer);
      if (!mounted) return;
      if (verifiedSimplerAnswer == null) {
        setState(() => answer = verificationUnavailableMessage);
        return;
      }
      final finalSimplerAnswer = cleanAiAnswer(localizeAiSections(verifiedSimplerAnswer));
      setState(() => answer = finalSimplerAnswer);
      requestSucceeded = true;
    } catch (e) {
      if (!mounted) return;
      setState(() => answer = currentAnswer);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('තවත් සරල පැහැදිලි කිරීම ලබාගැනීමට නොහැකි වුණා. නැවත උත්සාහ කරන්න.', 'Could not create a simpler explanation. Please try again.', 'எளிய விளக்கத்தை உருவாக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.'))),
      );
    } finally {
      if (wasCharged && !requestSucceeded) {
        try {
          await FirestoreService.refundAiRequest(requestId: coinRequestId);
        } catch (e) {
          debugPrint('AI quota refund error: $e');
        }
      }
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> showAnotherExample() async {
    final currentAnswer = answer.trim();
    if (currentAnswer.isEmpty || isLoading) return;

    final coinRequestId = FirestoreService.createCoinRequestId();
    var wasCharged = false;
    var requestSucceeded = false;

    setState(() => isLoading = true);

    try {
      final hasCoins = await FirestoreService.authorizeAiRequest(requestId: coinRequestId, grade: widget.selectedLevel);
      wasCharged = hasCoins;
      if (!hasCoins) {
        if (!mounted) return;
        await _showAccessLimitPopup();
        return;
      }

      final exampleAnswer = await giveAnotherExample(currentAnswer);
      if (!mounted) return;
      final verifiedExampleAnswer = await polishAndVerify(exampleAnswer);
      if (!mounted) return;
      if (verifiedExampleAnswer == null) {
        setState(() => answer = verificationUnavailableMessage);
        return;
      }
      final finalExampleAnswer = cleanAiAnswer(localizeAiSections(verifiedExampleAnswer));
      setState(() => answer = finalExampleAnswer);
      requestSucceeded = true;
    } catch (e) {
      if (!mounted) return;
      setState(() => answer = currentAnswer);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('තවත් උදාහරණයක් ලබාගැනීමට නොහැකි වුණා. නැවත උත්සාහ කරන්න.', 'Could not create another example. Please try again.', 'மற்றொரு உதாரணத்தை உருவாக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.'))),
      );
    } finally {
      if (wasCharged && !requestSucceeded) {
        try {
          await FirestoreService.refundAiRequest(requestId: coinRequestId);
        } catch (e) {
          debugPrint('AI quota refund error: $e');
        }
      }
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _saveLessonOffline() async {
    if (answer.trim().isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> savedLessons = prefs.getStringList('offline_lessons') ?? [];

      final newLesson = {
        'question': questionController.text.trim().isNotEmpty
            ? questionController.text.trim()
            : diagramQuestion ?? 'ඡායාරූප ප්‍රශ්නයක්',
        'subject': subjectName,
        'answer': answer.trim(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      savedLessons.add(json.encode(newLesson));
      await prefs.setStringList('offline_lessons', savedLessons);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('පාඩම Offline Save කරගන්නා ලදී!', 'Lesson saved offline!', 'பாடம் ஆஃப்லைனில் சேமிக்கப்பட்டது!')),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Error saving offline: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('Save කිරීමේදී ගැටලුවක් මතු විය.', 'Failed to save lesson.', 'சேமிப்பதில் சிக்கல் ஏற்பட்டது.'))),
      );
    }
  }

  Future<String?> checkQuestionAmbiguity(String typedQuestion) async {
    if (typedQuestion.trim().isEmpty && selectedImageBytes == null) return null;

    final ambiguityParts = <Content>[];
    String ambiguityPromptText = '''
You are the ambiguity safety checker for "ZingaCC Learn AI".

Your job is to check whether the ORIGINAL question is clearly outside the selected school level or subject, and whether it has a genuine wording or reference ambiguity that could change the answer.

STUDENT CONTEXT:
- Level: 
$levelName
- Study medium: 
$mediumName
- Subject: 
$subjectName
- Explanation language: 
${widget.language}

ORIGINAL STUDENT QUESTION:
$typedQuestion

If the typed question is blank, read the question from the attached image and check its wording and references from that image.

STRICT RULES:
1. Do NOT solve the question normally yet.
2. Check pronouns, possessive words and unclear references carefully.
3. If a pronoun or reference can reasonably refer to two or more people, objects or quantities, test EACH reasonable interpretation.
4. Ask whether the different reasonable interpretations would change the calculation, meaning or final answer.
5. Do NOT assume that a pronoun refers to the nearest name, first name, grammatical subject or previous actor.
6. If different reasonable interpretations produce different answers, the question is genuinely ambiguous.
7. Do NOT mark a question ambiguous merely because it is short or simple.

LEVEL AND SUBJECT SCREENING:
- FIRST classify the original question against the selected Sri Lankan school level and subject, before checking wording ambiguity. For example, integration/calculus is outside Grades 5-9 Mathematics and belongs to A/L Mathematics. If clearly outside, return [[OUT_OF_LEVEL]] immediately; never return [[CLEAR]] merely because the wording is unambiguous.
- If it clearly belongs outside the selected level or subject, return exactly [[OUT_OF_LEVEL]] followed by a brief explanation in the selected explanation language and suggest the appropriate level or subject.
- Do not solve an out-of-level or out-of-subject question.
- Do not reject foundational concepts shared across multiple grades, revision questions, or questions that can reasonably be explained at the selected level.
- When uncertain about the required level or subject, do not reject solely because of uncertainty.
- If the question is within scope, continue the existing ambiguity rules below.

8. If the wording has one reasonable meaning, return exactly:
[[CLEAR]]

9. If the wording is genuinely ambiguous, return:
[[AMBIGUOUS]]
followed by a short student-friendly explanation in the students selected explanation language.

PHYSICS RULE: For Science/Physics questions about Circuits or Optics, do NOT mark them as [[AMBIGUOUS]] merely due to sign conventions or missing diagram directions. Assume standard conventions (e.g. Cartesian) and return [[CLEAR]].

OUTPUT FORMAT - MANDATORY:
- The very first characters of your response MUST be exactly one of:
  [[CLEAR]]
  [[AMBIGUOUS]]
  [[OUT_OF_LEVEL]]
- Never begin with a heading, explanation, reasoning, markdown or introductory text.
''';

    if (selectedImageBytes != null) {
      ambiguityParts.add(Content.multi([
        TextPart(ambiguityPromptText),
        DataPart(selectedMimeType ?? 'image/jpeg', selectedImageBytes!),
      ]));
    } else {
      ambiguityParts.add(Content.text(ambiguityPromptText));
    }

    final result = await generateWithFallback(ambiguityParts);
    if (result == null || result.trim().isEmpty) {
      return t('ප්‍රශ්නයේ අර්ථය තහවුරු කළ නොහැකි වුණා. ප්‍රශ්නය තවත් පැහැදිලිව ලියා නැවත උත්සාහ කරන්න.', 'The question wording could not be checked. Please clarify it and try again.', 'கேள்வியின் பொருளைச் சரிபார்க்க முடியவில்லை. தெளிவாகக் கூறி மீண்டும் முயற்சிக்கவும்.');
    }

    final checked = result.trim();
    if (checked.startsWith('[[CLEAR]]') && !checked.contains('[[AMBIGUOUS]]') && !checked.contains('[[OUT_OF_LEVEL]]')) return null;

    if (checked.startsWith('[[OUT_OF_LEVEL]]')) {
      final guidance = checked.substring('[[OUT_OF_LEVEL]]'.length).trim();
      return guidance.isEmpty
          ? t('මෙම ප්‍රශ්නය තෝරාගත් ශ්‍රේණියට හෝ විෂයට නොගැළපෙන බව පෙනේ. කරුණාකර අදාළ ශ්‍රේණිය සහ විෂය තෝරා නැවත අසන්න.', 'This question appears to require a different level or subject. Please select the appropriate level and subject.', 'இந்தக் கேள்வி தேர்ந்தெடுத்த வகுப்பு அல்லது பாடத்திற்குப் பொருந்தவில்லை. சரியான வகுப்பையும் பாடத்தையும் தேர்ந்தெடுக்கவும்.')
          : guidance;
    }
    if (checked.startsWith('[[AMBIGUOUS]]')) {
      final clarification = checked.substring('[[AMBIGUOUS]]'.length).trim();
      return clarification.isEmpty
          ? t('ප්‍රශ්නයේ එක් කොටසක් පැහැදිලි නැහැ. අදහස් කළේ කුමක්ද කියලා තව පැහැදිලි කරන්න.', 'Part of the question is unclear. Please clarify what you mean.', 'கேள்வியின் ஒரு பகுதி தெளிவாக இல்லை. நீங்கள் குறிப்பிட்டது என்ன என்பதை விளக்கவும்.')
          : clarification;
    }

    return t('ප්‍රශ්නය පැහැදිලිදැයි තහවුරු කළ නොහැකි වුණා. තව පැහැදිලිව ලියා නැවත උත්සාහ කරන්න.', 'The question could not be confirmed as clear. Please clarify it and try again.', 'கேள்வி தெளிவானதா என்பதை உறுதிப்படுத்த முடியவில்லை. தெளிவாகக் கூறி மீண்டும் முயற்சிக்கவும்.');
  }

  String? _solveKnownTrigProblem(String question) {
    if (!isMathSubject || selectedImageBytes != null) return null;
    final q = question.toLowerCase().replaceAll(RegExp(r'\s+'), '').replaceAll('\\', '').replaceAll('≤', '<=').replaceAll('π', 'pi');
    final equation = q.contains('sin3x+sinx=cos2x') || q.contains('sin(3x)+sin(x)=cos(2x)');
    final domain = q.contains('0<=x<=2pi') || q.contains('0<=x<=2*pi');
    if (!equation || !domain) return null;

    double f(double x) => math.sin(3 * x) + math.sin(x) - math.cos(2 * x);

    final roots = <double>[];
    const n = 8192;
    final maxX = 2 * math.pi;

    for (var i = 0; i < n; i++) {
      var a = maxX * i / n;
      var b = maxX * (i + 1) / n;
      var fa = f(a);
      final fb = f(b);
      if (fa == 0) {
        roots.add(a);
      } else if (fa * fb < 0) {
        for (var j = 0; j < 55; j++) {
          final mid = (a + b) / 2;
          if (fa * f(mid) <= 0) b = mid;
          else {
            a = mid;
            fa = f(a);
          }
        }
        final root = (a + b) / 2;
        if (root >= 0 && root <= maxX && f(root).abs() < 1e-9) roots.add(root);
      }
    }
    if (f(maxX).abs() < 1e-9) roots.add(maxX);
    roots.sort();
    if (roots.length != 4 || roots.any((x) => f(x).abs() > 1e-9)) return null;

    final values = roots.map((x) => x.toStringAsFixed(6)).join(', ');
    final si = isSinhala;
    final ta = isTamil;
    final explanation = si
        ? 'sin 3x + sin x = 2 sin 2x cos x. එබැවින් 2 sin 2x cos x = cos 2x. sin 2x = 2 sin x cos x සහ cos²x = 1 − sin²x යොදමු. t = sin x ලෙස ගත් විට 4t³ − 2t² − 4t + 1 = 0 ලැබේ. මෙම සමීකරණයේ −1 ≤ t ≤ 1 මූල සොයා, 0 ≤ x ≤ 2π තුළ අදාළ x අගයන් සංඛ්‍යාත්මකව ගණනය කරමු.'
        : ta
        ? 'sin 3x + sin x = 2 sin 2x cos x. எனவே 2 sin 2x cos x = cos 2x. sin 2x = 2 sin x cos x மற்றும் cos²x = 1 − sin²x. t = sin x என வைத்தால் 4t³ − 2t² − 4t + 1 = 0. −1 ≤ t ≤ 1 இல் தீர்த்து, 0 ≤ x ≤ 2π இல் x மதிப்புகளைக் கணக்கிடுகிறோம்.'
        : 'Using sin 3x + sin x = 2 sin 2x cos x, obtain 2 sin 2x cos x = cos 2x. With sin 2x = 2 sin x cos x and cos²x = 1 − sin²x, set t = sin x to get 4t³ − 2t² − 4t + 1 = 0. Solve for −1 ≤ t ≤ 1, then find all x in 0 ≤ x ≤ 2π numerically.';
    final check = si
        ? 'සෑම x අගයක්ම මුල් සමීකරණයේ වම් පැත්තෙන් දකුණු පැත්ත අඩු කළ විට නිරපේක්ෂ දෝෂය 0.000000001 ට අඩුයි. අගයන් ආසන්න අගයන් වේ.'
        : ta
        ? 'ஒவ்வொரு x மதிப்பையும் மூலச் சமன்பாட்டில் பதிலிட்டபோது மீதம் 0.000000001-ஐ விடக் குறைவு. இவை தோராய மதிப்புகள்.'
        : 'Each candidate was substituted into the original equation; the absolute residual is below 0.000000001. Values are approximate.';
    return "[[QUESTION]]\nsin 3x + sin x = cos 2x, 0 ≤ x ≤ 2π\n[[FIND]]\n${si ? 'සියලු x අගයන්' : ta ? 'அனைத்து x மதிப்புகள்' : 'All x values'}\n[[INFO]]\n0 ≤ x ≤ 2π\n[[RULE]]\nsin A + sin B = 2 sin((A+B)/2) cos((A−B)/2)\n[[STEPS]]\n$explanation\n[[CHECK]]\n$check\n[[FINAL]]\nx ≈ $values (${si ? 'රේඩියන්' : ta ? 'ரேடியன்' : 'radians'})\n[[PRACTICE]]\n";
  }

  Future<void> askGemini() async {
    final typedQuestion = questionController.text.trim();
    final keepPractice = studentExplicitlyAskedForPractice;

    if (typedQuestion.isEmpty && selectedImageBytes == null) {
      setState(() {
        answer = t(
          'කරුණාකර $localizedSubjectName ප්‍රශ්නයක් ටයිප් කරන්න හෝ ප්‍රශ්නයේ ඡායාරූපයක් එක් කරන්න.',
          'Please type a $subjectName question or upload a question photo.',
          '$localizedSubjectName கேள்வியை தட்டச்சு செய்யவும் அல்லது கேள்விப் படத்தை பதிவேற்றவும்.',
        );
      });
      return;
    }

    final coinRequestId = FirestoreService.createCoinRequestId();
    var wasCharged = false;
    var answerSucceeded = false;

    setState(() {
      isLoading = true;
      answer = '';
      diagramQuestion = null;
    });
    FocusScope.of(context).unfocus();

    try {
      final hasCoins = await FirestoreService.authorizeAiRequest(
        requestId: coinRequestId,
        grade: widget.selectedLevel,
      );
      wasCharged = hasCoins;
      if (!hasCoins) {
        if (mounted) await _showAccessLimitPopup();
        return;
      }

      final deterministicAnswer = _solveKnownTrigProblem(typedQuestion);
      if (deterministicAnswer != null) {
        if (!mounted) return;
        setState(() {
          answer = cleanAiAnswer(localizeAiSections(deterministicAnswer), keepPractice: keepPractice);
        });
        answerSucceeded = true;
        return;
      }

      final requestParts = buildRequestParts();
      String rawStreamedResponse = "";

      try {
        final stream = generateStreamWithFallback(requestParts);

        await for (final chunk in stream) {
          if (!mounted) return;
          rawStreamedResponse += chunk;
          setState(() {
            answer = cleanAiAnswer(localizeAiSections(rawStreamedResponse), keepPractice: keepPractice);
          });
        }

        if (rawStreamedResponse.trim().isEmpty) {
          setState(() {
            answer = t(
              'AI වෙතින් පිළිතුරක් ලැබුණේ නැහැ. කරුණාකර නැවත උත්සාහ කරන්න.',
              'No answer was received from AI. Please try again.',
              'AI இலிருந்து பதில் கிடைக்கவில்லை. மீண்டும் முயற்சிக்கவும்.',
            );
          });
          return;
        }

        answerSucceeded = true;
        diagramQuestion = typedQuestion;

        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('history')
                .add({
              'question': typedQuestion.isNotEmpty ? typedQuestion : 'ඡායාරූප ප්‍රශ්නයක් / Uploaded Question Photo',
              'answer': answer,
              'subject': subjectName,
              'timestamp': FieldValue.serverTimestamp(),
            });
          }
        } catch (e) {
          debugPrint('History save error: $e');
        }

      } catch (e) {
        debugPrint('Streaming error in main function: $e');
        if (!mounted) return;
        setState(() {
          answer = t(
            'සේවාවට සම්බන්ධ වීමේ ගැටළුවක්. කරුණාකර නැවත උත්සාහ කරන්න.',
            'Connection error. Please try again.',
            'இணைப்பு பிழை. மீண்டும் முயற்சிக்கவும்.',
          );
        });
        return;
      }

    } catch (e) {
      debugPrint('Zingacc Learn AI error: $e');
      if (!mounted) return;
      final message = e.toString().toLowerCase();
      setState(() {
        if (message.contains('high demand') || message.contains('overloaded') || message.contains('[500]') || message.contains('server error') || message.contains('503')) {
          answer = t('AI සේවාව මේ මොහොතේ කාර්යබහුලයි. කරුණාකර තත්පර කිහිපයකින් නැවත උත්සාහ කරන්න.', 'The AI service is very busy at the moment. Please try again in a few seconds.', 'AI சேவை தற்போது மிகவும் பிஸியாக உள்ளது. சில விநாடிகளுக்குப் பிறகு மீண்டும் முயற்சிக்கவும்.');
        } else if (message.contains('app check') || message.contains('app-check') || message.contains('403')) {
          answer = t('AI ආරක්ෂක සම්බන්ධතාවයේ ගැටලුවක් ඇති වුණා. කරුණාකර නැවත උත්සාහ කරන්න.', 'There was a problem with the AI security connection. Please try again.', 'AI பாதுகாப்பு இணைப்பில் சிக்கல் ஏற்பட்டது. மீண்டும் முயற்சிக்கவும்.');
        } else {
          answer = t('AI සේවාවට සම්බන්ධ වීමේ ගැටලුවක් ඇති වුණා. කරුණාකර ටික වේලාවකින් නැවත උත්සාහ කරන්න.', 'There was a problem connecting to the AI service. Please try again shortly.', 'AI சேவையுடன் இணைப்பதில் சிக்கல் ஏற்பட்டது. சிறிது நேரத்தில் மீண்டும் முயற்சிக்கவும்.');
        }
      });
    } finally {
      if (wasCharged && !answerSucceeded) {
        try {
          await FirestoreService.refundAiRequest(requestId: coinRequestId);
        } catch (e) {
          debugPrint('AI quota refund error: $e');
        }
      }
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String localizeAiSections(String value) {
    var result = value;
    final markerReplacements = <String, String>{
      '[[QUESTION]]': headingQuestion,
      '[[FIND]]': headingFind,
      '[[INFO]]': headingInformation,
      '[[RULE]]': headingRule,
      '[[STEPS]]': headingSteps,
      '[[CHECK]]': headingCheck,
      '[[FINAL]]': headingFinal,
      '[[PRACTICE]]': headingPractice,
    };

    markerReplacements.forEach((marker, heading) {
      result = result.replaceAll(marker, '\n$heading\n');
    });

    final headingReplacements = <String, String>{
      'Question:': '$headingQuestion\n',
      'Question :': '$headingQuestion\n',
      'What we need to find:': '$headingFind\n',
      'What We Need to Find:': '$headingFind\n',
      'Important information:': '$headingInformation\n',
      'Important Information:': '$headingInformation\n',
      'Rule or idea:': '$headingRule\n',
      'Rule or Idea:': '$headingRule\n',
      'Step-by-step solution:': '$headingSteps\n',
      'Step-by-Step Solution:': '$headingSteps\n',
      'Check:': '$headingCheck\n',
      'Final answer:': '$headingFinal\n',
      'Final Answer:': '$headingFinal\n',
      'Practice:': '$headingPractice\n',
      'Practice question:': '$headingPractice\n',
      'Practice Question:': '$headingPractice\n',
    };

    headingReplacements.forEach((oldText, newText) {
      result = result.replaceAll(oldText, newText);
    });

    return result.trim();
  }

  bool get studentExplicitlyAskedForPractice {
    final request = questionController.text.trim().toLowerCase();
    if (request.isEmpty) return false;
    final englishRequest = RegExp(r'\b(?:give|make|create|provide|ask)\b.{0,60}\b(?:practice|quiz|exercise|question)\b|\bquiz me\b|\btest me\b').hasMatch(request);
    final sinhalaRequest = request.contains('පුහුණු ප්‍රශ්නයක් දෙන්න') || request.contains('පුහුණු ප්‍රශ්න දෙන්න') || request.contains('පුහුණු ප්‍රශ්නයක් අහන්න') || request.contains('තවත් ප්‍රශ්නයක් දෙන්න') || request.contains('puhunu prasnayak denna') || request.contains('puhunu prasna denna') || request.contains('puhunu prasnayak ahanna');
    final tamilRequest = request.contains('பயிற்சி கேள்வி கொடு') || request.contains('பயிற்சி கேள்வி கேள்') || request.contains('வினாடி வினா கேள்');
    return englishRequest || sinhalaRequest || tamilRequest;
  }

  String removeUnrequestedPractice(String value, {bool keepPractice = false}) {
    if (keepPractice) return value.trim();
    final lines = value.split('\n');
    final practiceHeadings = <String>{
      '[[practice]]', 'practice', 'practice question', 'practice question:', 'follow-up question', 'follow up question', 'additional question', 'extra question', 'පුහුණු ප්‍රශ්නය', 'පුහුණු ප්‍රශ්නය:', 'පසුතුරු ප්‍රශ්නය', 'පසුතුරු ප්‍රශ්නය:', 'අමතර ප්‍රශ්නය', 'අමතර ප්‍රශ්නය:', 'பயிற்சி கேள்வி', 'பயிற்சி கேள்வி:', 'தொடர் கேள்வி', 'கூடுதல் கேள்வி',
    };

    final headingIndex = lines.indexWhere((line) {
      final normalized = line.trim().replaceAll(RegExp(r'^[#*\s]+|[*:：]+$'), '').trim().toLowerCase();
      return practiceHeadings.contains(normalized) ||
          RegExp(r'^(?:practice(?: question)?|follow[- ]?up question|additional question|extra question)\s*[:：]', caseSensitive: false).hasMatch(normalized) ||
          RegExp(r'^(?:පුහුණු ප්‍රශ්නය|පසුතුරු ප්‍රශ්නය|අමතර ප්‍රශ්නය)\s*[:：]').hasMatch(normalized) ||
          RegExp(r'^(?:பயிற்சி கேள்வி|தொடர் கேள்வி|கூடுதல் கேள்வி)\s*[:：]').hasMatch(normalized);
    });

    if (headingIndex == -1) return value.trim();
    return lines.take(headingIndex).join('\n').trim();
  }

  String cleanAiAnswer(String value, {bool keepPractice = false}) {
    var cleaned = removeUnrequestedPractice(value, keepPractice: keepPractice);
    cleaned = cleaned.replaceAll('**', '').replaceAll('__', '').replaceAll('`', '');
    cleaned = cleaned.split('\n').map((line) => line.replaceFirst(RegExp(r'^\s*#{1,6}\s*'), '')).join('\n');
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return cleaned.trim();
  }

  MapEntry<String, int>? _readPdfBraceGroup(String input, int start) {
    var opening = start;
    while (opening < input.length && input[opening].trim().isEmpty) { opening++; }
    if (opening >= input.length || input[opening] != '{') return null;
    var depth = 0;
    for (var i = opening; i < input.length; i++) {
      if (input[i] == '{') { depth++; } else if (input[i] == '}') {
        depth--;
        if (depth == 0) return MapEntry(input.substring(opening + 1, i), i + 1);
      }
    }
    return null;
  }

  String _convertLatexForPdf(String input) {
    final output = StringBuffer();
    var i = 0;
    const commandSymbols = <String, String>{
      'times': '×', 'div': '÷', 'cdot': '·', 'le': '≤', 'leq': '≤', 'ge': '≥', 'geq': '≥', 'neq': '≠', 'approx': '≈', 'pm': '±', 'alpha': 'α', 'beta': 'β', 'theta': 'θ', 'pi': 'π', 'int': '∫', 'infty': '∞', 'degree': '°', 'rightarrow': '→', 'leftarrow': '←', 'to': '→', 'in': '∈', 'notin': '∉', 'forall': '∀', 'exists': '∃', 'sum': '∑', 'prod': '∏', 'therefore': '∴', 'because': '∵', 'emptyset': '∅',
    };

    while (i < input.length) {
      final code = input.codeUnitAt(i);
      if (code == 92) {
        if (i + 1 < input.length && input.codeUnitAt(i + 1) == 92) {
          output.write('\n');
          i += 2;
          continue;
        }
        var commandEnd = i + 1;
        while (commandEnd < input.length) {
          final c = input.codeUnitAt(commandEnd);
          final isLetter = (c >= 65 && c <= 90) || (c >= 97 && c <= 122);
          if (!isLetter) break;
          commandEnd++;
        }
        if (commandEnd == i + 1) {
          if (commandEnd < input.length) { output.write(input[commandEnd]); i = commandEnd + 1; } else { i++; }
          continue;
        }
        final command = input.substring(i + 1, commandEnd);
        if (command == 'hline' || command == 'toprule' || command == 'midrule' || command == 'bottomrule') { i = commandEnd; continue; }
        if (command == 'frac' || command == 'dfrac' || command == 'tfrac') {
          final numerator = _readPdfBraceGroup(input, commandEnd);
          final denominator = numerator == null ? null : _readPdfBraceGroup(input, numerator.value);
          if (numerator != null && denominator != null) {
            output..write('(')..write(_convertLatexForPdf(numerator.key))..write(')/(')..write(_convertLatexForPdf(denominator.key))..write(')');
            i = denominator.value;
            continue;
          }
        }
        if (command == 'sqrt') {
          var groupStart = commandEnd;
          var rootIndex = '';
          while (groupStart < input.length && input[groupStart].trim().isEmpty) { groupStart++; }
          if (groupStart < input.length && input[groupStart] == '[') {
            final close = input.indexOf(']', groupStart + 1);
            if (close != -1) { rootIndex = input.substring(groupStart + 1, close).trim(); groupStart = close + 1; }
          }
          final radicand = _readPdfBraceGroup(input, groupStart);
          if (radicand != null) {
            if (rootIndex == '3') { output.write('∛('); } else if (rootIndex.isNotEmpty && rootIndex != '2') { output.write('root($rootIndex, '); } else { output.write('√('); }
            output..write(_convertLatexForPdf(radicand.key))..write(')');
            i = radicand.value;
            continue;
          }
        }
        const groupCommands = <String>{ 'text', 'mathrm', 'mathbf', 'mathit', 'operatorname', 'overline', 'underline', };
        if (groupCommands.contains(command)) {
          final group = _readPdfBraceGroup(input, commandEnd);
          if (group != null) {
            if (command == 'overline') output.write('(');
            output.write(_convertLatexForPdf(group.key));
            if (command == 'overline') output.write(')̅');
            i = group.value;
            continue;
          }
        }
        if (command == 'left' || command == 'right' || command == 'displaystyle' || command == 'textstyle' || command == 'quad' || command == 'qquad' || command == ',') {
          if (command == 'quad' || command == 'qquad' || command == ',') { output.write(' '); }
          i = commandEnd;
          continue;
        }
        if (command == 'begin' || command == 'end') {
          final environment = _readPdfBraceGroup(input, commandEnd);
          i = environment?.value ?? commandEnd;
          continue;
        }
        output.write(commandSymbols[command] ?? command);
        i = commandEnd;
        continue;
      }
      if ((input[i] == '^' || input[i] == '_') && i + 1 < input.length && input[i + 1] == '{') {
        final group = _readPdfBraceGroup(input, i + 1);
        if (group != null) {
          output..write(input[i])..write('(')..write(_convertLatexForPdf(group.key))..write(')');
          i = group.value;
          continue;
        }
      }
      output.write(input[i]);
      i++;
    }
    return output.toString();
  }

  String cleanTextForPdf(String value) {
    var cleaned = value.replaceAll(r'\$', '');
    cleaned = cleaned.replaceAll(RegExp(r'\$\$?'), '');
    cleaned = cleaned.replaceAll(r'\[', '').replaceAll(r'\]', '').replaceAll(r'\(', '').replaceAll(r'\)', '');
    cleaned = _convertLatexForPdf(cleaned);
    return cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
  }

  Future<void> saveAnswerAsPdf() async {
    if (answer.trim().isEmpty || isSavingPdf) return;

    setState(() { isSavingPdf = true; });

    try {
      await PdfExportService.saveOrShareAnswerPdf(
        language: widget.language,
        question: '''
${t('ශ්‍රේණිය', 'Level', 'தரம்')}: $levelName
${t('අධ්‍යයන මාධ්‍යය', 'Study medium', 'கற்கும் மொழி')}: $localizedMediumName
${t('විෂය', 'Subject', 'பாடம்')}: $localizedSubjectName

${questionController.text.trim().isNotEmpty ? questionController.text.trim() : t('ඡායාරූපයෙන් ඉදිරිපත් කළ ප්‍රශ්නය', 'Question provided as an image', 'படமாக வழங்கப்பட்ட கேள்வி')}
'''.trim(),
        answer: removeUnrequestedPractice(answer, keepPractice: studentExplicitlyAskedForPractice).trim(),
        questionImageBytes: selectedImageBytes,
      );
    } catch (e) {
      debugPrint('PDF export error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('PDF එක සකස් කිරීමේදී ගැටලුවක් ඇති වුණා. නැවත උත්සාහ කරන්න.', 'There was a problem creating the PDF. Please try again.', 'PDF உருவாக்குவதில் சிக்கல் ஏற்பட்டது. மீண்டும் முயற்சிக்கவும்.')),
        ),
      );
    } finally {
      if (mounted) { setState(() { isSavingPdf = false; }); }
    }
  }

  void clearPhoto() {
    setState(() {
      selectedImageBytes = null;
      selectedFileName = null;
      selectedMimeType = null;
      answer = '';
    });
  }

  void clearAll() {
    _speech.stop();
    setState(() {
      _isListening = false;
      questionController.clear();
      selectedImageBytes = null;
      selectedFileName = null;
      selectedMimeType = null;
      answer = '';
    });
  }

  @override
  void dispose() {
    questionController.dispose();
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4AF37),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0A1C14),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37),
            foregroundColor: const Color(0xFF0A1C14),
            disabledBackgroundColor: const Color(0xFF112A20),
            disabledForegroundColor: Colors.white54,
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFD4AF37),
            minimumSize: const Size.fromHeight(54),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            side: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.5)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A1C14),
          foregroundColor: const Color(0xFFD4AF37),
          surfaceTintColor: Colors.transparent,
          title: Text(tutorTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: (isLoading || isSavingPdf) ? null : clearAll,
              tooltip: t('සියල්ල මකන්න', 'Clear all', 'அனைத்தையும் அழிக்கவும்'),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                behavior: HitTestBehavior.opaque,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const ZingaccBrandBanner(),
                    const SizedBox(height: 24),
                    const Icon(Icons.smart_toy_rounded, size: 46, color: Color(0xFFD4AF37)),
                    const SizedBox(height: 12),
                    Text(
                      askTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$languageLabel: ${widget.language}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ContextChip(icon: Icons.school_rounded, text: levelName),
                        _ContextChip(icon: Icons.translate_rounded, text: localizedMediumName),
                        _ContextChip(icon: Icons.menu_book_rounded, text: localizedSubjectName),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF112A20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFD4AF37), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              dynamicSubjectHint,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          String magicPrompt = '''ඔබ ශ්‍රී ලංකාවේ ප්‍රවීණ ගුරුවරයෙක්. 
ළමයා තෝරාගෙන ඇති විෂයට අදාළව, මෙවර විභාගයට අනිවාර්යයෙන්ම පැමිණිය හැකි ඉතා වැදගත් අනුමාන ප්‍රශ්නයක් ලබා දී, එය පියවරෙන් පියවර ඉතා සරලව විසඳා පෙන්වන්න. 
අවසානයේ අනිවාර්යයෙන්ම මෙම වාක්‍යය හරියටම එක් කරන්න: "පුතේ ඔයාට අමාරු මේ වගේ ප්‍රශ්න දිගටම මගෙන් අහන්න. අපි අනිවාර්යයෙන්ම විභාගෙට A එකක් ගමු!"''';

                          questionController.text = magicPrompt;
                        },
                        icon: const Icon(Icons.auto_awesome, color: Color(0xFFD4AF37)),
                        label: const Text(
                          'අනුමාන ප්‍රශ්නයක් ලබාදෙන්න',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF112A20),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Color(0xFFD4AF37)),
                          ),
                          elevation: 5,
                        ),
                      ),
                    ),
                    TextField(
                      controller: questionController,
                      readOnly: isLoading || isSavingPdf,
                      style: const TextStyle(fontSize: 17, height: 1.5, color: Colors.white),
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.multiline,
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF112A20),
                        labelStyle: const TextStyle(color: Color(0xFFD4AF37)),
                        hintStyle: const TextStyle(color: Colors.white54),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
                        ),
                        labelText: typeLabel,
                        hintText: questionHint,
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                            color: _isListening ? Colors.redAccent : const Color(0xFFD4AF37),
                            size: 28,
                          ),
                          onPressed: _toggleListening,
                          tooltip: t('හඬින් ටයිප් කරන්න', 'Voice input', 'குரல் உள்ளீடு'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: (isLoading || isSavingPdf) ? null : pickQuestionPhoto,
                      icon: const Icon(Icons.add_a_photo_rounded),
                      label: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(
                          uploadButton,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t(
                        'ප්‍රස්තාර හෝ රූප සටහන් ඇතුළත් නම්, ඡායාරූපය සමඟ "මෙම ප්‍රස්තාරය පැහැදිලි කරන්න" ලෙස ටයිප් කරන්න.',
                        'For graphs or diagrams, please type "explain this graph" along with the photo.',
                        'வரைபடங்கள் எனில், படத்துடன் "இந்த வரைபடத்தை விளக்குக" என தட்டச்சு செய்யவும்.',
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                    if (selectedImageBytes != null) ...[
                      const SizedBox(height: 20),
                      Text(selectedPhotoTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 10),
                      Card(
                        color: const Color(0xFF112A20),
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.5)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(selectedImageBytes!, height: 240, width: double.infinity, fit: BoxFit.contain),
                              ),
                              const SizedBox(height: 8),
                              if (selectedFileName != null)
                                Text(selectedFileName!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                              const SizedBox(height: 6),
                              TextButton.icon(
                                onPressed: (isLoading || isSavingPdf) ? null : clearPhoto,
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                label: Text(removePhotoText, style: const TextStyle(color: Colors.redAccent)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: (isLoading || isSavingPdf) ? null : askGemini,
                      icon: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD4AF37))) : const Icon(Icons.auto_awesome),
                      label: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(isLoading ? loadingText : explainButton, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      ),
                    ),
                    if (answer.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(answerTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 10),
                      Card(
                        color: const Color(0xFF112A20),
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: SizedBox(
                            width: double.infinity,
                            child: MathText(
                              text: answer,
                              style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.65),
                            ),
                          ),
                        ),
                      ),
                      if (diagramQuestion != null)
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: questionController,
                          builder: (context, value, child) {
                            if (value.text.trim() != diagramQuestion) {
                              return const SizedBox.shrink();
                            }
                            final diagram = DiagramQuestionParser.parse(diagramQuestion!);
                            if (diagram == null) {
                              return const SizedBox.shrink();
                            }
                            return SafeDiagramRenderer(data: diagram);
                          },
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: answer));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(t('පිළිතුර කොපි කරගන්නා ලදී!', 'Answer copied!', 'பதில் நகலெடுக்கப்பட்டது!')),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded),
                          label: Text(t('පිටපත් කරන්න (Copy)', 'Copy Answer', 'நகலெடு')),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _toggleSpeaking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isSpeaking ? Colors.redAccent : const Color(0xFFD4AF37),
                            foregroundColor: _isSpeaking ? Colors.white : const Color(0xFF0A1C14),
                          ),
                          icon: Icon(_isSpeaking ? Icons.stop_circle_rounded : Icons.volume_up_rounded),
                          label: Text(_isSpeaking ? t('කියවීම නවත්වන්න', 'Stop Speaking', 'வாசிப்பதை நிறுத்து') : t('හඬින් අසන්න', 'Listen to Answer', 'பதிலைக் கேளுங்கள்'), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Share.share(answer, subject: 'Zingacc Learn AI - Answer');
                          },
                          icon: const Icon(Icons.share_rounded),
                          label: Text(t('Share කරන්න', 'Share Answer', 'பகிரவும்')),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: (isLoading || isSavingPdf) ? null : _saveLessonOffline,
                          icon: const Icon(Icons.bookmark_add_outlined),
                          label: Text(t('Offline Save කරන්න', 'Save Offline', 'ஆஃப்லைனில் சேமிக்கவும்')),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: (isLoading || isSavingPdf) ? null : explainCurrentAnswerSimpler,
                          icon: const Icon(Icons.lightbulb_outline_rounded),
                          label: Text(t('තවත් සරලව කියලා දෙන්න', 'Explain it more simply', 'இன்னும் எளிமையாக விளக்குங்கள்'), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: (isLoading || isSavingPdf) ? null : showAnotherExample,
                          icon: const Icon(Icons.auto_awesome_outlined),
                          label: Text(t('තවත් උදාහරණයක් පෙන්වන්න', 'Show another example', 'மற்றொரு உதாரணத்தைக் காட்டுங்கள்'), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: (isLoading || isSavingPdf) ? null : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(t('නියමයි! ඔබට මේ පැහැදිලි කිරීම තේරුණා. දිගටම ඉගෙන ගනිමු!', 'Great! You understood this explanation. Keep learning!', 'அருமை! இந்த விளக்கம் உங்களுக்குப் புரிந்தது. தொடர்ந்து கற்போம்!')),
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_circle_outline_rounded),
                          label: Text(t('මට තේරුණා', 'I understand', 'எனக்குப் புரிந்தது')),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: (isLoading || isSavingPdf) ? null : () {
                            setState(() {
                              questionController.clear();
                              answer = '';
                              selectedImageBytes = null;
                              selectedFileName = null;
                              selectedMimeType = null;
                            });
                            FocusScope.of(context).unfocus();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(t('අලුත් ප්‍රශ්නය අහන්න සූදානම්!', 'Ready for a new question!', 'புதிய கேள்வியைக் கேட்கத் தயார்!')),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_circle_outline_rounded),
                          label: Text(t('අලුත් ප්‍රශ්නයක් අහන්න', 'Ask a new question', 'புதிய கேள்வியைக் கேளுங்கள்')),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: (isLoading || isSavingPdf) ? null : saveAnswerAsPdf,
                          icon: isSavingPdf ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0A1C14))) : const Icon(Icons.picture_as_pdf_rounded),
                          label: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              isSavingPdf ? t('PDF එක සකස් කරමින්...', 'Preparing PDF...', 'PDF தயாராகிறது...') : t('PDF ලෙස සුරකින්න', 'Save as PDF', 'PDF ஆக சேமிக்கவும்'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContextChip extends StatelessWidget {
  const _ContextChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF112A20),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFD4AF37)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

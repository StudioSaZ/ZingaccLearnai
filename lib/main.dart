import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'login_screen.dart';
import 'level_selection_screen.dart';
import 'medium_selection_screen.dart';
import 'subject_selection_screen.dart';
import 'explanation_language_screen.dart';
import 'al_stream_selection_screen.dart';
import 'al_subject_selection_screen.dart';
import 'junior_subject_selection_screen.dart';
import 'dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // මෙන්න මේ ලයින් එක එකතු කරන්න (Firestore ඔෆ්ලයින් ප්‍රශ්න මගහරවා ගැනීමට):
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false, // Web එකේදී offline persistence disable කරමු
    sslEnabled: true,
  );

  // මෙන්න මෙහෙම හදාගන්න: වෙබ් එකේදී App Check සම්පූර්ණයෙන්ම skip කරන්න
  if (!kIsWeb) {
    try {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
      // ඩීබග් මෝඩ් එකේදී ටෝකන් ප්‍රශ්න නොඑන්න මෙය එකතු කරන්න:
      await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
    } catch (e) {
      debugPrint('App Check Error: $e');
    }

  } else {
    // Web එකේදී App Check අවශ්‍ය නැත (Localhost වල AI සේවාව බ්ලොක් නොවී වැඩ කිරීමට)
    debugPrint('App Check is bypassed for Flutter Web development.');
  }

  runApp(const ZingaccLearnAI());
}

class ZingaccLearnAI extends StatelessWidget {
  const ZingaccLearnAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zingacc Learn AI',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A1C14),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37),
          secondary: Color(0xFF004D40),
          surface: Color(0xFF112A20),
          error: Color(0xFFCF6679),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4AF37),
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Color(0xFFE0E0E0),
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFFB0BEC5),
            height: 1.4,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A1C14),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: Color(0xFFD4AF37),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37),
            foregroundColor: const Color(0xFF0A1C14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF07132F),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('Login thathwaya pariksha karanna bari una.'),
            ),
          );
        }

        if (snapshot.data == null) {
          return const LoginScreen();
        }

        return const AppLevelSelectionScreen();
      },
    );
  }
}

class AppLevelSelectionScreen extends StatelessWidget {
  const AppLevelSelectionScreen({super.key});

  void _openExplanationLanguage(
      BuildContext context, {
        required String level,
        required String medium,
        required String subject,
      }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExplanationLanguageScreen(
          selectedLevel: level,
          selectedMedium: medium,
          selectedSubject: subject,
          onLanguageSelected: (selectedLanguage) {
            final String aiLanguage;

            switch (selectedLanguage) {
              case 'sinhala':
                aiLanguage = 'සිංහල';
                break;
              case 'tamil':
                aiLanguage = 'தமிழ்';
                break;
              default:
                aiLanguage = 'English';
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardScreen(
                  selectedLevel: level,
                  selectedMedium: medium,
                  selectedSubject: subject,
                  language: aiLanguage,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LevelSelectionScreen(
      onLevelSelected: (selectedLevel) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediumSelectionScreen(
              selectedLevel: selectedLevel,
              onMediumSelected: (selectedMedium) {
                if (selectedLevel == 'al') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ALStreamSelectionScreen(
                        selectedMedium: selectedMedium,
                        onStreamSelected: (selectedStream) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ALSubjectSelectionScreen(
                                selectedMedium: selectedMedium,
                                selectedStream: selectedStream,
                                onSubjectSelected: (selectedSubject) {
                                  _openExplanationLanguage(
                                    context,
                                    level: selectedLevel,
                                    medium: selectedMedium,
                                    subject: selectedSubject,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                  return;
                }

                if (const [
                  'grade_6',
                  'grade_7',
                  'grade_8',
                  'grade_9',
                ].contains(selectedLevel)) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JuniorSubjectSelectionScreen(
                        selectedLevel: selectedLevel,
                        selectedMedium: selectedMedium,
                        onSubjectSelected: (selectedSubject) {
                          _openExplanationLanguage(
                            context,
                            level: selectedLevel,
                            medium: selectedMedium,
                            subject: selectedSubject,
                          );
                        },
                      ),
                    ),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubjectSelectionScreen(
                      selectedLevel: selectedLevel,
                      selectedMedium: selectedMedium,
                      onSubjectSelected: (selectedSubject) {
                        _openExplanationLanguage(
                          context,
                          level: selectedLevel,
                          medium: selectedMedium,
                          subject: selectedSubject,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
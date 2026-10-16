import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  await FirebaseAppCheck.instance.activate(
    providerWeb: ReCaptchaEnterpriseProvider(
      '6LekicotAAAAACsT_5XVvqJFY-WOPcalZesw55IK',
    ),
  );
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F7FC),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFFF1EFF8),
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          elevation: 1,
          margin: EdgeInsets.zero,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

// Listen for authentication changes, including logout and restored sessions.
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
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
                child: Text('Login තත්ත්වය පරීක්ෂා කිරීමට නොහැකි වුණා.')),
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
                if (const ['grade_6', 'grade_7', 'grade_8', 'grade_9']
                    .contains(selectedLevel)) {
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

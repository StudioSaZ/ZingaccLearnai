import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'main.dart';
import 'firestore_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _submit() async {
    final email = _emailController.text.trim();

    // Password එකේ ඉදිරියට හෝ අගට යෙදූ spaces වෙනස් නොකර තබාගන්න.
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('කරුණාකර Email සහ Password ඇතුළත් කරන්න.'),
          backgroundColor: Color(0xFFD84315),
        ),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _isLoading = true;
    });

    String? firestoreWarning;

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      // Login/Sign up සාර්ථක වූ පසු මාසික coins පරීක්ෂා කරයි.
      // Firestore දෝෂයක් වුණත් පරිශීලකයාට app එකට යාමට ඉඩ දෙයි.
      try {
        await FirestoreService.setupNewUserOrGiveMonthlyCoins();
      } on FirebaseException catch (e, stackTrace) {
        debugPrint('Firestore setup error: ${e.code}');
        debugPrintStack(stackTrace: stackTrace);

        firestoreWarning =
        'පිවිසීම සාර්ථකයි. නමුත් coins යාවත්කාලීන කිරීම පසුව නැවත උත්සාහ කරන්න.';
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (context) => const AppLevelSelectionScreen(),
        ),
      );

      if (firestoreWarning != null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(firestoreWarning),
            backgroundColor: const Color(0xFFD84315),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'ගැටලුවක් මතු වුණා. කරුණාකර නැවත උත්සාහ කරන්න.';

      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        message = 'Email හෝ Password වැරදියි.';
      } else if (e.code == 'email-already-in-use') {
        message = 'මෙම Email ලිපිනයෙන් දැනටමත් ගිණුමක් සාදා ඇත.';
      } else if (e.code == 'weak-password') {
        message = 'Password එක දුර්වලයි. අවම වශයෙන් අකුරු/අංක 6ක් අවශ්‍යයි.';
      } else if (e.code == 'invalid-email') {
        message = 'කරුණාකර නිවැරදි Email ලිපිනයක් ඇතුළත් කරන්න.';
      } else if (e.code == 'too-many-requests') {
        message = 'උත්සාහ කිරීම් වැඩියි. ටික වේලාවකින් නැවත උත්සාහ කරන්න.';
      } else if (e.code == 'network-request-failed') {
        message = 'Internet සම්බන්ධතාව පරීක්ෂා කර නැවත උත්සාහ කරන්න.';
      }

      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFFD84315),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Login screen error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'ගැටලුවක් මතු වුණා. Internet පරීක්ෂා කර නැවත උත්සාහ කරන්න.',
            ),
            backgroundColor: Color(0xFFD84315),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07132F),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.school_rounded,
                    size: 80,
                    color: Color(0xFF70CFFF),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _isLogin
                        ? 'නැවත සාදරයෙන් පිළිගනිමු!'
                        : 'නව ගිණුමක් සාදන්න',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Zingacc Learn AI වෙත පිවිසෙන්න',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFABBCD8),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email field
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF101F43),
                      hintText: 'Email ලිපිනය',
                      hintStyle: const TextStyle(color: Color(0xFFABBCD8)),
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Color(0xFF70CFFF),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF70CFFF),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (!_isLoading) {
                        _submit();
                      }
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF101F43),
                      hintText: 'Password එක',
                      hintStyle: const TextStyle(color: Color(0xFFABBCD8)),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF70CFFF),
                      ),
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? 'Password පෙන්වන්න'
                            : 'Password සඟවන්න',
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xFFABBCD8),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF70CFFF),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Login / Sign up button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7546D8),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF514278),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      _isLogin
                          ? 'පිවිසෙන්න (Login)'
                          : 'ගිණුම සාදන්න (Sign Up)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Switch between Login and Sign up
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(
                      _isLogin
                          ? 'ගිණුමක් නැද්ද? අලුතින් ගිණුමක් හදන්න'
                          : 'දැනටමත් ගිණුමක් තිබේද? පිවිසෙන්න',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF70CFFF),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
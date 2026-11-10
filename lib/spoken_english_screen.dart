import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'zingacc_brand_banner.dart';

class SpokenEnglishScreen extends StatefulWidget {
  const SpokenEnglishScreen({super.key});

  @override
  State<SpokenEnglishScreen> createState() => _SpokenEnglishScreenState();
}

class _SpokenEnglishScreenState extends State<SpokenEnglishScreen> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  bool _isLoading = false;

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initTts();

    _messages.add({
      'role': 'ai',
      'text': "Hello! I am your Spoken English partner. How are you today? Let's practice English together!"
    });
    _speakText(_messages.first['text']!);
  }

  void _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speakText(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening') setState(() => _isListening = false);
      },
      onError: (error) => setState(() => _isListening = false),
    );

    if (available) {
      setState(() => _isListening = true);
      await _speech.listen(
        localeId: 'en_US',
        onResult: (result) {
          setState(() {
            _textController.text = result.recognizedWords;
          });
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('මයික්‍රෆෝනය ක්‍රියාත්මක කළ නොහැක.', style: TextStyle(color: Colors.white))),
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _messages.add({'role': 'user', 'text': text});
      _textController.clear();
    });

    _scrollToBottom();
    await _flutterTts.stop();

    try {
      String chatHistory = '';
      for (var msg in _messages) {
        chatHistory += "${msg['role'] == 'user' ? 'Student' : 'Tutor'}: ${msg['text']}\n";
      }

      final prompt = '''
You are a friendly and encouraging Spoken English conversation partner for a Sri Lankan school student.
Your goal is to practice everyday English conversation.

Here is the conversation history:
$chatHistory

INSTRUCTIONS FOR YOUR RESPONSE:
1. If the student made a grammar or pronunciation mistake in their last message, gently correct it in one short sentence (e.g., "Tip: We say 'I went' instead of 'I go'.").
2. Respond naturally and warmly to keep the conversation going.
3. Ask ONE simple follow-up question to encourage the student to speak again.
4. Keep your total response very short (2-3 sentences maximum) so it is easy for the student to listen to.
5. Do NOT use any Markdown formatting (*, #, etc.). Just plain text.
''';

      const apiKey = 'AQ.Ab8RN6KjvvtMPQtGecmGUTj6u2bMF7kY0kPOsgUjMuTlcJg1Iw';
      final model = GenerativeModel(
        model: 'gemini-3.8-flash',
        apiKey: apiKey,
      );

      // 🔴 Connection Error වළක්වන Timeout එක දැම්මා (තත්පර 15)
      final response = await model.generateContent([Content.text(prompt)]).timeout(const Duration(seconds: 15));

      final reply = response.text?.trim() ?? "Sorry, I didn't catch that. Could you say it again?";

      setState(() {
        _messages.add({'role': 'ai', 'text': reply});
      });

      _scrollToBottom();
      _speakText(reply);

    } catch (e) {
      // Primary එක අවුල් ගියොත් Fallback එකට යනවා
      try {
        const apiKey = 'AQ.Ab8RN6KjvvtMPQtGecmGUTj6u2bMF7kY0kPOsgUjMuTlcJg1Iw';
        final fallbackModel = GenerativeModel(
          model: 'gemini-3.5-flash-lite',
          apiKey: apiKey,
        );

        final fallbackResponse = await fallbackModel.generateContent([Content.text('You are a friendly english tutor. The user said: "${_messages.last['text']}". Reply in 1 short friendly sentence and ask a simple question.')]).timeout(const Duration(seconds: 15));

        final fallbackReply = fallbackResponse.text?.trim() ?? "Sorry, my internet connection is a bit slow. Can you say that again?";

        setState(() {
          _messages.add({'role': 'ai', 'text': fallbackReply});
        });
        _scrollToBottom();
        _speakText(fallbackReply);

      } catch (fallbackError) {
        setState(() {
          _messages.add({'role': 'ai', 'text': 'Oops! Connection is too slow. Please check your internet and try again.'});
        });
        _scrollToBottom();
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF0A1C14); // Deep Green
    const panel = Color(0xFF112A20); // Dark Green Panel
    const gold = Color(0xFFD4AF37); // Premium Gold

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: gold,
        title: const Text('Spoken English Partner', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const ZingaccBrandBanner(),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: panel,
                border: Border(bottom: BorderSide(color: gold.withOpacity(0.3))),
              ),
              width: double.infinity,
              child: const Text(
                '💡 මයික්‍රෆෝනය ඔබා ඉංග්‍රීසියෙන් කතා කරන්න. AI ගුරුවරයා ඔබේ වැරදි හදා ඔබ සමඟ කතා කරාවි!',
                style: TextStyle(color: gold, fontSize: 13, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['role'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75), // මෙතන * එක වැටිලා තිබුණේ නෑ කලින්
                      decoration: BoxDecoration(
                        color: isUser ? gold : panel, // User is Gold, AI is Dark Green
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                          bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                        ),
                        border: isUser ? null : Border.all(color: gold.withOpacity(0.5)),
                      ),
                      child: Text(
                        msg['text']!,
                        style: TextStyle(
                            color: isUser ? const Color(0xFF0A1C14) : Colors.white, // Dark text on Gold, White text on Green
                            fontSize: 16,
                            height: 1.4,
                            fontWeight: isUser ? FontWeight.bold : FontWeight.normal
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(color: gold),
              ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: background,
                border: Border(top: BorderSide(color: gold.withOpacity(0.2))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type or speak here...',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: panel,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: gold.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: gold.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: gold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _toggleListening,
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: _isListening ? Colors.redAccent : panel,
                      child: Icon(
                        _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                        color: _isListening ? Colors.white : gold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _isLoading ? null : _sendMessage,
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: _isLoading ? panel : gold,
                      child: Icon(Icons.send_rounded, color: _isLoading ? gold.withOpacity(0.5) : const Color(0xFF0A1C14)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
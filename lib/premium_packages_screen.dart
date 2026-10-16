import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PremiumPackagesScreen extends StatefulWidget {
  const PremiumPackagesScreen({super.key});

  @override
  State<PremiumPackagesScreen> createState() => _PremiumPackagesScreenState();
}

class _PremiumPackagesScreenState extends State<PremiumPackagesScreen> {
  int selected = 0;

  static const titles = <String>[
    '5 ශිෂ්‍යත්වය – 9 ශ්‍රේණිය',
    'සාමාන්‍ය පෙළ (O/L)',
    'උසස් පෙළ (A/L)',
    'Top-up 25',
    'Top-up 50',
    'Top-up 100',
  ];
  static const prices = <int>[1500, 2000, 2500, 250, 450, 800];
  static const counts = <int>[150, 150, 150, 25, 50, 100];

  // WhatsApp වෙත යොමු කිරීමේ ක්‍රියාවලිය
  Future<void> _sendWhatsAppMessage() async {
    final String package = titles[selected];
    final int price = prices[selected];

    // දැනට ලොග් වී සිටින ළමයාගේ Email එක ලබාගැනීම
    final user = FirebaseAuth.instance.currentUser;
    final String userEmail = user?.email ?? "Unknown Email";

    // WhatsApp මැසේජ් එක (Email එකත් සමඟ)
    final String message =
        "ආයුබෝවන්! මම Zingacc Learn AI හි '$package' (රු. $price) පැකේජය මිලදී ගැනීමට මුදල් තැන්පත් කළෙමි.\n\nමගේ ගිණුමේ Email ලිපිනය: $userEmail\n\nමගේ ගෙවීම් රිසිට්පත මේ සමඟ එවා ඇත.";

    // ඔයාගේ WhatsApp අංකය
    final Uri whatsappUri = Uri.parse("https://wa.me/94786346064?text=${Uri.encodeComponent(message)}");

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WhatsApp විවෘත කිරීමට නොහැකි විය. කරුණාකර 0786346064 අංකයට රිසිට්පත එවන්න.')),
        );
      }
    } catch (e) {
      debugPrint("WhatsApp Error: $e");
    }
  }

  Widget packageCard(int index) {
    final chosen = selected == index;
    return Card(
      color: chosen ? const Color(0xFF28477B) : const Color(0xFF142B56),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: chosen ? const Color(0xFF70CFFF) : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => selected = index),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                chosen ? Icons.radio_button_checked : Icons.radio_button_off,
                color: const Color(0xFF70CFFF),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titles[index],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(
                      '${counts[index]} AI ප්‍රශ්න · ${index < 3 ? 'දින 30' : 'අවසන් වන තුරු'}',
                      style: const TextStyle(
                          color: Color(0xFFD2DDF5), fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text('රු. ${prices[index]}',
                  style: const TextStyle(
                      color: Color(0xFF70CFFF),
                      fontWeight: FontWeight.bold,
                      fontSize: 17)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07132F),
      appBar: AppBar(
        title: const Text('Zingacc සාමාජිකත්වය', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF07132F),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
            children: [
              const Icon(Icons.school_rounded, color: Color(0xFF70CFFF), size: 54),
              const SizedBox(height: 10),
              const Text('ඔබේ ඉගෙනුම් පැකේජය තෝරන්න',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'මාසික පැකේජයකට AI ප්‍රශ්න 150ක් හිමිවේ.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFD2DDF5), fontSize: 15),
              ),
              const SizedBox(height: 24),

              const Text('මාසික පැකේජ',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              for (var i = 0; i < 3; i++) packageCard(i),

              const SizedBox(height: 18),
              const Text('අමතර ප්‍රශ්න (Top-up)',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              for (var i = 3; i < 6; i++) packageCard(i),

              const SizedBox(height: 24),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF101F43),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF263960)),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('මුදල් බැර කළ යුතු ගිණුම:',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _bankDetailRow('බැංකුව', 'Commercial Bank'),
                    const Divider(color: Color(0xFF263960), height: 20),
                    _bankDetailRow('ගිණුම් හිමියා', 'M.S.N. Fernando'),
                    const Divider(color: Color(0xFF263960), height: 20),
                    _bankDetailRow('ශාඛාව', 'Raddolugama'),
                    const Divider(color: Color(0xFF263960), height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('ගිණුම් අංකය', style: TextStyle(color: Color(0xFF8093B7), fontSize: 13)),
                            SizedBox(height: 4),
                            Text('8031567967', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(const ClipboardData(text: '8031567967'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('ගිණුම් අංකය Copy කරගන්නා ලදී!'), backgroundColor: Colors.green),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded, color: Color(0xFF70CFFF)),
                          tooltip: 'Copy',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              FilledButton.icon(
                onPressed: _sendWhatsAppMessage,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.send_rounded, size: 24),
                label: const Text(
                  'රිසිට්පත WhatsApp කරන්න',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'ඉහත ගිණුමට මුදල් තැන්පත් කර, එම රිසිට්පතෙහි ඡායාරූපයක් අප වෙත WhatsApp කරන්න. පැකේජය ඉක්මනින් සක්‍රිය කරනු ලැබේ.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFD2DDF5), fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bankDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: const TextStyle(color: Color(0xFF8093B7), fontSize: 14)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
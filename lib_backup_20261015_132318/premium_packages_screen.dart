import 'package:flutter/material.dart';

/// Safe preview only: no payments, entitlements or quota are changed.
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

  Widget packageCard(int index) {
    final chosen = selected == index;
    return Card(
      color: chosen ? const Color(0xFF28477B) : const Color(0xFF142B56),
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
                      '${counts[index]} AI ප්‍රශ්න · ${index < 3 ? 'දින 30' : 'වත්මන් සාමාජිකත්වය අවසන් වන තුරු'}',
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
        title: const Text('Zingacc සාමාජිකත්වය'),
        backgroundColor: const Color(0xFF07132F),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const Icon(Icons.school_rounded,
                  color: Color(0xFF70CFFF), size: 54),
              const SizedBox(height: 10),
              const Text('ඔබේ ඉගෙනුම් පැකේජය තෝරන්න',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'මාසික පැකේජයකට AI ප්‍රශ්න 150ක්. දිනපතා සීමාවක් නැහැ.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFD2DDF5)),
              ),
              const SizedBox(height: 22),
              const Text('මාසික පැකේජ',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold)),
              for (var i = 0; i < 3; i++) packageCard(i),
              const SizedBox(height: 18),
              const Text('අමතර ප්‍රශ්න (Top-up)',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold)),
              for (var i = 3; i < 6; i++) packageCard(i),
              const SizedBox(height: 16),
              Card(
                color: const Color(0xFF142B56),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ඔබ තෝරාගත් පැකේජය',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(titles[selected],
                          style: const TextStyle(color: Colors.white)),
                      Text(
                          'රු. ${prices[selected]} · AI ප්‍රශ්න ${counts[selected]}',
                          style: const TextStyle(
                              color: Color(0xFF70CFFF), fontSize: 18)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Card(
                color: Color(0xFF493618),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'මෙය පරීක්ෂණ පිටුවකි. බැංකු විස්තර සහ ආරක්ෂිත Server-side ගෙවීම් අනුමැතිය සකස් කර නැති නිසා ගෙවීම් තවම භාර නොගනී. සැබෑ මුදල් යවන්න එපා.',
                    style: TextStyle(color: Color(0xFFFFD69C)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.lock_outline),
                label: const Text('ගෙවීම් — ඉදිරියේදී සක්‍රිය වේ'),
              ),
              const SizedBox(height: 12),
              const Text(
                'ප්‍රශ්න 120 සහ 145 දී දැනුම්දීම්, 150 අවසන් වූ විට Top-up Popup එක සහ සුරක්ෂිත භාවිත ගණනය ඊළඟ අදියරේදී AI Tutor සමඟ සම්බන්ධ කරමු.',
                style: TextStyle(color: Color(0xFFD2DDF5), fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

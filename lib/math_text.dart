import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class MathText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const MathText({required this.text, required this.style, super.key});

  @override
  Widget build(BuildContext context) {
    // AI එකෙන් එන අකුරු වල තියෙන අනවශ්‍ය escape marks අයින් කිරීම
    String cleanText = text.replaceAll('\\\$', '\$');

    // $$ ලකුණු සහ \( \) ලකුණු ඔක්කොම සාමාන්‍ය $ බවට පත් කිරීම
    cleanText = cleanText.replaceAll('\$\$', '\$');
    cleanText = cleanText.replaceAll('\\(', '\$');
    cleanText = cleanText.replaceAll('\\)', '\$');
    cleanText = cleanText.replaceAll('\\[', '\$');
    cleanText = cleanText.replaceAll('\\]', '\$');

    final parts = cleanText.split('\$');
    List<InlineSpan> spans = [];

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;

      if (i % 2 == 0) {
        // සාමාන්‍ය අකුරු
        spans.add(TextSpan(text: parts[i], style: style));
      } else {
        // ගණිත සමීකරණ (LaTeX)

        // අඩුපාඩුව 1 නිවැරදි කිරීම: AI එකෙන් එන සමීකරණ ඇතුළේ 'Enter' (\n) තිබුණොත් අයින් කිරීම (නැත්නම් App එක Error ගහනවා)
        // වටේ තියෙන අනවශ්‍ය Space අයින් කිරීමට .trim() යෙදීම
        String mathEquation = parts[i].replaceAll('\n', ' ').trim();

        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Math.tex(
              mathEquation,
              textStyle: style,
              // අඩුපාඩුව 2 නිවැරදි කිරීම: භාග ගණන් (Fractions) කුඩාවට නොපෙනී ලොකුවට පැහැදිලිව පේන්න Display Style දැමීම
              mathStyle: MathStyle.display,
              onErrorFallback: (err) => Text(
                '\$$mathEquation\$',
                // අඩුපාඩුව 3 නිවැරදි කිරීම: Error ආවොත් රතු පාටින් කැතට පේන්නෙ නැතුව අපේ තීම් එකට ගැලපෙන Gold පාටින් පෙන්වීම
                style: style.copyWith(color: const Color(0xFFD4AF37)),
              ),
            ),
          ),
        );
      }
    }

    return SelectableText.rich(
      TextSpan(children: spans),
      textAlign: TextAlign.left,
    );
  }
}
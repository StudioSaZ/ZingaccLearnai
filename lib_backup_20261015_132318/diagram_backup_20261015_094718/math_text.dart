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

    // $$ ලකුණු සහ \( \) ලකුණු ඔක්කොම සාමාන්‍ය $ බවට පත් කිරීම (ලේසියෙන් අඳුරගන්න)
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
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Math.tex(
              parts[i],
              textStyle: style,
              onErrorFallback: (err) => Text(
                '\$${parts[i]}\$',
                style: style.copyWith(color: Colors.redAccent),
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
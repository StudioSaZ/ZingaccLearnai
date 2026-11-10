import 'package:flutter/material.dart';

class ZingaccBrandBanner extends StatelessWidget {
  const ZingaccBrandBanner({
    super.key,
    this.compact = false,
    this.margin = EdgeInsets.zero,
  });

  final bool compact;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          compact ? 16 : 22,
        ),
        // 🌟 Premium Gold Gradient Border
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF9D976), // Light Gold
            Color(0xFFD4AF37), // Classic Gold
            Color(0xFFB58E29), // Dark Gold
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(
              alpha: 0.28,
            ),
            blurRadius: compact ? 12 : 20,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: const Color(0xFFF9D976).withValues(
              alpha: 0.18,
            ),
            blurRadius: compact ? 8 : 16,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(2), // 2px Border width
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF112A20), // 🌟 Dark Green Background
          borderRadius: BorderRadius.circular(
            compact ? 14 : 20,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: compact
            ? SizedBox(
          height: 72,
          width: double.infinity,
          child: _bannerImage(),
        )
            : AspectRatio(
          aspectRatio: 16 / 9,
          child: _bannerImage(),
        ),
      ),
    );
  }

  Widget _bannerImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/student_banner.png',
          fit: BoxFit.contain,
          alignment: Alignment.center,
          errorBuilder: (
              BuildContext context,
              Object error,
              StackTrace? stackTrace,
              ) {
            // 🌟 Error Fallback Image with Dark Green Theme
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A3C2B), // Lighter Dark Green
                    Color(0xFF112A20), // Dark Green
                    Color(0xFF0A1C14), // Deep Dark Green
                  ],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.school_rounded,
                  color: Color(0xFFD4AF37), // 🌟 Gold Icon
                  size: 44,
                ),
              ),
            );
          },
        ),
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.07),
                  Colors.transparent,
                  const Color(0xFFD4AF37).withValues( // 🌟 Subtle Gold overlay
                    alpha: 0.08,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
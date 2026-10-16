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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7B24FF),
            Color(0xFF1769FF),
            Color(0xFF16D9FF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B24FF).withValues(
              alpha: 0.28,
            ),
            blurRadius: compact ? 12 : 20,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: const Color(0xFF16D9FF).withValues(
              alpha: 0.18,
            ),
            blurRadius: compact ? 8 : 16,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF07132F),
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
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF35156F),
                    Color(0xFF073B83),
                    Color(0xFF006B86),
                  ],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.school_rounded,
                  color: Colors.white,
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
                  const Color(0xFF16D9FF).withValues(
                    alpha: 0.05,
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

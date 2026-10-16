import 'package:flutter/material.dart';
import 'zingacc_brand_banner.dart';

class MediumSelectionScreen extends StatefulWidget {
  const MediumSelectionScreen({
    super.key,
    required this.selectedLevel,
    this.onMediumSelected,
  });

  final String selectedLevel;
  final ValueChanged<String>? onMediumSelected;

  @override
  State<MediumSelectionScreen> createState() => _MediumSelectionScreenState();
}

class _MediumSelectionScreenState extends State<MediumSelectionScreen> {
  String? selectedMedium;

  final List<StudyMedium> mediums = const [
    StudyMedium(
      id: 'sinhala',
      title: 'සිංහල මාධ්‍ය',
      englishTitle: 'Sinhala Medium',
      description: 'සිංහල මාධ්‍යයෙන් ඉගෙන ගන්න',
      icon: Icons.translate_rounded,
    ),
    StudyMedium(
      id: 'english',
      title: 'English Medium',
      englishTitle: 'English Medium',
      description: 'Learn in English Medium',
      icon: Icons.language_rounded,
    ),
    StudyMedium(
      id: 'tamil',
      title: 'தமிழ் மொழிமூலம்',
      englishTitle: 'Tamil Medium',
      description: 'தமிழ் மொழிமூலம் கற்கவும்',
      icon: Icons.translate_rounded,
    ),
  ];

  String get levelName {
    switch (widget.selectedLevel) {
      case 'grade_5_scholarship':
        return 'Grade 5 Scholarship / ශිෂ්‍යත්වය';
      case 'grade_6':
        return 'Grade 6 / 6 ශ්‍රේණිය';
      case 'grade_7':
        return 'Grade 7 / 7 ශ්‍රේණිය';
      case 'grade_8':
        return 'Grade 8 / 8 ශ්‍රේණිය';
      case 'grade_9':
        return 'Grade 9 / 9 ශ්‍රේණිය';
      case 'ol':
        return 'O/L / සාමාන්‍ය පෙළ';
      case 'al':
        return 'A/L / උසස් පෙළ';
      default:
        return widget.selectedLevel;
    }
  }

  void selectMedium(String mediumId) {
    setState(() {
      selectedMedium = mediumId;
    });
  }

  void continueToNextStep() {
    final mediumId = selectedMedium;

    if (mediumId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your learning medium.'),
        ),
      );
      return;
    }

    if (widget.onMediumSelected != null) {
      widget.onMediumSelected!(mediumId);
      return;
    }

    final medium = mediums.firstWhere(
          (item) => item.id == mediumId,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$levelName • ${medium.englishTitle} selected.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07132F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07132F),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Zingacc Learn AI',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 760 ? 3 : 1;
                      final cardWidth =
                          (constraints.maxWidth - 36 - 12 * (columns - 1)) /
                              columns;

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(
                          18,
                          14,
                          18,
                          24,
                        ),
                        children: [
                          const ZingaccBrandBanner(),
                          const SizedBox(height: 24),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF192B55),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF365393),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.school_rounded,
                                    color: Color(0xFF70CFFF),
                                    size: 22,
                                  ),
                                  const SizedBox(width: 9),
                                  Flexible(
                                    child: Text(
                                      levelName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Text(
                            'Select Your Medium',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'ඔබ ඉගෙන ගන්නා මාධ්‍යය තෝරන්න',
                            style: TextStyle(
                              color: Color(0xFFC3D0EA),
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'உங்கள் கல்வி மொழிமூலத்தைத் தேர்ந்தெடுக்கவும்',
                            style: TextStyle(
                              color: Color(0xFFC3D0EA),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Wrap(
                            spacing: 12,
                            runSpacing: 14,
                            children: [
                              for (final medium in mediums)
                                SizedBox(
                                  width: cardWidth,
                                  child: MediumCard(
                                    medium: medium,
                                    selected: selectedMedium == medium.id,
                                    onTap: () => selectMedium(medium.id),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF14264B),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFF29436E),
                              ),
                            ),
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  color: Color(0xFF70CFFF),
                                  size: 24,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'English Medium students can still ask the AI Tutor to explain difficult lessons in සිංහල or தமிழ்.',
                                    style: TextStyle(
                                      color: Color(0xFFD4E1F7),
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    12,
                    18,
                    18,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF07132F),
                    border: Border(
                      top: BorderSide(
                        color: Color(0xFF263960),
                      ),
                    ),
                  ),
                  child: FilledButton.icon(
                    onPressed:
                    selectedMedium == null ? null : continueToNextStep,
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                    ),
                    label: const Text(
                      'Continue / ඉදිරියට',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF7546D8),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF263451),
                      disabledForegroundColor: const Color(0xFFABBCD8),
                      minimumSize: const Size.fromHeight(54),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MediumCard extends StatelessWidget {
  const MediumCard({
    super.key,
    required this.medium,
    required this.selected,
    required this.onTap,
  });

  final StudyMedium medium;
  final bool selected;
  final VoidCallback onTap;

  Color get accent {
    switch (medium.id) {
      case 'sinhala':
        return const Color(0xFFB77AFF);
      case 'english':
        return const Color(0xFF55B9FF);
      case 'tamil':
        return const Color(0xFF39D5BD);
      default:
        return const Color(0xFFB77AFF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: Material(
        color:
        selected ? accent.withValues(alpha: 0.18) : const Color(0xFF101F43),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selected ? accent : const Color(0xFF263960),
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        medium.icon,
                        color: accent,
                        size: 28,
                      ),
                    ),
                    Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: selected ? accent : const Color(0xFF8093B7),
                      size: 26,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  medium.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                  ),
                ),
                if (medium.title != medium.englishTitle) ...[
                  const SizedBox(height: 5),
                  Text(
                    medium.englishTitle,
                    style: TextStyle(
                      color: accent,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 9),
                Text(
                  medium.description,
                  style: const TextStyle(
                    color: Color(0xFFC3D0EA),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StudyMedium {
  const StudyMedium({
    required this.id,
    required this.title,
    required this.englishTitle,
    required this.description,
    required this.icon,
  });

  final String id;
  final String title;
  final String englishTitle;
  final String description;
  final IconData icon;
}

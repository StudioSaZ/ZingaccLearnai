import 'package:flutter/material.dart';
import 'zingacc_brand_banner.dart';

class ALStreamSelectionScreen extends StatefulWidget {
  const ALStreamSelectionScreen({
    super.key,
    required this.selectedMedium,
    this.onStreamSelected,
  });

  final String selectedMedium;
  final ValueChanged<String>? onStreamSelected;

  @override
  State<ALStreamSelectionScreen> createState() =>
      _ALStreamSelectionScreenState();
}

class _ALStreamSelectionScreenState extends State<ALStreamSelectionScreen> {
  bool showStreams = false;
  String? selectedStream;

  String get mediumName {
    switch (widget.selectedMedium) {
      case 'sinhala':
        return 'Sinhala Medium';
      case 'tamil':
        return 'Tamil Medium';
      default:
        return 'English Medium';
    }
  }

  final List<_ALStreamItem> streams = const [
    _ALStreamItem(
      id: 'physical_science',
      title: 'Physical Science',
      subtitle: 'Mathematics / Physical Science stream',
      icon: Icons.calculate_rounded,
      color: Color(0xFFB77AFF),
    ),
    _ALStreamItem(
      id: 'biological_science',
      title: 'Biological Science',
      subtitle: 'Biology / Biological Science stream',
      icon: Icons.biotech_rounded,
      color: Color(0xFF39D5BD),
    ),
    _ALStreamItem(
      id: 'commerce',
      title: 'Commerce',
      subtitle: 'Commerce stream',
      icon: Icons.business_center_rounded,
      color: Color(0xFFFFC267),
    ),
    _ALStreamItem(
      id: 'arts',
      title: 'Arts',
      subtitle: 'Arts stream',
      icon: Icons.palette_rounded,
      color: Color(0xFFFF80B5),
    ),
    _ALStreamItem(
      id: 'engineering_technology',
      title: 'Engineering Technology',
      subtitle: 'Engineering Technology stream',
      icon: Icons.engineering_rounded,
      color: Color(0xFF55B9FF),
    ),
    _ALStreamItem(
      id: 'biosystems_technology',
      title: 'Biosystems Technology',
      subtitle: 'Biosystems Technology stream',
      icon: Icons.eco_rounded,
      color: Color(0xFFA9DE70),
    ),
  ];

  void openStreamList() {
    setState(() {
      showStreams = true;
    });
  }

  void chooseStream(String streamId) {
    setState(() {
      selectedStream = streamId;
    });
  }

  void confirmStream() {
    final stream = selectedStream;
    if (stream == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an A/L stream first.'),
        ),
      );
      return;
    }

    widget.onStreamSelected?.call(stream);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'A/L stream selected. Subject selection is the next step.',
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
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: showStreams ? _buildStreamList() : _buildIntro(),
                  ),
                ),
                _bottomButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topChips() {
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: [
        _chip(
          Icons.school_rounded,
          'A/L',
          const Color(0xFFB77AFF),
        ),
        _chip(
          Icons.language_rounded,
          mediumName,
          const Color(0xFF55B9FF),
        ),
      ],
    );
  }

  Widget _chip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 19, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFE0E9FA),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return ListView(
      key: const ValueKey('al-intro'),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
      children: [
        const ZingaccBrandBanner(),
        const SizedBox(height: 22),
        _topChips(),
        const SizedBox(height: 24),
        const Text(
          'Select Your Stream',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'A/L සඳහා පළමුව ඔබගේ විෂය ධාරාව තෝරන්න',
          style: TextStyle(
            color: Color(0xFFC3D0EA),
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF292052),
                Color(0xFF122E53),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFF48518C),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: const Color(0xFFB77AFF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.account_tree_rounded,
                  size: 44,
                  color: Color(0xFFB77AFF),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'A/L Stream Selection',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'A/L students first select the appropriate stream. '
                    'The subjects will be connected to the selected stream.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFD4E1F7),
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStreamList() {
    return LayoutBuilder(
      key: const ValueKey('al-streams'),
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700 ? 2 : 1;
        final cardWidth =
            (constraints.maxWidth - 36 - 12 * (columns - 1)) / columns;

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
          children: [
            const ZingaccBrandBanner(),
            const SizedBox(height: 22),
            _topChips(),
            const SizedBox(height: 24),
            const Text(
              'Choose Your A/L Stream',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select the stream you are studying.',
              style: TextStyle(
                color: Color(0xFFC3D0EA),
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'ඔබ ඉගෙන ගන්නා විෂය ධාරාව තෝරන්න.',
              style: TextStyle(
                color: Color(0xFFC3D0EA),
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final stream in streams)
                  SizedBox(
                    width: cardWidth,
                    child: _streamCard(stream),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _bottomButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      decoration: const BoxDecoration(
        color: Color(0xFF07132F),
        border: Border(
          top: BorderSide(color: Color(0xFF263960)),
        ),
      ),
      child: FilledButton(
        onPressed: showStreams
            ? (selectedStream == null ? null : confirmStream)
            : openStreamList,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.arrow_forward_rounded),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                showStreams
                    ? 'Continue to Subjects'
                    : 'Continue to Stream Selection',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _streamCard(_ALStreamItem item) {
    final selected = selectedStream == item.id;
    final accent = item.color;

    return Semantics(
      selected: selected,
      child: Material(
        color:
        selected ? accent.withValues(alpha: 0.18) : const Color(0xFF101F43),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(19),
          side: BorderSide(
            color: selected ? accent : const Color(0xFF263960),
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => chooseStream(item.id),
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    item.icon,
                    color: accent,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          height: 1.4,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          color: Color(0xFFC3D0EA),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 9),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? accent : const Color(0xFF8093B7),
                  size: 25,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ALStreamItem {
  const _ALStreamItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

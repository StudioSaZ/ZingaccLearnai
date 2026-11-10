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

  static const Color _gold = Color(0xFFD4AF37); // Premium Gold

  String _label(String sinhala, String english, String tamil) {
    final medium = widget.selectedMedium.toLowerCase();
    if (medium == 'sinhala' || medium == 'සිංහල') return sinhala;
    if (medium == 'tamil' || medium == 'தமிழ்') return tamil;
    return english;
  }

  String get mediumName {
    switch (widget.selectedMedium.toLowerCase()) {
      case 'sinhala':
      case 'සිංහල':
        return _label('සිංහල මාධ්‍යය', 'Sinhala Medium', 'சிங்கள மொழிமூலம்');
      case 'tamil':
      case 'தமிழ்':
        return _label('දෙමළ මාධ්‍යය', 'Tamil Medium', 'தமிழ் மொழிமூலம்');
      default:
        return _label('ඉංග්‍රීසි මාධ්‍යය', 'English Medium', 'ஆங்கில மொழிமூலம்');
    }
  }

  List<_ALStreamItem> get streams => [
    _ALStreamItem(
      id: 'physical_science',
      title: _label('භෞතික විද්‍යා (Maths)', 'Physical Science', 'பௌதிக விஞ்ஞானம் (Maths)'),
      subtitle: _label('ගණිතය / භෞතික විද්‍යා ධාරාව', 'Mathematics / Physical Science stream', 'கணிதம் / பௌதிக விஞ்ஞான துறை'),
      icon: Icons.calculate_rounded,
    ),
    _ALStreamItem(
      id: 'biological_science',
      title: _label('ජීව විද්‍යා (Bio)', 'Biological Science', 'உயிர் விஞ்ஞானம் (Bio)'),
      subtitle: _label('ජීව විද්‍යා ධාරාව', 'Biology / Biological Science stream', 'உயிரியல் / உயிர் விஞ்ஞான துறை'),
      icon: Icons.biotech_rounded,
    ),
    _ALStreamItem(
      id: 'commerce',
      title: _label('වාණිජ (Commerce)', 'Commerce', 'வர்த்தகம்'),
      subtitle: _label('වාණිජ ධාරාව', 'Commerce stream', 'வர்த்தக துறை'),
      icon: Icons.business_center_rounded,
    ),
    _ALStreamItem(
      id: 'arts',
      title: _label('කලා (Arts)', 'Arts', 'கலை'),
      subtitle: _label('කලා ධාරාව', 'Arts stream', 'கலை துறை'),
      icon: Icons.palette_rounded,
    ),
    _ALStreamItem(
      id: 'engineering_technology',
      title: _label('ඉංජිනේරු තාක්ෂණවේදය', 'Engineering Technology', 'பொறியியல் தொழில்நுட்பம்'),
      subtitle: _label('ඉංජිනේරු තාක්ෂණවේද ධාරාව (ET)', 'Engineering Technology stream', 'பொறியியல் தொழில்நுட்ப துறை (ET)'),
      icon: Icons.engineering_rounded,
    ),
    _ALStreamItem(
      id: 'biosystems_technology',
      title: _label('ජෛව පද්ධති තාක්ෂණවේදය', 'Biosystems Technology', 'உயிர் முறைமைகள் தொழில்நுட்பம்'),
      subtitle: _label('ජෛව පද්ධති තාක්ෂණවේද ධාරාව (BST)', 'Biosystems Technology stream', 'உயிர் முறைமைகள் தொழில்நுட்ப துறை (BST)'),
      icon: Icons.eco_rounded,
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
        SnackBar(
          content: Text(_label('කරුණාකර පළමුව A/L ධාරාවක් තෝරන්න.', 'Please select an A/L stream first.', 'தயவுசெய்து முதலில் A/L துறையைத் தேர்ந்தெடுக்கவும்.')),
        ),
      );
      return;
    }

    widget.onStreamSelected?.call(stream);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _label('A/L ධාරාව තෝරා ගන්නා ලදී. ඊළඟ පියවර විෂය තේරීමයි.', 'A/L stream selected. Subject selection is the next step.', 'A/L துறை தேர்ந்தெடுக்கப்பட்டது. அடுத்த படி பாடத் தேர்வு.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF0A1C14); // Deep Dark Green

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: _gold,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Zingacc Learn AI',
          style: TextStyle(fontWeight: FontWeight.w800, color: _gold),
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
          _gold,
        ),
        _chip(
          Icons.language_rounded,
          mediumName,
          _gold,
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
        color: const Color(0xFF112A20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.5),
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
                color: Colors.white,
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
    const panel = Color(0xFF112A20);

    return ListView(
      key: const ValueKey('al-intro'),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
      children: [
        const ZingaccBrandBanner(),
        const SizedBox(height: 22),
        _topChips(),
        const SizedBox(height: 24),
        Text(
          _label('ඔබගේ විෂය ධාරාව තෝරන්න', 'Select Your Stream', 'உங்கள் துறையைத் தேர்ந்தெடுக்கவும்'),
          style: const TextStyle(
            color: _gold,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _label(
            'A/L සඳහා පළමුව ඔබගේ විෂය ධාරාව තෝරන්න',
            'For A/L, first select your study stream',
            'A/L க்கு, முதலில் உங்கள் துறையைத் தேர்ந்தெடுக்கவும்',
          ),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: _gold.withOpacity(0.5),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: _gold.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.account_tree_rounded,
                  size: 44,
                  color: _gold,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _label('A/L විෂය ධාරාව', 'A/L Stream Selection', 'A/L துறை தேர்வு'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _label(
                  'උසස් පෙළ සිසුන් පළමුව තමන්ට අදාළ විෂය ධාරාව තෝරාගත යුතුය. ඉන්පසු ඊට අදාළ විෂයයන් තෝරාගත හැක.',
                  'A/L students first select the appropriate stream. The subjects will be connected to the selected stream.',
                  'உயர்தர மாணவர்கள் முதலில் பொருத்தமான துறையைத் தேர்ந்தெடுக்க வேண்டும். பின்னர் பாடங்களைத் தேர்ந்தெடுக்கலாம்.',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
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
        // කැඩිලා තිබුණු ගුණ කිරීමේ ලකුණ (*) මෙතන නිවැරදි කරලා තියෙනවා
        final cardWidth = (constraints.maxWidth - 36 - 12 * (columns - 1)) / columns;

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
          children: [
            const ZingaccBrandBanner(),
            const SizedBox(height: 22),
            _topChips(),
            const SizedBox(height: 24),
            Text(
              _label('ඔබගේ විෂය ධාරාව තෝරන්න', 'Choose Your A/L Stream', 'உங்கள் A/L துறையைத் தேர்ந்தெடுக்கவும்'),
              style: const TextStyle(
                color: _gold,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _label('ඔබ ඉගෙන ගන්නා විෂය ධාරාව තෝරන්න.', 'Select the stream you are studying.', 'நீங்கள் படிக்கும் துறையைத் தேர்ந்தெடுக்கவும்.'),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
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
    const background = Color(0xFF0A1C14);
    const panel = Color(0xFF112A20);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      decoration: BoxDecoration(
        color: background,
        border: Border(
          top: BorderSide(color: _gold.withOpacity(0.3)),
        ),
      ),
      child: FilledButton(
        onPressed: showStreams
            ? (selectedStream == null ? null : confirmStream)
            : openStreamList,
        style: FilledButton.styleFrom(
          backgroundColor: _gold,
          foregroundColor: background,
          disabledBackgroundColor: panel,
          disabledForegroundColor: Colors.white54,
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
                    ? _label('විෂයයන් තෝරන්න', 'Continue to Subjects', 'பாடங்களைத் தேர்ந்தெடுக்க தொடரவும்')
                    : _label('විෂය ධාරාව තෝරන්න', 'Continue to Stream Selection', 'துறைத் தேர்வுக்கு தொடரவும்'),
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

    return Semantics(
      selected: selected,
      child: Material(
        color:
        selected ? _gold.withOpacity(0.22) : const Color(0xFF112A20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(19),
          side: BorderSide(
            color: selected ? _gold : _gold.withOpacity(0.3),
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
                    color: _gold.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    item.icon,
                    color: _gold,
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
                          color: Colors.white70,
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
                  color: selected ? _gold : Colors.white54,
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
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}
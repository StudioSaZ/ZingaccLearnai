import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'zingacc_brand_banner.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({
    super.key,
    this.onLevelSelected,
  });

  final ValueChanged<String>? onLevelSelected;

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  String? _selectedLevel;
  String? _lockedLevel;
  bool _isAdmin = false;
  bool _loadingGrade = true;
  bool _savingGrade = false;

  @override
  void initState() {
    super.initState();
    _loadGrade();
  }

  Future<void> _loadGrade() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) setState(() => _loadingGrade = false);
        return;
      }
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final isAdmin = doc.data()?['is_admin'] == true;
      final value = doc.data()?['selected_grade'];
      final locked = value is String && value.isNotEmpty ? value : null;
      if (mounted) {
        setState(() {
          _isAdmin = isAdmin;
          _lockedLevel = locked;
          _selectedLevel = locked;
          _loadingGrade = false;
        });
      }
    } catch (e) {
      debugPrint('Grade loading failed: $e');
      if (mounted) {
        setState(() => _loadingGrade = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'ශ්‍රේණිය පරීක්ෂා කළ නොහැක. අන්තර්ජාල සම්බන්ධතාව පරීක්ෂා කරන්න.')),
        );
      }
    }
  }

  static const List<_LevelItem> _levels = [
    _LevelItem(
      id: 'grade_5_scholarship',
      title: 'Grade 5 Scholarship',
      subtitle: '5 වසර ශිෂ්‍යත්වය',
      icon: Icons.workspace_premium_rounded,
      color: Color(0xFFD4AF37), // Gold
    ),
    _LevelItem(
      id: 'grade_6',
      title: 'Grade 6',
      subtitle: '6 ශ්‍රේණිය',
      icon: Icons.looks_6_rounded,
      color: Color(0xFFD4AF37), // Gold
    ),
    _LevelItem(
      id: 'grade_7',
      title: 'Grade 7',
      subtitle: '7 ශ්‍රේණිය',
      icon: Icons.school_rounded,
      color: Color(0xFFD4AF37), // Gold
    ),
    _LevelItem(
      id: 'grade_8',
      title: 'Grade 8',
      subtitle: '8 ශ්‍රේණිය',
      icon: Icons.school_rounded,
      color: Color(0xFFD4AF37), // Gold
    ),
    _LevelItem(
      id: 'grade_9',
      title: 'Grade 9',
      subtitle: '9 ශ්‍රේණිය',
      icon: Icons.school_rounded,
      color: Color(0xFFD4AF37), // Gold
    ),
    _LevelItem(
      id: 'ol',
      title: 'O/L',
      subtitle: 'සාමාන්‍ය පෙළ',
      icon: Icons.menu_book_rounded,
      color: Color(0xFFD4AF37), // Gold
    ),
    _LevelItem(
      id: 'al',
      title: 'A/L',
      subtitle: 'උසස් පෙළ',
      icon: Icons.workspace_premium_rounded,
      color: Color(0xFFD4AF37), // Gold
    ),
  ];

  Future<void> _continue() async {
    final selected = _selectedLevel;
    if (selected == null || _savingGrade || _loadingGrade) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('කරුණාකර මුලින් Login වන්න.')),
      );
      return;
    }

    if (_isAdmin) {
      widget.onLevelSelected?.call(selected);
      return;
    }

    setState(() => _savingGrade = true);
    try {
      final userRef =
      FirebaseFirestore.instance.collection('users').doc(user.uid);
      final savedGrade =
      await FirebaseFirestore.instance.runTransaction<String>((tx) async {
        final snapshot = await tx.get(userRef);
        final existing = snapshot.data()?['selected_grade'];
        if (existing is String && existing.isNotEmpty) return existing;
        tx.set(
            userRef,
            {
              'selected_grade': selected,
              'selected_grade_at': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true));
        return selected;
      });
      if (!mounted) return;
      setState(() {
        _lockedLevel = savedGrade;
        _selectedLevel = savedGrade;
      });
      if (savedGrade != selected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'මෙම ගිණුමට කලින් තෝරාගත් ශ්‍රේණිය පමණක් භාවිත කළ හැක.')),
        );
        return;
      }
      widget.onLevelSelected?.call(savedGrade);
    } catch (e) {
      debugPrint('Grade saving failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'ශ්‍රේණිය සුරැකීමට නොහැකි වුණා. Firebase අවසර සහ අන්තර්ජාලය පරීක්ෂා කරන්න.')),
      );
    } finally {
      if (mounted) setState(() => _savingGrade = false);
    }
  }

  Widget _levelCard(_LevelItem item) {
    const gold = Color(0xFFD4AF37);
    final selected = _selectedLevel == item.id;
    final locked = !_isAdmin && _lockedLevel != null && _lockedLevel != item.id;

    return Semantics(
      selected: selected,
      child: Material(
        color: selected
            ? gold.withValues(alpha: 0.22)
            : const Color(0xFF112A20), // Dark Green Panel
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: locked || _loadingGrade || _savingGrade
              ? null
              : () => setState(() => _selectedLevel = item.id),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? gold : gold.withValues(alpha: 0.3),
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        item.icon,
                        color: gold,
                        size: 29,
                      ),
                    ),
                    Icon(
                      locked
                          ? Icons.lock_rounded
                          : selected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: selected ? gold : Colors.white54,
                      size: 23,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF0A1C14); // Deep Dark Green
    const gold = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Zingacc Learn AI',
          style: TextStyle(fontWeight: FontWeight.w700, color: gold),
        ),
        backgroundColor: background,
        foregroundColor: gold,
        elevation: 0,
        centerTitle: true,
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
                      final columns = constraints.maxWidth >= 700
                          ? 3
                          : constraints.maxWidth >= 340
                          ? 2
                          : 1;

                      const spacing = 12.0;
                      final cardWidth = (constraints.maxWidth -
                          36 -
                          spacing * (columns - 1)) /
                          columns;

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(
                          18,
                          14,
                          18,
                          20,
                        ),
                        children: [
                          const ZingaccBrandBanner(),
                          const SizedBox(height: 24),
                          const Text(
                            'Select Your Grade / Level',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: gold,
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'ඔබගේ ශ්‍රේණිය හෝ අධ්‍යයන මට්ටම තෝරන්න',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (_lockedLevel != null && !_isAdmin)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 14),
                              child: Text(
                                'මෙම ගිණුමට තෝරාගත් ශ්‍රේණිය අගුළු දමා ඇත.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: gold),
                              ),
                            ),
                          if (_isAdmin)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 14),
                              child: Text('ADMIN MODE — සියලුම ශ්‍රේණි විවෘතයි',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: gold,
                                      fontWeight: FontWeight.bold)),
                            ),
                          Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: [
                              for (final item in _levels)
                                SizedBox(
                                  width: cardWidth,
                                  child: _levelCard(item),
                                ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                  decoration: BoxDecoration(
                    color: background,
                    border: Border(
                      top: BorderSide(
                        color: gold.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  child: FilledButton.icon(
                    onPressed:
                    _selectedLevel == null || _loadingGrade || _savingGrade
                        ? null
                        : _continue,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Continue / ඉදිරියට'),
                    style: FilledButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: background,
                      disabledBackgroundColor: const Color(0xFF112A20),
                      disabledForegroundColor: Colors.white54,
                      minimumSize: const Size(double.infinity, 54),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
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

class _LevelItem {
  const _LevelItem({
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/dzikir_provider.dart';

class TasbihScreen extends ConsumerStatefulWidget {
  const TasbihScreen({super.key});

  @override
  ConsumerState<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends ConsumerState<TasbihScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  static const List<String> _labels = ['سُبْحَانَ اللّٰهُ', 'اَلْحَمْدُ لِلّٰهِ', 'اَللّٰهُ أَكْبَرُ'];
  static const List<String> _labelsLatin = ['Subhanallah', 'Alhamdulillah', 'Allahu Akbar'];
  static const List<Color> _colors = [AppColors.primary, AppColors.gold, Colors.deepOrange];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _tap() {
    // Animasi pulse
    _pulseCtrl.forward().then((_) => _pulseCtrl.reverse());

    final state = ref.read(tasbihProvider);
    final newCount = state.count + 1;

    // Haptic feedback
    if (newCount % state.target == 0) {
      // Milestone — getaran kuat
      HapticFeedback.heavyImpact();
    } else {
      // Biasa — getaran ringan
      HapticFeedback.lightImpact();
    }

    ref.read(tasbihProvider.notifier).tap();
  }

  String get _currentLabel {
    final count = ref.watch(tasbihProvider).count;
    final target = ref.watch(tasbihProvider).target;
    if (target == 0) return _labels[0];
    final phase = (count ~/ target) % 3;
    return _labels[phase];
  }

  String get _currentLabelLatin {
    final count = ref.watch(tasbihProvider).count;
    final target = ref.watch(tasbihProvider).target;
    if (target == 0) return _labelsLatin[0];
    final phase = (count ~/ target) % 3;
    return _labelsLatin[phase];
  }

  Color get _currentColor {
    final count = ref.watch(tasbihProvider).count;
    final target = ref.watch(tasbihProvider).target;
    if (target == 0) return _colors[0];
    final phase = (count ~/ target) % 3;
    return _colors[phase];
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tasbihProvider);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final inPhaseCount = state.count % state.target;
    final phasePct = state.target == 0 ? 0.0 : inPhaseCount / state.target;
    final totalRounds = state.count ~/ state.target;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _currentColor.withValues(alpha: isDark ? 0.25 : 0.12),
                    scheme.surface,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // AppBar manual
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_rounded,
                            color: scheme.onSurface),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          'Tasbih Digital',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.settings_rounded,
                            color: scheme.onSurfaceVariant),
                        onPressed: () => _showTargetDialog(context, state.target),
                      ),
                    ],
                  ),
                ),

                // Label saat ini
                const SizedBox(height: 16),
                Text(
                  _currentLabel,
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: _currentColor,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                Text(
                  _currentLabelLatin,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: _currentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                // Progress bar dalam fase
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$inPhaseCount',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: _currentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Target: ${state.target}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: phasePct,
                          minHeight: 8,
                          backgroundColor: isDark
                              ? _currentColor.withValues(alpha: 0.2)
                              : _currentColor.withValues(alpha: 0.12),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(_currentColor),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tombol tasbih utama
                const Spacer(),
                GestureDetector(
                  onTap: _tap,
                  child: AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (context, child) => Transform.scale(
                      scale: _pulseAnim.value,
                      child: child,
                    ),
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _currentColor,
                            _currentColor.withValues(alpha: 0.75),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _currentColor.withValues(alpha: 0.45),
                            blurRadius: 30,
                            spreadRadius: 4,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${state.count}',
                              style: GoogleFonts.poppins(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            Text(
                              'Ketuk',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),

                // Total ronde & info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _InfoChip(
                        label: 'Total Putaran',
                        value: '$totalRounds×',
                        color: _currentColor,
                      ),
                      _InfoChip(
                        label: 'Total Ketukan',
                        value: '${state.count}',
                        color: _currentColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tombol reset
                TextButton.icon(
                  onPressed: () => _confirmReset(context),
                  icon: Icon(Icons.refresh_rounded,
                      color: scheme.onSurfaceVariant, size: 18),
                  label: Text(
                    'Reset',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTargetDialog(BuildContext context, int currentTarget) {
    final options = [33, 34, 99, 100];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Target Per Fase',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        content: RadioGroup<int>(
          groupValue: currentTarget,
          onChanged: (val) {
            if (val != null) {
              ref.read(tasbihProvider.notifier).setTarget(val);
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options
                .map(
                  (opt) => RadioListTile<int>(
                    title: Text(
                      '$opt×',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    value: opt,
                    activeColor: AppColors.primary,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Reset Tasbih?',
            style:
                GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
        content: Text(
          'Semua hitungan akan dikembalikan ke 0.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              ref.read(tasbihProvider.notifier).reset();
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

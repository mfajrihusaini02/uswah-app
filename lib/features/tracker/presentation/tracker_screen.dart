import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../models/tracker_model.dart';
import '../providers/tracker_provider.dart';

class TrackerScreen extends ConsumerStatefulWidget {
  const TrackerScreen({super.key});

  @override
  ConsumerState<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends ConsumerState<TrackerScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'semua';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(trackerProvider.notifier).loadHabits(_selectedDate);
    });
  }

  void _changeDate(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    ref.read(trackerProvider.notifier).loadHabits(newDate);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trackerProvider);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final isToday = selectedDay.isAtSameMomentAs(today);
    final isFuture = selectedDay.isAfter(today);
    final isEditable = !isFuture;

    final dateFormatted = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate);

    final filteredHabits = state.habits.where((h) {
      if (_selectedCategory == 'semua') return true;
      return h.category == _selectedCategory;
    }).toList();

    return Scaffold(
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            expandedHeight: 110,
            pinned: true,
            centerTitle: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            title: Text(
              'Mutaba\'ah Yaumiyah',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -14,
                      bottom: -26,
                      child: Transform.scale(
                        scaleX: -1,
                        child: Icon(
                          Icons.task_alt_rounded,
                          size: 160,
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 24,
                      bottom: 12,
                      child: Icon(
                        Icons.check_circle_outline_rounded,
                        size: 44,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Baris Pemilih Tanggal (Kemarin & Hari Ini)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: () => _changeDate(_selectedDate.subtract(const Duration(days: 1))),
                      tooltip: 'Hari Sebelumnya',
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isToday ? 'Hari Ini' : DateFormat('dd MMM yyyy', 'id_ID').format(_selectedDate),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurface,
                              ),
                            ),
                            if (!isToday) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.info.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Catatan Lalu',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.info,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          dateFormatted,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: isToday
                          ? null
                          : () => _changeDate(_selectedDate.add(const Duration(days: 1))),
                      tooltip: 'Hari Berikutnya',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Card Progress Ibadah
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: isDark ? 0.45 : 0.28),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Capaian Ibadah',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${state.completedCount} / ${state.totalCount} Ibadah',
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${(state.progressRatio * 100).toInt()}%',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.gold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: state.progressRatio,
                          minHeight: 10,
                          backgroundColor: Colors.white.withValues(alpha: 0.25),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Filter Tab Kategori
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _CategoryChip(
                        label: 'Semua',
                        isSelected: _selectedCategory == 'semua',
                        onTap: () => setState(() => _selectedCategory = 'semua'),
                      ),
                      const SizedBox(width: 8),
                      _CategoryChip(
                        label: 'Sholat 5 Waktu',
                        isSelected: _selectedCategory == 'sholat',
                        onTap: () => setState(() => _selectedCategory = 'sholat'),
                      ),
                      const SizedBox(width: 8),
                      _CategoryChip(
                        label: 'Tilawah',
                        isSelected: _selectedCategory == 'quran',
                        onTap: () => setState(() => _selectedCategory = 'quran'),
                      ),
                      const SizedBox(width: 8),
                      _CategoryChip(
                        label: 'Dzikir',
                        isSelected: _selectedCategory == 'dzikir',
                        onTap: () => setState(() => _selectedCategory = 'dzikir'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Daftar Item Habit Check
                ...filteredHabits.map((habit) {
                  return _HabitTile(
                    habit: habit,
                    isEditable: isEditable,
                    onToggle: () {
                      if (isEditable) {
                        ref.read(trackerProvider.notifier).toggleHabit(habit.id);
                      }
                    },
                  );
                }),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: isSelected,
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
        ),
      ),
      selectedColor: AppColors.primary,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      onSelected: (_) => onTap(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      showCheckmark: false,
    );
  }
}

class _HabitTile extends StatelessWidget {
  final HabitItem habit;
  final bool isEditable;
  final VoidCallback onToggle;

  const _HabitTile({
    required this.habit,
    this.isEditable = true,
    required this.onToggle,
  });

  IconData _getIcon(String category) {
    switch (category) {
      case 'sholat':
        return Icons.mosque_rounded;
      case 'quran':
        return Icons.menu_book_rounded;
      case 'dzikir':
        return Icons.spa_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          enabled: isEditable,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: habit.isCompleted
                  ? AppColors.primarySoft
                  : scheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _getIcon(habit.category),
              color: habit.isCompleted ? AppColors.primary : scheme.onSurfaceVariant,
              size: 22,
            ),
          ),
          title: Text(
            habit.title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              decoration: habit.isCompleted ? TextDecoration.lineThrough : null,
              color: habit.isCompleted
                  ? scheme.onSurfaceVariant
                  : scheme.onSurface,
            ),
          ),
          subtitle: Text(
            habit.subtitle,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: scheme.onSurfaceVariant,
            ),
          ),
          trailing: Transform.scale(
            scale: 1.1,
            child: Checkbox(
              value: habit.isCompleted,
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              onChanged: isEditable ? (_) => onToggle() : null,
            ),
          ),
          onTap: isEditable ? onToggle : null,
        ),
      ),
    );
  }
}

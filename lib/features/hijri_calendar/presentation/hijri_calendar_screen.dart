import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/hijri_helper.dart';

class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  late int _selectedYear;
  late int _selectedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final hNow = HijriCalendar.fromDate(now);
    _selectedYear = hNow.hYear;
    _selectedMonth = hNow.hMonth;
    _selectedDate = now;
  }

  void _previousMonth() {
    setState(() {
      if (_selectedMonth == 1) {
        _selectedMonth = 12;
        _selectedYear--;
      } else {
        _selectedMonth--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_selectedMonth == 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else {
        _selectedMonth++;
      }
    });
  }

  void _goToToday() {
    final now = DateTime.now();
    final hNow = HijriCalendar.fromDate(now);
    setState(() {
      _selectedYear = hNow.hYear;
      _selectedMonth = hNow.hMonth;
      _selectedDate = now;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final monthName = HijriHelper.getMonthName(_selectedMonth);
    final hCalc = HijriCalendar();
    final totalDays = hCalc.getDaysInMonth(_selectedYear, _selectedMonth);

    // Dapatkan tanggal Masehi hari pertama bulan ini untuk offset hari (Ahad, Sen, dst)
    final firstDayGregorian = hCalc.hijriToGregorian(_selectedYear, _selectedMonth, 1);
    final startWeekday = firstDayGregorian.weekday % 7; // 0 = Minggu/Ahad, 1 = Senin, ...

    // Dapatkan tanggal Masehi hari terakhir bulan ini untuk rentang Masehi
    final lastDayGregorian = hCalc.hijriToGregorian(_selectedYear, _selectedMonth, totalDays);
    final gregorianRange = '${DateFormat('d MMM', 'id_ID').format(firstDayGregorian)} - ${DateFormat('d MMM yyyy', 'id_ID').format(lastDayGregorian)}';

    final fasting = HijriHelper.getFastingInfo(_selectedDate);
    final todayHijri = HijriHelper.formatHijriDate(_selectedDate);
    final todayGregorian = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate);

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
              'Kalender Hijriah',
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
                          Icons.calendar_month_rounded,
                          size: 160,
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 24,
                      bottom: 12,
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 44,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.today_rounded),
                onPressed: _goToToday,
                tooltip: 'Hari Ini',
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header Navigasi Bulan Hijriah
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.shadow.withValues(alpha: isDark ? 0.35 : 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left_rounded),
                            onPressed: _previousMonth,
                          ),
                          Column(
                            children: [
                              Text(
                                '$monthName $_selectedYear H',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                gregorianRange,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right_rounded),
                            onPressed: _nextMonth,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Header Nama Hari (Ahad - Sabtu)
                      Row(
                        children: ['Ahad', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'].map((day) {
                          final isWeekend = day == 'Ahad' || day == 'Jum';
                          return Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isWeekend ? AppColors.gold : scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      // Grid Tanggal Kalender
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: startWeekday + totalDays,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 6,
                          childAspectRatio: 0.82,
                        ),
                        itemBuilder: (context, index) {
                          if (index < startWeekday) {
                            return const SizedBox.shrink();
                          }
                          final hDay = index - startWeekday + 1;
                          final gDate = hCalc.hijriToGregorian(_selectedYear, _selectedMonth, hDay);

                          final isSelected = _selectedDate.year == gDate.year &&
                              _selectedDate.month == gDate.month &&
                              _selectedDate.day == gDate.day;

                          final now = DateTime.now();
                          final isToday = now.year == gDate.year &&
                              now.month == gDate.month &&
                              now.day == gDate.day;

                          final fasting = HijriHelper.getFastingInfo(gDate);

                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedDate = gDate;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : isToday
                                        ? AppColors.goldSoft
                                        : scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(color: AppColors.primary, width: 2)
                                    : isToday
                                        ? Border.all(color: AppColors.gold, width: 1.5)
                                        : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$hDay',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? Colors.white
                                          : isToday
                                              ? AppColors.primary
                                              : scheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    '${gDate.day}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: isSelected
                                          ? Colors.white.withValues(alpha: 0.8)
                                          : scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  if (fasting.isToday) ...[
                                    const SizedBox(height: 2),
                                    Container(
                                      width: 5,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppColors.gold : AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // Card Detail Tanggal yang Dipilih
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.shadow.withValues(alpha: isDark ? 0.35 : 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  todayHijri,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: scheme.onSurface,
                                  ),
                                ),
                                Text(
                                  todayGregorian,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: fasting.isToday
                                  ? AppColors.goldSoft
                                  : AppColors.primarySoft,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.wb_twilight_rounded,
                              color: fasting.isToday ? AppColors.gold : AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fasting.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: scheme.onSurface,
                                  ),
                                ),
                                Text(
                                  fasting.description,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // Legenda Kalender
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _LegendItem(color: AppColors.gold, label: 'Hari Ini'),
                      _LegendItem(color: AppColors.primary, label: 'Puasa Sunnah'),
                      _LegendItem(color: scheme.onSurface, label: 'Dipilih'),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

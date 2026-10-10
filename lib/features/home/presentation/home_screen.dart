import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/services/notification_service.dart';
import '../../../shared/utils/hijri_helper.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/uswah_refresh_indicator.dart';
import '../../prayer_times/providers/prayer_times_provider.dart';
import '../../settings/providers/notification_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../tracker/providers/tracker_provider.dart';

class HomeScreen extends ConsumerWidget {
  final ValueChanged<int>? onNavigate;

  const HomeScreen({super.key, this.onNavigate});

  Future<void> _requestNotificationPermission(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await NotificationService.requestPermission();
    await ref
        .read(notificationSettingsProvider.notifier)
        .setPrayerRemindersEnabled(true);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengingat sholat harian telah diaktifkan.'),
        ),
      );
    }
  }

  String _getGreeting(DateTime now) {
    final hour = now.hour;
    if (hour < 11) return 'Assalamu\'alaikum';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final greeting = _getGreeting(now);
    final today = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);
    final hijriDate = HijriHelper.formatHijriDate(now);
    final prayerState = ref.watch(prayerTimesProvider);
    final location = ref.watch(settingsProvider).locationName;

    return Scaffold(
      body: UswahRefreshIndicator(
        onRefresh: () async {
          final pt = await ref.refresh(prayerTimesProvider.future);
          ref.read(prayerTimesLastUpdatedProvider.notifier).state =
              DateTime.now();
          await ref
              .read(notificationSettingsProvider.notifier)
              .scheduleIfEnabled({
                'Subuh': pt.fajr,
                'Terbit': pt.sunrise,
                'Dzuhur': pt.dhuhr,
                'Ashar': pt.asr,
                'Maghrib': pt.maghrib,
                'Isya': pt.isha,
              });
        },
        child: CustomScrollView(
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
                'Uswah App',
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
                            Icons.mosque_rounded,
                            size: 160,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 24,
                        bottom: 12,
                        child: Icon(
                          Icons.mosque_outlined,
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
                  icon: const Icon(Icons.notifications_none_rounded),
                  onPressed: () => _requestNotificationPermission(context, ref),
                  tooltip: 'Aktifkan notifikasi',
                ),
                const SizedBox(width: 8),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),
                  _GreetingCard(
                    greeting: greeting,
                    date: today,
                    hijriDate: hijriDate,
                    location: location,
                  ),
                  const SizedBox(height: 16),
                  _NextPrayerCard(prayerState: prayerState),
                  const SizedBox(height: 16),
                  const _TrackerQuickCard(),
                  const SizedBox(height: 16),
                  const _FastingCard(),
                  const SizedBox(height: 24),
                  const SectionTitle(
                    title: 'Menu Fitur',
                    subtitle: 'Semua layanan Uswah App',
                  ),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.98,
                ),
                delegate: SliverChildListDelegate([
                  _FeatureCard(
                    title: 'Arah Kiblat',
                    subtitle: 'Kompas presisi',
                    icon: Icons.explore_rounded,
                    color: AppColors.primary,
                    softColor: AppColors.primarySoft,
                    onTap: () => context.push('/qibla'),
                  ),
                  _FeatureCard(
                    title: 'Dzikir Pagi-Petang',
                    subtitle: 'Bacaan dzikir harian',
                    icon: Icons.self_improvement_rounded,
                    color: const Color(0xFF7B5EA7),
                    softColor: const Color(0xFFEDE7F6),
                    onTap: () => context.push('/dzikir'),
                  ),
                  _FeatureCard(
                    title: 'Tasbih Digital',
                    subtitle: 'Hitung dzikir & tasbih',
                    icon: Icons.grain_rounded,
                    color: const Color(0xFF00897B),
                    softColor: const Color(0xFFE0F2F1),
                    onTap: () => context.push('/tasbih'),
                  ),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([const _DailyDuaCard()]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final String greeting;
  final String date;
  final String hijriDate;
  final String location;

  const _GreetingCard({
    required this.greeting,
    required this.date,
    required this.hijriDate,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Semoga harimu penuh berkah',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(icon: Icons.calendar_today_rounded, label: date),
              GestureDetector(
                onTap: () => context.push('/hijri-calendar'),
                child: _InfoPill(
                  icon: Icons.auto_awesome_rounded,
                  label: hijriDate,
                ),
              ),
              _InfoPill(icon: Icons.location_on_rounded, label: location),
            ],
          ),
        ],
      ),
    );
  }
}

class _FastingCard extends StatelessWidget {
  const _FastingCard();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final info = HijriHelper.getFastingInfo(now);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/hijri-calendar'),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: info.isToday
                      ? AppColors.goldSoft
                      : AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wb_twilight_rounded,
                  color: info.isToday ? AppColors.gold : AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: info.isToday
                                ? AppColors.gold.withValues(alpha: 0.15)
                                : AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            info.statusText,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: info.isToday
                                  ? AppColors.gold
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info.title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      info.description,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackerQuickCard extends ConsumerWidget {
  const _TrackerQuickCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trackerProvider);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/tracker'),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.task_alt_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mutaba\'ah Yaumiyah',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Capaian Hari Ini: ${state.completedCount} dari ${state.totalCount} Ibadah',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: state.progressRatio,
                        minHeight: 6,
                        backgroundColor: scheme.surfaceContainerHighest,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color softColor;
  final VoidCallback? onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.softColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final soft = isDark ? color.withValues(alpha: 0.18) : softColor;

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: soft,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextPrayerCard extends ConsumerStatefulWidget {
  final AsyncValue<dynamic> prayerState;

  const _NextPrayerCard({required this.prayerState});

  @override
  ConsumerState<_NextPrayerCard> createState() => _NextPrayerCardState();
}

class _NextPrayerCardState extends ConsumerState<_NextPrayerCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lastUpdated = ref.watch(prayerTimesLastUpdatedProvider);

    return widget.prayerState.when(
      data: (data) => _buildSchedule(data, lastUpdated),
      loading: () => const _PrayerCardSkeleton(),
      error: (err, _) => _buildEmpty(),
    );
  }

  Widget _buildEmpty() {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.schedule_rounded),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Jadwal sholat akan muncul setelah lokasi terkirim',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchedule(dynamic data, DateTime? lastUpdated) {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    final prayers = <({String name, String time, IconData icon})>[
      (name: 'Subuh', time: data.fajr, icon: Icons.wb_twilight_rounded),
      (name: 'Dzuhur', time: data.dhuhr, icon: Icons.wb_sunny_rounded),
      (name: 'Ashar', time: data.asr, icon: Icons.light_mode_rounded),
      (name: 'Maghrib', time: data.maghrib, icon: Icons.nights_stay_rounded),
      (name: 'Isya', time: data.isha, icon: Icons.dark_mode_rounded),
    ];

    // Hitung sholat berikutnya beserta sisa waktunya.
    int? nextIndex;
    DateTime? nextTime;
    for (var i = 0; i < prayers.length; i++) {
      final t = prayers[i].time;
      if (t.isEmpty) continue;
      final parts = t.split(':');
      final prayerTime = DateTime.parse('$todayStr ${parts[0]}:${parts[1]}:00');
      if (prayerTime.isAfter(now)) {
        nextIndex = i;
        nextTime = prayerTime;
        break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield_moon_rounded,
                color: AppColors.secondaryBright,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Jadwal Sholat Hari Ini',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              if (lastUpdated != null)
                Text(
                  'Terakhir perbarui ${DateFormat('HH:mm').format(lastUpdated)}',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (nextIndex != null && nextTime != null)
            _CountdownBanner(
              name: prayers[nextIndex].name,
              time: prayers[nextIndex].time,
              nextTime: nextTime,
              icon: prayers[nextIndex].icon,
            )
          else
            const SizedBox(height: 8),
          const SizedBox(height: 16),
          ...prayers.asMap().entries.map((entry) {
            final p = entry.value;
            final isNext = entry.key == nextIndex;
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isNext
                    ? Colors.white.withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(p.icon, color: Colors.white, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        p.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: isNext
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (isNext) ...[
                        Text(
                          'Berikutnya',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryBright,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        p.time,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CountdownBanner extends StatelessWidget {
  final String name;
  final String time;
  final DateTime nextTime;
  final IconData icon;

  const _CountdownBanner({
    required this.name,
    required this.time,
    required this.nextTime,
    required this.icon,
  });

  String _durationText(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}j ${m}m ${s}d';
    return '${m}m ${s}d';
  }

  @override
  Widget build(BuildContext context) {
    final remaining = nextTime.difference(DateTime.now());
    final overdue = remaining.isNegative;
    final display = overdue ? remaining.abs() : remaining;
    final label = overdue ? 'Terlewat' : 'Waktu tersisa';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name · $time',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _durationText(display),
            style: GoogleFonts.poppins(
              color: AppColors.secondaryBright,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerCardSkeleton extends StatelessWidget {
  const _PrayerCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.wb_sunny_rounded,
                    color: scheme.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 160,
                  height: 16,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            for (var i = 0; i < 5; i++) ...[
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _DailyDuaCard extends StatelessWidget {
  const _DailyDuaCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: context.secondaryAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: context.secondaryAccent,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Doa Harian',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.secondaryAccent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
            textAlign: TextAlign.center,
            style: GoogleFonts.scheherazadeNew(
              fontSize: 32,
              height: 1.8,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '"Ya Tuhan kami, berikanlah kami kebaikan di dunia dan kebaikan di akhirat, dan peliharalah kami dari azab neraka"',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: scheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'QS. Al-Baqarah: 201',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

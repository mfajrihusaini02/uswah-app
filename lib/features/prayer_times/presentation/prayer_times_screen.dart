import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/models/prayer_times_model.dart';
import '../../../shared/services/location_service.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/uswah_refresh_indicator.dart';
import '../../settings/providers/notification_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/prayer_times_provider.dart';

class PrayerTimesScreen extends ConsumerStatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  ConsumerState<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends ConsumerState<PrayerTimesScreen> {
  bool _loading = true;
  String _locating = '';

  Future<void> _getCurrentLocation() async {
    setState(() {
      _loading = true;
      _locating = '';
    });

    final position = await LocationService.getCurrentPosition();
    if (!mounted) return;

    if (position == null) {
      setState(() {
        _loading = false;
        _locating =
            'Layanan / izin lokasi tidak aktif. Menggunakan Jakarta default.';
      });
      await _useJakartaDefault();
      return;
    }

    String city;
    try {
      city = await LocationService.cityNameFrom(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      city = 'Lokasi Anda';
    }
    if (!mounted) return;

    await ref.read(settingsProvider.notifier).setCoordinates(
          latitude: position.latitude,
          longitude: position.longitude,
          locationName: city,
        );
    ref.invalidate(prayerTimesProvider);
    setState(() {
      _loading = false;
    });
  }

  Future<void> _useJakartaDefault() async {
    final fallback = await LocationService.getDefaultCoords();
    await ref.read(settingsProvider.notifier).setCoordinates(
          latitude: fallback.latitude,
          longitude: fallback.longitude,
          locationName: 'Jakarta',
        );
    ref.invalidate(prayerTimesProvider);
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
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
                'Jadwal Sholat',
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
                          Icons.wb_sunny_outlined,
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
                  icon: const Icon(Icons.my_location_rounded),
                  onPressed: _getCurrentLocation,
                  tooltip: 'Gunakan lokasi saat ini',
                ),
                const SizedBox(width: 8),
              ],
            ),
            if (_loading)
              const SliverFillRemaining(
                child: LoadingView(message: 'Mendeteksi lokasi Anda...'),
              )
            else
              ...ref.watch(prayerTimesProvider).when(
                    skipLoadingOnRefresh: false,
                    loading: () => [
                      const SliverToBoxAdapter(child: _PrayerTimesSkeleton()),
                    ],
                    error: (error, stackTrace) => [
                      SliverFillRemaining(
                        child: ErrorView(
                          message: 'Tidak dapat memuat jadwal sholat.',
                          onRetry: _getCurrentLocation,
                        ),
                      ),
                    ],
                    data: (prayerTimes) => [
                      _PrayerTimesView(
                        prayerTimes: prayerTimes,
                        notice: _locating,
                        location: ref.watch(settingsProvider).locationName,
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class _PrayerTimesView extends StatefulWidget {
  final PrayerTimesModel prayerTimes;
  final String notice;
  final String location;

  const _PrayerTimesView({
    required this.prayerTimes,
    this.notice = '',
    this.location = 'Jakarta',
  });

  @override
  State<_PrayerTimesView> createState() => _PrayerTimesViewState();
}

class _PrayerTimesViewState extends State<_PrayerTimesView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Perbarui status sholat aktif & countdown secara berkala (setiap 1 detik).
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
    final now = DateTime.now();
    final today = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);

    final items = _buildItems(widget.prayerTimes, now);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _HeaderDateCard(
            today: today,
            notice: widget.notice,
            location: widget.location,
            nextItem: items.next,
            now: now,
          ),
          const SizedBox(height: 20),
          ...items.list.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _PrayerTile(
              prayer: item,
              isActive: index == items.activeIndex,
              isNext: index == items.nextIndex,
              isLast: index == items.list.length - 1,
              now: now,
            );
          }),
        ]),
      ),
    );
  }
}

class _PrayerTiming {
  final String name;
  final String time;
  final DateTime dateTime;
  final IconData icon;
  final Color color;

  _PrayerTiming({
    required this.name,
    required this.time,
    required this.dateTime,
    required this.icon,
    required this.color,
  });
}

class _ScheduleResult {
  final List<_PrayerTiming> list;
  final int? activeIndex;
  final int? nextIndex;
  final _PrayerTiming? next;

  _ScheduleResult({
    required this.list,
    required this.activeIndex,
    required this.nextIndex,
    required this.next,
  });
}

_ScheduleResult _buildItems(PrayerTimesModel pt, DateTime now) {
  final todayStr = DateFormat('yyyy-MM-dd').format(now);

  DateTime toTime(String t) {
    final parts = t.split(':');
    return DateTime.parse('${todayStr}T${parts[0]}:${parts[1]}:00');
  }

  final raw = [
    _PrayerTiming(
      name: 'Subuh',
      time: pt.fajr,
      dateTime: toTime(pt.fajr),
      icon: Icons.wb_twilight_rounded,
      color: AppColors.info,
    ),
    _PrayerTiming(
      name: 'Terbit',
      time: pt.sunrise,
      dateTime: toTime(pt.sunrise),
      icon: Icons.wb_sunny_rounded,
      color: AppColors.gold,
    ),
    _PrayerTiming(
      name: 'Dzuhur',
      time: pt.dhuhr,
      dateTime: toTime(pt.dhuhr),
      icon: Icons.wb_sunny_rounded,
      color: AppColors.success,
    ),
    _PrayerTiming(
      name: 'Ashar',
      time: pt.asr,
      dateTime: toTime(pt.asr),
      icon: Icons.wb_cloudy_rounded,
      color: AppColors.info,
    ),
    _PrayerTiming(
      name: 'Maghrib',
      time: pt.maghrib,
      dateTime: toTime(pt.maghrib),
      icon: Icons.nights_stay_rounded,
      color: AppColors.warning,
    ),
    _PrayerTiming(
      name: 'Isya',
      time: pt.isha,
      dateTime: toTime(pt.isha),
      icon: Icons.nightlight_round,
      color: AppColors.primaryDark,
    ),
  ];

  final list = raw.toList();

  int? nextIndex;
  for (var i = 0; i < list.length; i++) {
    if (list[i].dateTime.isAfter(now)) {
      nextIndex = i;
      break;
    }
  }

  int? activeIndex;
  if (nextIndex != null) {
    activeIndex = nextIndex - 1;
    if (activeIndex < 0) activeIndex = null;
  } else {
    // Semua sholat hari ini sudah lewat; Isya dianggap berlangsung sampai tengah malam.
    activeIndex = list.length - 1;
  }

  return _ScheduleResult(
    list: list,
    activeIndex: activeIndex,
    nextIndex: nextIndex,
    next: nextIndex != null ? list[nextIndex] : null,
  );
}

class _HeaderDateCard extends StatelessWidget {
  final String today;
  final String notice;
  final String location;
  final _PrayerTiming? nextItem;
  final DateTime now;

  const _HeaderDateCard({
    required this.today,
    required this.notice,
    required this.location,
    required this.nextItem,
    required this.now,
  });

  String _durationText(DateTime nextTime, DateTime current) {
    final diff = nextTime.difference(current);
    if (diff.isNegative) return '00:00:00';
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    final s = diff.inSeconds % 60;
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(h)}:${two(m)}:${two(s)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      clipBehavior: Clip.antiAlias,
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
      child: Stack(
        children: [
          Positioned(
            right: -18,
            bottom: -30,
            child: Icon(
              Icons.mosque_rounded,
              size: 168,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.secondaryBright,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      today,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (nextItem != null) ...[
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            nextItem!.icon,
                            color: AppColors.secondaryBright,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sholat berikutnya',
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${nextItem!.name} · ${nextItem!.time}',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _durationText(nextItem!.dateTime, now),
                          style: GoogleFonts.poppins(
                            color: AppColors.secondaryBright,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (notice.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          notice,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerTile extends StatelessWidget {
  final _PrayerTiming prayer;
  final bool isActive;
  final bool isNext;
  final bool isLast;
  final DateTime now;

  const _PrayerTile({
    required this.prayer,
    required this.isActive,
    required this.isNext,
    required this.isLast,
    required this.now,
  });

  String? get _badgeLabel {
    if (isNext) return 'Berikutnya';
    if (isActive) {
      if (prayer.name == 'Terbit') return 'Berlangsung';
      return 'Sekarang';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final highlightColor = isNext
        ? AppColors.gold
        : (isActive ? AppColors.success : prayer.color);
    final softHighlight = highlightColor.withValues(alpha: isDark ? 0.22 : 0.12);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: (isActive || isNext) ? softHighlight : scheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (isActive || isNext)
            BoxShadow(
              color: highlightColor.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          else
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: (isActive || isNext)
                  ? highlightColor.withValues(alpha: isDark ? 0.3 : 0.16)
                  : prayer.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              prayer.icon,
              color: (isActive || isNext) ? highlightColor : prayer.color,
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
                    Text(
                      prayer.name,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    if (_badgeLabel != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isNext
                              ? AppColors.gold
                              : AppColors.success,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _badgeLabel!,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (isActive && prayer.name != 'Terbit') ...[
                  const SizedBox(height: 2),
                  Text(
                    'Waktu sholat ini sedang berlangsung',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: highlightColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            prayer.time,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: (isActive || isNext)
                  ? highlightColor
                  : context.primaryAccent,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerTimesSkeleton extends StatelessWidget {
  const _PrayerTimesSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const _ShimmerBox(height: 168, radius: 24),
        const SizedBox(height: 20),
        for (var i = 0; i < 6; i++) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              children: [
                _ShimmerBox(width: 46, height: 46, radius: 13),
                SizedBox(width: 14),
                Expanded(child: _ShimmerBox(height: 16, radius: 8)),
                SizedBox(width: 12),
                _ShimmerBox(width: 56, height: 20, radius: 8),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

/// Kotak gradient yang beranimasi menyerupai efek shimmer.
class _ShimmerBox extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;

  const _ShimmerBox({this.width, required this.height, required this.radius});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHighest;
    final highlight = scheme.surfaceContainerHigh.withValues(alpha: 0.9);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1.5 + 3 * t, 0),
              end: Alignment(-0.5 + 3 * t, 0),
              colors: [base, highlight, base],
              stops: const [0.2, 0.5, 0.8],
            ),
          ),
        );
      },
    );
  }
}

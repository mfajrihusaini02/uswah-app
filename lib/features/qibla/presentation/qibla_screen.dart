import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/services/location_service.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/qibla_provider.dart';

class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen> {
  StreamSubscription<CompassEvent>? _compassSub;
  double _heading = 0.0;
  bool _hasRealSensor = false;

  // Mode pengujian (tetap tersedia)
  bool _forceTestMode = false;
  double _simulatedHeading = 0.0;

  @override
  void initState() {
    super.initState();
    _startCompass();
    _initLocation();
  }

  void _startCompass() {
    try {
      final events = FlutterCompass.events;
      if (events == null) {
        // Perangkat tidak memiliki sensor kompas
        setState(() => _hasRealSensor = false);
        return;
      }

      _compassSub = events.listen((event) {
        final h = event.heading;
        if (h != null && !h.isNaN) {
          // Hanya update state heading – TIDAK rebuild seluruh widget tree
          setState(() {
            _heading = (h + 360) % 360;
            _hasRealSensor = true;
          });
        }
      });
    } catch (_) {
      setState(() => _hasRealSensor = false);
    }
  }

  Future<void> _initLocation() async {
    final pos = await LocationService.getCurrentPosition();
    if (pos != null && mounted) {
      final city = await LocationService.cityNameFrom(
        latitude: pos.latitude,
        longitude: pos.longitude,
      );
      ref.read(settingsProvider.notifier).setCoordinates(
            latitude: pos.latitude,
            longitude: pos.longitude,
            locationName: city,
          );
    }
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final lat = settings.latitude ?? -6.200000;
    final lng = settings.longitude ?? 106.816666;
    final qiblaDir = calculateQiblaDirection(lat, lng);

    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locationText =
        settings.locationName.isNotEmpty ? settings.locationName : 'Lokasi Anda';

    // Pilih sumber heading: sensor fisik atau simulasi manual
    final useSimulation = _forceTestMode || !_hasRealSensor;
    final heading = useSimulation ? _simulatedHeading : _heading;

    // Hitung alignment Kiblat
    final relDeg = ((qiblaDir - heading + 360) % 360);
    final normDiff = relDeg > 180 ? 360 - relDeg : relDeg;
    final isFacing = normDiff <= 3.5;

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
              'Arah Kiblat',
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
                          Icons.explore_rounded,
                          size: 160,
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 24,
                      bottom: 12,
                      child: Icon(
                        Icons.navigation_rounded,
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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Status Banner
                _AlignmentBanner(
                  isFacing: isFacing,
                  locationName: locationText,
                  qiblaDegree: '${qiblaDir.toStringAsFixed(1)}°',
                ),
                const SizedBox(height: 28),

                // Compass Dial
                Center(
                  child: _CompassDial(
                    heading: heading,
                    qiblaDir: qiblaDir,
                    isFacing: isFacing,
                    isDark: isDark,
                    scheme: scheme,
                  ),
                ),

                const SizedBox(height: 32),

                // Info Cards
                Row(
                  children: [
                    Expanded(
                      child: _InfoTile(
                        title: 'Sudut Kiblat',
                        value: '${qiblaDir.toStringAsFixed(1)}°',
                        subtitle: 'Dari Utara (0°)',
                        icon: Icons.explore_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoTile(
                        title: 'Arah Kompas',
                        value: '${heading.toStringAsFixed(0)}°',
                        subtitle: useSimulation ? 'Simulasi' : 'Sensor HP',
                        icon: Icons.navigation_outlined,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Mode Pengujian Card (selalu ada, bisa di-toggle)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: useSimulation ? AppColors.infoSoft : scheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: useSimulation
                          ? AppColors.info.withValues(alpha: 0.3)
                          : scheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.tune_rounded,
                                size: 20,
                                color: AppColors.info,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Mode Pengujian',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: useSimulation,
                            onChanged: (_hasRealSensor || _forceTestMode)
                                ? (val) {
                                    setState(() {
                                      _forceTestMode = val;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                      if (useSimulation) ...[
                        const SizedBox(height: 4),
                        Text(
                          _hasRealSensor
                              ? 'Mode paksa aktif. Geser slider untuk menguji kompas:'
                              : 'Sensor magnetometer tidak terdeteksi. Geser slider:',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        Slider(
                          value: _simulatedHeading,
                          min: 0,
                          max: 360,
                          divisions: 360,
                          label: '${_simulatedHeading.round()}°',
                          onChanged: (val) {
                            setState(() => _simulatedHeading = val);
                          },
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Tips kalibrasi
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
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
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppColors.primarySoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.screen_rotation_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tips Akurasi Kompas',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Jauhkan HP dari benda ber-magnetik. Putar HP membentuk pola angka 8 jika kompas terasa kaku.',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: scheme.onSurfaceVariant,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
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

// ─── Compass Dial Widget (terpisah agar tidak rebuild konten lain) ───────────
class _CompassDial extends StatelessWidget {
  final double heading;
  final double qiblaDir;
  final bool isFacing;
  final bool isDark;
  final ColorScheme scheme;

  const _CompassDial({
    required this.heading,
    required this.qiblaDir,
    required this.isFacing,
    required this.isDark,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    final relDeg = ((qiblaDir - heading + 360) % 360);

    return Container(
      width: 310,
      height: 310,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.surface,
        boxShadow: [
          BoxShadow(
            color: isFacing
                ? AppColors.primary.withValues(alpha: 0.35)
                : scheme.shadow.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: isFacing ? 28 : 20,
            spreadRadius: isFacing ? 4 : 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Piringan kompas berputar (mengikuti heading HP – arah Utara selalu ke atas)
          AnimatedRotation(
            turns: -heading / 360.0,
            duration: const Duration(milliseconds: 80),
            curve: Curves.linear,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ring border
                Container(
                  width: 290,
                  height: 290,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                ),
                // Label arah mata angin
                _compassLabel(context, 'U', Alignment.topCenter,
                    const EdgeInsets.only(top: 14), Colors.redAccent),
                _compassLabel(context, 'T', Alignment.centerRight,
                    const EdgeInsets.only(right: 16), null),
                _compassLabel(context, 'S', Alignment.bottomCenter,
                    const EdgeInsets.only(bottom: 14), null),
                _compassLabel(context, 'B', Alignment.centerLeft,
                    const EdgeInsets.only(left: 16), null),
                // Ikon Ka'bah pada sudut Kiblat
                Transform.rotate(
                  angle: qiblaDir * (pi / 180.0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.mosque_rounded,
                            size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Jarum penunjuk – selalu mengarah ke Kiblat
          AnimatedRotation(
            turns: relDeg / 360.0,
            duration: const Duration(milliseconds: 80),
            curve: Curves.linear,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.navigation_rounded,
                  size: 84,
                  color: isFacing
                      ? AppColors.primary
                      : (isDark ? AppColors.gold : AppColors.primaryLight),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Center pin
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFacing ? AppColors.primary : AppColors.gold,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2), blurRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _compassLabel(BuildContext context, String label, Alignment alignment,
      EdgeInsets padding, Color? color) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: alignment,
      child: Padding(
        padding: padding,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color ?? scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ─── Banner alignment Kiblat ────────────────────────────────────────────────
class _AlignmentBanner extends StatelessWidget {
  final bool isFacing;
  final String locationName;
  final String qiblaDegree;

  const _AlignmentBanner({
    required this.isFacing,
    required this.locationName,
    required this.qiblaDegree,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: isFacing
            ? AppColors.primary
            : (scheme.brightness == Brightness.dark
                ? scheme.surfaceContainerHigh
                : Colors.white),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isFacing
                ? AppColors.primary.withValues(alpha: 0.3)
                : scheme.shadow.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isFacing
                  ? Colors.white.withValues(alpha: 0.2)
                  : AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFacing ? Icons.check_circle_rounded : Icons.location_on_rounded,
              color: isFacing ? Colors.white : AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFacing
                      ? 'Menghadap Kiblat Presisi'
                      : 'Lokasi: $locationName',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isFacing ? Colors.white : scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isFacing
                      ? 'HP sudah lurus ke arah Ka\'bah'
                      : 'Arahkan panah menuju Ka\'bah ($qiblaDegree)',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isFacing
                        ? Colors.white.withValues(alpha: 0.9)
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info tile ───────────────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _InfoTile({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          Text(
            subtitle,
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

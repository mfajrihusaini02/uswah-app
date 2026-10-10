import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/services/notification_service.dart';
import '../../onboarding/providers/onboarding_provider.dart';
// import '../../prayer_times/providers/prayer_times_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '-';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = '${info.version}+${info.buildNumber}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notif = ref.watch(notificationSettingsProvider);
    final scheme = Theme.of(context).colorScheme;

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
              'Pengaturan',
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
                          Icons.settings_rounded,
                          size: 160,
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 24,
                      bottom: 12,
                      child: Icon(
                        Icons.tune_rounded,
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildGroup(
                  title: 'Tampilan',
                  icon: Icons.palette_outlined,
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.dark_mode_rounded),
                      title: const Text('Mode Gelap'),
                      subtitle: const Text('Nyaman di lingkungan gelap'),
                      value: settings.darkMode,
                      activeTrackColor: AppColors.primary,
                      activeThumbColor: Colors.white,
                      onChanged: (value) {
                        ref.read(settingsProvider.notifier).toggleDarkMode(value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildGroup(
                  title: 'Lokasi & Sholat',
                  icon: Icons.location_on_outlined,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.location_city_rounded),
                      title: const Text('Lokasi'),
                      subtitle: Text(
                        settings.locationName,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.calculate_rounded),
                      title: const Text('Metode Kalkulasi'),
                      subtitle: Text(
                        _getMethodName(settings.prayerCalculationMethod),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                      ),
                      onTap: () => _showMethodDialog(settings.prayerCalculationMethod),
                    ),
                    ListTile(
                      leading: const Icon(Icons.notifications_active_rounded),
                      title: const Text('Notifikasi & Izin'),
                      subtitle: const Text('Aktifkan izin notifikasi sholat'),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                      ),
                      onTap: _requestNotificationPermission,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildGroup(
                  title: 'Notifikasi',
                  icon: Icons.notifications_active_outlined,
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications_active_rounded),
                      title: const Text('Pengingat Waktu Sholat'),
                      subtitle: const Text('Notifikasi harian sesuai jadwal'),
                      value: notif.prayerRemindersEnabled,
                      activeTrackColor: AppColors.primary,
                      activeThumbColor: Colors.white,
                      onChanged: (value) {
                        ref
                            .read(notificationSettingsProvider.notifier)
                            .setPrayerRemindersEnabled(value);
                      },
                    ),
                    if (notif.prayerRemindersEnabled) ...[
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        leading: const Icon(Icons.timer_outlined),
                        title: const Text('Pengingat sebelum'),
                        subtitle: Text(
                          _minutesLabel(notif.minutesBefore),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                        ),
                        onTap: () => _showMinutesDialog(notif.minutesBefore),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                _buildGroup(
                  title: 'Informasi',
                  icon: Icons.info_outline_rounded,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.touch_app_rounded),
                      title: const Text('Lihat Panduan Singkat'),
                      subtitle: const Text('Tampilkan kembali onboarding'),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                      ),
                      onTap: _showOnboarding,
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.vibration_rounded),
                      title: const Text('Versi Aplikasi'),
                      subtitle: Text(
                        _appVersion,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيم',
                        style: GoogleFonts.scheherazadeNew(
                          fontSize: 18,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Uswah App',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurfaceVariant,
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

  Widget _buildGroup({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 10),
          child: Row(
            children: [
              Icon(icon, color: context.primaryAccent, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.primaryAccent,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Future<void> _showOnboarding() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pengenalan Aplikasi'),
        content: const Text('Tampilkan kembali halaman pengenalan aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tampilkan'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(onboardingProvider.notifier).resetOnboarding();
      if (mounted) context.go('/onboarding');
    }
  }

  Future<void> _requestNotificationPermission() async {
    await NotificationService.requestPermission();
    await ref
        .read(notificationSettingsProvider.notifier)
        .setPrayerRemindersEnabled(true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengingat sholat harian telah diaktifkan.'),
      ),
    );
  }

  String _minutesLabel(int minutes) {
    if (minutes == 0) return 'Tepat waktu adzan';
    return '$minutes menit sebelum adzan';
  }

  Future<void> _showMinutesDialog(int current) async {
    const options = [0, 5, 10, 15, 30];
    final scheme = Theme.of(context).colorScheme;
    final selected = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  'Pengingat sebelum adzan',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: options.map((minute) {
                    final isSelected = minute == current;
                    return ListTile(
                      leading: Icon(
                        isSelected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: isSelected
                            ? context.primaryAccent
                            : scheme.outline,
                      ),
                      title: Text(
                        _minutesLabel(minute),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: scheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      onTap: () => Navigator.pop(context, minute),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (selected != null && mounted) {
      await ref
          .read(notificationSettingsProvider.notifier)
          .setMinutesBefore(selected);
    }
  }

  String _getMethodName(int method) {
    const methods = {
      0: 'Shia Ithna-Ashari',
      1: 'University of Islamic Sciences, Karachi',
      2: 'Islamic Society of North America',
      3: 'Muslim World League',
      4: 'Umm Al-Qura University, Makkah',
      5: 'Egyptian General Authority of Survey',
      7: 'Institute of Geophysics, University of Tehran',
      8: 'Gulf Region',
      9: 'Kuwait',
      10: 'Qatar',
      11: 'Majlis Ugama Islam Singapura, Singapore',
      12: 'Union Organization islamic de France',
      13: 'Diyanet İşleri Başkanlığı, Turkey',
      14: 'Spiritual Administration of Muslims of Russia',
      15: 'Moonsighting Committee Worldwide',
      16: 'Dubai',
      17: 'JAKIM (Malaysia)',
      18: 'Tunisia',
      19: 'Algeria',
      20: 'KEMENAG (Indonesia)',
      21: 'Morocco',
      22: 'Portugal',
      23: 'Jordan',
      24: 'Egypt',
    };
    return methods[method] ?? 'Unknown';
  }

  Future<void> _showMethodDialog(int currentMethod) async {
    const methods = {
      20: 'KEMENAG (Indonesia)',
      5: 'Egyptian General Authority',
      3: 'Muslim World League',
      1: 'University of Karachi',
      2: 'ISNA',
      4: 'Umm Al-Qura',
    };

    final selected = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  'Pilih Metode Kalkulasi',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              ...methods.entries.map((entry) {
                final isSelected = entry.key == currentMethod;
                return ListTile(
                  leading: Icon(
                    isSelected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: isSelected ? AppColors.primary : scheme.outline,
                  ),
                  title: Text(
                    entry.value,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: scheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  onTap: () => Navigator.pop(context, entry.key),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      ref.read(settingsProvider.notifier).setCalculationMethod(selected);
    }
  }

  // Future<void> _showLocationDialog() async {
  //   final settings = ref.read(settingsProvider);
  //   const cities = [
  //     (name: 'Jakarta', lat: -6.200000, lng: 106.816666),
  //     (name: 'Surabaya', lat: -7.257471, lng: 112.752088),
  //     (name: 'Bandung', lat: -6.917464, lng: 107.619123),
  //     (name: 'Medan', lat: 3.595196, lng: 98.672223),
  //     (name: 'Semarang', lat: -6.966667, lng: 110.416664),
  //     (name: 'Makassar', lat: -5.147665, lng: 119.432732),
  //     (name: 'Palembang', lat: -2.976073, lng: 104.775429),
  //     (name: 'Yogyakarta', lat: -7.795580, lng: 110.369492),
  //     (name: 'Depok', lat: -6.402484, lng: 106.794240),
  //     (name: 'Tangerang', lat: -6.178306, lng: 106.631889),
  //   ];

  //   final selected = await showModalBottomSheet<String>(
  //     context: context,
  //     showDragHandle: true,
  //     builder: (context) {
  //       final scheme = Theme.of(context).colorScheme;
  //       return SafeArea(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Padding(
  //               padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
  //               child: Text(
  //                 'Pilih Kota',
  //                 style: GoogleFonts.poppins(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.w600,
  //                   color: scheme.onSurface,
  //                 ),
  //               ),
  //             ),
  //             Flexible(
  //               child: ListView(
  //                 shrinkWrap: true,
  //                 children: cities.map((c) {
  //                   final isSelected = c.name == settings.locationName;
  //                   return ListTile(
  //                     leading: Icon(
  //                       isSelected
  //                           ? Icons.radio_button_checked_rounded
  //                           : Icons.location_city_rounded,
  //                       color: isSelected
  //                           ? context.primaryAccent
  //                           : scheme.outline,
  //                     ),
  //                     title: Text(
  //                       c.name,
  //                       style: GoogleFonts.poppins(
  //                         fontSize: 14,
  //                         color: scheme.onSurface,
  //                         fontWeight: isSelected
  //                             ? FontWeight.w600
  //                             : FontWeight.w400,
  //                       ),
  //                     ),
  //                     onTap: () => Navigator.pop(context, c.name),
  //                   );
  //                 }).toList(),
  //               ),
  //             ),
  //             const SizedBox(height: 8),
  //           ],
  //         ),
  //       );
  //     },
  //   );

  //   if (selected != null) {
  //     final city = cities.firstWhere((c) => c.name == selected);
  //     ref
  //         .read(settingsProvider.notifier)
  //         .setCity(name: city.name, latitude: city.lat, longitude: city.lng);
  //     ref.invalidate(prayerTimesProvider);
  //   }
  // }
}

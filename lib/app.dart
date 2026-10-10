import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/providers/notification_provider.dart';
import 'features/settings/providers/settings_provider.dart';
import 'shared/services/location_service.dart';

class UswahApp extends ConsumerStatefulWidget {
  const UswahApp({super.key});

  @override
  ConsumerState<UswahApp> createState() => _UswahAppState();
}

class _UswahAppState extends ConsumerState<UswahApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(settingsProvider.notifier).loadSettings(),
    );
    Future.microtask(
      () => ref.read(notificationSettingsProvider.notifier).loadSettings(),
    );
    Future.microtask(_loadRealtimeLocation);
  }

  /// Ambil lokasi realtime dari GPS pada saat aplikasi dibuka.
  Future<void> _loadRealtimeLocation() async {
    final position = await LocationService.getCurrentPosition();
    if (position == null || !mounted) return;
    final city = await LocationService.cityNameFrom(
      latitude: position.latitude,
      longitude: position.longitude,
    );
    if (!mounted) return;
    await ref.read(settingsProvider.notifier).setCoordinates(
          latitude: position.latitude,
          longitude: position.longitude,
          locationName: city,
        );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);
    final isDark = settings.darkMode;

    return MaterialApp.router(
      title: 'Uswah App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}

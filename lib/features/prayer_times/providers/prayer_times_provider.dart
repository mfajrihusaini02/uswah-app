import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/location_service.dart';
import '../../../shared/models/prayer_times_model.dart';
import '../../settings/providers/settings_provider.dart';
import '../data/prayer_times_repository.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
});

final prayerTimesRepositoryProvider = Provider<PrayerTimesRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PrayerTimesRepository(dio);
});

class PrayerTimesNotifier extends AsyncNotifier<PrayerTimesModel> {
  @override
  Future<PrayerTimesModel> build() async {
    final settings = ref.watch(settingsProvider);
    final fallback = await LocationService.getDefaultCoords();
    final latitude = settings.latitude ?? fallback.latitude;
    final longitude = settings.longitude ?? fallback.longitude;
    final repository = ref.read(prayerTimesRepositoryProvider);
    final result = await repository.getPrayerTimes(
      latitude: latitude,
      longitude: longitude,
    );
    ref.read(prayerTimesLastUpdatedProvider.notifier).state = DateTime.now();
    return result;
  }
}

final prayerTimesProvider =
    AsyncNotifierProvider<PrayerTimesNotifier, PrayerTimesModel>(
      PrayerTimesNotifier.new,
    );

/// Waktu terakhir jadwal sholat berhasil diperbarui (untuk indikator UI).
final prayerTimesLastUpdatedProvider = StateProvider<DateTime?>((ref) => null);

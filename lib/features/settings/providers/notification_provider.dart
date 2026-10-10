import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/services/notification_service.dart';
import '../../prayer_times/providers/prayer_times_provider.dart';

class NotificationSettingsState {
  final bool prayerRemindersEnabled;
  final int minutesBefore;

  const NotificationSettingsState({
    this.prayerRemindersEnabled = false,
    this.minutesBefore = 0,
  });

  NotificationSettingsState copyWith({
    bool? prayerRemindersEnabled,
    int? minutesBefore,
  }) {
    return NotificationSettingsState(
      prayerRemindersEnabled:
          prayerRemindersEnabled ?? this.prayerRemindersEnabled,
      minutesBefore: minutesBefore ?? this.minutesBefore,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationSettingsState> {
  final Ref ref;

  NotificationNotifier(this.ref) : super(const NotificationSettingsState());

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = NotificationSettingsState(
      prayerRemindersEnabled: prefs.getBool('notifPrayerEnabled') ?? false,
      minutesBefore: prefs.getInt('notifPrayerMinutes') ?? 0,
    );
  }

  /// Aktifkan / nonaktifkan pengingat jadwal sholat.
  Future<void> setPrayerRemindersEnabled(bool value) async {
    state = state.copyWith(prayerRemindersEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifPrayerEnabled', value);

    if (value) {
      await NotificationService.requestPermission();
      await _rescheduleWithLatestPrayerTimes();
    } else {
      await NotificationService.cancelPrayerReminders();
    }
  }

  /// Atur berapa menit sebelum adzan pengingat muncul (0 = tepat waktu).
  Future<void> setMinutesBefore(int value) async {
    state = state.copyWith(minutesBefore: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notifPrayerMinutes', value);

    if (state.prayerRemindersEnabled) {
      await _rescheduleWithLatestPrayerTimes();
    }
  }

  Future<void> _rescheduleWithLatestPrayerTimes() async {
    final prayerTimes = await ref.read(prayerTimesProvider.future);
    await scheduleIfEnabled({
      'Subuh': prayerTimes.fajr,
      'Terbit': prayerTimes.sunrise,
      'Dzuhur': prayerTimes.dhuhr,
      'Ashar': prayerTimes.asr,
      'Maghrib': prayerTimes.maghrib,
      'Isya': prayerTimes.isha,
    });
  }

  /// Jadwalkan ulang bila pengingat aktif. Dipanggil dari halaman setelah
  /// jadwal sholat berhasil dimuat/di-refresh.
  Future<void> scheduleIfEnabled(Map<String, String> prayerTimes) async {
    if (!state.prayerRemindersEnabled) return;
    await NotificationService.schedulePrayerReminders(
      prayerTimes: prayerTimes,
      minutesBefore: state.minutesBefore,
    );
  }
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationNotifier, NotificationSettingsState>(
      (ref) => NotificationNotifier(ref),
    );
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Layanan notifikasi lokal (tanpa FCM / backend) untuk reminder ibadah.
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'prayer_reminders',
      'Pengingat Ibadah',
      channelDescription:
          'Notifikasi pengingat jadwal sholat dan ibadah lainnya.',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFF1B5E20),
      icon: 'ic_launcher',
    ),
    iOS: DarwinNotificationDetails(),
  );

  static bool _initialized = false;
  static bool _triedInit = false;

  // ---------- Inisialisasi ----------

  /// Wajib dipanggil sekali sebelum pemakaian (ideal di main()/initState).
  static Future<void> initialize() async {
    if (_initialized || _triedInit) return;
    _triedInit = true;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  /// Pastikan zona waktu lokal tersimpan. Perlu dipanggil sebelum `zonedSchedule`.
  static Future<void> ensureTimezone() async {
    try {
      tzdata.initializeTimeZones();
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Fallback: default UTC agar tidak gagal total.
      tz.setLocalLocation(tz.UTC);
    }
  }

  // ---------- Izin ----------

  static Future<void> requestPermission() async {
    await initialize();
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  // ---------- Penjadwalan ----------

  /// Jadwalkan notifikasi sholat harian (berulang) berdasarkan jadwal yang di-pass.
  /// `minutesBefore` memungkinkan pengingat dimajukan dari waktu sholat.
  static Future<void> schedulePrayerReminders({
    required Map<String, String> prayerTimes,
    int minutesBefore = 0,
  }) async {
    await initialize();
    await ensureTimezone();

    await cancelPrayerReminders();

    final now = tz.TZDateTime.now(tz.local);
    final todayStr = now.toIso8601String().substring(0, 10);

    DateTime parseTime(String hm) {
      final parts = hm.split(':');
      return DateTime.parse('${todayStr}T${parts[0]}:${parts[1]}:00');
    }

    prayerTimes.forEach((name, time) {
      if (time.isEmpty) return;
      final scheduled = parseTime(time).subtract(
        Duration(minutes: minutesBefore),
      );
      final tzScheduled = tz.TZDateTime(
        tz.local,
        scheduled.year,
        scheduled.month,
        scheduled.day,
        scheduled.hour,
        scheduled.minute,
      );

      // Jika waktu sudah lewat hari ini, jadwalkan di index besok.
      var next = tzScheduled;
      if (!next.isAfter(now)) {
        next = next.add(const Duration(days: 1));
      }

      _plugin.zonedSchedule(
        id: _idFor(name),
        title: 'Waktu Sholat $name',
        body: minutesBefore > 0
            ? '$name akan tiba dalam $minutesBefore menit (pukul $time).'
            : 'Saatnya sholat $name. Semoga ibadah kita diterima.',
        scheduledDate: next,
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    });
  }

  static Future<void> cancelPrayerReminders() async {
    const names = ['Subuh', 'Terbit', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'];
    for (final name in names) {
      await _plugin.cancel(id: _idFor(name));
    }
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static int _idFor(String name) {
    return switch (name) {
      'Subuh' => 101,
      'Terbit' => 102,
      'Dzuhur' => 103,
      'Ashar' => 104,
      'Maghrib' => 105,
      'Isya' => 106,
      _ => 100,
    };
  }
}
import 'package:hijri/hijri_calendar.dart';

class FastingInfo {
  final String title;
  final String description;
  final String statusText; // e.g. 'Hari Ini', 'Besok', 'Mendatang'
  final bool isToday;

  const FastingInfo({
    required this.title,
    required this.description,
    required this.statusText,
    required this.isToday,
  });
}

class HijriHelper {
  static const List<String> _monthNamesIndonesian = [
    'Muharram',
    'Shafar',
    'Rabi\'ul Awal',
    'Rabi\'ul Akhir',
    'Jumadil Awal',
    'Jumadil Akhir',
    'Rajab',
    'Sya\'ban',
    'Ramadhan',
    'Syawal',
    'Dzulqa\'dah',
    'Dzulhijjah',
  ];

  static String getMonthName(int month) {
    if (month >= 1 && month <= 12) {
      return _monthNamesIndonesian[month - 1];
    }
    return '';
  }

  /// Mendapatkan string tanggal Hijriah lengkap (contoh: "13 Rabi'ul Awal 1448 H").
  static String formatHijriDate(DateTime date) {
    final hDate = HijriCalendar.fromDate(date);
    final monthName = getMonthName(hDate.hMonth);
    return '${hDate.hDay} $monthName ${hDate.hYear} H';
  }

  /// Mendapatkan informasi puasa sunnah / wajib untuk tanggal tertentu.
  static FastingInfo getFastingInfo(DateTime date) {
    final hDate = HijriCalendar.fromDate(date);
    final monthName = getMonthName(hDate.hMonth);
    final weekday = date.weekday; // 1 = Monday, ..., 7 = Sunday

    // 1. Puasa Wajib Ramadhan (Bulan 9)
    if (hDate.hMonth == 9) {
      return FastingInfo(
        title: 'Puasa Ramadhan',
        description: 'Puasa wajib di bulan suci Ramadhan (Hari ke-${hDate.hDay})',
        statusText: 'Puasa Wajib Hari Ini',
        isToday: true,
      );
    }

    // 2. Hari Haram Puasa (Idul Fitri 1 Syawal, Idul Adha 10 Dzulhijjah, Tasyrik 11-13 Dzulhijjah)
    if ((hDate.hMonth == 10 && hDate.hDay == 1) ||
        (hDate.hMonth == 12 && hDate.hDay >= 10 && hDate.hDay <= 13)) {
      return const FastingInfo(
        title: 'Hari Tasyrik / Raya',
        description: 'Diharamkan berpuasa pada hari raya dan hari tasyrik.',
        statusText: 'Dilarang Berpuasa',
        isToday: false,
      );
    }

    // 3. Puasa Arafah (9 Dzulhijjah)
    if (hDate.hMonth == 12 && hDate.hDay == 9) {
      return const FastingInfo(
        title: 'Puasa Arafah',
        description: 'Menghapuskan dosa setahun yang lalu dan setahun yang akan datang.',
        statusText: 'Puasa Sunnah Hari Ini',
        isToday: true,
      );
    }

    // 4. Puasa Asyura & Tasu'a (9 & 10 Muharram)
    if (hDate.hMonth == 1 && (hDate.hDay == 9 || hDate.hDay == 10)) {
      final name = hDate.hDay == 9 ? 'Puasa Tasu\'a' : 'Puasa Asyura';
      return FastingInfo(
        title: name,
        description: 'Puasa sunnah yang sangat dianjurkan di bulan Muharram.',
        statusText: 'Puasa Sunnah Hari Ini',
        isToday: true,
      );
    }

    // 5. Puasa Ayyamul Bidh (13, 14, 15 setiap bulan Hijriah)
    if (hDate.hDay >= 13 && hDate.hDay <= 15) {
      return FastingInfo(
        title: 'Puasa Ayyamul Bidh',
        description: 'Puasa sunnah pertengahan bulan Hijriah (${hDate.hDay} $monthName).',
        statusText: 'Puasa Sunnah Hari Ini',
        isToday: true,
      );
    }

    // 6. Puasa Senin & Kamis
    if (weekday == DateTime.monday) {
      return const FastingInfo(
        title: 'Puasa Sunnah Senin',
        description: 'Hari di mana amalan manusia diperlihatkan kepada Allah SWT.',
        statusText: 'Puasa Sunnah Hari Ini',
        isToday: true,
      );
    }

    if (weekday == DateTime.thursday) {
      return const FastingInfo(
        title: 'Puasa Sunnah Kamis',
        description: 'Hari di mana amalan diangkat kepada Allah SWT.',
        statusText: 'Puasa Sunnah Hari Ini',
        isToday: true,
      );
    }

    // 7. Pengingat Puasa Sunnah Mendatang (misal: besok Senin / Kamis / Ayyamul Bidh)
    final tomorrow = date.add(const Duration(days: 1));
    final hTomorrow = HijriCalendar.fromDate(tomorrow);
    final tomorrowMonthName = getMonthName(hTomorrow.hMonth);
    if (tomorrow.weekday == DateTime.monday || tomorrow.weekday == DateTime.thursday) {
      final dayName = tomorrow.weekday == DateTime.monday ? 'Senin' : 'Kamis';
      return FastingInfo(
        title: 'Puasa Sunnah $dayName Besok',
        description: 'Persiapkan diri untuk menjalankan puasa sunnah besok.',
        statusText: 'Puasa Sunnah Besok',
        isToday: false,
      );
    }

    if (hTomorrow.hDay >= 13 && hTomorrow.hDay <= 15) {
      return FastingInfo(
        title: 'Puasa Ayyamul Bidh Besok',
        description: 'Besok adalah tanggal ${hTomorrow.hDay} $tomorrowMonthName.',
        statusText: 'Puasa Sunnah Besok',
        isToday: false,
      );
    }

    return const FastingInfo(
      title: 'Puasa Sunnah',
      description: 'Perbanyak puasa sunnah Senin-Kamis atau Ayyamul Bidh.',
      statusText: 'Anjuran Ibadah',
      isToday: false,
    );
  }
}

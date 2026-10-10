import 'dart:async';
import 'dart:math';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../settings/providers/settings_provider.dart';

/// Ka'bah coordinates in Mecca
const double _kaabaLat = 21.422487;
const double _kaabaLng = 39.826206;

class QiblaState {
  final double qiblaDirection; // Sudut Kiblat dari Utara asli (0° - 360°)
  final double? heading;        // Arah kompas perangkat saat ini (0° - 360°)
  final double accuracy;        // Akurasi sensor
  final bool isFacingQibla;     // Menghadap kiblat (toleransi ±3.5 derajat)
  final bool hasCompassSensor;  // Apakah perangkat memiliki sensor kompas

  const QiblaState({
    required this.qiblaDirection,
    this.heading,
    this.accuracy = 0,
    this.isFacingQibla = false,
    this.hasCompassSensor = true,
  });

  /// Menghitung rotasi penunjuk panah Kiblat relatif terhadap orientasi perangkat.
  /// (Dalam radian untuk Transform.rotate atau AnimatedRotation).
  double get qiblaAngleRad {
    final h = heading ?? 0;
    final diff = (qiblaDirection - h + 360) % 360;
    return diff * (pi / 180.0);
  }

  /// Selisih derajat relatif antara kompas dan Kiblat.
  double get relativeDegree {
    final h = heading ?? 0;
    final diff = (qiblaDirection - h + 360) % 360;
    return diff > 180 ? diff - 360 : diff;
  }

  QiblaState copyWith({
    double? qiblaDirection,
    double? heading,
    double? accuracy,
    bool? isFacingQibla,
    bool? hasCompassSensor,
  }) {
    return QiblaState(
      qiblaDirection: qiblaDirection ?? this.qiblaDirection,
      heading: heading ?? this.heading,
      accuracy: accuracy ?? this.accuracy,
      isFacingQibla: isFacingQibla ?? this.isFacingQibla,
      hasCompassSensor: hasCompassSensor ?? this.hasCompassSensor,
    );
  }
}

/// Menghitung sudut azimuth Kiblat dalam derajat (0°-360°) berdasarkan koordinat GPS.
double calculateQiblaDirection(double lat, double lng) {
  final phi1 = lat * (pi / 180.0);
  final lambda1 = lng * (pi / 180.0);
  final phi2 = _kaabaLat * (pi / 180.0);
  final lambda2 = _kaabaLng * (pi / 180.0);

  final dLambda = lambda2 - lambda1;

  final y = sin(dLambda);
  final x = cos(phi1) * tan(phi2) - sin(phi1) * cos(dLambda);

  final qiblaRad = atan2(y, x);
  final qiblaDeg = (qiblaRad * (180.0 / pi) + 360) % 360;
  return qiblaDeg;
}

final compassEventsStreamProvider = StreamProvider<CompassEvent?>((ref) {
  return FlutterCompass.events ?? Stream.value(null);
});

final qiblaStateProvider = Provider<QiblaState>((ref) {
  final settings = ref.watch(settingsProvider);
  final lat = settings.latitude ?? -6.200000;
  final lng = settings.longitude ?? 106.816666;

  final qiblaDir = calculateQiblaDirection(lat, lng);
  final compassAsync = ref.watch(compassEventsStreamProvider);

  return compassAsync.when(
    data: (event) {
      if (event == null) {
        return QiblaState(
          qiblaDirection: qiblaDir,
          hasCompassSensor: false,
        );
      }
      final heading = event.heading != null
          ? (event.heading! + 360) % 360
          : null;
      
      bool facing = false;
      if (heading != null) {
        final diff = ((qiblaDir - heading + 360) % 360);
        final normalizedDiff = diff > 180 ? 360 - diff : diff;
        facing = normalizedDiff <= 3.5;
      }

      return QiblaState(
        qiblaDirection: qiblaDir,
        heading: heading,
        accuracy: event.accuracy ?? 0,
        isFacingQibla: facing,
        hasCompassSensor: heading != null,
      );
    },
    loading: () => QiblaState(qiblaDirection: qiblaDir),
    error: (err, stack) => QiblaState(
      qiblaDirection: qiblaDir,
      hasCompassSensor: false,
    ),
  );
});

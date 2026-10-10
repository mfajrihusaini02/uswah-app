import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Hasil pengambilan lokasi realtime.
class LocationResult {
  final bool granted;
  final String? message;
  final double? latitude;
  final double? longitude;

  const LocationResult({
    this.granted = false,
    this.message,
    this.latitude,
    this.longitude,
  });
}

class LocationService {
  LocationService._();

  static Geocoding? _geocoding;

  /// Ambil koordinat default: coba GPS device dulu, fallback ke Jakarta.
  static Future<({double latitude, double longitude})> getDefaultCoords() async {
    const jakarta = (latitude: -6.200000, longitude: 106.816666);
    final position = await getCurrentPosition();
    if (position != null) {
      return (latitude: position.latitude, longitude: position.longitude);
    }
    return jakarta;
  }

  /// Ambil posisi realtime dari GPS. Mengembalikan `null` pada kegagalan.
  static Future<Position?> getCurrentPosition() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition();
    } catch (_) {
      return null;
    }
  }

  /// Reverse-geocode koordinat menjadi nama kota, fallback 'Jakarta'.
  static Future<String> cityNameFrom({
    required double latitude,
    required double longitude,
  }) async {
    try {
      _geocoding ??= Geocoding();
      final placemarks = await _geocoding!.placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final city = place.locality ?? place.subAdministrativeArea;
        if (city != null && city.isNotEmpty) {
          return city;
        }
      }
    } catch (_) {
      // geocoding gagal, fallback ke default
    }
    return 'Jakarta';
  }
}

import 'package:geocoding/geocoding.dart';

/// Reverse-geocode koordinat ke nama kota (non-web implementation).
Future<String> geocodeCityName({
  required double latitude,
  required double longitude,
}) async {
  try {
    final geocoding = Geocoding();
    final placemarks = await geocoding.placemarkFromCoordinates(
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

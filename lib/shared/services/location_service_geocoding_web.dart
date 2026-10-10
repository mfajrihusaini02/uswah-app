import 'package:dio/dio.dart';

/// Implementasi reverse geocoding untuk Web via HTTP API (CORS friendly).
/// BigDataCloud reverse-geocode-client API tidak memerlukan API key dan mendukung CORS di browser.
Future<String> geocodeCityName({
  required double latitude,
  required double longitude,
}) async {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 6),
      receiveTimeout: const Duration(seconds: 6),
    ),
  );

  // 1. Coba BigDataCloud API (CORS-friendly untuk Flutter Web)
  try {
    final response = await dio.get(
      'https://api.bigdatacloud.net/data/reverse-geocode-client',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'localityLanguage': 'id',
      },
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final city = data['city'] ??
            data['locality'] ??
            data['principalSubdivision'];
        if (city != null && city.toString().trim().isNotEmpty) {
          return city.toString().trim();
        }
      }
    }
  } catch (_) {
    // Abaikan dan coba fallback OpenStreetMap
  }

  // 2. Fallback Nominatim OpenStreetMap
  try {
    final response = await dio.get(
      'https://nominatim.openstreetmap.org/reverse',
      queryParameters: {
        'format': 'jsonv2',
        'lat': latitude,
        'lon': longitude,
        'zoom': 10,
        'accept-language': 'id,en',
      },
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final city = address['city'] ??
              address['town'] ??
              address['municipality'] ??
              address['city_district'] ??
              address['county'] ??
              address['state'];
          if (city != null && city.toString().trim().isNotEmpty) {
            return city.toString().trim();
          }
        }
      }
    }
  } catch (_) {
    // Fallback default
  }

  return 'Jakarta';
}

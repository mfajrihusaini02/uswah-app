import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../shared/models/prayer_times_model.dart';

class PrayerTimesRepository {
  final Dio _dio;

  PrayerTimesRepository(this._dio);

  Future<PrayerTimesModel> getPrayerTimes({
    required double latitude,
    required double longitude,
    int method = 5,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.prayerTimesEndpoint}',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'method': method,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final timings = data['data']['timings'] as Map<String, dynamic>;
      return PrayerTimesModel.fromJson(timings);
    } catch (e) {
      rethrow;
    }
  }
}

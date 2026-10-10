import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../shared/models/surah_model.dart';

class QuranRepository {
  final Dio _dio;

  QuranRepository(this._dio);

  Future<List<SurahModel>> getAllSurahs() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.quranApiUrl}/surah',
      );

      final data = response.data as Map<String, dynamic>;
      final surahs = data['data'] as List<dynamic>;
      return surahs
          .map((e) => SurahModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AyahModel>> getSurahDetail(int surahNumber) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.quranApiUrl}/surah/$surahNumber',
      );

      final data = response.data as Map<String, dynamic>;
      final surahData = data['data'] as Map<String, dynamic>;
      final ayahs = surahData['ayahs'] as List<dynamic>;
      return ayahs
          .map((e) => AyahModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}

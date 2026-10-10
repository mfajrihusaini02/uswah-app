import 'package:dio/dio.dart';
import '../../../shared/models/asmaul_husna_model.dart';

class AsmaulHusnaRepository {
  final Dio _dio;

  AsmaulHusnaRepository(this._dio);

  Future<List<AsmaulHusnaModel>> getAllAsmaulHusna() async {
    try {
      final response = await _dio.get(
        'https://asmaul-husna-api.vercel.app/api/all',
      );

      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>;
      return list
          .map((e) => AsmaulHusnaModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}

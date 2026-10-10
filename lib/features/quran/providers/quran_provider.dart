import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/surah_model.dart';
import '../../prayer_times/providers/prayer_times_provider.dart';
import '../data/quran_repository.dart';

final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return QuranRepository(dio);
});

class SurahListNotifier extends AsyncNotifier<List<SurahModel>> {
  @override
  Future<List<SurahModel>> build() async {
    final repository = ref.read(quranRepositoryProvider);
    return repository.getAllSurahs();
  }
}

final surahListProvider =
    AsyncNotifierProvider<SurahListNotifier, List<SurahModel>>(
  SurahListNotifier.new,
);

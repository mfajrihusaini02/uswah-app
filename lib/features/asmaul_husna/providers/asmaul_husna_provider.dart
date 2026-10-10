import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/asmaul_husna_model.dart';
import '../../prayer_times/providers/prayer_times_provider.dart';
import '../data/asmaul_husna_repository.dart';

final asmaulHusnaRepositoryProvider = Provider<AsmaulHusnaRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AsmaulHusnaRepository(dio);
});

class AsmaulHusnaNotifier
    extends AsyncNotifier<List<AsmaulHusnaModel>> {
  @override
  Future<List<AsmaulHusnaModel>> build() async {
    final repository = ref.read(asmaulHusnaRepositoryProvider);
    return repository.getAllAsmaulHusna();
  }
}

final asmaulHusnaProvider =
    AsyncNotifierProvider<AsmaulHusnaNotifier, List<AsmaulHusnaModel>>(
  AsmaulHusnaNotifier.new,
);

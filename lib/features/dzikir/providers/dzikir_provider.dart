import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Dzikir Progress Provider ─────────────────────────────────────────────────

class DzikirProgressState {
  /// Map dari id dzikir ke jumlah yang sudah diklik hari ini
  final Map<String, int> progress;
  final String savedDate; // tanggal saat progress disimpan (yyyy-MM-dd)

  const DzikirProgressState({
    required this.progress,
    required this.savedDate,
  });

  factory DzikirProgressState.empty() => DzikirProgressState(
        progress: {},
        savedDate: '',
      );
}

class DzikirProgressNotifier extends StateNotifier<DzikirProgressState> {
  DzikirProgressNotifier() : super(DzikirProgressState.empty()) {
    _load();
  }

  String get _todayKey =>
      DateTime.now().toIso8601String().substring(0, 10); // yyyy-MM-dd

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('dzikir_date') ?? '';
    final today = _todayKey;

    if (savedDate != today) {
      // Reset harian — hari baru
      state = DzikirProgressState(progress: {}, savedDate: today);
      await prefs.setString('dzikir_date', today);
      await prefs.remove('dzikir_progress');
      return;
    }

    final keys = prefs.getStringList('dzikir_progress_keys') ?? [];
    final Map<String, int> progress = {};
    for (final key in keys) {
      progress[key] = prefs.getInt('dzikir_$key') ?? 0;
    }
    state = DzikirProgressState(progress: progress, savedDate: today);
  }

  /// Tambah satu ketukan pada dzikir [id]
  Future<void> tap(String id) async {
    final today = _todayKey;
    if (state.savedDate != today) {
      // Reset jika hari berbeda
      state = DzikirProgressState(progress: {}, savedDate: today);
    }

    final updated = Map<String, int>.from(state.progress);
    updated[id] = (updated[id] ?? 0) + 1;
    state = DzikirProgressState(progress: updated, savedDate: today);

    // Persist
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dzikir_date', today);
    await prefs.setStringList('dzikir_progress_keys', updated.keys.toList());
    await prefs.setInt('dzikir_$id', updated[id]!);
  }

  /// Reset progress satu item
  Future<void> reset(String id) async {
    final updated = Map<String, int>.from(state.progress);
    updated.remove(id);
    state = DzikirProgressState(
        progress: updated, savedDate: state.savedDate);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('dzikir_progress_keys', updated.keys.toList());
    await prefs.remove('dzikir_$id');
  }

  int getCount(String id) => state.progress[id] ?? 0;
}

final dzikirProgressProvider =
    StateNotifierProvider<DzikirProgressNotifier, DzikirProgressState>((ref) {
  return DzikirProgressNotifier();
});

// ─── Tasbih Provider ─────────────────────────────────────────────────────────

class TasbihState {
  final int count;
  final int target; // default 33

  const TasbihState({this.count = 0, this.target = 33});

  TasbihState copyWith({int? count, int? target}) =>
      TasbihState(count: count ?? this.count, target: target ?? this.target);
}

class TasbihNotifier extends StateNotifier<TasbihState> {
  TasbihNotifier() : super(const TasbihState());

  void tap() => state = state.copyWith(count: state.count + 1);

  void reset() => state = state.copyWith(count: 0);

  void setTarget(int target) => state = state.copyWith(target: target);
}

final tasbihProvider =
    StateNotifierProvider<TasbihNotifier, TasbihState>((ref) {
  return TasbihNotifier();
});

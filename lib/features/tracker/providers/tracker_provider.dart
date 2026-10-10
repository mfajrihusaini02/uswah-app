import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tracker_model.dart';

class TrackerState {
  final String dateKey; // 'yyyy-MM-dd'
  final List<HabitItem> habits;
  final bool isLoading;

  const TrackerState({
    required this.dateKey,
    required this.habits,
    this.isLoading = false,
  });

  int get completedCount => habits.where((h) => h.isCompleted).length;
  int get totalCount => habits.length;
  double get progressRatio => totalCount == 0 ? 0 : completedCount / totalCount;

  TrackerState copyWith({
    String? dateKey,
    List<HabitItem>? habits,
    bool? isLoading,
  }) {
    return TrackerState(
      dateKey: dateKey ?? this.dateKey,
      habits: habits ?? this.habits,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final defaultHabits = [
  const HabitItem(
    id: 'sholat_subuh',
    title: 'Sholat Subuh',
    subtitle: 'Wajib 2 Rakaat Tepat Waktu',
    category: 'sholat',
  ),
  const HabitItem(
    id: 'sholat_dzuhur',
    title: 'Sholat Dzuhur',
    subtitle: 'Wajib 4 Rakaat Tepat Waktu',
    category: 'sholat',
  ),
  const HabitItem(
    id: 'sholat_ashar',
    title: 'Sholat Ashar',
    subtitle: 'Wajib 4 Rakaat Tepat Waktu',
    category: 'sholat',
  ),
  const HabitItem(
    id: 'sholat_maghrib',
    title: 'Sholat Maghrib',
    subtitle: 'Wajib 3 Rakaat Tepat Waktu',
    category: 'sholat',
  ),
  const HabitItem(
    id: 'sholat_isya',
    title: 'Sholat Isya',
    subtitle: 'Wajib 4 Rakaat Tepat Waktu',
    category: 'sholat',
  ),
  const HabitItem(
    id: 'tilawah_quran',
    title: 'Tilawah Al-Quran',
    subtitle: 'Membaca Al-Quran Minimal 1 Lembara/Halaman',
    category: 'quran',
  ),
  const HabitItem(
    id: 'dzikir_pagi',
    title: 'Dzikir Pagi',
    subtitle: 'Membaca Almatsurat / Dzikir Pagi hari',
    category: 'dzikir',
  ),
  const HabitItem(
    id: 'dzikir_petang',
    title: 'Dzikir Petang',
    subtitle: 'Membaca Almatsurat / Dzikir Petang hari',
    category: 'dzikir',
  ),
];

class TrackerNotifier extends StateNotifier<TrackerState> {
  TrackerNotifier()
      : super(
          TrackerState(
            dateKey: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            habits: defaultHabits,
            isLoading: true,
          ),
        ) {
    loadHabits(DateTime.now());
  }

  Future<void> loadHabits(DateTime date) async {
    state = state.copyWith(isLoading: true);
    final key = DateFormat('yyyy-MM-dd').format(date);
    final prefs = await SharedPreferences.getInstance();

    final completedIds = prefs.getStringList('tracker_$key') ?? [];

    final updated = defaultHabits.map((item) {
      return item.copyWith(isCompleted: completedIds.contains(item.id));
    }).toList();

    state = TrackerState(
      dateKey: key,
      habits: updated,
      isLoading: false,
    );
  }

  Future<void> toggleHabit(String habitId) async {
    final updatedHabits = state.habits.map((item) {
      if (item.id == habitId) {
        return item.copyWith(isCompleted: !item.isCompleted);
      }
      return item;
    }).toList();

    state = state.copyWith(habits: updatedHabits);

    final prefs = await SharedPreferences.getInstance();
    final completedIds = updatedHabits
        .where((h) => h.isCompleted)
        .map((h) => h.id)
        .toList();

    await prefs.setStringList('tracker_${state.dateKey}', completedIds);
  }
}

final trackerProvider =
    StateNotifierProvider<TrackerNotifier, TrackerState>((ref) {
  return TrackerNotifier();
});

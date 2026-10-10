import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final bool darkMode;
  final int prayerCalculationMethod;
  final String locationName;
  final double? latitude;
  final double? longitude;

  const SettingsState({
    this.darkMode = false,
    this.prayerCalculationMethod = 5,
    this.locationName = 'Jakarta',
    this.latitude,
    this.longitude,
  });

  SettingsState copyWith({
    bool? darkMode,
    int? prayerCalculationMethod,
    String? locationName,
    double? latitude,
    double? longitude,
  }) {
    return SettingsState(
      darkMode: darkMode ?? this.darkMode,
      prayerCalculationMethod:
          prayerCalculationMethod ?? this.prayerCalculationMethod,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      darkMode: prefs.getBool('darkMode') ?? false,
      prayerCalculationMethod: prefs.getInt('method') ?? 5,
      locationName: prefs.getString('location') ?? 'Jakarta',
      latitude: prefs.getDouble('latitude'),
      longitude: prefs.getDouble('longitude'),
    );
  }

  Future<void> toggleDarkMode(bool value) async {
    state = state.copyWith(darkMode: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
  }

  Future<void> setCalculationMethod(int method) async {
    state = state.copyWith(prayerCalculationMethod: method);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('method', method);
  }

  Future<void> setLocation(String location) async {
    state = state.copyWith(locationName: location);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('location', location);
  }

  Future<void> setCity({
    required String name,
    required double latitude,
    required double longitude,
  }) async {
    state = state.copyWith(
      locationName: name,
      latitude: latitude,
      longitude: longitude,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('location', name);
    await prefs.setDouble('latitude', latitude);
    await prefs.setDouble('longitude', longitude);
  }

  Future<void> setCoordinates({
    required double latitude,
    required double longitude,
    String? locationName,
  }) async {
    state = state.copyWith(
      latitude: latitude,
      longitude: longitude,
      locationName: locationName ?? state.locationName,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', latitude);
    await prefs.setDouble('longitude', longitude);
    if (locationName != null) {
      await prefs.setString('location', locationName);
    }
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

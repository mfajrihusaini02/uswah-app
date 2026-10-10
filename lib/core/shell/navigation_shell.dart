import 'package:flutter/material.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/prayer_times/presentation/prayer_times_screen.dart';
import '../../features/quran/presentation/surah_list_screen.dart';
import '../../features/asmaul_husna/presentation/asmaul_husna_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../theme/app_colors.dart';

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _selectedIndex = 0;

  void _switchTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screens = [
      HomeScreen(onNavigate: _switchTab),
      const PrayerTimesScreen(),
      const SurahListScreen(),
      const AsmaulHusnaScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: MediaQuery(
        // Beri ruang bawah pada konten agar mengalir melewati sangkar bar
        // mengambang dan item terakhir tetap bisa digulir ke atas bar.
        data: MediaQuery.of(context).copyWith(
          padding: MediaQuery.of(context).padding.copyWith(
                bottom: MediaQuery.of(context).padding.bottom + 96,
              ),
        ),
        child: IndexedStack(
          index: _selectedIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.45)
                    : AppColors.cardShadow,
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              elevation: 0,
              backgroundColor: Colors.transparent,
              indicatorColor: isDark
                  ? AppColors.primarySoftDark
                  : AppColors.primarySoft,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.wb_sunny_outlined),
                  selectedIcon: Icon(Icons.wb_sunny_rounded),
                  label: 'Sholat',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book_rounded),
                  label: 'Quran',
                ),
                NavigationDestination(
                  icon: Icon(Icons.spa_outlined),
                  selectedIcon: Icon(Icons.spa_rounded),
                  label: 'Asmaul',
                ),
                NavigationDestination(
                  icon: Icon(Icons.tune_rounded),
                  selectedIcon: Icon(Icons.tune_rounded),
                  label: 'Pengaturan',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

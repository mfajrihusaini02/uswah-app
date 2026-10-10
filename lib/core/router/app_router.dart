import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/hijri_calendar/presentation/hijri_calendar_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/providers/onboarding_provider.dart';
import '../../features/qibla/presentation/qibla_screen.dart';
import '../../features/quran/presentation/surah_detail_screen.dart';
import '../../features/asmaul_husna/presentation/asmaul_husna_detail_screen.dart';
import '../../features/tracker/presentation/tracker_screen.dart';
import '../../features/dzikir/presentation/dzikir_screen.dart';
import '../../features/dzikir/presentation/tasbih_screen.dart';
import '../shell/navigation_shell.dart';

Page<T> _detailPage<T>(Widget child) {
  return CustomTransitionPage<T>(
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.02),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final onboardingState = ref.watch(onboardingProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final completed = onboardingState.valueOrNull ?? false;
      final isOnboardingRoute = state.matchedLocation == '/onboarding';

      if (!completed && !isOnboardingRoute) {
        return '/onboarding';
      }
      if (completed && isOnboardingRoute) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/', builder: (context, state) => const NavigationShell()),

      GoRoute(
        path: '/tracker',
        pageBuilder: (context, state) => _detailPage(const TrackerScreen()),
      ),
      GoRoute(
        path: '/hijri-calendar',
        pageBuilder: (context, state) =>
            _detailPage(const HijriCalendarScreen()),
      ),
      GoRoute(
        path: '/qibla',
        pageBuilder: (context, state) => _detailPage(const QiblaScreen()),
      ),
      GoRoute(
        path: '/dzikir',
        pageBuilder: (context, state) => _detailPage(const DzikirScreen()),
      ),
      GoRoute(
        path: '/tasbih',
        pageBuilder: (context, state) => _detailPage(const TasbihScreen()),
      ),
      GoRoute(
        path: '/quran/:number',
        pageBuilder: (context, state) => _detailPage(
          SurahDetailScreen(
            surahNumber: int.parse(state.pathParameters['number'] ?? '1'),
            surahName: state.uri.queryParameters['name'],
            surahArabic: state.uri.queryParameters['arabic'],
          ),
        ),
      ),
      GoRoute(
        path: '/asmaul-husna/:index',
        pageBuilder: (context, state) => _detailPage(
          AsmaulHusnaDetailScreen(
            index: int.parse(state.pathParameters['index'] ?? '0'),
          ),
        ),
      ),
    ],
  );
});

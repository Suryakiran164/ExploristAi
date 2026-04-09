import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/login_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/home/home_screen.dart';
import '../features/recommendations/detail_screen.dart';
import '../features/trip_planner/trip_planner_screen.dart';
import '../services/providers.dart';
import '../models/app_models.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final userState = ref.watch(userControllerProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuth = authState.value != null;
      final isLoggingIn = state.uri.path == '/login';
      
      if (!isAuth) return isLoggingIn ? null : '/login';
      
      if (userState.isLoading) return null; // Wait for user data
      
      final hasProfile = userState.value != null;
      final isOnboarding = state.uri.path == '/onboarding';

      if (!hasProfile && !isOnboarding) return '/onboarding';
      if (hasProfile && (isLoggingIn || isOnboarding)) return '/home';

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/detail', 
        builder: (context, state) => DetailScreen(place: state.extra as PlaceRecommendationModel)
      ),
      GoRoute(path: '/planner', builder: (context, state) => const TripPlannerScreen()),
    ],
  );
});
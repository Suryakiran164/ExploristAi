import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Screens
import '../features/auth/login_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/home/home_screen.dart';
import '../features/recommendations/detail_screen.dart';
import '../features/trip_planner/trip_planner_screen.dart';
import '../features/saved/saved_trips_screen.dart'; // Make sure this exists

// Logic
import '../services/providers.dart';
import '../models/app_models.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final userController = ref.watch(userControllerProvider);

  return GoRouter(
    initialLocation: '/home',
    // The redirect logic handles the "Gateway" functionality automatically
    redirect: (context, state) {
      final isAuth = authState.value != null;
      final isLoggingIn = state.uri.path == '/login';

      // 1. If not logged in, force to Login screen
      if (!isAuth) {
        return isLoggingIn ? null : '/login';
      }

      // 2. If logged in but user profile is still loading, stay put
      if (userController.isLoading) return null;

      final hasProfile = userController.value != null;
      final isOnboarding = state.uri.path == '/onboarding';

      // 3. If logged in but no Firestore profile, force Onboarding
      if (!hasProfile) {
        return isOnboarding ? null : '/onboarding';
      }

      // 4. If logged in AND has profile, prevent going back to Login or Onboarding
      if (isLoggingIn || isOnboarding) {
        return '/home';
      }

      // Otherwise, let them go where they want
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/detail',
        builder: (context, state) {
          final place = state.extra as PlaceRecommendationModel;
          return DetailScreen(place: place);
        },
      ),
      GoRoute(
        path: '/planner',
        builder: (context, state) => const TripPlannerScreen(),
      ),
      // FIXED: The missing route that was causing the 404 error
      GoRoute(
        path: '/saved',
        builder: (context, state) => const SavedTripsScreen(),
      ),
    ],
    // Handle errors (like typing a wrong URL) by sending them home
    errorBuilder: (context, state) => const HomeScreen(),
  );
});
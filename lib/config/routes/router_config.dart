import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import 'dart:async';

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: const SplashRoute().location,
    debugLogDiagnostics: true,
    routes: $appRoutes,

    // Global redirect for authentication
    redirect: (context, state) {
      final authState = authBloc.state;
      // Note: This relies on how AuthState is implemented.
      // If we used freezed, we might need a better way to check "Authenticated"
      // For now assume standard way or specific check.
      // In the BLoC code: const factory AuthState.authenticated({required UserEntity user}) = _Authenticated;
      // So checking 'is Authenticated' might need the freezed class mixin logic or similar.
      // But we can check via runtime type if imports are correct.
      // Let's assume we can check if state has user.

      final isAuthenticated = authState.maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );

      final isAuthRoute = state.matchedLocation == const LoginRoute().location ||
          state.matchedLocation == const RegisterRoute().location ||
          state.matchedLocation == const ForgotPasswordRoute().location ||
          state.matchedLocation.startsWith('/verify-otp') ||
          state.matchedLocation.startsWith('/i/'); // Public invitation

      // Allow public routes
      if (state.matchedLocation.startsWith('/i/')) {
        return null;
      }

      // If not authenticated and not on auth route, redirect to login
      if (!isAuthenticated && !isAuthRoute) {
        return const LoginRoute().location;
      }

      // If authenticated and on auth route, redirect to home
      if (isAuthenticated && isAuthRoute) {
        return const HomeRoute().location;
      }

      return null;
    },

    // Refresh listenable for auth state changes
    refreshListenable: GoRouterRefreshStream(authBloc.stream),

    // Error page
    errorBuilder: (context, state) => Scaffold(body: Center(child: Text('Error: ${state.error}'))),
  );
}

// Refresh stream for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

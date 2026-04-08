// lib/core/utils/router/route_guard.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth/data/cubit/auth_cubit.dart';
import '../utils/local_storage/session_manager.dart';


class AuthGuard {
  static String? redirect(BuildContext context, GoRouterState state) {
    if (state.matchedLocation == '/splash') return null;

    final authCubit = context.read<AuthCubit>();
    final authState = authCubit.state;

    final isAuthenticated = authState is AuthSessionActive || authState is AuthSuccess;
    final isGuest = authState is AuthGuest;
    final isAuthPage = state.matchedLocation.contains('/login') ||
        state.matchedLocation.contains('/signup');

    // Authenticated user on auth page → home
    if (isAuthenticated && isAuthPage) {
      return '/home';
    }

    // Completely unauthenticated (no token, no guest) trying to access protected content → login
    // But we don't have a clear list of "protected" routes; instead we let the UI handle it.
    // So we only redirect if there is NO auth state at all and not on auth page.
    if (!isAuthenticated && !isGuest && !isAuthPage) {
      SessionManager().setPendingRedirect(state.uri.toString());
      return '/login';
    }

    return null;
  }
}
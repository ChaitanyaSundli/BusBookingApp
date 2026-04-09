
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth/data/cubit/auth_cubit.dart';
import '../utils/local_storage/session_manager.dart';


class AuthGuard {

  static String? redirect(BuildContext context, GoRouterState state) {

    final authCubit = context.read<AuthCubit>();
    final authState = authCubit.state;

    final isAuthenticated = authState is AuthSessionActive || authState is AuthSuccess;
    final isGuest = authState is AuthGuest;
    final isAuthPage = state.matchedLocation.contains('/login') ||
        state.matchedLocation.contains('/signup');

    if (isAuthenticated && isAuthPage) return '/home';
    if (!isAuthenticated && !isGuest && !isAuthPage) {
      SessionManager().setPendingRedirect(state.uri.toString());
      return '/login';
    }
    return null;
  }}
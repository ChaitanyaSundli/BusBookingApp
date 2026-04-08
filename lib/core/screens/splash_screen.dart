// lib/core/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../auth/data/cubit/auth_cubit.dart';
import '../utils/local_storage/session_manager.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // Only navigate once we have a definitive state (not initial/loading)
        if (state is AuthSessionActive || state is AuthSuccess || state is AuthGuest) {
          final pending = SessionManager().consumePendingRedirect();
          context.go(pending ?? '/home');
        } else if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: const Scaffold(
        body: Center(
          child: Text("Loading..."),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../auth/data/cubit/auth_cubit.dart';
import '../utils/local_storage/session_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 8), () {
      if (!mounted) return;
      final state = context.read<AuthCubit>().state;
      if (state is AuthInitial) {
        debugPrint(' Forcing navigation from splash');
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSessionActive || state is AuthSuccess || state is AuthGuest) {
          final pending = SessionManager().consumePendingRedirect();
          context.go(pending ?? '/home');
        } else if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading QuickBus...'),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../widgets/app_button.dart';
import '../../../../widgets/app_card.dart';
import '../../../../widgets/app_text_field.dart';
import '../../data/cubit/auth_cubit.dart';
import '../../../../utils/local_storage/session_manager.dart';

class LoginScreen extends StatefulWidget {
  final String? redirectTo;

  const LoginScreen({super.key, this.redirectTo});

  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _rememberMe = true;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess || state is AuthSessionActive) {
          final session = SessionManager();
          final pendingRedirect = session.consumePendingRedirect();
          final target = widget.redirectTo ?? pendingRedirect ?? '/home';
          context.pushReplacement(target);
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    "Welcome To\nQuickBus",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 28),
                  AppCard(
                    child: Column(
                      children: [
                        const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          hint: "Email",
                          controller: emailController,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          hint: "Password",
                          obscure: true,
                          controller: passwordController,
                        ),
                        const SizedBox(height: 20),
                        AppButton(
                          text: state is AuthLoading ? "Loading..." : "Login",
                          onTap: state is AuthLoading
                              ? null
                              : () {
                                  context.read<AuthCubit>().login(
                                        emailController.text.trim(),
                                        passwordController.text.trim(),
                                        rememberMe: _rememberMe,
                                      );
                                },
                        ),
                        const SizedBox(height: 8),
                        CheckboxListTile(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? true;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: const Text('Remember me'),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text("Forgot your password?"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: () {
                      final redirect = widget.redirectTo == null
                          ? '/signup'
                          : '/signup?redirect=${Uri.encodeComponent(widget.redirectTo!)}';
                      context.go(redirect);
                    },
                    child: const Text("Dont have an account ? Sign Up Now"),
                  ),
                  AppButton(
                    text: 'Sign Up',
                    onTap: () {
                      final redirect = widget.redirectTo == null
                          ? '/signup'
                          : '/signup?redirect=${Uri.encodeComponent(widget.redirectTo!)}';
                      context.go(redirect);
                    },
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'Login as Guest',
                    onTap: () => context.go('/home'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

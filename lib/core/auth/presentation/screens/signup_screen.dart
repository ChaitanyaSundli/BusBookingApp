import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';


import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_text_field.dart';
import '../../data/cubit/auth_cubit.dart';

class SignupScreen extends StatefulWidget {
  final String? redirectTo;

  const SignupScreen({super.key, this.redirectTo});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthRegisterSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful.')),
          );
        }

        if (state is AuthSuccess) {
          context.go(widget.redirectTo ?? '/home');
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Sign Up')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: AppCard(
                child: Column(
                  children: [
                    AppTextField(hint: 'Full Name', controller: nameController),
                    const SizedBox(height: 12),
                    AppTextField(hint: 'Email', controller: emailController),
                    const SizedBox(height: 12),
                    AppTextField(hint: 'Phone Number', controller: phoneController),
                    const SizedBox(height: 12),
                    AppTextField(
                      hint: 'Password',
                      obscure: true,
                      controller: passwordController,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      hint: 'Confirm Password',
                      obscure: true,
                      controller: confirmPasswordController,
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      text: state is AuthLoading ? 'Creating...' : 'Sign Up',
                      onTap: state is AuthLoading
                          ? null
                          : () {
                              if (passwordController.text !=
                                  confirmPasswordController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Passwords do not match')),
                                );
                                return;
                              }
                              context.read<AuthCubit>().register(
                                    name: nameController.text.trim(),
                                    email: emailController.text.trim(),
                                    phone: phoneController.text.trim(),
                                    password: passwordController.text.trim(),
                                  );
                            },
                    ),
                    TextButton(
                      onPressed: () {
                        final redirect = widget.redirectTo == null
                            ? '/login'
                            : '/login?redirect=${Uri.encodeComponent(widget.redirectTo!)}';
                        context.go(redirect);
                      },
                      child: const Text('Already have an account? Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}

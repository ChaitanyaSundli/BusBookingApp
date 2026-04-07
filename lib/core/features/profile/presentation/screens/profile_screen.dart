import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../utils/local_storage/session_manager.dart';
import '../../../../widgets/app_card.dart';
import '../../../../widgets/login_required_modal.dart';
import '../../../auth/data/cubit/auth_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: SessionManager().loadSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = SessionManager().currentUser;
        final isLoggedIn = SessionManager().token != null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            centerTitle: true,
          ),
          body: isLoggedIn
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      AppCard(
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 35,
                              child: Icon(Icons.person, size: 40),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              user?.name ?? 'Guest User',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(user?.email ?? 'Please login'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      AppCard(
                        child: Column(
                          children: [
                            _ProfileTile(
                              icon: Icons.history,
                              title: 'My Bookings',
                              onTap: () => context.go('/bookings'),
                            ),
                            const Divider(),
                            _ProfileTile(
                              icon: Icons.logout,
                              title: 'Logout',
                              onTap: () async {
                                await context.read<AuthCubit>().logout();
                                if (context.mounted) context.go('/login');
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : const LoginRequiredScreen(redirectTo: '/profile'),
        );
      },
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

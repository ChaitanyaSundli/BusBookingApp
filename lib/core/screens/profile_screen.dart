// lib/features/home/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/local_storage/session_manager.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../auth/data/cubit/auth_cubit.dart';
import '../widgets/app_layout_frame.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final isGuest = authState is AuthGuest;
        final session = SessionManager();
        final user = isGuest ? null : session.currentUser;

        return AppLayout(
          showAppBar: true,
          title: 'Profile',
          // Optional: customize app bar actions (e.g., settings icon for logged in)
          actions: isGuest
              ? null
              : [
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
              onPressed: () {
                // Navigate to settings if needed
              },
            ),
          ],
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (isGuest)
                  _buildGuestCard(context)
                else
                  _buildUserInfoCard(context, user!),
                const SizedBox(height: 16),
                if (!isGuest) _buildMenuCard(),
                const SizedBox(height: 24),
                _buildActionButton(context, isGuest),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGuestCard(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.account_circle, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Guest User',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to access your bookings, saved addresses, and more.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, dynamic user) {
    return AppCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              user.name.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard() {
    return AppCard(
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Personal Information',
            onTap: () {},
          ),
          const Divider(),
          _buildMenuItem(
            icon: Icons.payment_outlined,
            title: 'Payment Methods',
            onTap: () {},
          ),
          const Divider(),
          _buildMenuItem(
            icon: Icons.location_on_outlined,
            title: 'Saved Addresses',
            onTap: () {},
          ),
          const Divider(),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {},
          ),
          const Divider(),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {},
          ),
          const Divider(),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'About',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionButton(BuildContext context, bool isGuest) {
    if (isGuest) {
      return AppButton(
        text: 'Login / Register',
        onTap: () => context.go('/login'),
        backgroundColor: Theme.of(context).primaryColor,
      );
    } else {
      return AppButton(
        text: 'Logout',
        onTap: () async {
          await context.read<AuthCubit>().logout();
          if (context.mounted) {
            context.go('/login');
          }
        },
        backgroundColor: Colors.red,
      );
    }
  }
}
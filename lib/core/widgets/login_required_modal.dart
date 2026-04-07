import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/local_storage/session_manager.dart';

Future<void> showLoginRequiredModal(BuildContext context, {String? redirectTo}) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
              child: Icon(Icons.lock_outline, color: theme.colorScheme.primary, size: 18),
            ),
            const SizedBox(width: 10),
            const Expanded(child: Text('Login required')),
          ],
        ),
        content: const Text(
          'You need to be logged in before confirming this booking. Please sign in to continue securely.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Not now'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              final redirectPath = redirectTo;
              SessionManager().setPendingRedirect(redirectPath);
              final redirect = redirectPath == null
                  ? '/login'
                  : '/login?redirect=${Uri.encodeComponent(redirectPath)}';
              context.push(redirect);
            },
            icon: const Icon(Icons.login),
            label: const Text('Go to Login'),
          ),
        ],
      );
    },
  );
}

class LoginRequiredScreen extends StatelessWidget {
  final String redirectTo;

  const LoginRequiredScreen({super.key, required this.redirectTo});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 42),
                const SizedBox(height: 12),
                const Text(
                  'Login required',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You need to login before using this feature.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () => context.go(
                    '/login?redirect=${Uri.encodeComponent(redirectTo)}',
                  ),
                  child: const Text('Go to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

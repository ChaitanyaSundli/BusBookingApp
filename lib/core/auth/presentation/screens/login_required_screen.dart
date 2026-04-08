import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/local_storage/session_manager.dart';

Future<void> showLoginRequiredModal(
    BuildContext context, {
      required String redirectTo,
    }) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Icon(Icons.lock_outline, size: 48, color: Color(0xFF4F46E5)),
          const SizedBox(height: 12),
          const Text(
            'Login Required',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            'Please log in to continue booking your ticket.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(ctx); // Close bottom sheet

                // Save redirect path for after login
                SessionManager().setPendingRedirect(redirectTo);

                // Use the original context (from parameter) after the sheet is dismissed
                // We need to wait for the sheet animation to finish
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    context.go('/login?redirect=${Uri.encodeComponent(redirectTo)}');
                  }
                });
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Log In',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(ctx);
                // For signup, we can also store redirect
                SessionManager().setPendingRedirect(redirectTo);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    context.go('/signup?redirect=${Uri.encodeComponent(redirectTo)}');
                  }
                });
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Create Account'),
            ),
          ),
        ],
      ),
    ),
  );
}
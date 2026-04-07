import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/local_storage/session_manager.dart';
import '../../../widgets/login_required_modal.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _getIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/bookings')) return 1;
    if (location.startsWith('/profile')) return 2;

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) async {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              await _goProtected(context, '/bookings');
              break;
            case 2:
              await _goProtected(context, '/profile');
              break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.book), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Future<void> _goProtected(BuildContext context, String path) async {
    final session = SessionManager();
    await session.loadSession();
    if (!context.mounted) return;
    if (session.token == null) {
      await showLoginRequiredModal(context, redirectTo: path);
      return;
    }
    if (!context.mounted) return;
    context.go(path);
  }
}

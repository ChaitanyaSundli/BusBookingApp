// lib/features/home/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../auth/data/cubit/auth_cubit.dart';
import '../widgets/login_required.dart';
import 'home_tab.dart';
import 'my_bookings_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Read tab query parameter after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleDeepLink();
    });
  }

  void _handleDeepLink() {
    final uri = GoRouterState.of(context).uri;
    final tab = uri.queryParameters['tab'];
    if (tab != null) {
      final index = int.tryParse(tab);
      if (index != null && index >= 0 && index <= 2) {
        setState(() => _selectedIndex = index);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final isGuest = authState is AuthGuest;
        final pages = [
          const HomeTab(),
          isGuest
              ? LoginRequiredScreen(redirectTo: '/my-bookings')
              : const MyBookingsScreen(),
          isGuest
              ? LoginRequiredScreen(redirectTo: '/profile')
              : const ProfileScreen(),
        ];

        return Scaffold(
          body: pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              if (isGuest && index != 0) {
                showLoginRequiredModal(
                  context,
                  redirectTo: index == 1 ? '/my-bookings' : '/profile',
                );
                return;
              }
              setState(() => _selectedIndex = index);
              // Update URL to reflect tab (optional)
              final tabParam = index == 0 ? '' : '?tab=$index';
              context.go('/home$tabParam');
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book_online_outlined),
                activeIcon: Icon(Icons.book_online),
                label: 'My Bookings',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
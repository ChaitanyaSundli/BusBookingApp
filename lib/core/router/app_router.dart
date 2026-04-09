
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_bus/core/router/router_gaurd.dart';

import '../auth/data/cubit/auth_cubit.dart';
import '../auth/presentation/screens/login_screen.dart';
import '../auth/presentation/screens/signup_screen.dart';
import '../screens/booking_detail_screen.dart';
import '../screens/home_tab.dart';
import '../screens/my_bookings_screen.dart';
import '../screens/passenger_detail_screen.dart';
import '../screens/payment_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/trip_detail_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(AuthCubit authCubit) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/home',
      refreshListenable: GoRouterRefreshStream(authCubit.stream),
      redirect: (context, state) => AuthGuard.redirect(context, state),
      routes: [
        
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) {
            final redirect = state.uri.queryParameters['redirect'];
            return LoginScreen(redirectTo: redirect);
          },
        ),
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) {
            final redirect = state.uri.queryParameters['redirect'];
            return SignupScreen(redirectTo: redirect);
          },
        ),

        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return HomeScreenWithShell(navigationShell: navigationShell);
          },
          branches: [
            
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  name: 'home',
                  builder: (context, state) => const HomeTab(),
                  routes: [
                    GoRoute(
                      path: 'payment',
                      name: 'home_payment',
                      builder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>;
                        return PaymentScreen(
                          bookingId: extra['bookingId'] as int,
                          paymentId: extra['paymentId'] as int,
                          totalPrice: extra['totalPrice'] as double,
                          source: 'home',
                        );
                      },
                    ),
                    GoRoute(
                      path: 'booking/:id',
                      name: 'home_booking_detail',
                      builder: (context, state) {
                        final id = int.parse(state.pathParameters['id']!);
                        return BookingDetailScreen(bookingId: id, source: 'home');
                      },
                    ),
                    GoRoute(
                      path: '/trip/:id',
                      name: 'trip_detail',
                      builder: (context, state) {
                        final id = int.parse(state.pathParameters['id']!);
                        return TripDetailScreen(tripId: id);
                      },
                      routes: [
                        GoRoute(
                          path: '/passengers',
                          name: 'passengers',
                          builder: (context, state) {
                            final extra = state.extra as Map<String, dynamic>;
                            return PassengerDetailsScreen(
                              tripId: extra['tripId'] as int,
                              boardingStopId: extra['boardingStopId'] as int,
                              dropStopId: extra['dropStopId'] as int,
                              selectedSeatIds: (extra['selectedSeatIds'] as List).cast<int>(),
                            );
                          },
                        ),
                      ]
                    ),
                  ],
                ),
              ],
            ),
            
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/my-bookings',
                  name: 'my_bookings',
                  builder: (context, state) => const MyBookingsScreen(),
                  routes: [
                    GoRoute(
                      path: 'booking/:id',
                      name: 'my_bookings_booking_detail',
                      builder: (context, state) {
                        final id = int.parse(state.pathParameters['id']!);
                        return BookingDetailScreen(bookingId: id, source: 'my-bookings');
                      },
                    ),
                  ],
                ),
              ],
            ),
            
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  name: 'profile',
                  builder: (context, state) => const ProfileScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(child: Text('Page not found: ${state.uri}')),
      ),
    );
  }
}


class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.listen((_) => notifyListeners());
  }
}


class HomeScreenWithShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const HomeScreenWithShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
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
  }
}
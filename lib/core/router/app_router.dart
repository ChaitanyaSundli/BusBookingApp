// lib/core/utils/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_bus/core/router/router_gaurd.dart';

import '../auth/data/cubit/auth_cubit.dart';
import '../auth/presentation/screens/login_screen.dart';
import '../auth/presentation/screens/signup_screen.dart';
import '../screens/home_screen.dart';
import '../screens/passenger_detail_screen.dart';
import '../screens/payment_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/trip_detail_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(AuthCubit authCubit) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/splash',  // ← start here
      refreshListenable: GoRouterRefreshStream(authCubit.stream),
      redirect: (context, state) => AuthGuard.redirect(context, state),
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
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

        // Home (with tabs)
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),

        // Redirect /my-bookings → /home?tab=1
        GoRoute(
          path: '/my-bookings',
          redirect: (context, state) => '/home?tab=1',
        ),

        // Redirect /profile → /home?tab=2
        GoRoute(
          path: '/profile',
          redirect: (context, state) => '/home?tab=2',
        ),

        // Trip detail
        GoRoute(
          path: '/trip/:id',
          name: 'trip_detail',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return TripDetailScreen(tripId: id);
          },
        ),

        // Passenger details (booking flow)
        GoRoute(
          path: '/booking/passengers',
          name: 'booking_passengers',
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
        GoRoute(
          path: '/payment',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return PaymentScreen(
              bookingId: extra['bookingId'],
              paymentId: extra['paymentId'],
              totalPrice: extra['totalPrice'],
            );
          },
        ),
        GoRoute(
          path: '/payment',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return PaymentScreen(
              bookingId: extra['bookingId'],
              paymentId: extra['paymentId'],
              totalPrice: extra['totalPrice'],
            );
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Page not found: ${state.uri}'),
        ),
      ),
    );
  }
}

// Helper for GoRouter refresh
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.listen((_) {
      notifyListeners();
    });
  }
}
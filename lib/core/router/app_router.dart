import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_bus/core/features/home/presentation/screens/boarding_screen.dart';
import 'package:quick_bus/core/features/home/presentation/screens/passenger_screen.dart';
import 'package:quick_bus/core/features/home/presentation/screens/seat_selection_screen.dart';
import 'package:quick_bus/core/features/operators_bus/presentation/screen/bus_list_screen.dart';
import 'package:quick_bus/core/features/profile/presentation/screens/profile_screen.dart';

import '../features/SearchOperator/presentation/screens/operator_detail_screen.dart';
import '../features/SearchOperator/presentation/screens/operator_list_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/bookings/presentation/screens/booking_detail_screen.dart';
import '../features/bookings/presentation/screens/bookings.screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/navigation/presentation/main_shell.dart';
import '../utils/local_storage/session_manager.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  redirect: (context, state) async {
    final session = SessionManager();
    await session.loadSession();

    final isLoggedIn = session.token != null;
    final path = state.uri.path;
    final isAuthPage = path == '/login' || path == '/signup';

    if (isAuthPage && isLoggedIn) return '/home';
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(
        redirectTo: state.uri.queryParameters['redirect'],
      ),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => SignupScreen(
        redirectTo: state.uri.queryParameters['redirect'],
      ),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => HomeScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (_, _) => HomeScreen(),
        ),
        GoRoute(
          path: '/bookings',
          builder: (_, _) => const BookingsScreen(),
          routes: [
            GoRoute(
              path: 'detail/:id',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return BookingDetailScreen(id: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/profile',
          builder: (_, state) => const ProfileScreen(),
        ),
      ],
    ),

    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/operator-list/:source/:destination',
      builder: (context, state) => OperatorListScreen(
        source: state.pathParameters['source']!,
        destination: state.pathParameters['destination']!,
        date: state.uri.queryParameters['date'],
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/bus-list/:source/:destination/:operatorId',
      builder: (context, state) => BusListScreen(
        source: state.pathParameters['source']!,
        destination: state.pathParameters['destination']!,
        operatorId: int.parse(state.pathParameters['operatorId']!),
        date: state.uri.queryParameters['date'] ?? '',
        operatorName: state.uri.queryParameters['operator'] ?? 'Bus Operator',
      ),
    ),

    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/operators/:operatorId',
      builder: (context, state) => OperatorDetailScreen(
        operatorId: int.parse(state.pathParameters['operatorId']!),
        operatorName: state.uri.queryParameters['name'],
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/seat/:tripId',
      builder: (context, state) =>
          SeatSelectionScreen(tripId: int.parse(state.pathParameters['tripId']!)),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/boarding/:tripId',
      builder: (context, state) =>
          BoardingScreen(tripId: int.parse(state.pathParameters['tripId']!)),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/passenger/:tripId',
      builder: (context, state) =>
          PassengerScreen(tripId: int.parse(state.pathParameters['tripId']!)),
    ),
  ],
);

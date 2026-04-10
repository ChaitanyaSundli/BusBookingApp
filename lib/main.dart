// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/api/booking_api.dart';
import 'core/api/payment_api.dart';
import 'core/api/trips_api.dart';
import 'core/auth/data/api/auth_api.dart';
import 'core/auth/data/cubit/auth_cubit.dart';
import 'core/auth/data/repository/auth_repository.dart';
import 'core/cubit/booking_cubit.dart';
import 'core/cubit/city_search_cubit.dart';
import 'core/cubit/payment_cubit.dart';
import 'core/cubit/trips_cubit.dart';
import 'core/network/api_client.dart';
import 'core/repository/booking_repository.dart';
import 'core/repository/payment_repository.dart';
import 'core/repository/trips_repository.dart';
import 'core/router/app_router.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dio = DioClient.getDio();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => TripsApi(dio)),
        RepositoryProvider(
          create: (context) => TripsRepository(
            context.read<TripsApi>(),
            dio,
          ),
        ),
        RepositoryProvider(
          create: (_) => AuthApi(dio),
        ),
        RepositoryProvider(
          create: (context) => AuthRepository(
            context.read<AuthApi>(),
            dio,
          ),
        ),
        RepositoryProvider(
          create: (_) => BookingApi(dio),
        ),
        RepositoryProvider(
          create: (context) => BookingRepository(
            context.read<BookingApi>(),
            dio,
          ),
        ),
        RepositoryProvider(create: (_) => PaymentApi(dio)),
        RepositoryProvider(
          create: (context) => PaymentRepository(
            context.read<PaymentApi>(),
            dio,
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => TripsCubit(context.read<TripsRepository>()),
          ),
          BlocProvider(
            create: (context) => AuthCubit(context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (context) => BookingCubit(context.read<BookingRepository>()),
          ),
          BlocProvider(
            create: (context) => CitySearchCubit(tripsRepo: context.read<TripsRepository>()),
          ),
          BlocProvider(
            create: (context) => PaymentCubit(context.read<PaymentRepository>()),
          ),
        ],
        child: Builder(
          builder: (context) {
            final authCubit = context.read<AuthCubit>();
            final router = AppRouter.createRouter(authCubit);

            return MaterialApp.router(
              title: 'QuickBus',
              theme: _buildAppTheme(),
              routerConfig: router,
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }

  ThemeData _buildAppTheme() {
    const primaryColor = Color(0xFFE53935);
    const secondaryColor = Color(0xFFFF7043);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        error: Colors.red.shade800,
        brightness: Brightness.light,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(color: Colors.grey.shade700),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
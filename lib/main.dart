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
              theme: ThemeData(
                primarySwatch: Colors.blue,
                useMaterial3: true,
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              routerConfig: router,
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}
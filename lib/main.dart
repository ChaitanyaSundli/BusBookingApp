import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_bus/core/features/home/data/cubit/stops_cubit.dart';
import 'package:quick_bus/core/features/operators_bus/data/cubit/booking_flow_cubit.dart';

import 'core/features/SearchOperator/data/cubit/operator_list_cubit.dart';
import 'core/features/auth/data/cubit/auth_cubit.dart';
import 'core/features/operators_bus/data/cubit/trip_cubit.dart';
import 'core/network/di.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_layout_frame.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: DI.authRepository),
        RepositoryProvider.value(value: DI.stopsRepository),
        RepositoryProvider.value(value: DI.searchBusRepository),
        RepositoryProvider.value(value: DI.tripRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthCubit(DI.authRepository)),
          BlocProvider(create: (_) => StopsCubit()),
          BlocProvider(create: (_) => OperatorListCubit()),
          BlocProvider(create: (_) => TripCubit(DI.tripRepository)),
          BlocProvider(create: (_) => BookingFlowCubit(DI.tripRepository)),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
          theme: AppTheme.light,
          builder: (context, child) => AppLayoutFrame(child: child!),
        ),
      ),
    );
  }
}

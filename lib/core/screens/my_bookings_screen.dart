// lib/features/home/presentation/screens/my_bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_states.dart';
import '../cubit/booking_cubit.dart';
import '../widgets/app_layout_frame.dart';
import '../widgets/booking_card.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<BookingCubit>()..fetchBookings(),
      child: AppLayout(
        showAppBar: true,
        title: 'My Bookings',
        child: BlocBuilder<BookingCubit, BookingState>(
          builder: (context, state) {
            if (state is BookingLoading) {
              return const AppLoadingState(message: 'Loading your bookings...');
            }

            if (state is BookingError) {
              return AppErrorState(
                message: state.message,
                onRetry: () => context.read<BookingCubit>().fetchBookings(),
              );
            }

            if (state is BookingsLoaded) {
              if (state.bookings.isEmpty) {
                return AppEmptyState(
                  message: 'No bookings found',
                  icon: Icons.book_online_outlined,
                  action: ElevatedButton(
                    onPressed: () {
                      // Navigate to search/bus list
                    },
                    child: const Text('Book a Trip'),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => context.read<BookingCubit>().fetchBookings(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.bookings.length,
                  itemBuilder: (context, index) {
                    final booking = state.bookings[index];
                    return BookingCard(
                      booking: booking,
                      onTap: () => context.push('/booking/${booking.id}'),
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
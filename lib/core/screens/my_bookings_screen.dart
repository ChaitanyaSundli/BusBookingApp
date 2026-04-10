// lib/features/home/presentation/screens/my_bookings_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubit/booking_cubit.dart';
import '../widgets/app_button.dart';
import '../widgets/app_layout_frame.dart';
import '../widgets/app_states.dart';
import '../widgets/booking_card.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    await context.read<BookingCubit>().fetchBookings();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      showAppBar: true,
      title: 'My Bookings',
      child: BlocConsumer<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state is BookingError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is BookingLoading) {
            return const AppLoadingState(message: 'Loading your bookings...');
          }

          if (state is BookingLoaded) {
            if (state.bookings.isEmpty) {
              return AppEmptyState(
                message: 'No bookings yet',
                icon: Icons.book_online_outlined,
                action: AppButton(
                  text: 'Book a Trip',
                  onTap: () {
                    context.go('/home');
                    _fetchBookings();
                  },
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _fetchBookings,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.bookings.length,
                itemBuilder: (ctx, i) => BookingCard(
                  booking: state.bookings[i],
                  onTap: () async {
                    await context.push(
                      '/my-bookings/booking/${state.bookings[i].id}',
                    );
                    _fetchBookings();
                  },
                ),
              ),
            );
          }

          if (state is BookingError) {
            return AppErrorState(
              message: state.message,
              onRetry: _fetchBookings,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

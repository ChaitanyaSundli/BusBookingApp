import 'package:flutter/material.dart';

import '../../../../utils/local_storage/session_manager.dart';
import '../../../../widgets/login_required_modal.dart';
import '../../data/local/booking_history_store.dart';
import '../widgets/booking_card.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: SessionManager().loadSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final isLoggedIn = SessionManager().token != null;
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Bookings'),
            centerTitle: true,
          ),
          body: isLoggedIn
              ? FutureBuilder<List<BookingHistoryItem>>(
                  future: BookingHistoryStore().getBookings(),
                  builder: (context, bookingSnapshot) {
                    if (bookingSnapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final bookings = bookingSnapshot.data ?? const [];
                    if (bookings.isEmpty) {
                      return const Center(child: Text('No bookings yet'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: bookings.length,
                      itemBuilder: (_, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: BookingCard(booking: bookings[index]),
                      ),
                    );
                  },
                )
              : const LoginRequiredScreen(redirectTo: '/bookings'),
        );
      },
    );
  }
}

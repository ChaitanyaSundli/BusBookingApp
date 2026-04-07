import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/local/booking_history_store.dart';
import '../../../../widgets/app_card.dart';
import '../../../../utils/date_time_formatter.dart';

class BookingCard extends StatelessWidget {
  final BookingHistoryItem booking;

  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final displayFare =
        booking.totalPrice > 0 ? booking.totalPrice : (booking.paymentAmount ?? 0);

    return AppCard(
      child: GestureDetector(
        onTap: () => context.go('/bookings/detail/${booking.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.busName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              '${booking.source} → ${booking.destination}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    formatTravelDateTime(booking.departureTime),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    formatTravelDateTime(booking.arrivalTime),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Seats: ${booking.seatNumbers.join(', ')} • ₹${displayFare.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

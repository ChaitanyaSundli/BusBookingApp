import 'package:flutter/material.dart';
import '../../data/local/booking_history_store.dart';
import '../../../../widgets/app_card.dart';
import '../../../../utils/date_time_formatter.dart';
import '../widgets/passenger_row.dart';

class BookingDetailScreen extends StatelessWidget {
  final int id;

  const BookingDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BookingHistoryItem>>(
      future: BookingHistoryStore().getBookings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final bookings = snapshot.data ?? const [];
        BookingHistoryItem? booking;
        for (final item in bookings) {
          if (item.id == id) {
            booking = item;
            break;
          }
        }

        if (booking == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Booking Details')),
            body: const Center(child: Text('Booking not found')),
          );
        }

        final seats = booking.seatNumbers;
        final effectiveFare = booking.totalPrice > 0
            ? booking.totalPrice
            : (booking.paymentAmount ?? 0);
        final effectivePaidAmount = (booking.paymentAmount ?? 0) > 0
            ? booking.paymentAmount!
            : effectiveFare;
        final effectivePaymentStatus =
            (booking.paymentStatus ?? '').trim().isEmpty ? 'Pending' : booking.paymentStatus!;
        final taxes = (effectivePaidAmount - effectiveFare).clamp(0, double.infinity).toDouble();
        final farePerSeat = seats.isEmpty ? 0 : effectiveFare / seats.length;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Booking Details"),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${booking.busName} • ${booking.busNumber}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${booking.source} -> ${booking.destination}",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Departure: ${formatTravelDateTime(booking.departureTime)}",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Arrival: ${formatTravelDateTime(booking.arrivalTime)}",
                              textAlign: TextAlign.end,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Total Passengers: ${seats.length}",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildSectionHeader("Seat Details"),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    children: [
                      for (int i = 0; i < seats.length; i++) ...[
                        if (i > 0) const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: const Icon(Icons.event_seat_outlined),
                          title: Text('Seat ${seats[i]}'),
                          trailing: Text('₹${farePerSeat.toStringAsFixed(0)}'),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildSectionHeader("Payment Details"),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    children: [
                      PaymentRow(
                        label: "Ticket Fare",
                        value: "₹${effectiveFare.toStringAsFixed(0)}",
                      ),
                      const SizedBox(height: 8),
                      PaymentRow(label: "Taxes", value: "₹${taxes.toStringAsFixed(0)}"),
                      const SizedBox(height: 8),
                      PaymentRow(
                        label: "Paid Amount",
                        value: "₹${effectivePaidAmount.toStringAsFixed(0)}",
                      ),
                      const SizedBox(height: 8),
                      PaymentRow(
                        label: "Payment Status",
                        value: effectivePaymentStatus,
                      ),
                      const Divider(height: 20),
                      PaymentRow(
                        label: "Total",
                        value: "₹${effectiveFare.toStringAsFixed(0)}",
                        isBold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.indigo,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

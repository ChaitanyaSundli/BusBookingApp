// lib/features/booking/presentation/screens/booking_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_states.dart';
import '../cubit/booking_cubit.dart';
import '../models/response/booking_details.dart';
import '../widgets/app_layout_frame.dart';

class BookingDetailScreen extends StatefulWidget {
  final int bookingId;
  final String source;


  const BookingDetailScreen({super.key, required this.bookingId, required this.source});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BookingCubit>().fetchBookingDetails(widget.bookingId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state is BookingLoaded && state.cancelResponse != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.cancelResponse!.message ?? 'Booking cancelled')),
          );
          context.pop();
        }
        if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) => switch (state) {
        BookingLoading() => const Scaffold(
          body: AppLoadingState(message: 'Loading booking details...'),
        ),
        BookingError(message: final msg) => AppLayout(
          showAppBar: true,
          title: 'Booking Details',
          child: AppErrorState(
            message: msg,
            onRetry: () => context.read<BookingCubit>().fetchBookingDetails(widget.bookingId),
          ),
        ),
        BookingLoaded(selectedBooking: final booking) => booking == null
            ? const AppEmptyState(message: 'Booking not found')
            : _buildContent(booking),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildContent(BookingDetail booking) {
    return AppLayout(
      showAppBar: true,
      title: 'Booking #${booking.id}',
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Card
                  AppCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getStatusColor(booking.status).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.confirmation_number_outlined, color: _getStatusColor(booking.status)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Booking Status', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                              const SizedBox(height: 4),
                              Text(booking.status.toUpperCase(),
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _getStatusColor(booking.status))),
                            ],
                          ),
                        ),
                        if (booking.paymentStatus != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
                            child: Text('Payment: ${booking.paymentStatus}', style: const TextStyle(fontSize: 12)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Trip Details
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Trip Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _row('Route', '${booking.trip.route.sourceCity} → ${booking.trip.route.destinationCity}', Icons.route),
                        _row('Travel Date', _formatDate(booking.trip.travelStartDate), Icons.calendar_today),
                        _row('Departure', _formatTime(booking.trip.departureTime), Icons.departure_board),
                        _row('Arrival', _formatTime(booking.trip.arrivalTime), Icons.watch_later_outlined),
                        _row('Distance', '${booking.trip.route.totalDistanceKm.toStringAsFixed(1)} km', Icons.straighten),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Passengers
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Passengers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        ...booking.passengers.map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                child: Text(p.name.substring(0, 1).toUpperCase(),
                                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text('${p.age} years • ${p.gender}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Seats
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Seat Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        ...booking.bookingSeats.map((bs) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.event_seat, color: Theme.of(context).primaryColor),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Seat ${bs.tripSeat.seat.seatNumber}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text('${bs.tripSeat.seat.seatType} • Deck ${bs.tripSeat.seat.deck}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                    Text('Passenger: ${bs.passenger.name}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  ],
                                ),
                              ),
                              Text('₹${bs.seatPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Boarding & Drop
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Boarding & Drop-off', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _row('Boarding', '${booking.boardingStop.stopName}, ${booking.boardingStop.cityName}', Icons.location_on),
                        _row('Drop-off', '${booking.dropStop.stopName}, ${booking.dropStop.cityName}', Icons.location_off),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Summary
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Payment Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Amount'),
                            Text('₹${booking.bookingSeats.fold(0.0, (sum, bs) => sum + bs.seatPrice).toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (booking.status.toLowerCase() != 'cancelled')
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
              ),
              child: SafeArea(
                child: AppButton(
                  text: 'Cancel Booking',
                  onTap: () => _showCancelConfirmation(booking.id),
                  backgroundColor: Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  void _showCancelConfirmation(int bookingId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('No')),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BookingCubit>().cancelBooking(bookingId);
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  String _formatTime(String? time) {
    if (time == null) return '--';
    try {
      final dt = DateTime.parse(time).toLocal();
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return time;
    }
  }

  String _formatDate(String? date) {
    if (date == null) return '--';
    try {
      final dt = DateTime.parse(date);
      return DateFormat('EEE, dd MMM yyyy').format(dt);
    } catch (_) {
      return date;
    }
  }
}
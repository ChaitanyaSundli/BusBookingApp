// lib/core/features/booking/presentation/screens/booking_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/booking_cubit.dart';
import '../models/response/post_booking_detail.dart';
import '../utils/date_time_formatter.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_layout_frame.dart';
import '../widgets/app_states.dart';

class BookingDetailScreen extends StatefulWidget {
  final int bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

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
        if (state is BookingCancelled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.response.message ?? 'Booking cancelled')),
          );
          context.pop();
        }
        if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is BookingDetailLoading) {
          return const Scaffold(
            body: AppLoadingState(message: 'Loading booking details...'),
          );
        }

        if (state is BookingError) {
          return AppLayout(
            showAppBar: true,
            title: 'Booking Details',
            child: AppErrorState(
              message: state.message,
              onRetry: () => context.read<BookingCubit>().fetchBookingDetails(widget.bookingId),
            ),
          );
        }

        if (state is BookingDetailLoaded) {
          final booking = state.detail;
          return AppLayout(
            showAppBar: true,
            title: 'Booking #${booking.id}',
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(booking),
                  const SizedBox(height: 16),
                  _buildTripDetailsCard(booking),
                  const SizedBox(height: 16),
                  _buildPassengersCard(booking),
                  const SizedBox(height: 16),
                  _buildSeatsCard(booking),
                  const SizedBox(height: 16),
                  _buildBoardingDropCard(booking),
                  if (booking.status.toLowerCase() != 'cancelled') ...[
                    const SizedBox(height: 24),
                    AppButton(
                      text: 'Cancel Booking',
                      onTap: () => _showCancelConfirmation(context, booking.id),
                      backgroundColor: Colors.red,
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatusCard(PostBookingDetail booking) {
    Color statusColor;
    switch (booking.status.toLowerCase()) {
      case 'confirmed':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.confirmation_number_outlined,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking Status',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  booking.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          if (booking.paymentStatus != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Payment: ${booking.paymentStatus}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTripDetailsCard(PostBookingDetail booking) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trip Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Route',
            '${booking.trip.route.sourceCity} → ${booking.trip.route.destinationCity}',
            Icons.route,
          ),
          _buildDetailRow(
            'Travel Date',
            formatTravelDateTime(booking.trip.travelStartDate),
            Icons.calendar_today,
          ),
          _buildDetailRow(
            'Departure',
            formatTravelTime(booking.trip.departureTime),
            Icons.departure_board,
          ),
          _buildDetailRow(
            'Arrival',
            formatTravelTime(booking.trip.arrivalTime),
            Icons.share_arrival_time_outlined,
          ),
          _buildDetailRow(
            'Distance',
            '${booking.trip.route.totalDistanceKm.toStringAsFixed(1)} km',
            Icons.straighten,
          ),
        ],
      ),
    );
  }

  Widget _buildPassengersCard(PostBookingDetail booking) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Passengers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...booking.passengers.map((passenger) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Text(
                    passenger.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        passenger.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${passenger.age} years • ${passenger.gender}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSeatsCard(PostBookingDetail booking) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seat Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...booking.bookingSeats.map((bs) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.event_seat,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seat ${bs.tripSeat.seat.seatNumber}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${bs.tripSeat.seat.seatType} • Deck ${bs.tripSeat.seat.deck}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'Passenger: ${bs.passenger.name}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${bs.seatPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBoardingDropCard(PostBookingDetail booking) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Boarding & Drop-off',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Boarding',
            '${booking.boardingStop.stopName}, ${booking.boardingStop.cityName}',
            Icons.location_on,
          ),
          _buildDetailRow(
            'Drop-off',
            '${booking.dropStop.stopName}, ${booking.dropStop.cityName}',
            Icons.location_off,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
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
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context, int bookingId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No'),
          ),
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
}
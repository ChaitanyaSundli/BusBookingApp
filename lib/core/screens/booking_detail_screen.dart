import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_states.dart';
import '../cubit/booking_cubit.dart';
import '../models/response/booking_details.dart';
import '../widgets/app_layout_frame.dart';

class BookingDetailScreen extends StatefulWidget {
  final int bookingId;
  final String source;

  const BookingDetailScreen({
    super.key,
    required this.bookingId,
    required this.source,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    context.read<BookingCubit>().fetchBookingDetails(widget.bookingId);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state is BookingLoaded && state.cancelResponse != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.cancelResponse!.message ?? 'Booking cancelled',
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          context.pop();
          context.read<BookingCubit>().fetchBookings();
        }
        if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is BookingLoaded && state.selectedBooking != null)
          _fadeController.forward();
        else
          _fadeController.reverse();

        return AppLayout(
          showAppBar: true,
          title: 'Booking #${widget.bookingId}',
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildBody(state),
          ),
        );
      },
    );
  }

  Widget _buildBody(BookingState state) {
    switch (state) {
      case BookingLoading():
        return const Center(
          child: AppLoadingState(message: 'Loading booking details...'),
        );
      case BookingError(message: final msg):
        return Center(
          child: AppErrorState(
            message: msg,
            onRetry: () => context.read<BookingCubit>().fetchBookingDetails(
              widget.bookingId,
            ),
          ),
        );
      case BookingLoaded(selectedBooking: final booking):
        if (booking == null)
          return const Center(
            child: AppEmptyState(message: 'Booking not found'),
          );
        return FadeTransition(
          opacity: _fadeController,
          child: _buildContent(booking),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildContent(BookingDetail booking) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatusCard(booking),
                const SizedBox(height: 16),
                _buildTripCard(booking),
                const SizedBox(height: 16),
                _buildPassengersCard(booking),
                const SizedBox(height: 16),
                _buildSeatsCard(booking),
                const SizedBox(height: 16),
                _buildStopsCard(booking),
                const SizedBox(height: 16),
                _buildPaymentCard(booking),
              ],
            ),
          ),
        ),
        if (booking.status.toLowerCase() != 'cancelled')
          _buildBottomActions(booking),
      ],
    );
  }

  Widget _buildStatusCard(BookingDetail booking) {
    final statusColor = _getStatusColor(booking.status, context);
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.confirmation_number_outlined,
              color: statusColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking Status',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  booking.status.toUpperCase(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: statusColor),
                ),
              ],
            ),
          ),
          if (booking.paymentStatus != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                'Payment: ${booking.paymentStatus}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTripCard(BookingDetail booking) => _infoCard(
    title: 'Trip Details',
    icon: Icons.directions_bus,
    children: [
      _infoRow(
        'Route',
        '${booking.trip.route.sourceCity} → ${booking.trip.route.destinationCity}',
        Icons.route,
      ),
      _infoRow(
        'Travel Date',
        _formatDate(booking.trip.travelStartDate),
        Icons.calendar_today,
      ),
      _infoRow(
        'Departure',
        _formatTime(booking.trip.departureTime),
        Icons.departure_board,
      ),
      _infoRow(
        'Arrival',
        _formatTime(booking.trip.arrivalTime),
        Icons.watch_later_outlined,
      ),
      _infoRow(
        'Distance',
        '${booking.trip.route.totalDistanceKm.toStringAsFixed(1)} km',
        Icons.straighten,
      ),
    ],
  );

  Widget _buildPassengersCard(BookingDetail booking) => _infoCard(
    title: 'Passengers',
    icon: Icons.people,
    children: booking.passengers.map((p) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
              child: Text(
                p.name.substring(0, 1).toUpperCase(),
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name, style: Theme.of(context).textTheme.titleSmall),
                  Text(
                    '${p.age} years • ${p.gender}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );

  Widget _buildSeatsCard(BookingDetail booking) => _infoCard(
    title: 'Seat Details',
    icon: Icons.event_seat,
    children: booking.bookingSeats.map((bs) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.event_seat,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seat ${bs.tripSeat.seat.seatNumber}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    '${bs.tripSeat.seat.seatType} • Deck ${bs.tripSeat.seat.deck}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Passenger: ${bs.passenger.name}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Text(
              '₹${bs.seatPrice.toStringAsFixed(2)}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }).toList(),
  );

  Widget _buildStopsCard(BookingDetail booking) => _infoCard(
    title: 'Boarding & Drop-off',
    icon: Icons.location_on,
    children: [
      _infoRow(
        'Boarding',
        '${booking.boardingStop.stopName}, ${booking.boardingStop.cityName}',
        Icons.location_on,
      ),
      _infoRow(
        'Drop-off',
        '${booking.dropStop.stopName}, ${booking.dropStop.cityName}',
        Icons.location_off,
      ),
    ],
  );

  Widget _buildPaymentCard(BookingDetail booking) {
    final total = booking.bookingSeats.fold(
      0.0,
      (sum, bs) => sum + bs.seatPrice,
    );
    return _infoCard(
      title: 'Payment Summary',
      icon: Icons.receipt,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total Amount', style: Theme.of(context).textTheme.bodyLarge),
            Text(
              '₹${total.toStringAsFixed(2)}',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BookingDetail booking) {
    final isPending = booking.status.toLowerCase() == 'pending';
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).cardTheme.shadowColor!.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPending)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToPayment(booking),
                  icon: const Icon(Icons.payment),
                  label: const Text('Pay Now'),
                ),
              ),
            if (isPending) const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showCancelConfirmation(booking.id),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel Booking'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status, BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (status.toLowerCase()) {
      case 'confirmed':
        return scheme.primary;
      case 'pending':
        return scheme.secondary;
      case 'cancelled':
        return scheme.error;
      default:
        return scheme.onSurfaceVariant;
    }
  }

  void _showCancelConfirmation(int bookingId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BookingCubit>().cancelBooking(bookingId);
              context.read<BookingCubit>().fetchBookings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  String _formatTime(String? time) {
    if (time == null) return '--';
    try {
      return DateFormat('hh:mm a').format(DateTime.parse(time).toLocal());
    } catch (_) {
      return time;
    }
  }

  String _formatDate(String? date) {
    if (date == null) return '--';
    try {
      return DateFormat('EEE, dd MMM yyyy').format(DateTime.parse(date));
    } catch (_) {
      return date;
    }
  }

  void _navigateToPayment(BookingDetail booking) {
    final totalPrice = booking.bookingSeats.fold(
      0.0,
      (sum, bs) => sum + bs.seatPrice,
    );
    context.go(
      '/home/payment',
      extra: {
        'bookingId': booking.id,
        'paymentId': booking.id,
        'totalPrice': totalPrice,
        'source': 'booking_detail',
      },
    );
    context.read<BookingCubit>().fetchBookingDetails(widget.bookingId);
  }
}

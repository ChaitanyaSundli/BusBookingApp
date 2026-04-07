import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:quick_bus/core/features/operators_bus/data/cubit/booking_flow_cubit.dart';
import 'package:quick_bus/core/features/operators_bus/data/cubit/booking_flow_state.dart';
import 'package:quick_bus/core/features/operators_bus/data/models/response/seat_model.dart';

import '../../../../widgets/app_button.dart';
import '../../../../widgets/app_card.dart';

class SeatSelectionScreen extends StatelessWidget {
  final int tripId;

  const SeatSelectionScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingFlowCubit, BookingFlowState>(
      builder: (context, state) {
        final trip = state.selectedTrip;

        if (state.seatsLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Select Seat')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final lowerSeats =
            state.availableSeats.where((s) => s.deck == 'L' || s.deck == '1').toList();
        final upperSeats =
            state.availableSeats.where((s) => s.deck == 'U' || s.deck == '2').toList();
        final hasUpper = upperSeats.isNotEmpty;

        final selectedSeatSet = state.selectedSeatNumbers.toSet();
        final selectedCount = selectedSeatSet.length;
        final availableCount = state.availableSeats
            .where((s) => s.isAvailable && !selectedSeatSet.contains(s.seatnumber))
            .length;
        final bookedCount = state.availableSeats.length - availableCount - selectedCount;
        final departureLabel = trip == null ? '' : _formatDateTime(trip.departureTime);

        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () => context.read<BookingFlowCubit>().fetchSeats(tripId),
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh seats',
              ),
            ],
            title: trip == null
                ? const Text('Select Seat')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select Seat', style: TextStyle(fontSize: 16)),
                      Text(
                        '${trip.bus.name} • ${trip.bus.number} • $departureLabel',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _Legend(color: Colors.grey.shade200, label: 'Available'),
                        const SizedBox(width: 16),
                        _Legend(color: const Color(0xFF4F46E5), label: 'Selected'),
                        const SizedBox(width: 16),
                        _Legend(color: Colors.grey.shade400, label: 'Booked'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$availableCount available • $selectedCount selected • $bookedCount taken',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _DeckWidget(
                        title: 'Lower Deck',
                        seats: lowerSeats,
                        selected: state.selectedSeatNumbers,
                        onToggle: (s) => context.read<BookingFlowCubit>().toggleSeat(s),
                      ),
                      if (hasUpper) ...[
                        const SizedBox(height: 12),
                        _DeckWidget(
                          title: 'Upper Deck',
                          seats: upperSeats,
                          selected: state.selectedSeatNumbers,
                          onToggle: (s) => context.read<BookingFlowCubit>().toggleSeat(s),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.selectedSeatNumbers.isEmpty
                                ? 'No seats selected'
                                : 'Seats: ${state.selectedSeatNumbers.join(', ')}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Total: ₹${state.totalPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 150,
                      child: AppButton(
                        text: 'Continue',
                        onTap: state.selectedSeatNumbers.isEmpty
                            ? null
                            : () => context.push('/boarding/$tripId'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DeckWidget extends StatelessWidget {
  final String title;
  final List<SeatModel> seats;
  final List<String> selected;
  final void Function(SeatModel) onToggle;

  const _DeckWidget({
    required this.title,
    required this.seats,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final Map<int, List<SeatModel>> byRow = {};
    for (final s in seats) {
      byRow.putIfAbsent(s.rownumber, () => []).add(s);
    }
    final rows = byRow.keys.toList()..sort();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_bus,
                  size: 16, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 6),
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          ...rows.map((row) {
            final rowSeats = byRow[row]!
              ..sort((a, b) => a.colnumber.compareTo(b.colnumber));
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: rowSeats.map((seat) {
                  final isSelected = selected.contains(seat.seatnumber);
                  final isBooked = !seat.isAvailable;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: isBooked ? null : () => onToggle(seat),
                        child: Container(
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isBooked
                                ? Colors.grey.shade300
                                : isSelected
                                    ? const Color(0xFF4F46E5)
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF4F46E5)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                seat.seatnumber,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isBooked
                                      ? Colors.grey.shade500
                                      : isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                ),
                              ),
                              Text(
                                isBooked ? 'Taken' : 'Free',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: isBooked
                                      ? Colors.grey.shade500
                                      : isSelected
                                          ? Colors.white70
                                          : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }
}

String _formatDateTime(String raw) {
  try {
    return DateFormat('dd MMM, hh:mm a').format(DateTime.parse(raw).toLocal());
  } catch (_) {
    return raw;
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

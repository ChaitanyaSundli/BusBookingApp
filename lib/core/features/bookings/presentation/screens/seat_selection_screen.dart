import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../operators_bus/data/cubit/booking_flow_cubit.dart';
import '../../../operators_bus/data/cubit/booking_flow_state.dart';
import '../../../operators_bus/data/models/response/seat_model.dart';

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

        return Scaffold(
          appBar: AppBar(
            title: trip == null
                ? const Text('Select Seat')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select Seat', style: TextStyle(fontSize: 16)),
                      Text(
                        '${trip.bus.name} • ${trip.bus.number}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
          ),
          body: Column(
            children: [
              // Legend
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Legend(color: Colors.grey.shade200, label: 'Available'),
                    const SizedBox(width: 16),
                    _Legend(color: const Color(0xFF4F46E5), label: 'Selected'),
                    const SizedBox(width: 16),
                    _Legend(color: Colors.grey.shade400, label: 'Booked'),
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
                        onToggle: (s) =>
                            context.read<BookingFlowCubit>().toggleSeat(s),
                      ),
                      if (hasUpper) ...[
                        const SizedBox(height: 12),
                        _DeckWidget(
                          title: 'Upper Deck',
                          seats: upperSeats,
                          selected: state.selectedSeatNumbers,
                          onToggle: (s) =>
                              context.read<BookingFlowCubit>().toggleSeat(s),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Bottom summary
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.selectedSeatNumbers.isEmpty
                                  ? 'No seats selected'
                                  : 'Seats: ${state.selectedSeatNumbers.join(', ')}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
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
                        SizedBox(
                          width: 150,
                          child: AppButton(
                            text: 'Continue',
                            onTap: state.selectedSeatNumbers.isEmpty
                                ? null
                                : () => context.go('/boarding/$tripId'),
                          ),
                        ),
                      ],
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
    // Group by row
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
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: isBooked ? null : () => onToggle(seat),
                      child: Container(
                        width: 40,
                        height: 40,
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
                        child: Text(
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

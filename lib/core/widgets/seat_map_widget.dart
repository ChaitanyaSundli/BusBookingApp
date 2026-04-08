// lib/features/trips/presentation/widgets/seat_map_widget.dart
import 'package:flutter/material.dart';

import '../models/response/trip_detail.dart';

class SeatMapWidget extends StatelessWidget {
  final List<TripSeatDetail> seats;
  final Set<int> selectedSeatIds;
  final Function(TripSeatDetail) onSeatTap;
  final String deck; // 'lower' or 'upper'
  final String? busType; // e.g., 'ac_seater', 'ac_sleeper'

  const SeatMapWidget({
    super.key,
    required this.seats,
    required this.selectedSeatIds,
    required this.onSeatTap,
    required this.deck,
    this.busType,
  });

  bool get _isSleeper => busType?.toLowerCase().contains('sleeper') == true;

  @override
  Widget build(BuildContext context) {
    final deckSeats = seats.where((s) => s.deck == deck).toList();
    if (deckSeats.isEmpty) return const SizedBox.shrink();

    // Group by effective row
    final Map<String, List<TripSeatDetail>> rows = {};
    for (var seat in deckSeats) {
      final row = seat.effectiveRow;
      rows.putIfAbsent(row, () => []).add(seat);
    }

    final sortedRowKeys = rows.keys.toList()
      ..sort((a, b) {
        final aNum = int.tryParse(a) ?? 0;
        final bNum = int.tryParse(b) ?? 0;
        return aNum.compareTo(bNum);
      });

    int maxCols = deckSeats
        .map((s) => s.effectiveCol)
        .where((col) => col != null)
        .fold<int>(0, (a, b) => a > b! ? a : b);
    if (maxCols == 0) maxCols = _isSleeper ? 2 : 4;

    final showFrontIndicators = deck == 'lower';

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Front indicators row (Driver & Entry Gate)
          if (showFrontIndicators) _buildFrontIndicators(maxCols),
          // Seat rows
          ...sortedRowKeys.map((rowKey) {
            final rowSeats = rows[rowKey]!;
            rowSeats.sort((a, b) => (a.effectiveCol ?? 0).compareTo(b.effectiveCol ?? 0));
            return _buildSeatRow(context, rowKey, rowSeats, maxCols);
          }),
        ],
      ),
    );
  }

  Widget _buildFrontIndicators(int maxCols) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 28), // Row label spacer
          // Driver
          Container(
            width: _isSleeper ? 60 : 48,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                const Icon(Icons.airline_seat_recline_normal, color: Colors.grey, size: 20),
                const SizedBox(height: 2),
                Text('Driver', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
              ],
            ),
          ),
          // Entry Gate
          Container(
            width: _isSleeper ? 60 : 48,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                const Icon(Icons.door_front_door, color: Colors.blueGrey, size: 20),
                const SizedBox(height: 2),
                Text('Entry', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
              ],
            ),
          ),
          // Aisle gap (after entry gate)
          if (_shouldAddGapAfterColumn(2)) ...[
            const SizedBox(width: 24), // Aisle width
          ],
          // Placeholder for remaining columns (optional)
        ],
      ),
    );
  }

  Widget _buildSeatRow(BuildContext context, String rowKey, List<TripSeatDetail> rowSeats, int maxCols) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row label
          SizedBox(
            width: 28,
            child: Text(rowKey, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          // Generate columns
          ...List.generate(maxCols, (index) {
            final col = index + 1;
            final seat = rowSeats.firstWhere(
                  (s) => s.effectiveCol == col,
              orElse: () => TripSeatDetail(),
            );

            // Determine if we should add an aisle gap after this column
            final addGapAfter = _shouldAddGapAfterColumn(col);

            if (seat.id == null) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 48, height: 48),
                  if (addGapAfter) const SizedBox(width: 24),
                ],
              );
            }

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _SeatItem(
                    seat: seat,
                    isSelected: selectedSeatIds.contains(seat.id),
                    onTap: () => onSeatTap(seat),
                  ),
                ),
                if (addGapAfter) const SizedBox(width: 24), // Aisle gap
              ],
            );
          }),
        ],
      ),
    );
  }

  bool _shouldAddGapAfterColumn(int col) {
    if (_isSleeper) {
      // Sleeper: gap after first column (1+1 layout)
      return col == 1;
    } else {
      // Seater: gap after second column (2+2 layout)
      return col == 2;
    }
  }
}

class _SeatItem extends StatelessWidget {
  final TripSeatDetail seat;
  final bool isSelected;
  final VoidCallback onTap;

  const _SeatItem({
    required this.seat,
    required this.isSelected,
    required this.onTap,
  });

  Color _getSeatColor() {
    final status = seat.status?.toLowerCase() ?? '';
    if (isSelected) return Colors.green;
    switch (status) {
      case 'available':
        return Colors.grey.shade300;
      case 'booked':
        return Colors.red.shade300;
      case 'locked':
        return Colors.orange.shade300;
      default:
        return Colors.grey.shade400;
    }
  }

  bool get _isAvailable => seat.status?.toLowerCase() == 'available';

  IconData? _getSeatIcon() {
    final type = seat.seatType?.toLowerCase() ?? '';
    switch (type) {
      case 'sleeper':
        return Icons.airline_seat_flat;
      case 'window':
        return Icons.exit_to_app;
      case 'aisle':
        return Icons.airline_seat_recline_normal;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final seatIcon = _getSeatIcon();
    return GestureDetector(
      onTap: _isAvailable ? onTap : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _getSeatColor(),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.green.shade700 : Colors.grey.shade400,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (seatIcon != null)
              Icon(seatIcon, size: 16, color: _isAvailable ? Colors.black87 : Colors.white70),
            Text(
              seat.seatNumber ?? '',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _isAvailable ? Colors.black87 : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
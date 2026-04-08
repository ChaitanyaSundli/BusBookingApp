// lib/features/trips/presentation/widgets/trip_info_bottom_sheet.dart
import 'package:flutter/material.dart';
import '../../../../core/widgets/app_button.dart';
import '../models/response/trip_detail.dart';

class TripInfoBottomSheet extends StatelessWidget {
  final TripDetail trip;
  final int selectedSeatsCount;
  final double totalFare;
  final VoidCallback onProceed;

  const TripInfoBottomSheet({
    super.key,
    required this.trip,
    required this.selectedSeatsCount,
    required this.totalFare,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Trip summary
          Text(
            '${trip.operator?.companyName ?? ''} • ${trip.bus?.busName ?? ''}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.event_seat, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text('$selectedSeatsCount seat${selectedSeatsCount > 1 ? 's' : ''} selected'),
              const Spacer(),
              Text(
                'Total: ₹${totalFare.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 24),
          // Cancellation Policy (static)
          _buildSection(
            title: 'Cancellation Policy',
            icon: Icons.info_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPolicyRow('Before 24h', 'Full refund'),
                _buildPolicyRow('12-24h', '50% refund'),
                _buildPolicyRow('Less than 12h', 'No refund'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Amenities (static)
          _buildSection(
            title: 'Amenities',
            icon: Icons.ac_unit,
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildAmenity(Icons.wifi, 'WiFi'),
                _buildAmenity(Icons.ac_unit, 'AC'),
                _buildAmenity(Icons.tv, 'Entertainment'),
                _buildAmenity(Icons.charging_station, 'Charging'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Reviews placeholder
          _buildSection(
            title: 'Reviews',
            icon: Icons.star,
            child: Row(
              children: [
                ...List.generate(5, (i) => Icon(Icons.star, color: Colors.amber, size: 16)),
                const SizedBox(width: 8),
                Text('4.5 (120 reviews)', style: TextStyle(color: Colors.grey.shade600)),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text('See all')),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'Proceed to Select Boarding Point',
            onTap: () {
              Navigator.pop(context);
              onProceed();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade700),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildPolicyRow(String condition, String refund) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(condition)),
          Text(refund, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildAmenity(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
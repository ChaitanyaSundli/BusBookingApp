// lib/features/trips/presentation/widgets/stop_selector_bottom_sheet.dart
import 'package:flutter/material.dart';

import '../models/response/stop_point.dart';

class StopSelectorBottomSheet extends StatelessWidget {
  final List<StopPoint> points;
  final String title;

  const StopSelectorBottomSheet({
    super.key,
    required this.points,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: points.isEmpty
                ? const Center(child: Text('No stops available'))
                : ListView.builder(
              itemCount: points.length,
              itemBuilder: (context, index) {
                final point = points[index];
                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(point.stopName),
                  subtitle: Text(
                    '${point.cityName}${point.stopAddress != null ? ' • ${point.stopAddress}' : ''}',
                  ),
                  trailing: point.scheduledDepartureTime != null
                      ? Text(point.scheduledDepartureTime!)
                      : null,
                  onTap: () => Navigator.pop(context, point),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
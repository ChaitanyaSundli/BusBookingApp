import 'package:flutter/material.dart';

import '../../../../network/di.dart';
import '../../../../utils/date_time_formatter.dart';
import '../../../../widgets/app_card.dart';

class OperatorDetailScreen extends StatefulWidget {
  final int operatorId;
  final String? operatorName;

  const OperatorDetailScreen({
    super.key,
    required this.operatorId,
    this.operatorName,
  });

  @override
  State<OperatorDetailScreen> createState() => _OperatorDetailScreenState();
}

class _OperatorDetailScreenState extends State<OperatorDetailScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = DI.searchBusRepository.fetchOperatorOverview(widget.operatorId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.operatorName ?? 'Operator Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                textAlign: TextAlign.center,
              ),
            );
          }

          final data = snapshot.data ?? const <String, dynamic>{};
          final operator = (data['operator'] as Map?)?.cast<String, dynamic>() ??
              const <String, dynamic>{};
          final buses = (data['buses'] as List?) ?? const [];
          final trips = (data['scheduled_trips'] as List?) ?? const [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      operator['name']?.toString() ?? widget.operatorName ?? 'Operator',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text('Verified: ${operator['verified'] == true ? 'Yes' : 'No'}'),
                    Text('Total buses: ${operator['total_buses'] ?? buses.length}'),
                    Text('Active trips: ${operator['active_trips'] ?? trips.length}'),
                    if (operator['contact_email'] != null)
                      Text('Contact: ${operator['contact_email']}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Buses',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...buses.map((item) {
                final bus = (item as Map).cast<String, dynamic>();
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.directions_bus),
                    title: Text(bus['name']?.toString() ?? 'Bus'),
                    subtitle: Text(
                      '${bus['number'] ?? 'NA'} • ${bus['type'] ?? 'Bus'} • ${bus['deck'] ?? '1'} deck',
                    ),
                    trailing: Text('${bus['total_seats'] ?? '-'} seats'),
                  ),
                );
              }),
              const SizedBox(height: 8),
              const Text(
                'Scheduled Trips',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...trips.map((item) {
                final trip = (item as Map).cast<String, dynamic>();
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${trip['source'] ?? '-'} → ${trip['destination'] ?? '-'}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text('${trip['bus_name'] ?? 'Bus'} (${trip['bus_number'] ?? 'NA'})'),
                      Text(
                        'Departure: ${formatTravelDateTime(trip['departure_time']?.toString() ?? '')}',
                      ),
                      Text(
                        'Arrival: ${formatTravelDateTime(trip['arrival_time']?.toString() ?? '')}',
                      ),
                      Text('Seats left: ${trip['available_seats'] ?? '-'}'),
                      Text('Fare: ₹${(trip['fare'] as num?)?.toStringAsFixed(0) ?? '0'}'),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

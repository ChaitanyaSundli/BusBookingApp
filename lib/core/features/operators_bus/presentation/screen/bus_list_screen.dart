import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../utils/date_time_formatter.dart';
import '../../../../widgets/app_card.dart';
import '../../data/cubit/booking_flow_cubit.dart';
import '../../data/cubit/trip_cubit.dart';

class BusListScreen extends StatefulWidget {
  final String source;
  final String destination;
  final String operatorName;
  final int operatorId;
  final String date;

  const BusListScreen({
    super.key,
    required this.source,
    required this.destination,
    required this.operatorName,
    required this.operatorId,
    required this.date,
  });

  @override
  State<BusListScreen> createState() => _BusListScreenState();
}

class _BusListScreenState extends State<BusListScreen> {
  @override
  void initState() {
    super.initState();

    context.read<TripCubit>().fetchTrips(
          source: widget.source,
          destination: widget.destination,
          date: widget.date,
          operatorId: widget.operatorId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.operatorName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.source} → ${widget.destination}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: BlocBuilder<TripCubit, TripState>(
        builder: (context, state) {
          if (state is TripLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TripError) {
            return Center(child: Text(state.message));
          }

          if (state is TripEmpty) {
            return const Center(child: Text('No buses found'));
          }

          if (state is TripSuccess) {
            final trips = state.data;

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: trips.length,
              itemBuilder: (_, i) {
                final t = trips[i];

                return AppCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.zero,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        context.read<BookingFlowCubit>().selectTrip(t);
                        context.push('/seat/${t.id}');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      formatTravelTime(t.departureTime),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'Departure',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.grey,
                                  size: 16,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      formatTravelTime(t.arrivalTime),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'Arrival',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 8),
                            Text(
                              formatTravelDateTime(t.departureTime),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.bus.name ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${t.bus.number ?? 'N/A'} • ${_busTypeLabel(t.bus.type)} • ${_deckLabel(t.bus.deck)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      t.price != null
                                          ? '₹${t.price!.toStringAsFixed(0)}'
                                          : 'Price unavailable',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    Text(
                                      '${t.availableSeats} seats left',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: t.availableSeats < 5
                                            ? Colors.red
                                            : Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

String _busTypeLabel(int? type) {
  if (type == null) return 'Bus';
  if (type == 1) return 'Sleeper';
  return 'Seater';
}

String _deckLabel(int? deck) {
  if (deck == null || deck <= 1) return '1 Deck';
  return '$deck Decks';
}

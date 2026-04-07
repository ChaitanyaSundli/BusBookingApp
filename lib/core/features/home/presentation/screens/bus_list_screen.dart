// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
//
// import '../../../../widgets/app_states.dart';
// import '../../data/cubit/trip_cubit.dart';
// import '../../data/cubit/booking_flow_cubit.dart';
// import '../../data/models/response/trip.dart';
//
// class BusListScreen extends StatefulWidget {
//   final String source;
//   final String destination;
//   final int operatorId;
//   final String? operatorName;
//   final String? date;
//
//   const BusListScreen({
//     super.key,
//     required this.source,
//     required this.destination,
//     required this.operatorId,
//     this.operatorName,
//     this.date,
//   });
//
//   @override
//   State<BusListScreen> createState() => _BusListScreenState();
// }
//
// class _BusListScreenState extends State<BusListScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() {
//       context.read<TripCubit>().searchTrips(
//         source: widget.source,
//         destination: widget.destination,
//         date: widget.date ?? '',
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               '${widget.source} → ${widget.destination}',
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
//             ),
//             if (widget.operatorName != null)
//               Text(
//                 widget.operatorName!,
//                 style:
//                 const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
//               ),
//           ],
//         ),
//       ),
//       body: BlocBuilder<TripCubit, TripState>(
//         builder: (context, state) {
//           if (state is TripLoading || state is TripInitial) {
//             return const AppLoading();
//           }
//           if (state is TripError) {
//             return AppError(
//                 message: state.message,
//                 onRetry: () => context.read<TripCubit>().searchTrips(
//                   source: widget.source,
//                   destination: widget.destination,
//                   date: widget.date ?? '',
//                 ));
//           }
//           if (state is! TripSuccess) {
//             return const AppEmpty(message: 'No buses found');
//           }
//
//           final trips = state.response.data
//               .where((t) => t.operator.id == widget.operatorId)
//               .toList();
//
//           if (trips.isEmpty) {
//             return const AppEmpty(message: 'No buses for this operator');
//           }
//
//           return ListView.separated(
//             padding: const EdgeInsets.all(16),
//             itemCount: trips.length,
//             separatorBuilder: (_, __) => const SizedBox(height: 12),
//             itemBuilder: (ctx, i) => _TripCard(trip: trips[i]),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class _TripCard extends StatelessWidget {
//   final Trip trip;
//
//   const _TripCard({required this.trip});
//
//   @override
//   Widget build(BuildContext context) {
//     final primary = Theme.of(context).colorScheme.primary;
//
//     String _busTypeLabel(dynamic type) {
//       switch (type?.toString()) {
//         case '0':
//         case 'seater':
//           return 'Seater';
//         case '1':
//         case 'sleeper':
//           return 'Sleeper';
//         case '2':
//         case 'ac_seater':
//           return 'AC Seater';
//         case '3':
//         case 'ac_sleeper':
//           return 'AC Sleeper';
//         default:
//           return 'Standard';
//       }
//     }
//
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 2,
//       shadowColor: Colors.black12,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16),
//         onTap: () {
//           context.read<BookingFlowCubit>().selectTrip(trip);
//           context.go('/seat/${trip.id}');
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               // ── Header ──────────────────────────────────────────
//               Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           trip.bus.busName,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.w700,
//                             fontSize: 15,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           trip.operator.company_name,
//                           style: TextStyle(
//                             color: Colors.grey.shade600,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     padding:
//                     const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: primary.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       '₹${trip.bus.price.toStringAsFixed(0)}',
//                       style: TextStyle(
//                         color: primary,
//                         fontWeight: FontWeight.w800,
//                         fontSize: 15,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 12),
//               const Divider(height: 1),
//               const SizedBox(height: 12),
//
//               // ── Departure → Arrival ──────────────────────────────
//               Row(
//                 children: [
//                   _TimeBlock(
//                     time: trip.departureTime,
//                     label: trip.route.sourceCity,
//                   ),
//                   Expanded(
//                     child: Column(
//                       children: [
//                         Icon(Icons.arrow_forward,
//                             size: 18, color: Colors.grey.shade400),
//                         const SizedBox(height: 2),
//                         Text(
//                           'Bus No: ${trip.bus.busNo}',
//                           style: TextStyle(
//                               fontSize: 10, color: Colors.grey.shade500),
//                         ),
//                       ],
//                     ),
//                   ),
//                   _TimeBlock(
//                     time: trip.arrivalTime,
//                     label: trip.route.destinationCity,
//                     alignEnd: true,
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 12),
//
//               // ── Tags row ─────────────────────────────────────────
//               Row(
//                 children: [
//                   _Tag(
//                       label: _busTypeLabel(trip.bus.busType),
//                       color: Colors.blue.shade50,
//                       textColor: Colors.blue.shade700),
//                   const SizedBox(width: 6),
//                   _Tag(
//                       label: '${trip.bus.deck == 2 ? "2" : "1"} Deck',
//                       color: Colors.purple.shade50,
//                       textColor: Colors.purple.shade700),
//                   const Spacer(),
//                   Icon(Icons.event_seat,
//                       size: 14, color: Colors.grey.shade500),
//                   const SizedBox(width: 4),
//                   Text(
//                     '${trip.availableSeats} seats',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: trip.availableSeats < 5
//                           ? Colors.red
//                           : Colors.grey.shade600,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _TimeBlock extends StatelessWidget {
//   final String? time;
//   final String label;
//   final bool alignEnd;
//
//   const _TimeBlock({
//     this.time,
//     required this.label,
//     this.alignEnd = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment:
//       alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//       children: [
//         Text(
//           time ?? '--:--',
//           style: const TextStyle(
//             fontWeight: FontWeight.w800,
//             fontSize: 18,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
//         ),
//       ],
//     );
//   }
// }
//
// class _Tag extends StatelessWidget {
//   final String label;
//   final Color color;
//   final Color textColor;
//
//   const _Tag(
//       {required this.label, required this.color, required this.textColor});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       decoration:
//       BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
//       child: Text(label,
//           style:
//           TextStyle(fontSize: 11, color: textColor, fontWeight: FontWeight.w600)),
//     );
//   }
// }
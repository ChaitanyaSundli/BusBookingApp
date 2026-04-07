// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
//
// import '../../../../widgets/app_states.dart';
// import '../../data/cubit/booking_cubit.dart';
// import '../../data/models/response/booking_model.dart';
//
// class BookingsScreen extends StatefulWidget {
//   const BookingsScreen({super.key});
//
//   @override
//   State<BookingsScreen> createState() => _BookingsScreenState();
// }
//
// class _BookingsScreenState extends State<BookingsScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() => context.read<BookingCubit>().loadBookings());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Bookings'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () => context.read<BookingCubit>().loadBookings(),
//           ),
//         ],
//       ),
//       body: BlocBuilder<BookingCubit, BookingState>(
//         builder: (ctx, state) {
//           if (state is BookingLoading) return const AppLoading();
//           if (state is BookingError) {
//             return AppError(
//                 message: state.message,
//                 onRetry: () => context.read<BookingCubit>().loadBookings());
//           }
//           if (state is! BookingListSuccess || state.bookings.isEmpty) {
//             return const AppEmpty(message: 'No bookings yet');
//           }
//
//           return RefreshIndicator(
//             onRefresh: () => context.read<BookingCubit>().loadBookings(),
//             child: ListView.separated(
//               padding: const EdgeInsets.all(16),
//               itemCount: state.bookings.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 12),
//               itemBuilder: (_, i) => _BookingCard(booking: state.bookings[i]),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class _BookingCard extends StatelessWidget {
//   final BookingModel booking;
//
//   const _BookingCard({required this.booking});
//
//   Color _statusColor(String? s) {
//     switch (s?.toLowerCase()) {
//       case 'confirmed':
//         return Colors.green;
//       case 'cancelled':
//         return Colors.red;
//       case 'pending':
//         return Colors.orange;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final primary = Theme.of(context).colorScheme.primary;
//
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 2,
//       shadowColor: Colors.black12,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16),
//         onTap: () => context.go('/bookings/detail/${booking.id}'),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ── Header ──────────────────────────────────────────
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       '#${booking.id}',
//                       style: TextStyle(
//                         color: primary,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 13,
//                       ),
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 8, vertical: 3),
//                     decoration: BoxDecoration(
//                       color:
//                       _statusColor(booking.status).withOpacity(0.12),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       booking.status?.toUpperCase() ?? 'PENDING',
//                       style: TextStyle(
//                         color: _statusColor(booking.status),
//                         fontSize: 11,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//
//               // Route
//               Row(
//                 children: [
//                   Text(
//                     booking.sourcecity ?? '—',
//                     style: const TextStyle(fontWeight: FontWeight.w700),
//                   ),
//                   const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 8),
//                     child: Icon(Icons.arrow_forward, size: 14),
//                   ),
//                   Text(
//                     booking.destinationcity ?? '—',
//                     style: const TextStyle(fontWeight: FontWeight.w700),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 4),
//
//               Text(
//                 '${booking.busname ?? ''} • ${booking.operatorname ?? ''}',
//                 style:
//                 TextStyle(color: Colors.grey.shade600, fontSize: 12),
//               ),
//               const SizedBox(height: 8),
//               const Divider(height: 1),
//               const SizedBox(height: 8),
//
//               // Timings + price
//               Row(
//                 children: [
//                   Icon(Icons.schedule, size: 14, color: Colors.grey.shade500),
//                   const SizedBox(width: 4),
//                   Text(
//                     '${booking.departuretime ?? '--'} → ${booking.arrivaltime ?? '--'}',
//                     style: TextStyle(
//                         fontSize: 12, color: Colors.grey.shade600),
//                   ),
//                   const Spacer(),
//                   Text(
//                     '₹${booking.totalprice?.toStringAsFixed(0) ?? '—'}',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w800,
//                       color: primary,
//                       fontSize: 15,
//                     ),
//                   ),
//                 ],
//               ),
//               if (booking.travelstartdate != null) ...[
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     Icon(Icons.calendar_today,
//                         size: 12, color: Colors.grey.shade400),
//                     const SizedBox(width: 4),
//                     Text(
//                       booking.travelstartdate!,
//                       style: TextStyle(
//                           fontSize: 11, color: Colors.grey.shade500),
//                     ),
//                     const Spacer(),
//                     Text(
//                       '${booking.passengers.length} passenger(s)',
//                       style: TextStyle(
//                           fontSize: 11, color: Colors.grey.shade500),
//                     ),
//                   ],
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
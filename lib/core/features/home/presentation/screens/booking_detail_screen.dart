// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
//
// import '../../../../widgets/app_states.dart';
// import '../../data/cubit/booking_cubit.dart';
// import '../../data/models/response/booking_model.dart';
//
// class BookingDetailScreen extends StatefulWidget {
//   final int id;
//
//   const BookingDetailScreen({super.key, required this.id});
//
//   @override
//   State<BookingDetailScreen> createState() => _BookingDetailScreenState();
// }
//
// class _BookingDetailScreenState extends State<BookingDetailScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(
//             () => context.read<BookingCubit>().loadBookingDetail(widget.id));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Booking Details')),
//       body: BlocBuilder<BookingCubit, BookingState>(
//         builder: (ctx, state) {
//           if (state is BookingLoading) return const AppLoading();
//           if (state is BookingError) {
//             return AppError(
//               message: state.message,
//               onRetry: () =>
//                   context.read<BookingCubit>().loadBookingDetail(widget.id),
//             );
//           }
//           if (state is! BookingDetailSuccess) {
//             return const AppEmpty(message: 'Booking not found');
//           }
//
//           final b = state.booking;
//           return _BookingDetailBody(booking: b);
//         },
//       ),
//     );
//   }
// }
//
// class _BookingDetailBody extends StatelessWidget {
//   final BookingModel booking;
//
//   const _BookingDetailBody({required this.booking});
//
//   @override
//   Widget build(BuildContext context) {
//     final primary = Theme.of(context).colorScheme.primary;
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Booking ID banner ──────────────────────────────────────────
//           _SectionCard(
//             child: Row(
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Booking ID',
//                       style: TextStyle(
//                           fontSize: 11, color: Colors.grey.shade500),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       '#${booking.id}',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w900,
//                         color: primary,
//                         letterSpacing: 1,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const Spacer(),
//                 _StatusBadge(status: booking.status),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 12),
//
//           // ── Bus + Route info ───────────────────────────────────────────
//           _SectionCard(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   booking.busname ?? '—',
//                   style: const TextStyle(
//                       fontWeight: FontWeight.w800, fontSize: 17),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   booking.operatorname ?? '—',
//                   style: TextStyle(
//                       color: Colors.grey.shade600, fontSize: 13),
//                 ),
//                 const SizedBox(height: 12),
//
//                 // Route row
//                 Row(children: [
//                   Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           booking.departuretime ?? '--:--',
//                           style: const TextStyle(
//                               fontWeight: FontWeight.w800, fontSize: 20),
//                         ),
//                         Text(
//                           booking.sourcecity ?? '',
//                           style: TextStyle(
//                               fontSize: 12, color: Colors.grey.shade500),
//                         ),
//                       ]),
//                   Expanded(
//                     child: Column(children: [
//                       Icon(Icons.arrow_forward,
//                           color: Colors.grey.shade400),
//                       Text(
//                         booking.travelstartdate ?? '',
//                         style: TextStyle(
//                             fontSize: 10, color: Colors.grey.shade400),
//                       ),
//                     ]),
//                   ),
//                   Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text(
//                           booking.arrivaltime ?? '--:--',
//                           style: const TextStyle(
//                               fontWeight: FontWeight.w800, fontSize: 20),
//                         ),
//                         Text(
//                           booking.destinationcity ?? '',
//                           style: TextStyle(
//                               fontSize: 12, color: Colors.grey.shade500),
//                         ),
//                       ]),
//                 ]),
//
//                 if (booking.boardingstop != null ||
//                     booking.dropstop != null) ...[
//                   const SizedBox(height: 12),
//                   const Divider(height: 1),
//                   const SizedBox(height: 12),
//                   Row(children: [
//                     Expanded(
//                         child: _InfoTile(
//                           icon: Icons.directions_bus,
//                           label: 'Boarding',
//                           value: booking.boardingstop ?? '—',
//                         )),
//                     Expanded(
//                         child: _InfoTile(
//                           icon: Icons.flag_outlined,
//                           label: 'Dropping',
//                           value: booking.dropstop ?? '—',
//                         )),
//                   ]),
//                 ],
//
//                 const SizedBox(height: 8),
//                 _InfoTile(
//                   icon: Icons.people_outline,
//                   label: 'Total Passengers',
//                   value: '${booking.passengers.length}',
//                 ),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 12),
//
//           // ── Passenger details ──────────────────────────────────────────
//           if (booking.passengers.isNotEmpty) ...[
//             _SectionHeader(title: 'Passenger Details'),
//             const SizedBox(height: 8),
//             ...booking.passengers
//                 .map((p) => Padding(
//               padding: const EdgeInsets.only(bottom: 8),
//               child: _SectionCard(
//                 child: Row(children: [
//                   CircleAvatar(
//                     radius: 22,
//                     backgroundColor: primary.withOpacity(0.12),
//                     child: Text(
//                       p.name.isNotEmpty
//                           ? p.name[0].toUpperCase()
//                           : '?',
//                       style: TextStyle(
//                           color: primary,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           p.name,
//                           style: const TextStyle(
//                               fontWeight: FontWeight.w700,
//                               fontSize: 15),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           p.phone ?? '',
//                           style: TextStyle(
//                               color: Colors.grey.shade600,
//                               fontSize: 13),
//                         ),
//                         Row(children: [
//                           if (p.age != null)
//                             Text(
//                               'Age ${p.age}',
//                               style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey.shade500),
//                             ),
//                           if (p.age != null && p.gender != null)
//                             Text(
//                               '  •  ',
//                               style: TextStyle(
//                                   color: Colors.grey.shade400),
//                             ),
//                           if (p.gender != null)
//                             Text(
//                               _genderLabel(p.gender),
//                               style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey.shade500),
//                             ),
//                         ]),
//                       ],
//                     ),
//                   ),
//                   if (p.seatnumber != null)
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: primary.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         p.seatnumber!,
//                         style: TextStyle(
//                             color: primary,
//                             fontWeight: FontWeight.w700,
//                             fontSize: 13),
//                       ),
//                     ),
//                 ]),
//               ),
//             ))
//                 .toList(),
//           ],
//
//           const SizedBox(height: 4),
//
//           // ── Payment details ────────────────────────────────────────────
//           _SectionHeader(title: 'Payment Details'),
//           const SizedBox(height: 8),
//           _SectionCard(
//             child: Column(
//               children: [
//                 _PayRow(
//                     label: 'Total Amount',
//                     value:
//                     '₹${booking.totalprice?.toStringAsFixed(2) ?? "—"}',
//                     bold: true),
//                 if (booking.payment != null) ...[
//                   const Divider(height: 20),
//                   _PayRow(
//                       label: 'Status',
//                       value: booking.payment!.status ?? '—'),
//                   if (booking.payment!.gatewayname != null)
//                     _PayRow(
//                         label: 'Gateway',
//                         value: booking.payment!.gatewayname!),
//                   if (booking.payment!.gatewayTxnId != null)
//                     _PayRow(
//                         label: 'Transaction ID',
//                         value: booking.payment!.gatewayTxnId!),
//                 ],
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 24),
//
//           // Cancel button (only if confirmed/pending)
//           if (booking.status == 'confirmed' ||
//               booking.status == 'pending')
//             SizedBox(
//               width: double.infinity,
//               child: OutlinedButton.icon(
//                 onPressed: () => _confirmCancel(context),
//                 icon: const Icon(Icons.cancel_outlined,
//                     color: Colors.red),
//                 label: const Text('Cancel Booking',
//                     style: TextStyle(color: Colors.red)),
//                 style: OutlinedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   side: const BorderSide(color: Colors.red),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14)),
//                 ),
//               ),
//             ),
//
//           const SizedBox(height: 16),
//         ],
//       ),
//     );
//   }
//
//   String _genderLabel(String? g) {
//     switch (g) {
//       case '0':
//       case 'male':
//         return 'Male';
//       case '1':
//       case 'female':
//         return 'Female';
//       default:
//         return 'Other';
//     }
//   }
//
//   void _confirmCancel(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Cancel Booking?'),
//         content: const Text(
//             'Are you sure you want to cancel this booking? This action cannot be undone.'),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('No')),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               context.read<BookingCubit>().cancelBooking(booking.id);
//               context.go('/bookings');
//             },
//             child: const Text('Yes, Cancel',
//                 style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ── Small reusable widgets ─────────────────────────────────────────────────────
//
// class _SectionCard extends StatelessWidget {
//   final Widget child;
//
//   const _SectionCard({required this.child});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }
// }
//
// class _SectionHeader extends StatelessWidget {
//   final String title;
//
//   const _SectionHeader({required this.title});
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(children: [
//       Expanded(
//           child: Divider(color: Colors.grey.shade300, endIndent: 12)),
//       Text(
//         title,
//         style: const TextStyle(
//             fontWeight: FontWeight.w700, fontSize: 13),
//       ),
//       Expanded(
//           child: Divider(color: Colors.grey.shade300, indent: 12)),
//     ]);
//   }
// }
//
// class _InfoTile extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//
//   const _InfoTile(
//       {required this.icon, required this.label, required this.value});
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       Icon(icon, size: 15, color: Colors.grey.shade500),
//       const SizedBox(width: 6),
//       Expanded(
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Text(label,
//               style: TextStyle(
//                   fontSize: 11, color: Colors.grey.shade500)),
//           Text(value,
//               style: const TextStyle(
//                   fontWeight: FontWeight.w600, fontSize: 13)),
//         ]),
//       ),
//     ]);
//   }
// }
//
// class _PayRow extends StatelessWidget {
//   final String label;
//   final String value;
//   final bool bold;
//
//   const _PayRow(
//       {required this.label, required this.value, this.bold = false});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 3),
//       child: Row(children: [
//         Text(label,
//             style:
//             TextStyle(color: Colors.grey.shade600, fontSize: 13)),
//         const Spacer(),
//         Text(
//           value,
//           style: TextStyle(
//             fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
//             fontSize: bold ? 16 : 13,
//           ),
//         ),
//       ]),
//     );
//   }
// }
//
// class _StatusBadge extends StatelessWidget {
//   final String? status;
//
//   const _StatusBadge({this.status});
//
//   @override
//   Widget build(BuildContext context) {
//     Color color;
//     switch (status?.toLowerCase()) {
//       case 'confirmed':
//         color = Colors.green;
//         break;
//       case 'cancelled':
//         color = Colors.red;
//         break;
//       default:
//         color = Colors.orange;
//     }
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.12),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: color.withOpacity(0.4)),
//       ),
//       child: Text(
//         status?.toUpperCase() ?? 'PENDING',
//         style: TextStyle(
//             color: color,
//             fontWeight: FontWeight.w700,
//             fontSize: 12),
//       ),
//     );
//   }
// }
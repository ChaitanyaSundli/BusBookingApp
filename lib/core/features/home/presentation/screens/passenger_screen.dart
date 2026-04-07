import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_bus/core/features/auth/data/cubit/auth_cubit.dart';
import 'package:quick_bus/core/features/bookings/data/local/booking_history_store.dart';
import 'package:quick_bus/core/features/bookings/data/models/request/create_booking_request.dart';
import 'package:quick_bus/core/features/operators_bus/data/cubit/booking_flow_cubit.dart';
import 'package:quick_bus/core/features/operators_bus/data/cubit/booking_flow_state.dart';
import 'package:quick_bus/core/network/di.dart';
import 'package:quick_bus/core/utils/local_storage/session_manager.dart';

import '../../../../utils/date_time_formatter.dart';
import '../../../../widgets/app_button.dart';
import '../../../../widgets/app_card.dart';
import '../../../../widgets/login_required_modal.dart';

class PassengerScreen extends StatefulWidget {
  final int tripId;

  const PassengerScreen({super.key, required this.tripId});

  @override
  State<PassengerScreen> createState() => _PassengerScreenState();
}

class _PassengerScreenState extends State<PassengerScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<_PassengerController> _controllers = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<BookingFlowCubit>().state;
    _syncPassengerControllers(state.selectedSeatNumbers);
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncPassengerControllers(List<String> seats) {
    if (_controllers.length == seats.length) {
      var sameOrder = true;
      for (var i = 0; i < seats.length; i++) {
        if (_controllers[i].seatNumber != seats[i]) {
          sameOrder = false;
          break;
        }
      }
      if (sameOrder) return;
    }

    final existingBySeat = <String, _PassengerController>{
      for (final c in _controllers) c.seatNumber: c,
    };

    for (final c in _controllers) {
      if (!seats.contains(c.seatNumber)) {
        c.dispose();
      }
    }

    _controllers
      ..clear()
      ..addAll(
        seats.map((seat) => existingBySeat[seat] ?? _PassengerController(seat)),
      );
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    final session = SessionManager();
    await session.loadSession();
    final authState = context.read<AuthCubit>().state;
    final isLoggedIn =
        authState is AuthSuccess ||
        authState is AuthSessionActive ||
        session.token != null;

    if (!isLoggedIn) {
      if (!mounted) return;
      await showLoginRequiredModal(
        context,
        redirectTo: '/boarding/${widget.tripId}',
      );
      return;
    }

    if (!mounted) return;

    final bookingCubit = context.read<BookingFlowCubit>();
    final bookingState = bookingCubit.state;
    final trip = bookingState.selectedTrip;

    if (trip == null ||
        bookingState.selectedBoardingStop == null ||
        bookingState.selectedDroppingStop == null ||
        bookingState.selectedSeatNumbers.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete seat and stop selection first.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await bookingCubit.fetchSeats(trip.id);
      final refreshedState = bookingCubit.state;
      final unavailableSeats = refreshedState.availableSeats
          .where(
            (seat) =>
                refreshedState.selectedSeatNumbers.contains(seat.seatnumber) &&
                !seat.isAvailable,
          )
          .map((seat) => seat.seatnumber)
          .toList();

      if (unavailableSeats.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Seats no longer available: ${unavailableSeats.join(', ')}. Please reselect.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        context.go('/seat/${widget.tripId}');
        return;
      }

      final request = CreateBookingRequest(
        tripId: trip.id,
        boardingStopId: refreshedState.selectedBoardingStop!.id,
        dropStopId: refreshedState.selectedDroppingStop!.id,
        seatNumbers: refreshedState.selectedSeatNumbers,
        passengers: _controllers
            .map(
              (p) => PassengerRequest(
                name: p.nameController.text.trim(),
                age: int.tryParse(p.ageController.text.trim()) ?? 0,
                phone: p.phoneController.text.trim().isEmpty
                    ? null
                    : p.phoneController.text.trim(),
                gender: p.gender.toLowerCase(),
              ),
            )
            .toList(),
      );

      final response = await DI.bookingRepository.createBooking(request);
      final data = response.data;
      final seatNumbers = data.seats.map((s) => s.seatNumber).toList();
      final resolvedSeatNumbers = seatNumbers.isEmpty
          ? refreshedState.selectedSeatNumbers
          : seatNumbers;
      final apiSeatTotal = data.seats.fold<double>(0, (sum, seat) => sum + seat.seatPrice);
      final fallbackTotalPrice = refreshedState.totalPrice;
      final resolvedTotalPrice = data.totalPrice > 0
          ? data.totalPrice
          : (apiSeatTotal > 0 ? apiSeatTotal : fallbackTotalPrice);
      final resolvedPaymentAmount = (data.payment?.amount ?? 0) > 0
          ? data.payment?.amount
          : resolvedTotalPrice;
      final resolvedPaymentStatus = (data.payment?.status ?? '').trim().isNotEmpty
          ? data.payment!.status
          : data.status;

      final booking = BookingHistoryItem(
        id: data.id,
        tripId: data.tripId,
        operatorName: trip.operator.name,
        busName: trip.bus.name ?? 'Bus',
        busNumber: trip.bus.number ?? 'NA',
        source: data.boardingStop.cityName,
        destination: data.dropStop.cityName,
        departureTime: trip.departureTime,
        arrivalTime: trip.arrivalTime,
        seatNumbers: resolvedSeatNumbers,
        boardingStopId: data.boardingStop.id,
        dropStopId: data.dropStop.id,
        totalPrice: resolvedTotalPrice,
        createdAt: data.createdAt,
        paymentStatus: resolvedPaymentStatus,
        paymentAmount: resolvedPaymentAmount,
      );

      await BookingHistoryStore().addBooking(booking);
      bookingCubit.markSeatsBooked(resolvedSeatNumbers);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Booking successful.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      context.go('/bookings');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingFlowCubit, BookingFlowState>(
      builder: (context, state) {
        _syncPassengerControllers(state.selectedSeatNumbers);

        final missingFlowData =
            state.selectedTrip == null || state.selectedSeatNumbers.isEmpty;

        if (missingFlowData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Passenger Details')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AppCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 32,
                        color: Colors.indigo,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Your booking session has expired.',
                        style: TextStyle(fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please select a bus and seats again to continue.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      AppButton(
                        text: 'Back to Seat Selection',
                        onTap: () => context.go('/seat/${widget.tripId}'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        final baseFare = state.totalPrice;
        const taxes = 0.0;
        final payable = baseFare + taxes;

        return Scaffold(
          appBar: AppBar(title: const Text('Passenger Details')),
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seats: ${state.selectedSeatNumbers.join(', ')}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${formatTravelDateTime(state.selectedTrip!.departureTime)}  →  ${formatTravelDateTime(state.selectedTrip!.arrivalTime)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1),
                        const SizedBox(height: 10),
                        _FareRow(
                          label: 'Seat fare',
                          value: '₹${baseFare.toStringAsFixed(0)}',
                        ),
                        const SizedBox(height: 6),
                        _FareRow(
                          label: 'Taxes & fees',
                          value: '₹${taxes.toStringAsFixed(0)}',
                        ),
                        const SizedBox(height: 6),
                        _FareRow(
                          label: 'Total payable',
                          value: '₹${payable.toStringAsFixed(0)}',
                          highlight: true,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: _controllers.length,
                    itemBuilder: (context, index) {
                      return _PassengerCard(controller: _controllers[index]);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: AppButton(
                    text: _isSubmitting ? 'Processing...' : 'Confirm Booking',
                    onTap: _isSubmitting ? null : _submit,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PassengerCard extends StatefulWidget {
  final _PassengerController controller;

  const _PassengerCard({required this.controller});

  @override
  State<_PassengerCard> createState() => _PassengerCardState();
}

class _PassengerCardState extends State<_PassengerCard> {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Seat ${widget.controller.seatNumber}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.controller.nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter passenger name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: widget.controller.phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone (optional)',
              hintText: 'Enter phone number',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: widget.controller.ageController,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final age = int.tryParse(v ?? '');
                    if (age == null || age < 1 || age > 119) return '1-119';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  initialValue: widget.controller.gender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    prefixIcon: Icon(Icons.wc),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                  ],
                  onChanged: (v) {
                    setState(() {
                      widget.controller.gender = v!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FareRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _FareRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: highlight ? 15 : 13,
      fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
      color: highlight ? Theme.of(context).colorScheme.primary : null,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}

class _PassengerController {
  final String seatNumber;
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  String gender = 'Male';

  _PassengerController(this.seatNumber);

  void dispose() {
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
  }
}

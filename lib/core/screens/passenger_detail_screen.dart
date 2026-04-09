import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../cubit/booking_cubit.dart';
import '../models/request/booking_request.dart';
import '../widgets/app_layout_frame.dart';

class PassengerDetailsScreen extends StatefulWidget {
  final int tripId;
  final int boardingStopId;
  final int dropStopId;
  final List<int> selectedSeatIds;

  const PassengerDetailsScreen({
    super.key,
    required this.tripId,
    required this.boardingStopId,
    required this.dropStopId,
    required this.selectedSeatIds,
  });

  @override
  State<PassengerDetailsScreen> createState() => _PassengerDetailsScreenState();
}

class _PassengerDetailsScreenState extends State<PassengerDetailsScreen> {
  final List<PassengerFormData> _passengers = [];
  bool _didNavigate = false;
  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.selectedSeatIds.length; i++) {
      _passengers.add(PassengerFormData());
    }
  }

  int _genderToInt(String? gender) {
    switch (gender) {
      case 'Male':
        return 0;
      case 'Female':
        return 1;
      case 'Other':
        return 2;
      default:
        return 0;
    }
  }

  bool _validateForm() {
    for (var p in _passengers) {
      if (p.name.isEmpty || p.age == null || p.gender == null) return false;
    }
    return true;
  }

  void _submitBooking() {
    if (!_validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all passenger details')),
      );
      return;
    }

    final request = CreateBookingRequest(
      tripId: widget.tripId,
      boardingStopId: widget.boardingStopId,
      dropStopId: widget.dropStopId,
      seatIds: widget.selectedSeatIds,
      passengers: _passengers
          .map(
            (p) => PassengerRequest(
              name: p.name,
              age: p.age!,
              gender: _genderToInt(p.gender),
            ),
          )
          .toList(),
    );

    context.read<BookingCubit>().createBooking(request);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingCubit, BookingState>(
      listener: (context, state) {

        if (state is BookingLoaded && state.createResponse != null && !_didNavigate) {
          _didNavigate = true;
          final response = state.createResponse!;
          if (!context.mounted) return;
          context.push('/home/payment', extra: {
            'bookingId': response.bookingId,
            'paymentId': response.paymentId,
            'totalPrice': response.totalPrice,
          });
        }
        if (state is BookingError) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) => AppLayout(
        showAppBar: true,
        title: 'Passenger Details',
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Passenger Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please enter details for ${widget.selectedSeatIds.length} passenger${widget.selectedSeatIds.length > 1 ? 's' : ''}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_passengers.length, (index) {
                    return _PassengerFormCard(
                      index: index + 1,
                      formData: _passengers[index],
                      onChanged: () => setState(() {}),
                    );
                  }),
                  const SizedBox(height: 80),
                ],
              ),
            ),
            if (state is! BookingLoading)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: AppButton(
                  text: 'Confirm & Proceed to Pay',
                  onTap: _submitBooking,
                ),
              ),
            if (state is BookingLoading)
              const Positioned.fill(
                child: AppLoadingState(message: 'Creating booking...'),
              ),
          ],
        ),
      ),
    );
  }
}

class _PassengerFormCard extends StatelessWidget {
  final int index;
  final PassengerFormData formData;
  final VoidCallback onChanged;

  const _PassengerFormCard({
    required this.index,
    required this.formData,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Passenger $index',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          AppTextField(
            hint: 'Full Name',
            onChanged: (value) {
              formData.name = value;
              onChanged();
            },
          ),
          const SizedBox(height: 12),
          AppTextField(
            hint: 'Age',
            keyboardType: TextInputType.number,
            onChanged: (value) {
              formData.age = int.tryParse(value);
              onChanged();
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: formData.gender,
            hint: const Text('Select Gender'),
            items: const [
              DropdownMenuItem(value: 'Male', child: Text('Male')),
              DropdownMenuItem(value: 'Female', child: Text('Female')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            onChanged: (value) {
              formData.gender = value;
              onChanged();
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PassengerFormData {
  String name = '';
  int? age;
  String? gender;
}

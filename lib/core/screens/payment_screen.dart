import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_states.dart';
import '../cubit/payment_cubit.dart';
import '../widgets/app_layout_frame.dart';

class PaymentScreen extends StatelessWidget {
  final int bookingId;
  final int paymentId;
  final double totalPrice;
  final String source;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.paymentId,
    required this.totalPrice,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentCubit, PaymentState>(
      listener: (context, state) {
        if (state is PaymentSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment successful!')),
          );
          // If source is 'trip_flow', go to My Bookings detail.
          // Otherwise (e.g., 'home' or 'my-bookings'), pop back to the detail screen.
          if (source == 'trip_flow') {
            context.go('/my-bookings/booking/$bookingId');
          } else {
            Navigator.pop(context);
          }
        }
        if (state is PaymentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return AppLayout(
          showAppBar: true,
          title: 'Payment',
          child: Stack(
            children: [
              Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: AppCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.payment,
                            size: 48,
                            color: Colors.green,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Total Amount',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹${totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          AppButton(
                            text: state is PaymentLoading
                                ? 'Processing...'
                                : 'Pay Now',
                            onTap: state is PaymentLoading
                                ? null
                                : () => context
                                .read<PaymentCubit>()
                                .createPayment(bookingId),
                          ),
                        ],
                      ),
                    ),
                  ),

              ),
            ],
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/payment_cubit.dart';
import '../widgets/app_layout_frame.dart';

class PaymentScreen extends StatelessWidget {
  final int bookingId;
  final int paymentId;
  final double totalPrice;
  final String source;
  const PaymentScreen({super.key, required this.bookingId, required this.paymentId, required this.totalPrice, required this.source});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentCubit, PaymentState>(
      listener: (context, state) {
        if (state is PaymentSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Payment successful!'), behavior: SnackBarBehavior.floating, backgroundColor: Theme.of(context).colorScheme.primary),
          );
          context.go('/home/booking/$bookingId');
          context.read<BookingCubit>().fetchBookings();
        }
        if (state is PaymentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), behavior: SnackBarBehavior.floating, backgroundColor: Theme.of(context).colorScheme.error),
          );
        }
      },
      builder: (context, state) {
        return AppLayout(
          showAppBar: true,
          title: 'Secure Payment',
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      children: [
                        _buildOrderSummary(context),
                        const SizedBox(height: 24),
                        _buildPayButton(context, state),
                        const SizedBox(height: 16),
                        _buildSecureBadge(context),
                      ],
                    ),
                  ),
                ),
              ),
              if (state is PaymentLoading) _buildLoadingOverlay(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text('Order Summary', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const Divider(height: 24),
          _summaryRow(context, 'Booking ID', '#$bookingId'),
          const SizedBox(height: 12),
          _summaryRow(context, 'Total Amount', '₹${totalPrice.toStringAsFixed(2)}', isTotal: true),
        ],
      ),
    );
  }

  Widget _summaryRow(BuildContext context, String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isTotal ? null : Theme.of(context).colorScheme.onSurfaceVariant)),
        Text(value, style: isTotal ? Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary) : Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }


  Widget _paymentMethodTile(BuildContext context, {required IconData icon, required String title, required String subtitle, required bool isSelected}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Radio<bool>(value: true, groupValue: isSelected, onChanged: (_) {}, activeColor: Theme.of(context).colorScheme.primary),
        ],
      ),
    );
  }

  Widget _buildPayButton(BuildContext context, PaymentState state) {
    return SizedBox(
      width: double.infinity,
      child: AppButton(
        text: state is PaymentLoading ? 'Processing...' : 'Pay Now',
        onTap: state is PaymentLoading ? null : () => context.read<PaymentCubit>().createPayment(bookingId),
        backgroundColor: Theme.of(context).colorScheme.primary,
        loading: state is PaymentLoading,
      ),
    );
  }

  Widget _buildSecureBadge(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text('Secure transaction encrypted', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
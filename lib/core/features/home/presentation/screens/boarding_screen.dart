import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_bus/core/features/operators_bus/data/cubit/booking_flow_cubit.dart';
import 'package:quick_bus/core/features/operators_bus/data/cubit/booking_flow_state.dart';
import 'package:quick_bus/core/features/operators_bus/data/models/response/route_stop_model.dart';

import '../../../../utils/date_time_formatter.dart';
import '../../../../widgets/app_button.dart';
import '../../../../widgets/app_card.dart';

class BoardingScreen extends StatelessWidget {
  final int tripId;

  const BoardingScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingFlowCubit, BookingFlowState>(
      builder: (context, state) {
        if (state.stopsLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Boarding & Dropping'),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Boarding Point'),
                  Tab(text: 'Dropping Point'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _StopList(
                  stops: state.boardingPoints,
                  selectedId: state.selectedBoardingStop?.id,
                  onSelect: (stop) =>
                      context.read<BookingFlowCubit>().selectBoardingStop(stop),
                ),
                _StopList(
                  stops: state.droppingPoints,
                  selectedId: state.selectedDroppingStop?.id,
                  onSelect: (stop) =>
                      context.read<BookingFlowCubit>().selectDroppingStop(stop),
                ),
              ],
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: AppButton(
                text: 'Proceed to Passenger Details',
                onTap: (state.selectedBoardingStop != null &&
                        state.selectedDroppingStop != null)
                    ? () => context.push('/passenger/$tripId')
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StopList extends StatelessWidget {
  final List<RouteStopModel> stops;
  final int? selectedId;
  final Function(RouteStopModel) onSelect;

  const _StopList({
    required this.stops,
    this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (stops.isEmpty) {
      return const Center(child: Text('No points available'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: stops.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final stop = stops[index];

        final isSelected = stop.id == selectedId;

        return AppCard(
          padding: EdgeInsets.zero,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.06)
                  : Colors.white,
            ),
            child: ListTile(
              onTap: () => onSelect(stop),
              leading: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
              title: Text(
                stop.stopname,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stop.cityname, style: const TextStyle(fontSize: 12)),
                  if (stop.address != null)
                    Text(
                      stop.address!,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                ],
              ),
              trailing: Text(
                stop.time ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

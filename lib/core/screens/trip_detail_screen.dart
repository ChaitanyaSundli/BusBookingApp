
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_states.dart';

import '../cubit/trips_cubit.dart';
import '../models/response/stop_point.dart';
import '../models/response/trip_detail.dart';
import '../utils/date_time_formatter.dart';
import '../widgets/app_layout_frame.dart';
import '../widgets/seat_map_widget.dart';

class TripDetailScreen extends StatefulWidget {
  final int tripId;

  const TripDetailScreen({super.key, required this.tripId});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  int _currentStep = 0;
  StopPoint? _selectedBoardingPoint;
  StopPoint? _selectedDropPoint;
  final Set<int> _selectedSeatIds = {};

  @override
  void initState() {
    super.initState();
    context.read<TripsCubit>().getTripDetail(widget.tripId);
    context.read<TripsCubit>().getBoardingPoints(widget.tripId);
    context.read<TripsCubit>().getDropPoints(widget.tripId);
  }

  double _baseFarePerSeat(TripsLoaded state) =>
      state.selectedTrip?.tripSeats?.firstOrNull?.seatPrice ?? 0.0;

  double _totalFare(TripsLoaded state) =>
      _baseFarePerSeat(state) * _selectedSeatIds.length;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TripsCubit, TripsState>(
      listener: (context, state) {
        if (state case TripsError(message: final msg)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
        }
      },
      builder: (context, state) => switch (state) {
        TripsInitial() || TripsLoading() => const Scaffold(
          body: AppLoadingState(message: 'Loading trip details...'),
        ),
        TripsError(message: final msg) => AppLayout(
          showAppBar: true,
          title: 'Trip Details',
          child: AppErrorState(
            message: msg,
            onRetry: () =>
                context.read<TripsCubit>().getTripDetail(widget.tripId),
          ),
        ),
        TripsLoaded(
            :final selectedTrip,
            :final boardingPoints,
            :final dropPoints,
        ) =>
        selectedTrip == null
            ? const AppEmptyState(message: 'Trip not found')
            : _buildContent(context, state, boardingPoints, dropPoints),
      },
    );
  }

  Widget _buildContent(
      BuildContext context,
      TripsLoaded state,
      List<StopPoint> boardingPoints,
      List<StopPoint> dropPoints,
      ) {
    final trip = state.selectedTrip!;
    return AppLayout(
      showAppBar: true,
      title: '${trip.route?.sourceCity ?? ''} → ${trip.route?.destinationCity ?? ''}',
      child: Column(
        children: [
          Expanded(
            child: Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              onStepContinue: _onStepContinue,
              onStepCancel: _onStepCancel,
              controlsBuilder: (context, details) {
                if (_currentStep == 0) {
                  
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: AppButton(
                      text: 'Next: Select Boarding Point',
                      onTap: _isStepValid() ? details.onStepContinue : null,
                    ),
                  );
                } else if (_currentStep == 1) {
                  
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Back',
                            onTap: details.onStepCancel,
                            outlined: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            text: 'Next',
                            onTap: _isStepValid()
                                ? () => _proceedToPassengers(state)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              steps: [
                Step(
                  title: const Text('Select Seats'),
                  content: _buildSeatSelectionStep(state, trip),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Boarding & Drop'),
                  content: _buildStopSelectionStep(
                    state,
                    trip,
                    boardingPoints,
                    dropPoints,
                  ),
                  isActive: _currentStep >= 1,
                  state: StepState.indexed,
                ),
              ],
            ),
          ),
          
        ],
      ),
    );
  }

  
  
  
  Widget _buildSeatSelectionStep(TripsLoaded state, TripDetail trip) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTripInfoCompact(trip),
          const SizedBox(height: 16),
          _buildSeatMapCard(state, trip),
        ],
      ),
    );
  }

  
  
  
  Widget _buildStopSelectionStep(
      TripsLoaded state,
      TripDetail trip,
      List<StopPoint> boardingPoints,
      List<StopPoint> dropPoints,
      ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTripInfoCompact(trip),
          const SizedBox(height: 16),
          const Text(
            'Select Boarding Point',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...boardingPoints.map(
                (point) => RadioListTile<StopPoint>(
              title: Text(point.stopName),
              subtitle: Text('${point.cityName} • ${point.stopAddress ?? ''} • ${formatTravelTime(point.scheduledArrivalTime)}'),
              value: point,
              groupValue: _selectedBoardingPoint,
              onChanged: (value) =>
                  setState(() => _selectedBoardingPoint = value),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select Drop-off Point',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...dropPoints.map(
                (point) => RadioListTile<StopPoint>(
              title: Text(point.stopName),
              subtitle: Text('${point.cityName} • ${point.stopAddress ?? ''} • ${formatTravelTime(point.scheduledDepartureTime)} '),
              value: point,
              groupValue: _selectedDropPoint,
              onChanged: (value) => setState(() => _selectedDropPoint = value),
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildSeatMapCard(TripsLoaded state, TripDetail trip) {
    final seats = trip.tripSeats ?? [];
    if (seats.isEmpty)
      return const AppEmptyState(message: 'No seats available');

    final Map<String, List<TripSeatDetail>> seatsByDeck = {};
    for (var seat in seats) {
      final deck = seat.deck ?? 'lower';
      seatsByDeck.putIfAbsent(deck, () => []).add(seat);
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Seats',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${_selectedSeatIds.length} selected',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.yellow, 'Locked'),
              const SizedBox(width: 12,),
              _buildLegendItem(Colors.grey.shade300, 'Available'),
              const SizedBox(width: 12),
              _buildLegendItem(Colors.green, 'Selected'),
              const SizedBox(width: 12),
              _buildLegendItem(Colors.red.shade300, 'Booked'),
            ],
          ),
          const SizedBox(height: 12),
          ...seatsByDeck.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (seatsByDeck.keys.length > 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      '${entry.key == 'lower' ? 'Lower' : 'Upper'} Deck',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                SeatMapWidget(
                  seats: entry.value,
                  selectedSeatIds: _selectedSeatIds,
                  onSeatTap: _handleSeatTap,
                  deck: entry.key,
                  busType: trip.bus?.busType,
                ),
              ],
            );
          }),
          const Divider(),
          Text(
            'Seat Price: ₹${_baseFarePerSeat(state).toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _handleSeatTap(TripSeatDetail seat) {
    final status = seat.status?.toLowerCase() ?? '';
    if (status != 'available') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This seat is $status')),
      );
      return;
    }
    setState(() {
      if (_selectedSeatIds.contains(seat.id)) {
        _selectedSeatIds.remove(seat.id);
      } else {
        _selectedSeatIds.add(seat.id!);
      }
    });
  }

  
  
  
  void _onStepContinue() {
    if (_currentStep == 0) {
      if (_selectedSeatIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one seat')),
        );
        return;
      }
      setState(() => _currentStep = 1);
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep = _currentStep - 1);
    }
  }

  bool _isStepValid() {
    if (_currentStep == 0) return _selectedSeatIds.isNotEmpty;
    if (_currentStep == 1) {
      return _selectedBoardingPoint != null && _selectedDropPoint != null;
    }
    return false;
  }

  void _proceedToPassengers(TripsLoaded state) {
    if (!_isStepValid()) return;
    context.push(
      '/home/trip/$state./passengers',
      extra: {
        'tripId': widget.tripId,
        'boardingStopId': _selectedBoardingPoint!.id,
        'dropStopId': _selectedDropPoint!.id,
        'selectedSeatIds': _selectedSeatIds.toList(),
      },
    );
  }

  
  
  
  Widget _buildTripInfoCompact(TripDetail trip) {
    final duration = _calculateDuration(
      trip.departureTime ?? '',
      trip.arrivalTime ?? '',
    );
    final boardingPoints =
        trip.route?.routeStops
            ?.where((s) => s.isBoardingPoint == true)
            .map((s) => s.stopName)
            .join(', ') ??
            'Multiple points';
    final dropPoints =
        trip.route?.routeStops
            ?.where((s) => s.isDropPoint == true)
            .map((s) => s.stopName)
            .join(', ') ??
            'Multiple points';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  trip.operator?.companyName ?? 'Operator',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(trip.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trip.status?.toUpperCase() ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(trip.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${trip.bus?.busName ?? ''} • ${trip.bus?.busType?.replaceAll('_', ' ').toUpperCase() ?? ''}',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const Divider(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatTravelTime(trip.departureTime),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      trip.route?.sourceCity ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  const Icon(Icons.arrow_forward, color: Colors.grey, size: 20),
                  Text(
                    duration,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatTravelTime(trip.arrivalTime),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      trip.route?.destinationCity ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.straighten, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${trip.route?.distanceKm?.toStringAsFixed(0) ?? '--'} km',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    formatTravelDateTime(trip.travelStartDate ?? ''),
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.event_seat, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${trip.availableSeats ?? 0} seats',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: Colors.grey.shade400),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'scheduled':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _calculateDuration(String departure, String arrival) {
    try {
      final dep = DateTime.parse(departure);
      final arr = DateTime.parse(arrival);
      final diff = arr.difference(dep);
      final hours = diff.inHours;
      final minutes = diff.inMinutes.remainder(60);
      return '${hours}h ${minutes}m';
    } catch (_) {
      return '--';
    }
  }
}
import 'package:equatable/equatable.dart';
import '../models/response/trip_model.dart';
import '../models/response/seat_model.dart';
import '../models/response/route_stop_model.dart';

const _unset = Object();

class BookingFlowState extends Equatable {
  final TripModel? selectedTrip;
  final List<SeatModel> availableSeats;
  final bool seatsLoading;
  final List<String> selectedSeatNumbers;
  final List<SeatModel> selectedSeats;

  final List<RouteStopModel> boardingPoints;
  final List<RouteStopModel> droppingPoints;
  final bool stopsLoading;
  final RouteStopModel? selectedBoardingStop;
  final RouteStopModel? selectedDroppingStop;

  const BookingFlowState({
    this.selectedTrip,
    this.availableSeats = const [],
    this.seatsLoading = false,
    this.selectedSeatNumbers = const [],
    this.selectedSeats = const [],
    this.boardingPoints = const [],
    this.droppingPoints = const [],
    this.stopsLoading = false,
    this.selectedBoardingStop,
    this.selectedDroppingStop,
  });

  double get totalPrice {
    if (selectedSeats.isEmpty) return 0;
    final sum = selectedSeats.fold<double>(0, (total, seat) => total + seat.price);
    if (sum > 0) return sum;
    final tripPrice = selectedTrip?.price ?? 0;
    if (tripPrice <= 0) return 0;
    return tripPrice * selectedSeats.length;
  }

  BookingFlowState copyWith({
    TripModel? selectedTrip,
    List<SeatModel>? availableSeats,
    bool? seatsLoading,
    List<String>? selectedSeatNumbers,
    List<SeatModel>? selectedSeats,
    List<RouteStopModel>? boardingPoints,
    List<RouteStopModel>? droppingPoints,
    bool? stopsLoading,
    Object? selectedBoardingStop = _unset,
    Object? selectedDroppingStop = _unset,
  }) {
    return BookingFlowState(
      selectedTrip: selectedTrip ?? this.selectedTrip,
      availableSeats: availableSeats ?? this.availableSeats,
      seatsLoading: seatsLoading ?? this.seatsLoading,
      selectedSeatNumbers: selectedSeatNumbers ?? this.selectedSeatNumbers,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      boardingPoints: boardingPoints ?? this.boardingPoints,
      droppingPoints: droppingPoints ?? this.droppingPoints,
      stopsLoading: stopsLoading ?? this.stopsLoading,
      selectedBoardingStop: selectedBoardingStop == _unset
          ? this.selectedBoardingStop
          : selectedBoardingStop as RouteStopModel?,
      selectedDroppingStop: selectedDroppingStop == _unset
          ? this.selectedDroppingStop
          : selectedDroppingStop as RouteStopModel?,
    );
  }

  @override
  List<Object?> get props => [
        selectedTrip,
        availableSeats,
        seatsLoading,
        selectedSeatNumbers,
        selectedSeats,
        boardingPoints,
        droppingPoints,
        stopsLoading,
        selectedBoardingStop,
        selectedDroppingStop,
      ];
}

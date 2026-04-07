import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/response/trip_model.dart';
import '../models/response/seat_model.dart';
import '../models/response/route_stop_model.dart';
import '../repository/fetch_trips.dart';
import 'booking_flow_state.dart';

class BookingFlowCubit extends Cubit<BookingFlowState> {
  final TripRepository repository;

  BookingFlowCubit(this.repository) : super(const BookingFlowState());

  void selectTrip(TripModel trip) {
    emit(state.copyWith(
      selectedTrip: trip,
      availableSeats: [],
      selectedSeatNumbers: [],
      selectedSeats: [],
      selectedBoardingStop: null,
      selectedDroppingStop: null,
    ));
    fetchSeats(trip.id);
    fetchBoardingDroppingPoints(trip.id);
  }

  Future<void> fetchSeats(int tripId) async {
    emit(state.copyWith(seatsLoading: true));
    try {
      final seats = await repository.fetchTripSeats(tripId);
      final selectableSeatNumbers = seats
          .where((seat) => seat.isAvailable)
          .map((seat) => seat.seatnumber)
          .toSet();
      final selectedSeatNumbers = state.selectedSeatNumbers
          .where(selectableSeatNumbers.contains)
          .toList();
      final selectedSeats = seats
          .where((seat) => selectedSeatNumbers.contains(seat.seatnumber))
          .toList();

      emit(state.copyWith(
        availableSeats: seats,
        selectedSeatNumbers: selectedSeatNumbers,
        selectedSeats: selectedSeats,
        seatsLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(seatsLoading: false));
    }
  }

  Future<void> fetchBoardingDroppingPoints(int tripId) async {
    emit(state.copyWith(stopsLoading: true));
    try {
      final boarding = await repository.fetchBoardingPoints(tripId);
      final dropping = await repository.fetchDroppingPoints(tripId);
      emit(state.copyWith(
        boardingPoints: boarding,
        droppingPoints: dropping,
        stopsLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(stopsLoading: false));
    }
  }

  void toggleSeat(SeatModel seat) {
    if (!seat.isAvailable) return;

    final List<String> currentNumbers = List.from(state.selectedSeatNumbers);
    final List<SeatModel> currentSeats = List.from(state.selectedSeats);

    if (currentNumbers.contains(seat.seatnumber)) {
      currentNumbers.remove(seat.seatnumber);
      currentSeats.removeWhere((s) => s.seatnumber == seat.seatnumber);
    } else {
      currentNumbers.add(seat.seatnumber);
      currentSeats.add(seat);
    }

    emit(state.copyWith(
      selectedSeatNumbers: currentNumbers,
      selectedSeats: currentSeats,
    ));
  }

  void selectBoardingStop(RouteStopModel stop) {
    emit(state.copyWith(selectedBoardingStop: stop));
  }

  void selectDroppingStop(RouteStopModel stop) {
    emit(state.copyWith(selectedDroppingStop: stop));
  }

  void markSeatsBooked(List<String> bookedSeatNumbers) {
    if (bookedSeatNumbers.isEmpty) return;

    final bookedSet = bookedSeatNumbers.toSet();
    final updatedSeats = state.availableSeats
        .map((seat) {
          if (!bookedSet.contains(seat.seatnumber)) return seat;
          return SeatModel(
            id: seat.id,
            seatnumber: seat.seatnumber,
            seattype: seat.seattype,
            deck: seat.deck,
            rownumber: seat.rownumber,
            colnumber: seat.colnumber,
            status: 1,
            price: seat.price,
            tripseatid: seat.tripseatid,
          );
        })
        .toList();

    final trip = state.selectedTrip;
    final updatedTrip = trip == null
        ? null
        : TripModel(
            id: trip.id,
            departureTime: trip.departureTime,
            arrivalTime: trip.arrivalTime,
            availableSeats:
                (trip.availableSeats - bookedSet.length).clamp(0, 9999).toInt(),
            durationMins: trip.durationMins,
            price: trip.price,
            bus: trip.bus,
            operator: trip.operator,
          );

    emit(state.copyWith(
      availableSeats: updatedSeats,
      selectedSeatNumbers: [],
      selectedSeats: [],
      selectedTrip: updatedTrip,
    ));
  }
}

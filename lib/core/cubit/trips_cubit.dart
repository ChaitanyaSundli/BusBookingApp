// lib/core/features/trips/data/cubit/trips_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/response/stop_point.dart';
import '../models/response/trip.dart';
import '../models/response/trip_detail.dart';
import '../repository/trips_repository.dart';

part 'trips_state.dart';

class TripsCubit extends Cubit<TripsState> {
  final TripsRepository repo;

  TripsCubit(this.repo) : super(const TripsInitial());

  Future<void> searchTrips({
    required String source,
    required String destination,
    required String date,
  }) async {
    emit(const TripsLoading());
    try {
      final trips = await repo.searchTrips(
        source: source,
        destination: destination,
        date: date,
      );

      // Preserve existing loaded data if any (e.g., selectedTrip)
      final current = state is TripsLoaded ? state as TripsLoaded : null;
      emit(TripsLoaded(
        searchResults: trips,
        selectedTrip: current?.selectedTrip,
        boardingPoints: current?.boardingPoints ?? const [],
        dropPoints: current?.dropPoints ?? const [],
      ));
    } catch (e) {
      emit(TripsError(e.toString()));
    }
  }

  Future<void> getTripDetail(int id) async {
    emit(const TripsLoading());
    try {
      final detail = await repo.getTripDetail(id);

      final current = state is TripsLoaded ? state as TripsLoaded : null;
      emit(TripsLoaded(
        searchResults: current?.searchResults ?? const [],
        selectedTrip: detail,
        boardingPoints: current?.boardingPoints ?? const [],
        dropPoints: current?.dropPoints ?? const [],
      ));
    } catch (e) {
      emit(TripsError(e.toString()));
    }
  }

  Future<void> getBoardingPoints(int tripId, {String? city}) async {
    emit(const TripsLoading());
    try {
      final points = await repo.getBoardingPoints(tripId, city: city);

      final current = state is TripsLoaded ? state as TripsLoaded : null;
      emit(TripsLoaded(
        searchResults: current?.searchResults ?? const [],
        selectedTrip: current?.selectedTrip,
        boardingPoints: points,
        dropPoints: current?.dropPoints ?? const [],
      ));
    } catch (e) {
      emit(TripsError(e.toString()));
    }
  }

  Future<void> getDropPoints(int tripId, {String? city}) async {
    emit(const TripsLoading());
    try {
      final points = await repo.getDropPoints(tripId, city: city);

      final current = state is TripsLoaded ? state as TripsLoaded : null;
      emit(TripsLoaded(
        searchResults: current?.searchResults ?? const [],
        selectedTrip: current?.selectedTrip,
        boardingPoints: current?.boardingPoints ?? const [],
        dropPoints: points,
      ));
    } catch (e) {
      emit(TripsError(e.toString()));
    }
  }

  void clearSearch() {
    final current = state is TripsLoaded ? state as TripsLoaded : null;
    emit(TripsLoaded(
      searchResults: const [],
      selectedTrip: current?.selectedTrip,
      boardingPoints: current?.boardingPoints ?? const [],
      dropPoints: current?.dropPoints ?? const [],
    ));
  }
}
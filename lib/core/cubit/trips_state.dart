// lib/core/features/trips/data/cubit/trips_state.dart
part of 'trips_cubit.dart';

sealed class TripsState {
  const TripsState();
}

class TripsInitial extends TripsState {
  const TripsInitial();
}

class TripsLoading extends TripsState {
  const TripsLoading();
}

class TripsLoaded extends TripsState {
  final List<Trip> searchResults;
  final TripDetail? selectedTrip;
  final List<StopPoint> boardingPoints;
  final List<StopPoint> dropPoints;

  const TripsLoaded({
    this.searchResults = const [],
    this.selectedTrip,
    this.boardingPoints = const [],
    this.dropPoints = const [],
  });

  TripsLoaded copyWith({
    List<Trip>? searchResults,
    TripDetail? selectedTrip,
    List<StopPoint>? boardingPoints,
    List<StopPoint>? dropPoints,
  }) {
    return TripsLoaded(
      searchResults: searchResults ?? this.searchResults,
      selectedTrip: selectedTrip ?? this.selectedTrip,
      boardingPoints: boardingPoints ?? this.boardingPoints,
      dropPoints: dropPoints ?? this.dropPoints,
    );
  }
}

class TripsError extends TripsState {
  final String message;
  const TripsError(this.message);
}
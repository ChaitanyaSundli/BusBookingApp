part of 'trip_cubit.dart';

@immutable
sealed class TripState {}

final class TripInitial extends TripState {}

final class TripLoading extends TripState {}

final class TripSuccess extends TripState {
  final List<TripModel> data;

  TripSuccess(this.data);
}

final class TripEmpty extends TripState {}

final class TripError extends TripState {
  final String message;

  TripError(this.message);
}
part of 'stops_cubit.dart';

@immutable
sealed class StopsState {}

final class StopsLoading extends StopsState {}

final class StopsSuccess extends StopsState {
  final List<StopModel> stops;

  StopsSuccess(this.stops);
}

final class StopsEmpty extends StopsState {}

final class StopsError extends StopsState {
  final String message;

  StopsError(this.message);
}

final class StopsInitial extends StopsState {}

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../models/response/trip_model.dart';
import '../repository/fetch_trips.dart';

part 'trip_state.dart';

class TripCubit extends Cubit<TripState> {
  final TripRepository repository;

  TripCubit(this.repository) : super(TripInitial());

  Future<void> fetchTrips({
    required String source,
    required String destination,
    required String date,
    required int operatorId,
  }) async {
    try {
      emit(TripLoading());

      final trips = await repository.fetchTrips(
        source: source,
        destination: destination,
        date: date,
        operatorId: operatorId,
      );

      if (trips.isEmpty) {
        emit(TripEmpty());
      } else {
        emit(TripSuccess(trips));
      }
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }
}
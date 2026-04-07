import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:quick_bus/core/network/di.dart';

import '../models/stop_model.dart';

part 'stops_state.dart';


class StopsCubit extends Cubit<StopsState> {
  StopsCubit() : super(StopsInitial());
  void fetchSuggestions(String query) {
    emit(StopsLoading());
    DI.stopsRepository.fetchSuggestions(query).then((stops) {
      if (stops.data.isEmpty) {
        emit(StopsEmpty());
        return;
      }
      emit(StopsSuccess(stops.data));
    }).catchError((error) {
      emit(StopsError(error.toString()));
    });
    }

  void clearSuggestions() {
    emit(StopsInitial());
  }
}

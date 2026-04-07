import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../network/di.dart';
import '../models/response/operator_list_item.dart';

part 'operator_list_state.dart';

class OperatorListCubit extends Cubit<OperatorListState> {
  OperatorListCubit() : super(OperatorListInitial());

  Future<void> searchTrips({
    required String source,
    required String destination,
    required String date,
  }) async {
    emit(OperatorListLoading());
    try {
      final res = await DI.searchBusRepository.fetchSuggestions(source, destination, date);
      if (res.isEmpty) {
        emit(OperatorListEmpty());
        return;
      }
      emit(OperatorListSuccess(res));
    } catch (e) {
      emit(OperatorListError(e.toString()));
    }
  }
}

part of 'operator_list_cubit.dart';

@immutable
sealed class OperatorListState {}

final class OperatorListInitial extends OperatorListState {}

final class OperatorListLoading extends OperatorListState {}

final class OperatorListError extends OperatorListState {
  final String message;

  OperatorListError(this.message);
}

final class OperatorListSuccess extends OperatorListState {
  final List<OperatorListItem> data;

  OperatorListSuccess(this.data);

}

final class OperatorListEmpty extends OperatorListState {}


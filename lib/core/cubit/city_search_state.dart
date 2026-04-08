// lib/features/home/presentation/cubit/city_search_state.dart
part of 'city_search_cubit.dart';

abstract class CitySearchState {}

class CitySearchInitial extends CitySearchState {}
class CitySearchLoading extends CitySearchState {}
class CitySearchLoaded extends CitySearchState {
  final List<String> allCities;
  final List<String> sourceCities;
  final List<String> destinationCities;

  CitySearchLoaded({
    required this.allCities,
    required this.sourceCities,
    required this.destinationCities,
  });
}
class CitySearchError extends CitySearchState {
  final String message;
  CitySearchError(this.message);
}
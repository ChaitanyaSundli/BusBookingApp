// lib/features/home/presentation/cubit/city_search_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/trips_repository.dart';
import '../utils/local_storage/session_manager.dart';

part 'city_search_state.dart';

class CitySearchCubit extends Cubit<CitySearchState> {
  final TripsRepository tripsRepo;

  CitySearchCubit({required this.tripsRepo}) : super(CitySearchInitial());

  List<String> _allCities = [];
  List<String> _sourceCities = [];
  List<String> _destinationCities = [];

  Future<void> loadCities() async {
    if (SessionManager().isGuest) {
      emit(CitySearchLoaded(allCities: [], sourceCities: [], destinationCities: []));
      return;
    }
    if (_allCities.isNotEmpty) return;
    emit(CitySearchLoading());
    try {

      final routes = await tripsRepo.getAllRoutes(); // to be added
      final cities = <String>{};
      for (var route in routes) {
        cities.add(route.sourceCity);
        cities.add(route.destinationCity);
      }
      _allCities = cities.toList()..sort();
      _sourceCities = routes.map((r) => r.sourceCity).toSet().toList()..sort();
      _destinationCities = routes.map((r) => r.destinationCity).toSet().toList()..sort();
      emit(CitySearchLoaded(allCities: _allCities, sourceCities: _sourceCities, destinationCities: _destinationCities));
    } catch (e) {
      emit(CitySearchError(e.toString()));
    }
  }

  List<String> getSourceSuggestions(String query) {
    if (_sourceCities.isEmpty) return [];
    return _sourceCities.where((city) => city.toLowerCase().contains(query.toLowerCase())).toList();
  }

  List<String> getDestinationSuggestions(String query) {
    if (_destinationCities.isEmpty) return [];
    return _destinationCities.where((city) => city.toLowerCase().contains(query.toLowerCase())).toList();
  }
}
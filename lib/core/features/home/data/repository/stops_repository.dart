import 'package:quick_bus/core/features/home/data/apis/home_api.dart';
import 'package:quick_bus/core/features/home/data/models/stops_wrapper.dart';

class StopsRepository {
  final HomeApi _homeApi;

  StopsRepository(this._homeApi);

  Future<StopsWrapper> fetchSuggestions(String query) async {
    final response = await _homeApi.getStops(query);
    return response;
  }
}
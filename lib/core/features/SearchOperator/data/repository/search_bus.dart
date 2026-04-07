import '../api/search_bus_api.dart';
import '../models/response/operator_list_item.dart';

class SearchBusRepository {
  final SearchBusApi _busApi;

  SearchBusRepository(this._busApi);

  Future<List<OperatorListItem>> fetchSuggestions(String source, String destination, String date) async {
    final response = await _busApi.getOperatorList(source, destination, date);
    return response.data;
  }

  Future<List<Map<String, dynamic>>> fetchAllOperators() async {
    final response = await _busApi.getAllOperators();
    final data = (response['data'] as List?) ?? const [];
    return data.map((item) => (item as Map).cast<String, dynamic>()).toList();
  }

  Future<Map<String, dynamic>> fetchOperatorOverview(int operatorId) async {
    final response = await _busApi.getOperatorOverview(operatorId);
    return (response['data'] as Map?)?.cast<String, dynamic>() ?? const {};
  }
}
import 'package:dio/dio.dart';
import '../api/trips_api.dart';
import '../models/response/post_booking_detail.dart' as route_model;
import '../models/response/stop_point.dart';
import '../models/response/trip.dart';
import '../models/response/trip_detail.dart';
import '../models/response/trips_wrapper.dart';

class TripsRepository {
  final TripsApi api;
  final Dio dio;

  TripsRepository(this.api, this.dio);

  Future<List<Trip>> searchTrips({
    required String source,
    required String destination,
    required String date,
  }) async {
    try {
      final dynamic response = await api.searchTrips({
        'source': source,
        'destination': destination,
        'date': date,
      });

      final Map<String, dynamic> json = response as Map<String, dynamic>;
      final dataList = json['data'] as List<dynamic>? ?? [];

      return dataList.map((item) {
        try {
          return Trip.fromJson(item as Map<String, dynamic>);
        } catch (e) {
          print('❌ Failed to parse trip: $item');
          print('Error: $e');
          rethrow;
        }
      }).toList();
    } on DioException catch (e) {
      throw _handleDioError(e, fallback: 'Failed to search trips');
    } catch (e, stack) {
      print('❌ Unexpected error in searchTrips: $e');
      print(stack);
      throw Exception('Something went wrong: $e');
    }
  }

  Future<List<Trip>> getTrips({Map<String, dynamic>? query}) async {
    try {
      final response = await api.getTrips(query ?? {});
      final wrapper = TripsWrapper.fromJson(response);
      return wrapper.data ?? [];
    } on DioException catch (e) {
      throw _handleDioError(e, fallback: 'Failed to fetch trips');
    } catch (e) {
      throw Exception('Something went wrong');
    }
  }

  Future<TripDetail> getTripDetail(int id) async {
    try {
      final dynamic response = await api.getTripDetail(id);
      final Map<String, dynamic> json = response as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>? ?? {};
      return TripDetail.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Trip not found');
      }
      throw _handleDioError(e, fallback: 'Failed to fetch trip details');
    } catch (e) {
      throw Exception('Something went wrong');
    }
  }

  Future<List<StopPoint>> getBoardingPoints(int tripId, {String? city}) async {
    try {
      final dynamic response = await api.getBoardingPoints(tripId, city);
      final Map<String, dynamic> json = response as Map<String, dynamic>;
      final dataList = json['data'] as List<dynamic>? ?? [];
      return dataList
          .map((e) => StopPoint.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e, fallback: 'Failed to fetch boarding points');
    } catch (e) {
      throw Exception('Something went wrong');
    }
  }

  Future<List<StopPoint>> getDropPoints(int tripId, {String? city}) async {
    try {
      final response = await api.getDropPoints(tripId, city);

      final dataList = response['data'] as List<dynamic>? ?? [];

      return dataList
          .map((json) => StopPoint.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e, fallback: 'Failed to fetch drop points');
    } catch (e) {
      throw Exception('Something went wrong');
    }
  }

  // In TripsRepository
  Future<List<route_model.Route>> getAllRoutes() async {
    try {
      final response = await api.getAllRoutes(); // add to TripsApi
      final data = response['data'] as List<dynamic>? ?? [];
      return data.map((json) => route_model.Route.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getCities(int tripId) async {
    try {
      final response = await api.getStops(tripId);

      final stopsList = response['stops'] as List<dynamic>? ?? [];

      return stopsList.map((e) => e.toString()).toList();
    } on DioException catch (e) {
      throw _handleDioError(e, fallback: 'Failed to fetch cities');
    } catch (e) {
      throw Exception('Something went wrong');
    }
  }

  String _handleDioError(DioException e, {required String fallback}) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      if (data['errors'] != null) {
        final errors = data['errors'];
        if (errors is List && errors.isNotEmpty) {
          return errors.first.toString();
        }
        return errors.toString();
      }
      if (data['error'] != null) {
        return data['error'].toString();
      }
      if (data['message'] != null) {
        return data['message'].toString();
      }
    }

    if (e.response?.statusCode != null) {
      switch (e.response!.statusCode) {
        case 400:
          return 'Bad request. Please check your input.';
        case 401:
          return 'Session expired. Please login again.';
        case 404:
          return 'Resource not found.';
        case 422:
          return 'Validation failed.';
        case 500:
        case 502:
        case 503:
          return 'Server error. Please try again later.';
        default:
          return 'HTTP ${e.response!.statusCode}: ${e.response?.statusMessage ?? fallback}';
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      default:
        return fallback;
    }
  }
}

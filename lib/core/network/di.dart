import 'package:dio/dio.dart';
import 'package:quick_bus/core/features/bookings/data/api/booking_api.dart';
import 'package:quick_bus/core/features/bookings/data/repository/booking_repository.dart';
import 'package:quick_bus/core/features/home/data/apis/home_api.dart';
import 'package:quick_bus/core/features/operators_bus/data/repository/fetch_trips.dart';
import '../features/SearchOperator/data/api/search_bus_api.dart';
import '../features/SearchOperator/data/repository/search_bus.dart';
import '../features/auth/data/api/auth_api.dart';
import '../features/auth/data/repository/auth_repository.dart';
import '../features/home/data/repository/stops_repository.dart';
import '../features/operators_bus/data/api/trips_api.dart';
import 'api_client.dart';

class DI {
  DI._();

  static Dio? _dio;

  static Dio get dio => _dio ??= DioClient.getDio();

  static AuthApi? _authApi;

  static AuthApi get authApi => _authApi ??= AuthApi(dio);

  static HomeApi? _homeApi;

  static HomeApi get homeApi => _homeApi ??= HomeApi(dio);

  static SearchBusApi? _searchBusApi;

  static SearchBusApi get searchBusApi => _searchBusApi ??= SearchBusApi(dio);

  static TripsApi? _tripsApi;

  static TripsApi get tripsApi => _tripsApi ??= TripsApi(dio);

  static AuthRepository? _authRepository;

  static AuthRepository get authRepository =>
      _authRepository ??= AuthRepository(authApi, dio);

  static StopsRepository? _stopsRepository;

  static StopsRepository get stopsRepository =>
      _stopsRepository ??= StopsRepository(homeApi);

  static SearchBusRepository? _searchBusRepository;

  static SearchBusRepository get searchBusRepository =>
      _searchBusRepository ??= SearchBusRepository(searchBusApi);

  static TripRepository? _tripRepository;

  static TripRepository get tripRepository =>
      _tripRepository ??= TripRepository(tripsApi);

  static BookingApi? _bookingApi;

  static BookingApi get bookingApi => _bookingApi ??= BookingApi(dio);

  static BookingRepository? _bookingRepository;

  static BookingRepository get bookingRepository =>
      _bookingRepository ??= BookingRepository(bookingApi);
}

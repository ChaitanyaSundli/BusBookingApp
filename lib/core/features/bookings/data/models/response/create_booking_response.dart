class CreateBookingResponse {
  final String message;
  final CreateBookingData data;

  CreateBookingResponse({
    required this.message,
    required this.data,
  });

  factory CreateBookingResponse.fromJson(Map<String, dynamic> json) {
    return CreateBookingResponse(
      message: json['message']?.toString() ?? '',
      data: CreateBookingData.fromJson((json['data'] as Map).cast<String, dynamic>()),
    );
  }
}

class CreateBookingData {
  final int id;
  final int tripId;
  final String status;
  final double totalPrice;
  final BookingStopInfo boardingStop;
  final BookingStopInfo dropStop;
  final List<BookedSeatInfo> seats;
  final String createdAt;
  final BookingPaymentInfo? payment;

  CreateBookingData({
    required this.id,
    required this.tripId,
    required this.status,
    required this.totalPrice,
    required this.boardingStop,
    required this.dropStop,
    required this.seats,
    required this.createdAt,
    this.payment,
  });

  factory CreateBookingData.fromJson(Map<String, dynamic> json) {
    final rawSeats = (json['seats'] as List?) ?? const [];
    return CreateBookingData(
      id: (json['id'] as num).toInt(),
      tripId: (json['trip_id'] as num).toInt(),
      status: json['status']?.toString() ?? '',
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0,
      boardingStop:
          BookingStopInfo.fromJson((json['boarding_stop'] as Map).cast<String, dynamic>()),
      dropStop: BookingStopInfo.fromJson((json['drop_stop'] as Map).cast<String, dynamic>()),
      seats: rawSeats
          .map((e) => BookedSeatInfo.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      createdAt: json['created_at']?.toString() ?? '',
      payment: json['payment'] == null
          ? null
          : BookingPaymentInfo.fromJson((json['payment'] as Map).cast<String, dynamic>()),
    );
  }
}

class BookingStopInfo {
  final int id;
  final String stopName;
  final String cityName;

  BookingStopInfo({
    required this.id,
    required this.stopName,
    required this.cityName,
  });

  factory BookingStopInfo.fromJson(Map<String, dynamic> json) {
    return BookingStopInfo(
      id: (json['id'] as num).toInt(),
      stopName: json['stop_name']?.toString() ?? '',
      cityName: json['city_name']?.toString() ?? '',
    );
  }
}

class BookedSeatInfo {
  final String seatNumber;
  final double seatPrice;

  BookedSeatInfo({
    required this.seatNumber,
    required this.seatPrice,
  });

  factory BookedSeatInfo.fromJson(Map<String, dynamic> json) {
    return BookedSeatInfo(
      seatNumber: json['seat_number']?.toString() ?? '',
      seatPrice: (json['seat_price'] as num?)?.toDouble() ?? 0,
    );
  }
}


class BookingPaymentInfo {
  final int id;
  final double amount;
  final String status;

  BookingPaymentInfo({
    required this.id,
    required this.amount,
    required this.status,
  });

  factory BookingPaymentInfo.fromJson(Map<String, dynamic> json) {
    return BookingPaymentInfo(
      id: (json['id'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      status: json['status']?.toString() ?? 'unknown',
    );
  }
}

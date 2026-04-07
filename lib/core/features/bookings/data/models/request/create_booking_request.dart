class CreateBookingRequest {
  final int tripId;
  final int boardingStopId;
  final int dropStopId;
  final List<String> seatNumbers;
  final List<PassengerRequest> passengers;

  CreateBookingRequest({
    required this.tripId,
    required this.boardingStopId,
    required this.dropStopId,
    required this.seatNumbers,
    required this.passengers,
  });

  Map<String, dynamic> toJson() => {
        'trip_id': tripId,
        'boarding_stop_id': boardingStopId,
        'drop_stop_id': dropStopId,
        'seat_numbers': seatNumbers,
        'passengers': passengers.map((e) => e.toJson()).toList(),
      };
}

class PassengerRequest {
  final String name;
  final int age;
  final String? phone;
  final String gender;

  PassengerRequest({
    required this.name,
    required this.age,
    required this.phone,
    required this.gender,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'phone': phone,
        'gender': gender.toLowerCase(),
      };
}

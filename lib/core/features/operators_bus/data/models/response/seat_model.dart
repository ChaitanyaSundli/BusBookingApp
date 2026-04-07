import 'package:json_annotation/json_annotation.dart';

part 'seat_model.g.dart';

@JsonSerializable()
class SeatModel {
  final int id;
  @JsonKey(name: 'seatnumber')
  final String seatnumber;
  @JsonKey(name: 'seattype')
  final String seattype;
  final String deck;
  @JsonKey(name: 'rownumber')
  final int rownumber;
  @JsonKey(name: 'colnumber')
  final int colnumber;
  final int status;
  final double price;
  @JsonKey(name: 'tripseatid')
  final int? tripseatid;

  SeatModel({
    required this.id,
    required this.seatnumber,
    required this.seattype,
    required this.deck,
    required this.rownumber,
    required this.colnumber,
    required this.status,
    required this.price,
    this.tripseatid,
  });

  bool get isAvailable => status == 0;

  factory SeatModel.fromJson(Map<String, dynamic> json) =>
      _$SeatModelFromJson(json);

  Map<String, dynamic> toJson() => _$SeatModelToJson(this);
}

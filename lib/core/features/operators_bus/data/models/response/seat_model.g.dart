// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SeatModel _$SeatModelFromJson(Map<String, dynamic> json) => SeatModel(
  id: (json['id'] as num).toInt(),
  seatnumber: json['seatnumber'] as String,
  seattype: json['seattype'] as String,
  deck: json['deck'] as String,
  rownumber: (json['rownumber'] as num).toInt(),
  colnumber: (json['colnumber'] as num).toInt(),
  status: (json['status'] as num).toInt(),
  price: (json['price'] as num).toDouble(),
  tripseatid: (json['tripseatid'] as num?)?.toInt(),
);

Map<String, dynamic> _$SeatModelToJson(SeatModel instance) => <String, dynamic>{
  'id': instance.id,
  'seatnumber': instance.seatnumber,
  'seattype': instance.seattype,
  'deck': instance.deck,
  'rownumber': instance.rownumber,
  'colnumber': instance.colnumber,
  'status': instance.status,
  'price': instance.price,
  'tripseatid': instance.tripseatid,
};

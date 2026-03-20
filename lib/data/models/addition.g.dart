// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'addition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Addition _$AdditionFromJson(Map<String, dynamic> json) => _Addition(
  id: json['id'] as String,
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  kasPrice: (json['kasPrice'] as num?)?.toDouble(),
);

Map<String, dynamic> _$AdditionToJson(_Addition instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'price': instance.price,
  'kasPrice': instance.kasPrice,
};

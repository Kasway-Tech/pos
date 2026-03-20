// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => _OrderItem(
  id: json['id'] as String,
  productName: json['productName'] as String,
  unitPrice: (json['unitPrice'] as num).toDouble(),
  quantity: (json['quantity'] as num).toInt(),
  additions:
      (json['additions'] as List<dynamic>?)
          ?.map((e) => OrderItemAddition.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$OrderItemToJson(_OrderItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productName': instance.productName,
      'unitPrice': instance.unitPrice,
      'quantity': instance.quantity,
      'additions': instance.additions,
    };

_OrderItemAddition _$OrderItemAdditionFromJson(Map<String, dynamic> json) =>
    _OrderItemAddition(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$OrderItemAdditionToJson(_OrderItemAddition instance) =>
    <String, dynamic>{'name': instance.name, 'price': instance.price};

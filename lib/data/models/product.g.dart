// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: json['id'] as String,
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  description: json['description'] as String? ?? '',
  imageUrl: json['imageUrl'] as String? ?? '',
  additions:
      (json['additions'] as List<dynamic>?)
          ?.map((e) => Addition.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  kasPrice: (json['kasPrice'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'price': instance.price,
  'description': instance.description,
  'imageUrl': instance.imageUrl,
  'additions': instance.additions.map((e) => e.toJson()).toList(),
  'kasPrice': instance.kasPrice,
};

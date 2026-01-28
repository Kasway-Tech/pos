import 'package:kasway/data/models/addition.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
abstract class Product with _$Product {
  @JsonSerializable(explicitToJson: true)
  const factory Product({
    required String id,
    required String name,
    required double price,
    @Default('') String description,
    @Default('') String imageUrl,
    @Default([]) List<Addition> additions,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'addition.freezed.dart';
part 'addition.g.dart';

@freezed
abstract class Addition with _$Addition {
  const factory Addition({
    required String id,
    required String name,
    required double price,
  }) = _Addition;

  factory Addition.fromJson(Map<String, dynamic> json) =>
      _$AdditionFromJson(json);
}

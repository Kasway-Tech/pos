// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Order {

 String get id; double get totalIdr; DateTime get createdAt; double get kasAmount; double get kasIdrRate; String get txId; String get tableLabel; List<OrderItem> get items;
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderCopyWith<Order> get copyWith => _$OrderCopyWithImpl<Order>(this as Order, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Order&&(identical(other.id, id) || other.id == id)&&(identical(other.totalIdr, totalIdr) || other.totalIdr == totalIdr)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.kasAmount, kasAmount) || other.kasAmount == kasAmount)&&(identical(other.kasIdrRate, kasIdrRate) || other.kasIdrRate == kasIdrRate)&&(identical(other.txId, txId) || other.txId == txId)&&(identical(other.tableLabel, tableLabel) || other.tableLabel == tableLabel)&&const DeepCollectionEquality().equals(other.items, items));
}


@override
int get hashCode => Object.hash(runtimeType,id,totalIdr,createdAt,kasAmount,kasIdrRate,txId,tableLabel,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'Order(id: $id, totalIdr: $totalIdr, createdAt: $createdAt, kasAmount: $kasAmount, kasIdrRate: $kasIdrRate, txId: $txId, tableLabel: $tableLabel, items: $items)';
}


}

/// @nodoc
abstract mixin class $OrderCopyWith<$Res>  {
  factory $OrderCopyWith(Order value, $Res Function(Order) _then) = _$OrderCopyWithImpl;
@useResult
$Res call({
 String id, double totalIdr, DateTime createdAt, double kasAmount, double kasIdrRate, String txId, String tableLabel, List<OrderItem> items
});




}
/// @nodoc
class _$OrderCopyWithImpl<$Res>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._self, this._then);

  final Order _self;
  final $Res Function(Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? totalIdr = null,Object? createdAt = null,Object? kasAmount = null,Object? kasIdrRate = null,Object? txId = null,Object? tableLabel = null,Object? items = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,totalIdr: null == totalIdr ? _self.totalIdr : totalIdr // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,kasAmount: null == kasAmount ? _self.kasAmount : kasAmount // ignore: cast_nullable_to_non_nullable
as double,kasIdrRate: null == kasIdrRate ? _self.kasIdrRate : kasIdrRate // ignore: cast_nullable_to_non_nullable
as double,txId: null == txId ? _self.txId : txId // ignore: cast_nullable_to_non_nullable
as String,tableLabel: null == tableLabel ? _self.tableLabel : tableLabel // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [Order].
extension OrderPatterns on Order {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Order value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Order value)  $default,){
final _that = this;
switch (_that) {
case _Order():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Order value)?  $default,){
final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double totalIdr,  DateTime createdAt,  double kasAmount,  double kasIdrRate,  String txId,  String tableLabel,  List<OrderItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.totalIdr,_that.createdAt,_that.kasAmount,_that.kasIdrRate,_that.txId,_that.tableLabel,_that.items);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double totalIdr,  DateTime createdAt,  double kasAmount,  double kasIdrRate,  String txId,  String tableLabel,  List<OrderItem> items)  $default,) {final _that = this;
switch (_that) {
case _Order():
return $default(_that.id,_that.totalIdr,_that.createdAt,_that.kasAmount,_that.kasIdrRate,_that.txId,_that.tableLabel,_that.items);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double totalIdr,  DateTime createdAt,  double kasAmount,  double kasIdrRate,  String txId,  String tableLabel,  List<OrderItem> items)?  $default,) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.totalIdr,_that.createdAt,_that.kasAmount,_that.kasIdrRate,_that.txId,_that.tableLabel,_that.items);case _:
  return null;

}
}

}

/// @nodoc


class _Order implements Order {
  const _Order({required this.id, required this.totalIdr, required this.createdAt, this.kasAmount = 0.0, this.kasIdrRate = 0.0, this.txId = '', this.tableLabel = '', final  List<OrderItem> items = const []}): _items = items;
  

@override final  String id;
@override final  double totalIdr;
@override final  DateTime createdAt;
@override@JsonKey() final  double kasAmount;
@override@JsonKey() final  double kasIdrRate;
@override@JsonKey() final  String txId;
@override@JsonKey() final  String tableLabel;
 final  List<OrderItem> _items;
@override@JsonKey() List<OrderItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderCopyWith<_Order> get copyWith => __$OrderCopyWithImpl<_Order>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Order&&(identical(other.id, id) || other.id == id)&&(identical(other.totalIdr, totalIdr) || other.totalIdr == totalIdr)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.kasAmount, kasAmount) || other.kasAmount == kasAmount)&&(identical(other.kasIdrRate, kasIdrRate) || other.kasIdrRate == kasIdrRate)&&(identical(other.txId, txId) || other.txId == txId)&&(identical(other.tableLabel, tableLabel) || other.tableLabel == tableLabel)&&const DeepCollectionEquality().equals(other._items, _items));
}


@override
int get hashCode => Object.hash(runtimeType,id,totalIdr,createdAt,kasAmount,kasIdrRate,txId,tableLabel,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'Order(id: $id, totalIdr: $totalIdr, createdAt: $createdAt, kasAmount: $kasAmount, kasIdrRate: $kasIdrRate, txId: $txId, tableLabel: $tableLabel, items: $items)';
}


}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) = __$OrderCopyWithImpl;
@override @useResult
$Res call({
 String id, double totalIdr, DateTime createdAt, double kasAmount, double kasIdrRate, String txId, String tableLabel, List<OrderItem> items
});




}
/// @nodoc
class __$OrderCopyWithImpl<$Res>
    implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(this._self, this._then);

  final _Order _self;
  final $Res Function(_Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? totalIdr = null,Object? createdAt = null,Object? kasAmount = null,Object? kasIdrRate = null,Object? txId = null,Object? tableLabel = null,Object? items = null,}) {
  return _then(_Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,totalIdr: null == totalIdr ? _self.totalIdr : totalIdr // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,kasAmount: null == kasAmount ? _self.kasAmount : kasAmount // ignore: cast_nullable_to_non_nullable
as double,kasIdrRate: null == kasIdrRate ? _self.kasIdrRate : kasIdrRate // ignore: cast_nullable_to_non_nullable
as double,txId: null == txId ? _self.txId : txId // ignore: cast_nullable_to_non_nullable
as String,tableLabel: null == tableLabel ? _self.tableLabel : tableLabel // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,
  ));
}


}

// dart format on

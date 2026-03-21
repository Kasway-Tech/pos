// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'table_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TableItem {

 String get id; String get label; int get seats; double get x; double get y; double get rotation; bool get isOccupied; bool get isServed; String? get groupId;
/// Create a copy of TableItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TableItemCopyWith<TableItem> get copyWith => _$TableItemCopyWithImpl<TableItem>(this as TableItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TableItem&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.seats, seats) || other.seats == seats)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.rotation, rotation) || other.rotation == rotation)&&(identical(other.isOccupied, isOccupied) || other.isOccupied == isOccupied)&&(identical(other.isServed, isServed) || other.isServed == isServed)&&(identical(other.groupId, groupId) || other.groupId == groupId));
}


@override
int get hashCode => Object.hash(runtimeType,id,label,seats,x,y,rotation,isOccupied,isServed,groupId);

@override
String toString() {
  return 'TableItem(id: $id, label: $label, seats: $seats, x: $x, y: $y, rotation: $rotation, isOccupied: $isOccupied, isServed: $isServed, groupId: $groupId)';
}


}

/// @nodoc
abstract mixin class $TableItemCopyWith<$Res>  {
  factory $TableItemCopyWith(TableItem value, $Res Function(TableItem) _then) = _$TableItemCopyWithImpl;
@useResult
$Res call({
 String id, String label, int seats, double x, double y, double rotation, bool isOccupied, bool isServed, String? groupId
});




}
/// @nodoc
class _$TableItemCopyWithImpl<$Res>
    implements $TableItemCopyWith<$Res> {
  _$TableItemCopyWithImpl(this._self, this._then);

  final TableItem _self;
  final $Res Function(TableItem) _then;

/// Create a copy of TableItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? seats = null,Object? x = null,Object? y = null,Object? rotation = null,Object? isOccupied = null,Object? isServed = null,Object? groupId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,seats: null == seats ? _self.seats : seats // ignore: cast_nullable_to_non_nullable
as int,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,rotation: null == rotation ? _self.rotation : rotation // ignore: cast_nullable_to_non_nullable
as double,isOccupied: null == isOccupied ? _self.isOccupied : isOccupied // ignore: cast_nullable_to_non_nullable
as bool,isServed: null == isServed ? _self.isServed : isServed // ignore: cast_nullable_to_non_nullable
as bool,groupId: freezed == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TableItem].
extension TableItemPatterns on TableItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TableItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TableItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TableItem value)  $default,){
final _that = this;
switch (_that) {
case _TableItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TableItem value)?  $default,){
final _that = this;
switch (_that) {
case _TableItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  int seats,  double x,  double y,  double rotation,  bool isOccupied,  bool isServed,  String? groupId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TableItem() when $default != null:
return $default(_that.id,_that.label,_that.seats,_that.x,_that.y,_that.rotation,_that.isOccupied,_that.isServed,_that.groupId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  int seats,  double x,  double y,  double rotation,  bool isOccupied,  bool isServed,  String? groupId)  $default,) {final _that = this;
switch (_that) {
case _TableItem():
return $default(_that.id,_that.label,_that.seats,_that.x,_that.y,_that.rotation,_that.isOccupied,_that.isServed,_that.groupId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  int seats,  double x,  double y,  double rotation,  bool isOccupied,  bool isServed,  String? groupId)?  $default,) {final _that = this;
switch (_that) {
case _TableItem() when $default != null:
return $default(_that.id,_that.label,_that.seats,_that.x,_that.y,_that.rotation,_that.isOccupied,_that.isServed,_that.groupId);case _:
  return null;

}
}

}

/// @nodoc


class _TableItem extends TableItem {
  const _TableItem({required this.id, required this.label, required this.seats, required this.x, required this.y, this.rotation = 0.0, this.isOccupied = false, this.isServed = false, this.groupId}): super._();
  

@override final  String id;
@override final  String label;
@override final  int seats;
@override final  double x;
@override final  double y;
@override@JsonKey() final  double rotation;
@override@JsonKey() final  bool isOccupied;
@override@JsonKey() final  bool isServed;
@override final  String? groupId;

/// Create a copy of TableItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TableItemCopyWith<_TableItem> get copyWith => __$TableItemCopyWithImpl<_TableItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TableItem&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.seats, seats) || other.seats == seats)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.rotation, rotation) || other.rotation == rotation)&&(identical(other.isOccupied, isOccupied) || other.isOccupied == isOccupied)&&(identical(other.isServed, isServed) || other.isServed == isServed)&&(identical(other.groupId, groupId) || other.groupId == groupId));
}


@override
int get hashCode => Object.hash(runtimeType,id,label,seats,x,y,rotation,isOccupied,isServed,groupId);

@override
String toString() {
  return 'TableItem(id: $id, label: $label, seats: $seats, x: $x, y: $y, rotation: $rotation, isOccupied: $isOccupied, isServed: $isServed, groupId: $groupId)';
}


}

/// @nodoc
abstract mixin class _$TableItemCopyWith<$Res> implements $TableItemCopyWith<$Res> {
  factory _$TableItemCopyWith(_TableItem value, $Res Function(_TableItem) _then) = __$TableItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, int seats, double x, double y, double rotation, bool isOccupied, bool isServed, String? groupId
});




}
/// @nodoc
class __$TableItemCopyWithImpl<$Res>
    implements _$TableItemCopyWith<$Res> {
  __$TableItemCopyWithImpl(this._self, this._then);

  final _TableItem _self;
  final $Res Function(_TableItem) _then;

/// Create a copy of TableItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? seats = null,Object? x = null,Object? y = null,Object? rotation = null,Object? isOccupied = null,Object? isServed = null,Object? groupId = freezed,}) {
  return _then(_TableItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,seats: null == seats ? _self.seats : seats // ignore: cast_nullable_to_non_nullable
as int,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,rotation: null == rotation ? _self.rotation : rotation // ignore: cast_nullable_to_non_nullable
as double,isOccupied: null == isOccupied ? _self.isOccupied : isOccupied // ignore: cast_nullable_to_non_nullable
as bool,isServed: null == isServed ? _self.isServed : isServed // ignore: cast_nullable_to_non_nullable
as bool,groupId: freezed == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

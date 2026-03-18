// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'withdrawal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Withdrawal {

 String get txId; String get toAddress; double get amountKas; double get amountIdr; double get kasIdrRate; DateTime get createdAt;
/// Create a copy of Withdrawal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WithdrawalCopyWith<Withdrawal> get copyWith => _$WithdrawalCopyWithImpl<Withdrawal>(this as Withdrawal, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Withdrawal&&(identical(other.txId, txId) || other.txId == txId)&&(identical(other.toAddress, toAddress) || other.toAddress == toAddress)&&(identical(other.amountKas, amountKas) || other.amountKas == amountKas)&&(identical(other.amountIdr, amountIdr) || other.amountIdr == amountIdr)&&(identical(other.kasIdrRate, kasIdrRate) || other.kasIdrRate == kasIdrRate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,txId,toAddress,amountKas,amountIdr,kasIdrRate,createdAt);

@override
String toString() {
  return 'Withdrawal(txId: $txId, toAddress: $toAddress, amountKas: $amountKas, amountIdr: $amountIdr, kasIdrRate: $kasIdrRate, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $WithdrawalCopyWith<$Res>  {
  factory $WithdrawalCopyWith(Withdrawal value, $Res Function(Withdrawal) _then) = _$WithdrawalCopyWithImpl;
@useResult
$Res call({
 String txId, String toAddress, double amountKas, double amountIdr, double kasIdrRate, DateTime createdAt
});




}
/// @nodoc
class _$WithdrawalCopyWithImpl<$Res>
    implements $WithdrawalCopyWith<$Res> {
  _$WithdrawalCopyWithImpl(this._self, this._then);

  final Withdrawal _self;
  final $Res Function(Withdrawal) _then;

/// Create a copy of Withdrawal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? txId = null,Object? toAddress = null,Object? amountKas = null,Object? amountIdr = null,Object? kasIdrRate = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
txId: null == txId ? _self.txId : txId // ignore: cast_nullable_to_non_nullable
as String,toAddress: null == toAddress ? _self.toAddress : toAddress // ignore: cast_nullable_to_non_nullable
as String,amountKas: null == amountKas ? _self.amountKas : amountKas // ignore: cast_nullable_to_non_nullable
as double,amountIdr: null == amountIdr ? _self.amountIdr : amountIdr // ignore: cast_nullable_to_non_nullable
as double,kasIdrRate: null == kasIdrRate ? _self.kasIdrRate : kasIdrRate // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Withdrawal].
extension WithdrawalPatterns on Withdrawal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Withdrawal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Withdrawal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Withdrawal value)  $default,){
final _that = this;
switch (_that) {
case _Withdrawal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Withdrawal value)?  $default,){
final _that = this;
switch (_that) {
case _Withdrawal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String txId,  String toAddress,  double amountKas,  double amountIdr,  double kasIdrRate,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Withdrawal() when $default != null:
return $default(_that.txId,_that.toAddress,_that.amountKas,_that.amountIdr,_that.kasIdrRate,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String txId,  String toAddress,  double amountKas,  double amountIdr,  double kasIdrRate,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Withdrawal():
return $default(_that.txId,_that.toAddress,_that.amountKas,_that.amountIdr,_that.kasIdrRate,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String txId,  String toAddress,  double amountKas,  double amountIdr,  double kasIdrRate,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Withdrawal() when $default != null:
return $default(_that.txId,_that.toAddress,_that.amountKas,_that.amountIdr,_that.kasIdrRate,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _Withdrawal implements Withdrawal {
  const _Withdrawal({required this.txId, required this.toAddress, required this.amountKas, required this.amountIdr, required this.kasIdrRate, required this.createdAt});
  

@override final  String txId;
@override final  String toAddress;
@override final  double amountKas;
@override final  double amountIdr;
@override final  double kasIdrRate;
@override final  DateTime createdAt;

/// Create a copy of Withdrawal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WithdrawalCopyWith<_Withdrawal> get copyWith => __$WithdrawalCopyWithImpl<_Withdrawal>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Withdrawal&&(identical(other.txId, txId) || other.txId == txId)&&(identical(other.toAddress, toAddress) || other.toAddress == toAddress)&&(identical(other.amountKas, amountKas) || other.amountKas == amountKas)&&(identical(other.amountIdr, amountIdr) || other.amountIdr == amountIdr)&&(identical(other.kasIdrRate, kasIdrRate) || other.kasIdrRate == kasIdrRate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,txId,toAddress,amountKas,amountIdr,kasIdrRate,createdAt);

@override
String toString() {
  return 'Withdrawal(txId: $txId, toAddress: $toAddress, amountKas: $amountKas, amountIdr: $amountIdr, kasIdrRate: $kasIdrRate, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$WithdrawalCopyWith<$Res> implements $WithdrawalCopyWith<$Res> {
  factory _$WithdrawalCopyWith(_Withdrawal value, $Res Function(_Withdrawal) _then) = __$WithdrawalCopyWithImpl;
@override @useResult
$Res call({
 String txId, String toAddress, double amountKas, double amountIdr, double kasIdrRate, DateTime createdAt
});




}
/// @nodoc
class __$WithdrawalCopyWithImpl<$Res>
    implements _$WithdrawalCopyWith<$Res> {
  __$WithdrawalCopyWithImpl(this._self, this._then);

  final _Withdrawal _self;
  final $Res Function(_Withdrawal) _then;

/// Create a copy of Withdrawal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? txId = null,Object? toAddress = null,Object? amountKas = null,Object? amountIdr = null,Object? kasIdrRate = null,Object? createdAt = null,}) {
  return _then(_Withdrawal(
txId: null == txId ? _self.txId : txId // ignore: cast_nullable_to_non_nullable
as String,toAddress: null == toAddress ? _self.toAddress : toAddress // ignore: cast_nullable_to_non_nullable
as String,amountKas: null == amountKas ? _self.amountKas : amountKas // ignore: cast_nullable_to_non_nullable
as double,amountIdr: null == amountIdr ? _self.amountIdr : amountIdr // ignore: cast_nullable_to_non_nullable
as double,kasIdrRate: null == kasIdrRate ? _self.kasIdrRate : kasIdrRate // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

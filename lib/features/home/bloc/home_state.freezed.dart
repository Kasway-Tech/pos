// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeState {

 HomeStatus get status; List<String> get categories; Map<String, List<Product>> get itemsByCategory; Map<String, List<Product>> get initialItemsByCategory; String get searchTerm; List<CartItem> get cartItems; TransactionStatus get transactionStatus; String? get branchId; String? get storeId;
/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeStateCopyWith<HomeState> get copyWith => _$HomeStateCopyWithImpl<HomeState>(this as HomeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.itemsByCategory, itemsByCategory)&&const DeepCollectionEquality().equals(other.initialItemsByCategory, initialItemsByCategory)&&(identical(other.searchTerm, searchTerm) || other.searchTerm == searchTerm)&&const DeepCollectionEquality().equals(other.cartItems, cartItems)&&(identical(other.transactionStatus, transactionStatus) || other.transactionStatus == transactionStatus)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.storeId, storeId) || other.storeId == storeId));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(itemsByCategory),const DeepCollectionEquality().hash(initialItemsByCategory),searchTerm,const DeepCollectionEquality().hash(cartItems),transactionStatus,branchId,storeId);

@override
String toString() {
  return 'HomeState(status: $status, categories: $categories, itemsByCategory: $itemsByCategory, initialItemsByCategory: $initialItemsByCategory, searchTerm: $searchTerm, cartItems: $cartItems, transactionStatus: $transactionStatus, branchId: $branchId, storeId: $storeId)';
}


}

/// @nodoc
abstract mixin class $HomeStateCopyWith<$Res>  {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) _then) = _$HomeStateCopyWithImpl;
@useResult
$Res call({
 HomeStatus status, List<String> categories, Map<String, List<Product>> itemsByCategory, Map<String, List<Product>> initialItemsByCategory, String searchTerm, List<CartItem> cartItems, TransactionStatus transactionStatus, String? branchId, String? storeId
});




}
/// @nodoc
class _$HomeStateCopyWithImpl<$Res>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._self, this._then);

  final HomeState _self;
  final $Res Function(HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? categories = null,Object? itemsByCategory = null,Object? initialItemsByCategory = null,Object? searchTerm = null,Object? cartItems = null,Object? transactionStatus = null,Object? branchId = freezed,Object? storeId = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as HomeStatus,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,itemsByCategory: null == itemsByCategory ? _self.itemsByCategory : itemsByCategory // ignore: cast_nullable_to_non_nullable
as Map<String, List<Product>>,initialItemsByCategory: null == initialItemsByCategory ? _self.initialItemsByCategory : initialItemsByCategory // ignore: cast_nullable_to_non_nullable
as Map<String, List<Product>>,searchTerm: null == searchTerm ? _self.searchTerm : searchTerm // ignore: cast_nullable_to_non_nullable
as String,cartItems: null == cartItems ? _self.cartItems : cartItems // ignore: cast_nullable_to_non_nullable
as List<CartItem>,transactionStatus: null == transactionStatus ? _self.transactionStatus : transactionStatus // ignore: cast_nullable_to_non_nullable
as TransactionStatus,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeState].
extension HomeStatePatterns on HomeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeState value)  $default,){
final _that = this;
switch (_that) {
case _HomeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeState value)?  $default,){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HomeStatus status,  List<String> categories,  Map<String, List<Product>> itemsByCategory,  Map<String, List<Product>> initialItemsByCategory,  String searchTerm,  List<CartItem> cartItems,  TransactionStatus transactionStatus,  String? branchId,  String? storeId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.status,_that.categories,_that.itemsByCategory,_that.initialItemsByCategory,_that.searchTerm,_that.cartItems,_that.transactionStatus,_that.branchId,_that.storeId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HomeStatus status,  List<String> categories,  Map<String, List<Product>> itemsByCategory,  Map<String, List<Product>> initialItemsByCategory,  String searchTerm,  List<CartItem> cartItems,  TransactionStatus transactionStatus,  String? branchId,  String? storeId)  $default,) {final _that = this;
switch (_that) {
case _HomeState():
return $default(_that.status,_that.categories,_that.itemsByCategory,_that.initialItemsByCategory,_that.searchTerm,_that.cartItems,_that.transactionStatus,_that.branchId,_that.storeId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HomeStatus status,  List<String> categories,  Map<String, List<Product>> itemsByCategory,  Map<String, List<Product>> initialItemsByCategory,  String searchTerm,  List<CartItem> cartItems,  TransactionStatus transactionStatus,  String? branchId,  String? storeId)?  $default,) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.status,_that.categories,_that.itemsByCategory,_that.initialItemsByCategory,_that.searchTerm,_that.cartItems,_that.transactionStatus,_that.branchId,_that.storeId);case _:
  return null;

}
}

}

/// @nodoc


class _HomeState implements HomeState {
  const _HomeState({this.status = HomeStatus.initial, final  List<String> categories = const [], final  Map<String, List<Product>> itemsByCategory = const {}, final  Map<String, List<Product>> initialItemsByCategory = const {}, this.searchTerm = '', final  List<CartItem> cartItems = const [], this.transactionStatus = TransactionStatus.idle, this.branchId, this.storeId}): _categories = categories,_itemsByCategory = itemsByCategory,_initialItemsByCategory = initialItemsByCategory,_cartItems = cartItems;
  

@override@JsonKey() final  HomeStatus status;
 final  List<String> _categories;
@override@JsonKey() List<String> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

 final  Map<String, List<Product>> _itemsByCategory;
@override@JsonKey() Map<String, List<Product>> get itemsByCategory {
  if (_itemsByCategory is EqualUnmodifiableMapView) return _itemsByCategory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_itemsByCategory);
}

 final  Map<String, List<Product>> _initialItemsByCategory;
@override@JsonKey() Map<String, List<Product>> get initialItemsByCategory {
  if (_initialItemsByCategory is EqualUnmodifiableMapView) return _initialItemsByCategory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_initialItemsByCategory);
}

@override@JsonKey() final  String searchTerm;
 final  List<CartItem> _cartItems;
@override@JsonKey() List<CartItem> get cartItems {
  if (_cartItems is EqualUnmodifiableListView) return _cartItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cartItems);
}

@override@JsonKey() final  TransactionStatus transactionStatus;
@override final  String? branchId;
@override final  String? storeId;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeStateCopyWith<_HomeState> get copyWith => __$HomeStateCopyWithImpl<_HomeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._itemsByCategory, _itemsByCategory)&&const DeepCollectionEquality().equals(other._initialItemsByCategory, _initialItemsByCategory)&&(identical(other.searchTerm, searchTerm) || other.searchTerm == searchTerm)&&const DeepCollectionEquality().equals(other._cartItems, _cartItems)&&(identical(other.transactionStatus, transactionStatus) || other.transactionStatus == transactionStatus)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.storeId, storeId) || other.storeId == storeId));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_itemsByCategory),const DeepCollectionEquality().hash(_initialItemsByCategory),searchTerm,const DeepCollectionEquality().hash(_cartItems),transactionStatus,branchId,storeId);

@override
String toString() {
  return 'HomeState(status: $status, categories: $categories, itemsByCategory: $itemsByCategory, initialItemsByCategory: $initialItemsByCategory, searchTerm: $searchTerm, cartItems: $cartItems, transactionStatus: $transactionStatus, branchId: $branchId, storeId: $storeId)';
}


}

/// @nodoc
abstract mixin class _$HomeStateCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory _$HomeStateCopyWith(_HomeState value, $Res Function(_HomeState) _then) = __$HomeStateCopyWithImpl;
@override @useResult
$Res call({
 HomeStatus status, List<String> categories, Map<String, List<Product>> itemsByCategory, Map<String, List<Product>> initialItemsByCategory, String searchTerm, List<CartItem> cartItems, TransactionStatus transactionStatus, String? branchId, String? storeId
});




}
/// @nodoc
class __$HomeStateCopyWithImpl<$Res>
    implements _$HomeStateCopyWith<$Res> {
  __$HomeStateCopyWithImpl(this._self, this._then);

  final _HomeState _self;
  final $Res Function(_HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? categories = null,Object? itemsByCategory = null,Object? initialItemsByCategory = null,Object? searchTerm = null,Object? cartItems = null,Object? transactionStatus = null,Object? branchId = freezed,Object? storeId = freezed,}) {
  return _then(_HomeState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as HomeStatus,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,itemsByCategory: null == itemsByCategory ? _self._itemsByCategory : itemsByCategory // ignore: cast_nullable_to_non_nullable
as Map<String, List<Product>>,initialItemsByCategory: null == initialItemsByCategory ? _self._initialItemsByCategory : initialItemsByCategory // ignore: cast_nullable_to_non_nullable
as Map<String, List<Product>>,searchTerm: null == searchTerm ? _self.searchTerm : searchTerm // ignore: cast_nullable_to_non_nullable
as String,cartItems: null == cartItems ? _self._cartItems : cartItems // ignore: cast_nullable_to_non_nullable
as List<CartItem>,transactionStatus: null == transactionStatus ? _self.transactionStatus : transactionStatus // ignore: cast_nullable_to_non_nullable
as TransactionStatus,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

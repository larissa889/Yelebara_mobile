// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$HomeState {
  bool get isFirstLaunch => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String get greeting => throw _privateConstructorUsedError;
  bool get isGpsEnabled => throw _privateConstructorUsedError;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HomeStateCopyWith<HomeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeStateCopyWith<$Res> {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) then) =
      _$HomeStateCopyWithImpl<$Res, HomeState>;
  @useResult
  $Res call({
    bool isFirstLaunch,
    String userName,
    String greeting,
    bool isGpsEnabled,
  });
}

/// @nodoc
class _$HomeStateCopyWithImpl<$Res, $Val extends HomeState>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isFirstLaunch = null,
    Object? userName = null,
    Object? greeting = null,
    Object? isGpsEnabled = null,
  }) {
    return _then(
      _value.copyWith(
            isFirstLaunch: null == isFirstLaunch
                ? _value.isFirstLaunch
                : isFirstLaunch // ignore: cast_nullable_to_non_nullable
                      as bool,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            greeting: null == greeting
                ? _value.greeting
                : greeting // ignore: cast_nullable_to_non_nullable
                      as String,
            isGpsEnabled: null == isGpsEnabled
                ? _value.isGpsEnabled
                : isGpsEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HomeStateImplCopyWith<$Res>
    implements $HomeStateCopyWith<$Res> {
  factory _$$HomeStateImplCopyWith(
    _$HomeStateImpl value,
    $Res Function(_$HomeStateImpl) then,
  ) = __$$HomeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isFirstLaunch,
    String userName,
    String greeting,
    bool isGpsEnabled,
  });
}

/// @nodoc
class __$$HomeStateImplCopyWithImpl<$Res>
    extends _$HomeStateCopyWithImpl<$Res, _$HomeStateImpl>
    implements _$$HomeStateImplCopyWith<$Res> {
  __$$HomeStateImplCopyWithImpl(
    _$HomeStateImpl _value,
    $Res Function(_$HomeStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isFirstLaunch = null,
    Object? userName = null,
    Object? greeting = null,
    Object? isGpsEnabled = null,
  }) {
    return _then(
      _$HomeStateImpl(
        isFirstLaunch: null == isFirstLaunch
            ? _value.isFirstLaunch
            : isFirstLaunch // ignore: cast_nullable_to_non_nullable
                  as bool,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        greeting: null == greeting
            ? _value.greeting
            : greeting // ignore: cast_nullable_to_non_nullable
                  as String,
        isGpsEnabled: null == isGpsEnabled
            ? _value.isGpsEnabled
            : isGpsEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$HomeStateImpl implements _HomeState {
  const _$HomeStateImpl({
    this.isFirstLaunch = false,
    this.userName = '',
    this.greeting = '',
    this.isGpsEnabled = false,
  });

  @override
  @JsonKey()
  final bool isFirstLaunch;
  @override
  @JsonKey()
  final String userName;
  @override
  @JsonKey()
  final String greeting;
  @override
  @JsonKey()
  final bool isGpsEnabled;

  @override
  String toString() {
    return 'HomeState(isFirstLaunch: $isFirstLaunch, userName: $userName, greeting: $greeting, isGpsEnabled: $isGpsEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeStateImpl &&
            (identical(other.isFirstLaunch, isFirstLaunch) ||
                other.isFirstLaunch == isFirstLaunch) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.greeting, greeting) ||
                other.greeting == greeting) &&
            (identical(other.isGpsEnabled, isGpsEnabled) ||
                other.isGpsEnabled == isGpsEnabled));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isFirstLaunch, userName, greeting, isGpsEnabled);

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      __$$HomeStateImplCopyWithImpl<_$HomeStateImpl>(this, _$identity);
}

abstract class _HomeState implements HomeState {
  const factory _HomeState({
    final bool isFirstLaunch,
    final String userName,
    final String greeting,
    final bool isGpsEnabled,
  }) = _$HomeStateImpl;

  @override
  bool get isFirstLaunch;
  @override
  String get userName;
  @override
  String get greeting;
  @override
  bool get isGpsEnabled;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TimerState {

 TimerStatus get status; Duration get totalElapsed; int get currentExerciseIndex; Duration get currentExerciseElapsed; Routine? get activeRoutine; DateTime? get startTime; DateTime? get lastTickTime;
/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimerStateCopyWith<TimerState> get copyWith => _$TimerStateCopyWithImpl<TimerState>(this as TimerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimerState&&(identical(other.status, status) || other.status == status)&&(identical(other.totalElapsed, totalElapsed) || other.totalElapsed == totalElapsed)&&(identical(other.currentExerciseIndex, currentExerciseIndex) || other.currentExerciseIndex == currentExerciseIndex)&&(identical(other.currentExerciseElapsed, currentExerciseElapsed) || other.currentExerciseElapsed == currentExerciseElapsed)&&(identical(other.activeRoutine, activeRoutine) || other.activeRoutine == activeRoutine)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.lastTickTime, lastTickTime) || other.lastTickTime == lastTickTime));
}


@override
int get hashCode => Object.hash(runtimeType,status,totalElapsed,currentExerciseIndex,currentExerciseElapsed,activeRoutine,startTime,lastTickTime);

@override
String toString() {
  return 'TimerState(status: $status, totalElapsed: $totalElapsed, currentExerciseIndex: $currentExerciseIndex, currentExerciseElapsed: $currentExerciseElapsed, activeRoutine: $activeRoutine, startTime: $startTime, lastTickTime: $lastTickTime)';
}


}

/// @nodoc
abstract mixin class $TimerStateCopyWith<$Res>  {
  factory $TimerStateCopyWith(TimerState value, $Res Function(TimerState) _then) = _$TimerStateCopyWithImpl;
@useResult
$Res call({
 TimerStatus status, Duration totalElapsed, int currentExerciseIndex, Duration currentExerciseElapsed, Routine? activeRoutine, DateTime? startTime, DateTime? lastTickTime
});


$RoutineCopyWith<$Res>? get activeRoutine;

}
/// @nodoc
class _$TimerStateCopyWithImpl<$Res>
    implements $TimerStateCopyWith<$Res> {
  _$TimerStateCopyWithImpl(this._self, this._then);

  final TimerState _self;
  final $Res Function(TimerState) _then;

/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? totalElapsed = null,Object? currentExerciseIndex = null,Object? currentExerciseElapsed = null,Object? activeRoutine = freezed,Object? startTime = freezed,Object? lastTickTime = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TimerStatus,totalElapsed: null == totalElapsed ? _self.totalElapsed : totalElapsed // ignore: cast_nullable_to_non_nullable
as Duration,currentExerciseIndex: null == currentExerciseIndex ? _self.currentExerciseIndex : currentExerciseIndex // ignore: cast_nullable_to_non_nullable
as int,currentExerciseElapsed: null == currentExerciseElapsed ? _self.currentExerciseElapsed : currentExerciseElapsed // ignore: cast_nullable_to_non_nullable
as Duration,activeRoutine: freezed == activeRoutine ? _self.activeRoutine : activeRoutine // ignore: cast_nullable_to_non_nullable
as Routine?,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,lastTickTime: freezed == lastTickTime ? _self.lastTickTime : lastTickTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoutineCopyWith<$Res>? get activeRoutine {
    if (_self.activeRoutine == null) {
    return null;
  }

  return $RoutineCopyWith<$Res>(_self.activeRoutine!, (value) {
    return _then(_self.copyWith(activeRoutine: value));
  });
}
}


/// Adds pattern-matching-related methods to [TimerState].
extension TimerStatePatterns on TimerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimerState value)  $default,){
final _that = this;
switch (_that) {
case _TimerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimerState value)?  $default,){
final _that = this;
switch (_that) {
case _TimerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TimerStatus status,  Duration totalElapsed,  int currentExerciseIndex,  Duration currentExerciseElapsed,  Routine? activeRoutine,  DateTime? startTime,  DateTime? lastTickTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimerState() when $default != null:
return $default(_that.status,_that.totalElapsed,_that.currentExerciseIndex,_that.currentExerciseElapsed,_that.activeRoutine,_that.startTime,_that.lastTickTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TimerStatus status,  Duration totalElapsed,  int currentExerciseIndex,  Duration currentExerciseElapsed,  Routine? activeRoutine,  DateTime? startTime,  DateTime? lastTickTime)  $default,) {final _that = this;
switch (_that) {
case _TimerState():
return $default(_that.status,_that.totalElapsed,_that.currentExerciseIndex,_that.currentExerciseElapsed,_that.activeRoutine,_that.startTime,_that.lastTickTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TimerStatus status,  Duration totalElapsed,  int currentExerciseIndex,  Duration currentExerciseElapsed,  Routine? activeRoutine,  DateTime? startTime,  DateTime? lastTickTime)?  $default,) {final _that = this;
switch (_that) {
case _TimerState() when $default != null:
return $default(_that.status,_that.totalElapsed,_that.currentExerciseIndex,_that.currentExerciseElapsed,_that.activeRoutine,_that.startTime,_that.lastTickTime);case _:
  return null;

}
}

}

/// @nodoc


class _TimerState implements TimerState {
  const _TimerState({required this.status, required this.totalElapsed, required this.currentExerciseIndex, required this.currentExerciseElapsed, this.activeRoutine, this.startTime, this.lastTickTime});
  

@override final  TimerStatus status;
@override final  Duration totalElapsed;
@override final  int currentExerciseIndex;
@override final  Duration currentExerciseElapsed;
@override final  Routine? activeRoutine;
@override final  DateTime? startTime;
@override final  DateTime? lastTickTime;

/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimerStateCopyWith<_TimerState> get copyWith => __$TimerStateCopyWithImpl<_TimerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimerState&&(identical(other.status, status) || other.status == status)&&(identical(other.totalElapsed, totalElapsed) || other.totalElapsed == totalElapsed)&&(identical(other.currentExerciseIndex, currentExerciseIndex) || other.currentExerciseIndex == currentExerciseIndex)&&(identical(other.currentExerciseElapsed, currentExerciseElapsed) || other.currentExerciseElapsed == currentExerciseElapsed)&&(identical(other.activeRoutine, activeRoutine) || other.activeRoutine == activeRoutine)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.lastTickTime, lastTickTime) || other.lastTickTime == lastTickTime));
}


@override
int get hashCode => Object.hash(runtimeType,status,totalElapsed,currentExerciseIndex,currentExerciseElapsed,activeRoutine,startTime,lastTickTime);

@override
String toString() {
  return 'TimerState(status: $status, totalElapsed: $totalElapsed, currentExerciseIndex: $currentExerciseIndex, currentExerciseElapsed: $currentExerciseElapsed, activeRoutine: $activeRoutine, startTime: $startTime, lastTickTime: $lastTickTime)';
}


}

/// @nodoc
abstract mixin class _$TimerStateCopyWith<$Res> implements $TimerStateCopyWith<$Res> {
  factory _$TimerStateCopyWith(_TimerState value, $Res Function(_TimerState) _then) = __$TimerStateCopyWithImpl;
@override @useResult
$Res call({
 TimerStatus status, Duration totalElapsed, int currentExerciseIndex, Duration currentExerciseElapsed, Routine? activeRoutine, DateTime? startTime, DateTime? lastTickTime
});


@override $RoutineCopyWith<$Res>? get activeRoutine;

}
/// @nodoc
class __$TimerStateCopyWithImpl<$Res>
    implements _$TimerStateCopyWith<$Res> {
  __$TimerStateCopyWithImpl(this._self, this._then);

  final _TimerState _self;
  final $Res Function(_TimerState) _then;

/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? totalElapsed = null,Object? currentExerciseIndex = null,Object? currentExerciseElapsed = null,Object? activeRoutine = freezed,Object? startTime = freezed,Object? lastTickTime = freezed,}) {
  return _then(_TimerState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TimerStatus,totalElapsed: null == totalElapsed ? _self.totalElapsed : totalElapsed // ignore: cast_nullable_to_non_nullable
as Duration,currentExerciseIndex: null == currentExerciseIndex ? _self.currentExerciseIndex : currentExerciseIndex // ignore: cast_nullable_to_non_nullable
as int,currentExerciseElapsed: null == currentExerciseElapsed ? _self.currentExerciseElapsed : currentExerciseElapsed // ignore: cast_nullable_to_non_nullable
as Duration,activeRoutine: freezed == activeRoutine ? _self.activeRoutine : activeRoutine // ignore: cast_nullable_to_non_nullable
as Routine?,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,lastTickTime: freezed == lastTickTime ? _self.lastTickTime : lastTickTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoutineCopyWith<$Res>? get activeRoutine {
    if (_self.activeRoutine == null) {
    return null;
  }

  return $RoutineCopyWith<$Res>(_self.activeRoutine!, (value) {
    return _then(_self.copyWith(activeRoutine: value));
  });
}
}

// dart format on

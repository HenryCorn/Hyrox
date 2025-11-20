// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_run.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkoutRun {

 Routine get routine; List<Duration> get exerciseDurations;
/// Create a copy of WorkoutRun
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutRunCopyWith<WorkoutRun> get copyWith => _$WorkoutRunCopyWithImpl<WorkoutRun>(this as WorkoutRun, _$identity);

  /// Serializes this WorkoutRun to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutRun&&(identical(other.routine, routine) || other.routine == routine)&&const DeepCollectionEquality().equals(other.exerciseDurations, exerciseDurations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,routine,const DeepCollectionEquality().hash(exerciseDurations));

@override
String toString() {
  return 'WorkoutRun(routine: $routine, exerciseDurations: $exerciseDurations)';
}


}

/// @nodoc
abstract mixin class $WorkoutRunCopyWith<$Res>  {
  factory $WorkoutRunCopyWith(WorkoutRun value, $Res Function(WorkoutRun) _then) = _$WorkoutRunCopyWithImpl;
@useResult
$Res call({
 Routine routine, List<Duration> exerciseDurations
});


$RoutineCopyWith<$Res> get routine;

}
/// @nodoc
class _$WorkoutRunCopyWithImpl<$Res>
    implements $WorkoutRunCopyWith<$Res> {
  _$WorkoutRunCopyWithImpl(this._self, this._then);

  final WorkoutRun _self;
  final $Res Function(WorkoutRun) _then;

/// Create a copy of WorkoutRun
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? routine = null,Object? exerciseDurations = null,}) {
  return _then(_self.copyWith(
routine: null == routine ? _self.routine : routine // ignore: cast_nullable_to_non_nullable
as Routine,exerciseDurations: null == exerciseDurations ? _self.exerciseDurations : exerciseDurations // ignore: cast_nullable_to_non_nullable
as List<Duration>,
  ));
}
/// Create a copy of WorkoutRun
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoutineCopyWith<$Res> get routine {
  
  return $RoutineCopyWith<$Res>(_self.routine, (value) {
    return _then(_self.copyWith(routine: value));
  });
}
}


/// Adds pattern-matching-related methods to [WorkoutRun].
extension WorkoutRunPatterns on WorkoutRun {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutRun value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutRun() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutRun value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutRun():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutRun value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutRun() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Routine routine,  List<Duration> exerciseDurations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutRun() when $default != null:
return $default(_that.routine,_that.exerciseDurations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Routine routine,  List<Duration> exerciseDurations)  $default,) {final _that = this;
switch (_that) {
case _WorkoutRun():
return $default(_that.routine,_that.exerciseDurations);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Routine routine,  List<Duration> exerciseDurations)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutRun() when $default != null:
return $default(_that.routine,_that.exerciseDurations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutRun extends WorkoutRun {
  const _WorkoutRun({required this.routine, required final  List<Duration> exerciseDurations}): _exerciseDurations = exerciseDurations,super._();
  factory _WorkoutRun.fromJson(Map<String, dynamic> json) => _$WorkoutRunFromJson(json);

@override final  Routine routine;
 final  List<Duration> _exerciseDurations;
@override List<Duration> get exerciseDurations {
  if (_exerciseDurations is EqualUnmodifiableListView) return _exerciseDurations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exerciseDurations);
}


/// Create a copy of WorkoutRun
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutRunCopyWith<_WorkoutRun> get copyWith => __$WorkoutRunCopyWithImpl<_WorkoutRun>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutRunToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutRun&&(identical(other.routine, routine) || other.routine == routine)&&const DeepCollectionEquality().equals(other._exerciseDurations, _exerciseDurations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,routine,const DeepCollectionEquality().hash(_exerciseDurations));

@override
String toString() {
  return 'WorkoutRun(routine: $routine, exerciseDurations: $exerciseDurations)';
}


}

/// @nodoc
abstract mixin class _$WorkoutRunCopyWith<$Res> implements $WorkoutRunCopyWith<$Res> {
  factory _$WorkoutRunCopyWith(_WorkoutRun value, $Res Function(_WorkoutRun) _then) = __$WorkoutRunCopyWithImpl;
@override @useResult
$Res call({
 Routine routine, List<Duration> exerciseDurations
});


@override $RoutineCopyWith<$Res> get routine;

}
/// @nodoc
class __$WorkoutRunCopyWithImpl<$Res>
    implements _$WorkoutRunCopyWith<$Res> {
  __$WorkoutRunCopyWithImpl(this._self, this._then);

  final _WorkoutRun _self;
  final $Res Function(_WorkoutRun) _then;

/// Create a copy of WorkoutRun
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? routine = null,Object? exerciseDurations = null,}) {
  return _then(_WorkoutRun(
routine: null == routine ? _self.routine : routine // ignore: cast_nullable_to_non_nullable
as Routine,exerciseDurations: null == exerciseDurations ? _self._exerciseDurations : exerciseDurations // ignore: cast_nullable_to_non_nullable
as List<Duration>,
  ));
}

/// Create a copy of WorkoutRun
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoutineCopyWith<$Res> get routine {
  
  return $RoutineCopyWith<$Res>(_self.routine, (value) {
    return _then(_self.copyWith(routine: value));
  });
}
}

// dart format on

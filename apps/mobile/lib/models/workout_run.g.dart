// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_run.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutRun _$WorkoutRunFromJson(Map<String, dynamic> json) => _WorkoutRun(
  routine: Routine.fromJson(json['routine'] as Map<String, dynamic>),
  exerciseDurations:
      (json['exerciseDurations'] as List<dynamic>)
          .map((e) => Duration(microseconds: (e as num).toInt()))
          .toList(),
);

Map<String, dynamic> _$WorkoutRunToJson(_WorkoutRun instance) =>
    <String, dynamic>{
      'routine': instance.routine,
      'exerciseDurations':
          instance.exerciseDurations.map((e) => e.inMicroseconds).toList(),
    };

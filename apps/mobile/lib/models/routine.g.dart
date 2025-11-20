// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Routine _$RoutineFromJson(Map<String, dynamic> json) => _Routine(
  name: json['name'] as String,
  exercises:
      (json['exercises'] as List<dynamic>)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$RoutineToJson(_Routine instance) => <String, dynamic>{
  'name': instance.name,
  'exercises': instance.exercises,
};

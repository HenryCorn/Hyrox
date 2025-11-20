// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Exercise _$ExerciseFromJson(Map<String, dynamic> json) => _Exercise(
  name: json['name'] as String,
  description: json['description'] as String,
  weight: (json['weight'] as num?)?.toDouble(),
  weightNote: json['weightNote'] as String?,
);

Map<String, dynamic> _$ExerciseToJson(_Exercise instance) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'weight': instance.weight,
  'weightNote': instance.weightNote,
};

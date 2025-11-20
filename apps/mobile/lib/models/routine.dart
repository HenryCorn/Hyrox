import 'package:freezed_annotation/freezed_annotation.dart';
import 'exercise.dart';

part 'routine.freezed.dart';
part 'routine.g.dart';

@freezed
abstract class Routine with _$Routine {
  const Routine._();

  const factory Routine({
    required String name,
    required List<Exercise> exercises,
  }) = _Routine;

  factory Routine.fromJson(Map<String, dynamic> json) =>
      _$RoutineFromJson(json);

  int get length => exercises.length;
}

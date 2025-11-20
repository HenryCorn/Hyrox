import 'package:freezed_annotation/freezed_annotation.dart';
import 'routine.dart';

part 'workout_run.freezed.dart';
part 'workout_run.g.dart';

@freezed
abstract class WorkoutRun with _$WorkoutRun {
  const WorkoutRun._();

  const factory WorkoutRun({
    required Routine routine,
    required List<Duration> exerciseDurations,
  }) = _WorkoutRun;

  factory WorkoutRun.fromJson(Map<String, dynamic> json) =>
      _$WorkoutRunFromJson(json);

  Duration get totalDuration => exerciseDurations.fold(
      Duration.zero, (previous, element) => previous + element);
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'subtask_model.freezed.dart';
part 'subtask_model.g.dart';

@freezed
class Subtask with _$Subtask {
  const factory Subtask({
    required String id,
    required String title,
    @Default(false) bool isCompleted,
    @Default(0) int order,
    String? taskId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? assigneeId,
  }) = _Subtask;

  factory Subtask.fromJson(Map<String, dynamic> json) => _$SubtaskFromJson(json);

  static Subtask create({
    required String title,
    String? taskId,
  }) {
    return Subtask(
      id: const Uuid().v4(),
      title: title,
      taskId: taskId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Subtask copyWithCompletion(bool isCompleted) {
    return copyWith(
      isCompleted: isCompleted,
      updatedAt: DateTime.now(),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import 'subtask_model.dart';
import 'reminder_model.dart';
import 'tag_model.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    String? description,
    @Default(false) bool isCompleted,
    @Default(0) int priority,
    DateTime? dueDate,
    DateTime? startDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? projectId,
    String? userId,
    @Default([]) List<String> tagIds,
    @Default([]) List<Subtask> subtasks,
    @Default([]) List<Reminder> reminders,
    String? parentTaskId,
    @Default(false) bool isRecurring,
    String? recurrencePattern,
    @Default(false) bool isArchived,
    @Default(false) bool isPinned,
    String? color,
    @Default(0) double estimatedHours,
    @Default(0) double actualHours,
    @Default([]) List<String> assigneeIds,
    @Default([]) List<String> collaboratorIds,
    String? categoryId,
    @Default(0) int order,
    @Default(false) bool hasAttachment,
    @Default('') String notes,
    @Default([]) List<String> attachmentUrls,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  
  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task.fromJson({...data, 'id': doc.id});
  }

  static Task create({
    required String title,
    String? description,
    String? projectId,
    String? userId,
    List<String>? tagIds,
    String? color,
  }) {
    return Task(
      id: const Uuid().v4(),
      title: title,
      description: description,
      projectId: projectId,
      userId: userId,
      tagIds: tagIds ?? [],
      color: color,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Task copyWithCompletion(bool isCompleted) {
    return copyWith(
      isCompleted: isCompleted,
      updatedAt: DateTime.now(),
    );
  }

  Task copyWithPriority(int priority) {
    return copyWith(
      priority: priority,
      updatedAt: DateTime.now(),
    );
  }

  double get progress {
    if (subtasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    final completed = subtasks.where((s) => s.isCompleted).length;
    return completed / subtasks.length;
  }

  bool get hasReminders => reminders.isNotEmpty;
  bool get hasSubtasks => subtasks.isNotEmpty;
  
  DateTime? get nextReminder {
    final now = DateTime.now();
    final futureReminders = reminders
        .where((r) => r.dateTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return futureReminders.isNotEmpty ? futureReminders.first.dateTime : null;
  }
}

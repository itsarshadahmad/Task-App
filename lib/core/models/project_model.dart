import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'project_model.freezed.dart';
part 'project_model.g.dart';

@freezed
class Project with _$Project {
  const factory Project({
    required String id,
    required String name,
    String? description,
    required String color,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    @Default([]) List<String> memberIds,
    @Default(false) bool isArchived,
    @Default(false) bool isPinned,
    @Default(0) int order,
    String? parentProjectId,
    @Default(false) bool isShared,
    @Default([]) List<String> sharedWith,
    @Default('') String thumbnailUrl,
    @Default(0) int taskCount,
    @Default(0) int completedTaskCount,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);
  
  factory Project.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Project.fromJson({...data, 'id': doc.id});
  }

  static Project create({
    required String name,
    required String color,
    String? description,
    String? icon,
    String? userId,
  }) {
    return Project(
      id: const Uuid().v4(),
      name: name,
      description: description,
      color: color,
      icon: icon,
      userId: userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  double get progress {
    if (taskCount == 0) return 0.0;
    return completedTaskCount / taskCount;
  }

  bool get isComplete => taskCount > 0 && completedTaskCount == taskCount;
}

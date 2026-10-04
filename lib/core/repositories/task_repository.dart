import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task_model.dart';
import '../constants/app_constants.dart';
import 'base_repository.dart';

class TaskRepository extends BaseRepository<Task> {
  TaskRepository({
    required super.userId,
    super.ref,
  }) : super(
          collectionName: AppConstants.collectionTasks,
          boxName: AppConstants.hiveTasksBox,
        );

  @override
  Task fromFirestore(DocumentSnapshot doc) => Task.fromFirestore(doc);

  @override
  Task fromHive(dynamic data) => Task.fromJson(data as Map<String, dynamic>);

  @override
  Map<String, dynamic> toJson(Task item) => item.toJson();

  Future<List<Task>> getTasksByProject(String projectId) async {
    final query = FirebaseFirestore.instance
        .collection(collectionName)
        .where('userId', isEqualTo: userId)
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true);

    return await _getFromFirebase(query);
  }

  Future<List<Task>> getTasksByTag(String tagId) async {
    final query = FirebaseFirestore.instance
        .collection(collectionName)
        .where('userId', isEqualTo: userId)
        .where('tagIds', arrayContains: tagId)
        .orderBy('createdAt', descending: true);

    return await _getFromFirebase(query);
  }

  Future<List<Task>> getTasksByCategory(String categoryId) async {
    final query = FirebaseFirestore.instance
        .collection(collectionName)
        .where('userId', isEqualTo: userId)
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('createdAt', descending: true);

    return await _getFromFirebase(query);
  }

  Future<List<Task>> getTasksByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day + 1);

    final query = FirebaseFirestore.instance
        .collection(collectionName)
        .where('userId', isEqualTo: userId)
        .where('dueDate', isGreaterThanOrEqualTo: startOfDay)
        .where('dueDate', isLessThan: endOfDay)
        .orderBy('dueDate', descending: false);

    return await _getFromFirebase(query);
  }

  Future<List<Task>> getUpcomingTasks() async {
    final now = DateTime.now();
    final query = FirebaseFirestore.instance
        .collection(collectionName)
        .where('userId', isEqualTo: userId)
        .where('dueDate', isGreaterThan: now)
        .where('isCompleted', isEqualTo: false)
        .orderBy('dueDate', descending: false);

    return await _getFromFirebase(query);
  }

  Future<List<Task>> getOverdueTasks() async {
    final now = DateTime.now();
    final query = FirebaseFirestore.instance
        .collection(collectionName)
        .where('userId', isEqualTo: userId)
        .where('dueDate', isLessThan: now)
        .where('isCompleted', isEqualTo: false)
        .orderBy('dueDate', descending: false);

    return await _getFromFirebase(query);
  }

  Future<List<Task>> getTodayTasks() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day + 1);

    final query = FirebaseFirestore.instance
        .collection(collectionName)
        .where('userId', isEqualTo: userId)
        .where('dueDate', isGreaterThanOrEqualTo: startOfDay)
        .where('dueDate', isLessThan: endOfDay)
        .orderBy('priority', descending: true)
        .orderBy('dueDate', descending: false);

    return await _getFromFirebase(query);
  }

  Future<List<Task>> getPinnedTasks() async {
    final query = FirebaseFirestore.instance
        .collection(collectionName)
        .where('userId', isEqualTo: userId)
        .where('isPinned', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    return await _getFromFirebase(query);
  }

  Future<List<Task>> getArchivedTasks() async {
    final query = FirebaseFirestore.instance
        .collection(collectionName)
        .where('userId', isEqualTo: userId)
        .where('isArchived', isEqualTo: true)
        .orderBy('updatedAt', descending: true);

    return await _getFromFirebase(query);
  }

  Future<List<Task>> searchTasks(String query) async {
    final firebaseTasks = await _getFromFirebase(
      FirebaseFirestore.instance
          .collection(collectionName)
          .where('userId', isEqualTo: userId),
    );

    return firebaseTasks
        .where((task) => 
          task.title.toLowerCase().contains(query.toLowerCase()) ||
          (task.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
        )
        .toList();
  }

  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    final task = await getById(taskId);
    if (task != null) {
      final updatedTask = task.copyWithCompletion(isCompleted);
      await update(updatedTask);
    }
  }

  Future<void> updateTaskPriority(String taskId, int priority) async {
    final task = await getById(taskId);
    if (task != null) {
      final updatedTask = task.copyWithPriority(priority);
      await update(updatedTask);
    }
  }

  Future<void> pinTask(String taskId, bool isPinned) async {
    final task = await getById(taskId);
    if (task != null) {
      await update(task.copyWith(isPinned: isPinned));
    }
  }

  Future<void> archiveTask(String taskId, bool isArchived) async {
    final task = await getById(taskId);
    if (task != null) {
      await update(task.copyWith(isArchived: isArchived));
    }
  }
}

final taskRepositoryProvider = Provider.family<TaskRepository, String>((ref, userId) {
  return TaskRepository(
    userId: userId,
    ref: ref,
  );
});

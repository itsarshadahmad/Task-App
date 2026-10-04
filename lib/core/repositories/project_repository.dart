import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/project_model.dart';
import '../constants/app_constants.dart';
import 'base_repository.dart';

class ProjectRepository extends BaseRepository<Project> {
  ProjectRepository({
    required super.userId,
    super.ref,
  }) : super(
          collectionName: AppConstants.collectionProjects,
          boxName: AppConstants.hiveProjectsBox,
        );

  @override
  Project fromFirestore(DocumentSnapshot doc) => Project.fromFirestore(doc);

  @override
  Project fromHive(dynamic data) => Project.fromJson(data as Map<String, dynamic>);

  @override
  Map<String, dynamic> toJson(Project item) => item.toJson();

  Future<List<Project>> getRootProjects() async {
    final query = FirebaseFirestore.instance
        .collection(collectionName)
        .where('userId', isEqualTo: userId)
        .where('parentProjectId', isNull: true)
        .orderBy('order', descending: false);

    return await _getFromFirebase(query);
  }

  Future<List<Project>> getSubProjects(String parentProjectId) async {
    final query = FirebaseFirestore.instance
        .collection(collectionName)
        .where('userId', isEqualTo: userId)
        .where('parentProjectId', isEqualTo: parentProjectId)
        .orderBy('order', descending: false);

    return await _getFromFirebase(query);
  }

  Future<List<Project>> getPinnedProjects() async {
    final query = FirebaseFirestore.instance
        .collection(collectionName)
        .where('userId', isEqualTo: userId)
        .where('isPinned', isEqualTo: true)
        .orderBy('order', descending: false);

    return await _getFromFirebase(query);
  }

  Future<void> updateProjectColor(String projectId, String color) async {
    final project = await getById(projectId);
    if (project != null) {
      await update(project.copyWith(color: color));
    }
  }

  Future<void> toggleProjectPin(String projectId, bool isPinned) async {
    final project = await getById(projectId);
    if (project != null) {
      await update(project.copyWith(isPinned: isPinned));
    }
  }

  Future<void> reorderProjects(List<String> projectIds) async {
    for (int i = 0; i < projectIds.length; i++) {
      final project = await getById(projectIds[i]);
      if (project != null) {
        await update(project.copyWith(order: i));
      }
    }
  }
}

final projectRepositoryProvider = Provider.family<ProjectRepository, String>((ref, userId) {
  return ProjectRepository(
    userId: userId,
    ref: ref,
  );
});

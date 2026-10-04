import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/folder_model.dart';
import '../constants/app_constants.dart';
import 'base_repository.dart';

class FolderRepository extends BaseRepository<Folder> {
  FolderRepository({
    required super.userId,
    super.ref,
  }) : super(
          collectionName: AppConstants.collectionFolders,
          boxName: AppConstants.hiveFoldersBox,
        );

  @override
  Folder fromFirestore(DocumentSnapshot doc) => Folder.fromFirestore(doc);

  @override
  Folder fromHive(dynamic data) => Folder.fromJson(data as Map<String, dynamic>);

  @override
  Map<String, dynamic> toJson(Folder item) => item.toJson();

  Future<List<Folder>> getRootFolders() async {
    final query = FirebaseFirestore.instance
        .collection(collectionName)
        .where('userId', isEqualTo: userId)
        .where('parentFolderId', isNull: true)
        .orderBy('order', descending: false);

    return await _getFromFirebase(query);
  }

  Future<List<Folder>> getSubFolders(String parentFolderId) async {
    final query = FirebaseFirestore.instance
        .collection(collectionName)
        .where('userId', isEqualTo: userId)
        .where('parentFolderId', isEqualTo: parentFolderId)
        .orderBy('order', descending: false);

    return await _getFromFirebase(query);
  }

  Future<void> updateFolderColor(String folderId, String color) async {
    final folder = await getById(folderId);
    if (folder != null) {
      await update(folder.copyWith(color: color));
    }
  }

  Future<void> addProjectToFolder(String folderId, String projectId) async {
    final folder = await getById(folderId);
    if (folder != null) {
      final updatedProjectIds = List<String>.from(folder.projectIds);
      if (!updatedProjectIds.contains(projectId)) {
        updatedProjectIds.add(projectId);
      }
      await update(folder.copyWith(projectIds: updatedProjectIds));
    }
  }

  Future<void> removeProjectFromFolder(String folderId, String projectId) async {
    final folder = await getById(folderId);
    if (folder != null) {
      final updatedProjectIds = List<String>.from(folder.projectIds);
      updatedProjectIds.remove(projectId);
      await update(folder.copyWith(projectIds: updatedProjectIds));
    }
  }
}

final folderRepositoryProvider = Provider.family<FolderRepository, String>((ref, userId) {
  return FolderRepository(
    userId: userId,
    ref: ref,
  );
});

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'folder_model.freezed.dart';
part 'folder_model.g.dart';

@freezed
class Folder with _$Folder {
  const factory Folder({
    required String id,
    required String name,
    required String color,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    String? parentFolderId,
    @Default(0) int order,
    @Default(false) bool isPinned,
    @Default(false) bool isArchived,
    @Default([]) List<String> projectIds,
    @Default([]) List<String> taskIds,
    @Default(false) bool isShared,
    @Default([]) List<String> sharedWith,
  }) = _Folder;

  factory Folder.fromJson(Map<String, dynamic> json) => _$FolderFromJson(json);
  
  factory Folder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Folder.fromJson({...data, 'id': doc.id});
  }

  static Folder create({
    required String name,
    required String color,
    String? description,
    String? userId,
    String? parentFolderId,
  }) {
    return Folder(
      id: const Uuid().v4(),
      name: name,
      color: color,
      description: description,
      userId: userId,
      parentFolderId: parentFolderId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

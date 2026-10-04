import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tag_model.dart';
import '../constants/app_constants.dart';
import 'base_repository.dart';

class TagRepository extends BaseRepository<Tag> {
  TagRepository({
    required super.userId,
    super.ref,
  }) : super(
          collectionName: AppConstants.collectionTags,
          boxName: AppConstants.hiveTagsBox,
        );

  @override
  Tag fromFirestore(DocumentSnapshot doc) => Tag.fromFirestore(doc);

  @override
  Tag fromHive(dynamic data) => Tag.fromJson(data as Map<String, dynamic>);

  @override
  Map<String, dynamic> toJson(Tag item) => item.toJson();

  Future<List<Tag>> getPinnedTags() async {
    final query = FirebaseFirestore.instance
        .collection(collectionName)
        .where('userId', isEqualTo: userId)
        .where('isPinned', isEqualTo: true)
        .orderBy('order', descending: false);

    return await _getFromFirebase(query);
  }

  Future<void> updateTagColor(String tagId, String color) async {
    final tag = await getById(tagId);
    if (tag != null) {
      await update(tag.copyWith(color: color));
    }
  }

  Future<void> toggleTagPin(String tagId, bool isPinned) async {
    final tag = await getById(tagId);
    if (tag != null) {
      await update(tag.copyWith(isPinned: isPinned));
    }
  }

  Future<void> incrementUsage(String tagId) async {
    final tag = await getById(tagId);
    if (tag != null) {
      await update(tag.copyWith(usageCount: tag.usageCount + 1));
    }
  }
}

final tagRepositoryProvider = Provider.family<TagRepository, String>((ref, userId) {
  return TagRepository(
    userId: userId,
    ref: ref,
  );
});

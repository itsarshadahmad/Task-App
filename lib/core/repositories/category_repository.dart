import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category_model.dart';
import '../constants/app_constants.dart';
import 'base_repository.dart';

class CategoryRepository extends BaseRepository<Category> {
  CategoryRepository({
    required super.userId,
    super.ref,
  }) : super(
          collectionName: AppConstants.collectionCategories,
          boxName: AppConstants.hiveCategoriesBox,
        );

  @override
  Category fromFirestore(DocumentSnapshot doc) => Category.fromFirestore(doc);

  @override
  Category fromHive(dynamic data) => Category.fromJson(data as Map<String, dynamic>);

  @override
  Map<String, dynamic> toJson(Category item) => item.toJson();

  Future<List<Category>> getRootCategories() async {
    final query = FirebaseFirestore.instance
        .collection(collectionName)
        .where('userId', isEqualTo: userId)
        .where('parentCategoryId', isNull: true)
        .orderBy('order', descending: false);

    return await _getFromFirebase(query);
  }

  Future<List<Category>> getSubCategories(String parentCategoryId) async {
    final query = FirebaseFirestore.instance
        .collection(collectionName)
        .where('userId', isEqualTo: userId)
        .where('parentCategoryId', isEqualTo: parentCategoryId)
        .orderBy('order', descending: false);

    return await _getFromFirebase(query);
  }

  Future<void> updateCategoryColor(String categoryId, String color) async {
    final category = await getById(categoryId);
    if (category != null) {
      await update(category.copyWith(color: color));
    }
  }
}

final categoryRepositoryProvider = Provider.family<CategoryRepository, String>((ref, userId) {
  return CategoryRepository(
    userId: userId,
    ref: ref,
  );
});

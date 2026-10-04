import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'category_model.freezed.dart';
part 'category_model.g.dart';

@freezed
class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    String? description,
    required String color,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    @Default(0) int order,
    @Default(false) bool isPinned,
    @Default(false) bool isArchived,
    String? parentCategoryId,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  
  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Category.fromJson({...data, 'id': doc.id});
  }

  static Category create({
    required String name,
    required String color,
    String? description,
    String? icon,
    String? userId,
  }) {
    return Category(
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
}

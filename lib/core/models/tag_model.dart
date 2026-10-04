import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'tag_model.freezed.dart';
part 'tag_model.g.dart';

@freezed
class Tag with _$Tag {
  const factory Tag({
    required String id,
    required String name,
    required String color,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    @Default(0) int usageCount,
    @Default(false) bool isPinned,
    @Default(0) int order,
  }) = _Tag;

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
  
  factory Tag.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Tag.fromJson({...data, 'id': doc.id});
  }

  static Tag create({
    required String name,
    required String color,
    String? description,
    String? userId,
  }) {
    return Tag(
      id: const Uuid().v4(),
      name: name,
      color: color,
      description: description,
      userId: userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

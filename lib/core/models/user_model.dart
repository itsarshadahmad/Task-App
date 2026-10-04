import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    @Default('user') String role,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    @Default(true) bool isActive,
    @Default(false) bool isVerified,
    String? preferredTheme,
    String? preferredLanguage,
    @Default({}) Map<String, dynamic> preferences,
    @Default([]) List<String> notificationPreferences,
    String? timezone,
    @Default(0) int taskCount,
    @Default(0) int completedTaskCount,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson({...data, 'id': doc.id});
  }

  bool get isAdmin => role == 'admin';
  bool get isManager => role == 'admin' || role == 'manager';
}

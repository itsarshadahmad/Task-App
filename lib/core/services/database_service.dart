// Database Service - Abstract layer for both Supabase and Firebase
// This allows switching between backends easily

import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class DatabaseService {
  Future<void> initialize();
  
  // Auth operations
  Future<void> signInWithEmail(String email, String password);
  Future<void> signUpWithEmail(String email, String password);
  Future<void> signOut();
  String? get currentUserId;
  Stream<bool> get authStateStream;
  
  // CRUD operations
  Future<List<Map<String, dynamic>>> fetchData(String table, {Map<String, dynamic>? filters});
  Future<Map<String, dynamic>> insertData(String table, Map<String, dynamic> data);
  Future<Map<String, dynamic>> updateData(String table, Map<String, dynamic> data, String id);
  Future<void> deleteData(String table, String id);
  
  // Real-time subscriptions
  Stream<List<Map<String, dynamic>>> subscribeToTable(String table, {Map<String, dynamic>? filters});
  
  // Batch operations
  Future<List<Map<String, dynamic>>> batchInsert(String table, List<Map<String, dynamic>> data);
  Future<void> batchUpdate(String table, List<Map<String, dynamic>> updates);
  Future<void> batchDelete(String table, List<String> ids);
}

// Factory to create the appropriate database service
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  throw Exception('DatabaseService must be initialized');
});

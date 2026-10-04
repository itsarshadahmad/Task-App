import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupabaseService {
  final SupabaseClient _supabase;

  SupabaseService(this._supabase);

  SupabaseClient get client => _supabase;

  /// Initialize Supabase
  static Future<SupabaseService> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    final supabase = Supabase.instance.client;
    return SupabaseService(supabase);
  }

  /// Auth operations
  Future<void> signInWithEmail(String email, String password) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUpWithEmail(String email, String password) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Get auth state changes stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Database operations
  Future<List<Map<String, dynamic>>> fetchData(String table) async {
    final response = await _supabase.from(table).select();
    return response;
  }

  Future<Map<String, dynamic>> insertData(
    String table,
    Map<String, dynamic> data,
  ) async {
    final response = await _supabase.from(table).insert(data).select();
    return response.first;
  }

  Future<Map<String, dynamic>> updateData(
    String table,
    Map<String, dynamic> data,
    String id,
  ) async {
    final response = await _supabase
        .from(table)
        .update(data)
        .eq('id', id)
        .select();
    return response.first;
  }

  Future<void> deleteData(String table, String id) async {
    await _supabase.from(table).delete().eq('id', id);
  }

  /// Real-time subscriptions
  Stream<List<Map<String, dynamic>>> subscribeToTable(String table) {
    return _supabase
        .from(table)
        .stream(primaryKey: ['id'])
        .map((data) => data.map((e) => e as Map<String, dynamic>).toList());
  }

  /// Storage operations
  Future<String> uploadFile(String path, Uint8List file) async {
    final response = await _supabase.storage
        .from('attachments')
        .upload(path, file);
    return response;
  }

  Future<String> getFileUrl(String path) async {
    return _supabase.storage
        .from('attachments')
        .getPublicUrl(path);
  }
}

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  throw Exception('SupabaseService must be initialized');
});

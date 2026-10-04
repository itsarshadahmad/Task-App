import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user_model.dart';
import '../../../core/services/mock_database_service.dart';

class AuthState {
  final UserModel? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ProviderRef ref;
  final MockDatabaseService _mockDb;

  AuthNotifier({required this.ref}) : 
    _mockDb = ref.read(mockDatabaseServiceProvider),
    super(const AuthState()) {
    // In mock mode, we're always authenticated with a mock user
    _loadMockUser();
  }

  Future<void> _loadMockUser() async {
    try {
      // Create a mock user
      final userModel = UserModel(
        id: _mockDb.currentUserId ?? 'mock_user_id',
        email: 'user@example.com',
        displayName: 'Test User',
        photoUrl: null,
        phoneNumber: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        role: 'user',
      );
      
      state = state.copyWith(
        user: userModel,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load user: $e',
        isLoading: false,
      );
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // In mock mode, just set a user
      await _mockDb.signInWithEmail(email, password);
      await _loadMockUser();
    } catch (e) {
      state = state.copyWith(
        error: 'Sign in failed: $e',
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> signUpWithEmail(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _mockDb.signUpWithEmail(email, password);
      await _loadMockUser();
    } catch (e) {
      state = state.copyWith(
        error: 'Sign up failed: $e',
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // In mock mode, just load mock user
      await _loadMockUser();
    } catch (e) {
      state = state.copyWith(
        error: 'Google sign in failed: $e',
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _mockDb.signOut();
      state = state.copyWith(
        user: null,
        isAuthenticated: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Sign out failed: $e',
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _auth.sendPasswordResetEmail(email: email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Password reset failed: $e',
        isLoading: false,
      );
      rethrow;
    }
  }

  UserModel? get currentUser => state.user;
  bool get isAuthenticated => state.isAuthenticated;
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref: ref);
});

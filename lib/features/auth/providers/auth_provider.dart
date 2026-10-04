import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../core/models/user_model.dart';
import '../../../core/services/encryption_service.dart';

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
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final ProviderRef ref;

  AuthNotifier({required this.ref}) : super(const AuthState()) {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _loadUser(user);
      } else {
        state = state.copyWith(
          user: null,
          isAuthenticated: false,
        );
      }
    });
  }

  Future<void> _loadUser(firebase_auth.User user) async {
    try {
      // Load user from Firestore
      // For now, create a basic user model
      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
        phoneNumber: user.phoneNumber,
        createdAt: user.metadata.creationTime,
        updatedAt: user.metadata.lastSignInTime,
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
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
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
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await userCredential.user?.updateDisplayName(name);
      
      // Create user in Firestore
      // Will be handled by Firestore triggers or separate call
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
      // Google sign in implementation
      // final googleUser = await GoogleSignIn().signIn();
      // final googleAuth = await googleUser?.authentication;
      // final credential = firebase_auth.GoogleAuthProvider.credential(
      //   accessToken: googleAuth?.accessToken,
      //   idToken: googleAuth?.idToken,
      // );
      // await _auth.signInWithCredential(credential);
      
      throw Exception('Google sign in not implemented yet');
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
      await _auth.signOut();
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

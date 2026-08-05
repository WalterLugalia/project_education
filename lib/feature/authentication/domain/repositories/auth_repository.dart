import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signIn({required String email, required String password});

  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<void> resendVerificationEmail({required String email});

  Future<void> sendPasswordResetEmail({required String email});

  Future<void> updatePassword({required String newPassword});

  /// Returns the locally cached user without a network call (offline-safe).
  UserEntity? getCachedUser();

  /// Forces a fresh fetch from Supabase to get up-to-date verification status.
  Future<UserEntity> refreshUser();

  Future<void> signOut();
}
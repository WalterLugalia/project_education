import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn({required String email, required String password});

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<void> resendVerificationEmail({required String email});

  Future<void> sendPasswordResetEmail({required String email});

  Future<void> updatePassword({required String newPassword});

  UserModel? getCachedUser();

  Future<UserModel> refreshUser();

  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  static const String _redirectUrl = 'https://learnshelf-auth.kifwolow.workers.dev';

  @override
  Future<UserModel> signIn({required String email, required String password}) async {
    final response = await supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('Sign in failed. Please check your credentials.');
    }
    return UserModel.fromSupabaseUser(user);
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final response = await supabaseClient.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: _redirectUrl,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'display_name': '$firstName $lastName',
      },
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('Sign up failed. Please try again.');
    }
    return UserModel.fromSupabaseUser(user);
  }

  @override
  Future<void> resendVerificationEmail({required String email}) async {
    await supabaseClient.auth.resend(
      type: OtpType.signup,
      email: email,
      emailRedirectTo: _redirectUrl,
    );
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    await supabaseClient.auth.resetPasswordForEmail(
      email,
      redirectTo: _redirectUrl,
    );
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {
    await supabaseClient.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  @override
UserModel? getCachedUser() {
  final user = supabaseClient.auth.currentUser;
  if (user == null) return null;
  return UserModel.fromSupabaseUser(user); // user is now smart-cast to non-null — this line is already correct in your file
}

@override
Future<UserModel> refreshUser() async {
  final response = await supabaseClient.auth.getUser();
  final user = response.user;
  if (user == null) {
    throw const AuthException('Unable to refresh user — no active session.');
  }
  return UserModel.fromSupabaseUser(user);
}

  @override
  Future<void> signOut() async {
    await supabaseClient.auth.signOut();
  }
}
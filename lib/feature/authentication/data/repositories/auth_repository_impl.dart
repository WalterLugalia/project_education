import 'package:project_education/feature/authentication/data/datasource/auth_remote_data_source.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> signIn({required String email, required String password}) {
    return remoteDataSource.signIn(email: email, password: password);
  }

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) {
    return remoteDataSource.signUp(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
  }

  @override
  Future<void> resendVerificationEmail({required String email}) {
    return remoteDataSource.resendVerificationEmail(email: email);
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return remoteDataSource.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> updatePassword({required String newPassword}) {
    return remoteDataSource.updatePassword(newPassword: newPassword);
  }

  @override
  UserEntity? getCachedUser() => remoteDataSource.getCachedUser();

  @override
  Future<UserEntity> refreshUser() => remoteDataSource.refreshUser();

  @override
  Future<void> signOut() => remoteDataSource.signOut();
}
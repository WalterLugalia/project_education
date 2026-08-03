import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  const SignUpUseCase(this.repository);

  Future<UserEntity> call({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) {
    return repository.signUp(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
  }
}
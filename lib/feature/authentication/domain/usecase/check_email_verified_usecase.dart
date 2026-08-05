import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class CheckEmailVerifiedUseCase {
  final AuthRepository repository;

  const CheckEmailVerifiedUseCase(this.repository);

  Future<UserEntity> call() {
    return repository.refreshUser();
  }
}
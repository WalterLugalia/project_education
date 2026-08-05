import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetCachedUserUseCase {
  final AuthRepository repository;

  const GetCachedUserUseCase(this.repository);

  UserEntity? call() => repository.getCachedUser();
}
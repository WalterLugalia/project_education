// check_username_available_usecase.dart

import 'package:project_education/feature/profile/data/repositories/profile_repository.dart';

class CheckUsernameAvailableUseCase {
  final ProfileRepository repository;
  const CheckUsernameAvailableUseCase(this.repository);
  Future<bool> call(String username) => repository.isUsernameAvailable(username);
}
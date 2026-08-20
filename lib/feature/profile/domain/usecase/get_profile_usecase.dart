// get_profile_usecase.dart
import 'package:project_education/feature/profile/data/repositories/profile_repository.dart';

import '../entities/profile_entity.dart';

class GetProfileUseCase {
  final ProfileRepository repository;
  const GetProfileUseCase(this.repository);
  Future<ProfileEntity?> call() => repository.getProfile();
}
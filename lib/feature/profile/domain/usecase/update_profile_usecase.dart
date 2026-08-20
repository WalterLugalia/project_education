// update_profile_usecase.dart

import 'package:project_education/feature/profile/data/repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;
  const UpdateProfileUseCase(this.repository);
  Future<void> call({String? fullName, String? username, String? bio, String? website, String? location}) =>
      repository.updateProfile(fullName: fullName, username: username, bio: bio, website: website, location: location);
}
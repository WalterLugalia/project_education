// upload_avatar_usecase.dart

import 'package:project_education/feature/profile/data/repositories/profile_repository.dart';

class UploadAvatarUseCase {
  final ProfileRepository repository;
  const UploadAvatarUseCase(this.repository);
  Future<String> call(String filePath) => repository.uploadAvatar(filePath);
}
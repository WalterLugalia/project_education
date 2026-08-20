// log_resource_view_usecase.dart

import 'package:project_education/feature/profile/data/repositories/profile_repository.dart';

class LogResourceViewUseCase {
  final ProfileRepository repository;
  const LogResourceViewUseCase(this.repository);
  Future<void> call(String resourceId) => repository.logResourceView(resourceId);
}

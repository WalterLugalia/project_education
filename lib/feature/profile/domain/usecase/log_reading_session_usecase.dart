import 'package:project_education/feature/profile/data/repositories/profile_repository.dart';

class LogReadingSessionUseCase {
  final ProfileRepository repository;
  const LogReadingSessionUseCase(this.repository);
  Future<void> call(String resourceId, int seconds) => repository.logReadingSession(resourceId, seconds);
}
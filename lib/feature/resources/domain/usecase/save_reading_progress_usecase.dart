import 'package:project_education/feature/resources/domain/repositories/resource_repository.dart';

class SaveReadingProgressUseCase {
  final ResourceRepository repository;
  const SaveReadingProgressUseCase(this.repository);
  Future<void> call(String resourceId, double percent) =>
      repository.saveReadingProgress(resourceId, percent);
}
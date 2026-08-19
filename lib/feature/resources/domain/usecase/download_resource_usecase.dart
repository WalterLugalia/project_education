// lib/feature/resources/domain/usecase/download_resource_usecase.dart
import '../repositories/resource_repository.dart';

class DownloadResourceUseCase {
  final ResourceRepository repository;
  const DownloadResourceUseCase(this.repository);
  Future<void> call(String resourceId) => repository.markDownloaded(resourceId);
}
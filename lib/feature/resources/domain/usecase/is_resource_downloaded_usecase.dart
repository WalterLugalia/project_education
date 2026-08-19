// lib/feature/resources/domain/usecase/is_resource_downloaded_usecase.dart
import '../repositories/resource_repository.dart';

class IsResourceDownloadedUseCase {
  final ResourceRepository repository;
  const IsResourceDownloadedUseCase(this.repository);
  Future<bool> call(String resourceId) => repository.isDownloaded(resourceId);
}
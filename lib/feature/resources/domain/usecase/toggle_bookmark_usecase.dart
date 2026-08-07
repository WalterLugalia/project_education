import '../repositories/resource_repository.dart';

class ToggleBookmarkUseCase {
  final ResourceRepository repository;

  const ToggleBookmarkUseCase(this.repository);

  Future<void> call(String resourceId) => repository.toggleBookmark(resourceId);
}
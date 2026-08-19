// lib/feature/resources/domain/usecase/get_related_resources_usecase.dart
import '../entities/resource_entity.dart';
import '../repositories/resource_repository.dart';

class GetRelatedResourcesUseCase {
  final ResourceRepository repository;
  const GetRelatedResourcesUseCase(this.repository);
  Future<List<ResourceEntity>> call(String resourceId, String? categoryId) =>
      repository.getRelatedResources(resourceId, categoryId);
}
// lib/feature/resources/domain/usecase/get_resource_details_usecase.dart
import '../entities/resource_entity.dart';
import '../repositories/resource_repository.dart';

class GetResourceDetailsUseCase {
  final ResourceRepository repository;
  const GetResourceDetailsUseCase(this.repository);
  Future<ResourceEntity?> call(String resourceId) => repository.getResourceById(resourceId);
}
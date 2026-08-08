import '../entities/resource_entity.dart';
import '../repositories/resource_repository.dart';

class SearchResourcesUseCase {
  final ResourceRepository repository;
  const SearchResourcesUseCase(this.repository);
  Future<List<ResourceEntity>> call(String query) => repository.searchResources(query);
}
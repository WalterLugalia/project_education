import '../entities/resource_entity.dart';
import '../repositories/resource_repository.dart';

class GetHomeFeedUseCase {
  final ResourceRepository repository;

  const GetHomeFeedUseCase(this.repository);

  Future<List<ResourceEntity>> call() => repository.getHomeFeed();
}
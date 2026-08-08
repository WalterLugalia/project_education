import '../entities/resource_entity.dart';
import '../repositories/resource_repository.dart';

class GetTrendingBooksUseCase {
  final ResourceRepository repository;
  const GetTrendingBooksUseCase(this.repository);
  Future<List<ResourceEntity>> call() => repository.getTrendingBooks();
}
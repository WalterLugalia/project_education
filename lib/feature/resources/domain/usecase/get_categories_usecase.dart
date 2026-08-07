import '../entities/category_entity.dart';
import '../repositories/resource_repository.dart';

class GetCategoriesUseCase {
  final ResourceRepository repository;

  const GetCategoriesUseCase(this.repository);

  Future<List<CategoryEntity>> call() => repository.getCategories();
}
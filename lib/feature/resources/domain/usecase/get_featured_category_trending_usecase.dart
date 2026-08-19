// lib/feature/resources/domain/usecase/get_featured_category_trending_usecase.dart
import '../entities/category_entity.dart';
import '../entities/resource_entity.dart';
import '../repositories/resource_repository.dart';

class GetFeaturedCategoryTrendingUseCase {
  final ResourceRepository repository;
  const GetFeaturedCategoryTrendingUseCase(this.repository);
  Future<(CategoryEntity, List<ResourceEntity>)?> call() =>
      repository.getFeaturedCategoryTrending();
}
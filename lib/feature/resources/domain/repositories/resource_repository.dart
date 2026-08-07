import '../entities/resource_entity.dart';
import '../entities/category_entity.dart';

abstract class ResourceRepository {
  /// Home screen sections: continue reading, trending, recommended, etc.
  Future<List<ResourceEntity>> getHomeFeed();

  Future<List<CategoryEntity>> getCategories();

  Future<List<ResourceEntity>> getResourcesByCategory(String categoryId);

  /// Searches local Supabase catalog first; caller decides whether to
  /// fall back to external APIs if results are too few.
  Future<List<ResourceEntity>> searchResources(String query);

  Future<List<ResourceEntity>> getBookmarkedResources();

  Future<void> toggleBookmark(String resourceId);

  Future<bool> isBookmarked(String resourceId);
}
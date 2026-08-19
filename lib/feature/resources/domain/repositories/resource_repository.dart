import '../entities/resource_entity.dart';
import '../entities/category_entity.dart';
import '../entities/continue_reading_item.dart';

abstract class ResourceRepository {
  Future<List<ResourceEntity>> getTrendingBooks();
  Future<List<ContinueReadingItem>> getContinueReading();
  Future<List<CategoryEntity>> getCategories();
  Future<List<ResourceEntity>> getResourcesByCategory(String categoryId);

  /// Checks the Supabase catalog first; if nothing is found, falls back to
  /// the search-resource Edge Function, which fetches from Open Library
  /// and writes the results into the catalog server-side.
  Future<List<ResourceEntity>> searchResources(String query);

  Future<List<ResourceEntity>> getBookmarkedResources();
  Future<void> toggleBookmark(String resourceId);
  Future<bool> isBookmarked(String resourceId);

  Future<List<ResourceEntity>> getNewReleases({String? type});

  /// Returns the category with the most resources, and its resources —
  /// powers the "Trending in {category}" row. Null if no categories have
  /// any resources yet.
  Future<(CategoryEntity, List<ResourceEntity>)?> getFeaturedCategoryTrending();

  Future<ResourceEntity?> getResourceById(String resourceId);
  Future<List<ResourceEntity>> getRelatedResources(String resourceId, String? categoryId);

  Future<void> markDownloaded(String resourceId);
  Future<bool> isDownloaded(String resourceId);
  Future<String?> getReadableContent(ResourceEntity resource);
Future<void> saveReadingProgress(String resourceId, double percent);
}
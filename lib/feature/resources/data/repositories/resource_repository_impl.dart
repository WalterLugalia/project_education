import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/resource_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/continue_reading_item.dart';
import '../../domain/repositories/resource_repository.dart';
import '../datasource/resource_remote_data_source.dart';
import '../datasource/resource_local_data_source.dart';
import '../models/resource_model.dart';

class ResourceRepositoryImpl implements ResourceRepository {
  final ResourceRemoteDataSource remoteDataSource;
  final ResourceLocalDataSource localDataSource;

  ResourceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  Future<bool> get _isOnline async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  @override
  Future<List<ResourceEntity>> getTrendingBooks() async {
    if (await _isOnline) {
      try {
        final resources = await remoteDataSource.getTrendingBooks();
        await localDataSource.cacheHomeFeed(resources);
        return resources;
      } catch (_) {
        return localDataSource.getCachedHomeFeed();
      }
    }
    return localDataSource.getCachedHomeFeed();
  }

  @override
  Future<List<ContinueReadingItem>> getContinueReading() async {
    final rows = await remoteDataSource.getContinueReading();
    return rows.map((row) {
      final resource = ResourceModel.fromJson(row['resources'] as Map<String, dynamic>);
      final progress = (row['progress_percent'] as num).toDouble();
      return ContinueReadingItem(resource: resource, progressPercent: progress);
    }).toList();
  }

  @override
  Future<List<CategoryEntity>> getCategories() => remoteDataSource.getCategories();

  @override
  Future<List<ResourceEntity>> getResourcesByCategory(String categoryId) async {
    if (await _isOnline) {
      try {
        final resources = await remoteDataSource.getResourcesByCategory(categoryId);
        await localDataSource.cacheCategoryResources(categoryId, resources);
        return resources;
      } catch (_) {
        return localDataSource.getCachedCategoryResources(categoryId);
      }
    }
    return localDataSource.getCachedCategoryResources(categoryId);
  }

  @override
  Future<List<ResourceEntity>> searchResources(String query) async {
    if (!await _isOnline) {
      final cached = localDataSource.getCachedSearchResults(query);
      return cached ?? [];
    }

    final catalogResults = await remoteDataSource.searchResources(query);

    if (catalogResults.isNotEmpty) {
      await localDataSource.cacheSearchResults(query, catalogResults);
      return catalogResults;
    }

    // Nothing in our catalog — fall back to the Edge Function, which
    // fetches from Open Library and writes the results server-side.
    try {
      final externalResults = await remoteDataSource.searchExternalAndSave(query);
      await localDataSource.cacheSearchResults(query, externalResults);
      return externalResults;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<ResourceEntity>> getBookmarkedResources() =>
      remoteDataSource.getBookmarkedResources();

  @override
  Future<void> toggleBookmark(String resourceId) async {
    final bookmarked = await remoteDataSource.isBookmarked(resourceId);
    if (bookmarked) {
      await remoteDataSource.removeBookmark(resourceId);
    } else {
      await remoteDataSource.addBookmark(resourceId);
    }
  }

  @override
  Future<bool> isBookmarked(String resourceId) => remoteDataSource.isBookmarked(resourceId);

  @override
  Future<List<ResourceEntity>> getNewReleases({String? type}) =>
      remoteDataSource.getNewReleases(type: type);

  @override
  Future<(CategoryEntity, List<ResourceEntity>)?> getFeaturedCategoryTrending() async {
    final category = await remoteDataSource.getMostPopulatedCategory();
    if (category == null) return null;

    final resources = await remoteDataSource.getResourcesInCategory(category.id);
    if (resources.isEmpty) return null;

    return (category, resources);
  }

  @override
  Future<ResourceEntity?> getResourceById(String resourceId) async {
    if (await _isOnline) {
      try {
        final resource = await remoteDataSource.getResourceById(resourceId);
        if (resource != null) {
          await localDataSource.cacheResourceDetails(resource);
        }
        return resource;
      } catch (_) {
        return localDataSource.getCachedResourceDetails(resourceId);
      }
    }
    return localDataSource.getCachedResourceDetails(resourceId);
  }

  @override
  Future<List<ResourceEntity>> getRelatedResources(String resourceId, String? categoryId) =>
      remoteDataSource.getRelatedResources(resourceId, categoryId);

  @override
  Future<void> markDownloaded(String resourceId) => remoteDataSource.markDownloaded(resourceId);

  @override
  Future<bool> isDownloaded(String resourceId) => remoteDataSource.isDownloaded(resourceId);

  @override
  Future<String?> getReadableContent(ResourceEntity resource) async {
    // Dev.to articles: fetch full markdown body (list sync never pulled it),
    // cache the text directly since it's small.
    if (resource.type == ResourceType.article && resource.source == ResourceSource.devTo) {
      final cached = localDataSource.getCachedArticleContent(resource.id);
      if (cached != null) return cached;

      if (!await _isOnline) return null;

      if (resource.externalId == null) return null;
      final body = await remoteDataSource.fetchDevToArticleBody(resource.externalId!);
      if (body != null) {
        await localDataSource.cacheArticleContent(resource.id, body);
      }
      return body;
    }

    // Real downloadable files (manual entries with content_url set):
    // download once, cache file path/size/date, reuse on repeat reads.
    if (resource.contentFormat != ContentFormat.unavailable && resource.contentUrl != null) {
      final cachedInfo = localDataSource.getCachedFileInfo(resource.id);
      if (cachedInfo != null) return cachedInfo['path'] as String;

      if (!await _isOnline) return null;
      return localDataSource.downloadAndCacheFile(resource.id, resource.contentUrl!);
    }

    // Genuinely no readable content available — e.g. Open Library books,
    // where only metadata and an external link exist.
    return null;
  }

  @override
  Future<void> saveReadingProgress(String resourceId, double percent) =>
      remoteDataSource.upsertReadingProgress(resourceId, percent);
}
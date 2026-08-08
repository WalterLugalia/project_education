import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project_education/feature/resources/data/models/resource_model.dart';
import 'package:project_education/feature/resources/domain/entities/continue_reading_item.dart';
import '../../domain/entities/resource_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/resource_repository.dart';
import '../datasource/resource_remote_data_source.dart';
import '../datasource/resource_local_data_source.dart';

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
  Future<List<ResourceEntity>> getHomeFeed() async {
    if (await _isOnline) {
      try {
        final resources = await remoteDataSource.getHomeFeed();
        await localDataSource.cacheHomeFeed(resources);
        return resources;
      } catch (_) {
        return localDataSource.getCachedHomeFeed();
      }
    }
    return localDataSource.getCachedHomeFeed();
  }

  @override
  Future<List<CategoryEntity>> getCategories() async {
    return remoteDataSource.getCategories();
  }

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
    return remoteDataSource.searchResources(query);
  }

  @override
  Future<List<ResourceEntity>> getBookmarkedResources() async {
    return remoteDataSource.getBookmarkedResources();
  }

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
  Future<bool> isBookmarked(String resourceId) async {
    return remoteDataSource.isBookmarked(resourceId);
  }

  @override
Future<List<ResourceEntity>> getTrendingBooks() async {
  return remoteDataSource.getTrendingBooks();
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
}
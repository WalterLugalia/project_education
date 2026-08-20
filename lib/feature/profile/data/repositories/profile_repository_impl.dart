import 'package:project_education/feature/profile/data/repositories/profile_repository.dart';
import 'package:project_education/feature/resources/domain/entities/resource_entity.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/entities/profile_stats_entity.dart';
import '../datasource/profile_remote_data_source.dart';


class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ProfileEntity?> getProfile() => remoteDataSource.getProfile();

  @override
  Future<void> updateProfile({String? fullName, String? username, String? bio, String? website, String? location}) =>
      remoteDataSource.updateProfile(fullName: fullName, username: username, bio: bio, website: website, location: location);

  @override
  Future<String> uploadAvatar(String filePath) => remoteDataSource.uploadAvatar(filePath);

  @override
  Future<bool> isUsernameAvailable(String username) => remoteDataSource.isUsernameAvailable(username);

  @override
  Future<void> logResourceView(String resourceId) => remoteDataSource.logResourceView(resourceId);

  @override
  Future<void> logReadingSession(String resourceId, int seconds) =>
      remoteDataSource.logReadingSession(resourceId, seconds);

  @override
  Future<ProfileStatsEntity> getProfileStats() async {
    final results = await Future.wait([
      remoteDataSource.getResourcesEngagedCount(),
      remoteDataSource.getReadingHours(),
      remoteDataSource.getBookmarksCount(),
      remoteDataSource.getReadThisMonthPercentDelta(),
      remoteDataSource.getReadingStreakDays(),
      remoteDataSource.getCategoryBreakdownRaw(),
      remoteDataSource.getMostVisited(),
    ]);

    final rawBreakdown = results[5] as List<Map<String, dynamic>>;
    final counts = <String, int>{};
    for (final row in rawBreakdown) {
      final category = row['resources']?['categories']?['name'] as String?;
      if (category == null) continue;
      counts[category] = (counts[category] ?? 0) + 1;
    }
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    final breakdown = total == 0
        ? <CategoryBreakdown>[]
        : (counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
            .map((e) => CategoryBreakdown(categoryName: e.key, percent: e.value / total * 100))
            .toList();

    return ProfileStatsEntity(
      resourcesEngaged: results[0] as int,
      readingHours: results[1] as double,
      bookmarksCount: results[2] as int,
      readThisMonthPercentDelta: results[3] as int,
      readingStreakDays: results[4] as int,
      categoryBreakdown: breakdown,
      mostVisited: results[6] as List<ResourceEntity>,
    );
  }
}
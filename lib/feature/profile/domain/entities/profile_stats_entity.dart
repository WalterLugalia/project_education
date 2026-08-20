import 'package:project_education/feature/resources/domain/entities/resource_entity.dart';

class CategoryBreakdown {
  final String categoryName;
  final double percent;
  const CategoryBreakdown({required this.categoryName, required this.percent});
}

class ProfileStatsEntity {
  final int resourcesEngaged;
  final double readingHours;
  final int bookmarksCount;
  final int readThisMonthPercentDelta;
  final int readingStreakDays;
  final List<CategoryBreakdown> categoryBreakdown;
  final List<ResourceEntity> mostVisited;

  const ProfileStatsEntity({
    required this.resourcesEngaged,
    required this.readingHours,
    required this.bookmarksCount,
    required this.readThisMonthPercentDelta,
    required this.readingStreakDays,
    required this.categoryBreakdown,
    required this.mostVisited,
  });
}
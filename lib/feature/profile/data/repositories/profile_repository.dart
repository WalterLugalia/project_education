import 'package:project_education/feature/profile/domain/entities/profile_entity.dart';
import 'package:project_education/feature/profile/domain/entities/profile_stats_entity.dart';
import 'package:project_education/feature/resources/domain/entities/resource_entity.dart';


abstract class ProfileRepository {
  Future<ProfileEntity?> getProfile();
  Future<void> updateProfile({
    String? fullName,
    String? username,
    String? bio,
    String? website,
    String? location,
  });
  Future<String> uploadAvatar(String filePath);
  Future<bool> isUsernameAvailable(String username);
  Future<ProfileStatsEntity> getProfileStats();
  Future<void> logResourceView(String resourceId);
  Future<void> logReadingSession(String resourceId, int seconds);
}
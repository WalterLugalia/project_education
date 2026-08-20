// get_profile_stats_usecase.dart
import 'package:project_education/feature/profile/data/repositories/profile_repository.dart';

import '../entities/profile_stats_entity.dart';

class GetProfileStatsUseCase {
  final ProfileRepository repository;
  const GetProfileStatsUseCase(this.repository);
  Future<ProfileStatsEntity> call() => repository.getProfileStats();
}
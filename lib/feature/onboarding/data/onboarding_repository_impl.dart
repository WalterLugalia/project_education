

import 'package:project_education/feature/onboarding/data/onboarding_local_data_source.dart';
import 'package:project_education/feature/onboarding/domain/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource localDataSource;

  OnboardingRepositoryImpl({required this.localDataSource});

  @override
  Future<bool> isOnboardingCompleted() async {
    return localDataSource.getOnboardingStatus();
  }

  @override
  Future<void> completeOnboarding() async {
    await localDataSource.setOnboardingCompleted();
  }
}
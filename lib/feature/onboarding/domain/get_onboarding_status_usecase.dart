

import 'package:project_education/feature/onboarding/domain/onboarding_repository.dart';

class GetOnboardingStatusUseCase {
  final OnboardingRepository repository;

  const GetOnboardingStatusUseCase(this.repository);

  Future<bool> call() => repository.isOnboardingCompleted();
}

import 'package:project_education/feature/onboarding/domain/onboarding_repository.dart';

class CompleteOnboardingUseCase {
  final OnboardingRepository repository;

  const CompleteOnboardingUseCase(this.repository);

  Future<void> call() => repository.completeOnboarding();
}
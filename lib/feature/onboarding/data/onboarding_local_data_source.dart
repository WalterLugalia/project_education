import 'package:hive/hive.dart';
import 'package:project_education/core/constants/hive_constants.dart';

abstract class OnboardingLocalDataSource {
  bool getOnboardingStatus();
  Future<void> setOnboardingCompleted();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  final Box<bool> onboardingBox;

  OnboardingLocalDataSourceImpl({required this.onboardingBox});

  @override
  bool getOnboardingStatus() {
    return onboardingBox.get(
      HiveConstants.hasSeenOnboardingKey,
      defaultValue: false,
    )!;
  }

  @override
  Future<void> setOnboardingCompleted() async {
    await onboardingBox.put(HiveConstants.hasSeenOnboardingKey, true);
  }
}
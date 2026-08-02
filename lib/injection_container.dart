import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:project_education/core/constants/hive_constants.dart';
import 'package:project_education/feature/onboarding/data/onboarding_local_data_source.dart';
import 'package:project_education/feature/onboarding/data/onboarding_repository_impl.dart';
import 'package:project_education/feature/onboarding/domain/complete_onboarding_usecase.dart';
import 'package:project_education/feature/onboarding/domain/get_onboarding_status_usecase.dart';
import 'package:project_education/feature/onboarding/domain/onboarding_repository.dart';
import 'package:project_education/feature/onboarding/presentation/bloc/onboarding_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  await _initOnboarding();

  // Other features' init calls go here, e.g.:
  // await _initAuth();
}

Future<void> _initOnboarding() async {
  // Bloc — factory: a fresh instance every time the onboarding screen is built
  sl.registerFactory<OnboardingBloc>(
    () => OnboardingBloc(
      completeOnboardingUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton<CompleteOnboardingUseCase>(
    () => CompleteOnboardingUseCase(sl()),
  );
  sl.registerLazySingleton<GetOnboardingStatusUseCase>(
    () => GetOnboardingStatusUseCase(sl()),
  );

  // Repository
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(localDataSource: sl()),
  );

  // Data source
  sl.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(onboardingBox: sl()),
  );

  // Hive box — must already be open (awaited in main.dart) before this resolves
  sl.registerLazySingleton<Box<bool>>(
    () => Hive.box<bool>(HiveConstants.onboardingBox),
  );
}
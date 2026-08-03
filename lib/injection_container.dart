import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_education/core/constants/hive_constants.dart';

// Onboarding
import 'package:project_education/feature/onboarding/data/onboarding_local_data_source.dart';
import 'package:project_education/feature/onboarding/data/onboarding_repository_impl.dart';
import 'package:project_education/feature/onboarding/domain/complete_onboarding_usecase.dart';
import 'package:project_education/feature/onboarding/domain/get_onboarding_status_usecase.dart';
import 'package:project_education/feature/onboarding/domain/onboarding_repository.dart';
import 'package:project_education/feature/onboarding/presentation/bloc/onboarding_bloc.dart';

// Auth

import 'package:project_education/feature/authentication/data/datasource/auth_remote_data_source.dart';
import 'package:project_education/feature/authentication/data/repositories/auth_repository_impl.dart';
import 'package:project_education/feature/authentication/domain/repositories/auth_repository.dart';
import 'package:project_education/feature/authentication/domain/usecase/sign_in_usecase.dart';
import 'package:project_education/feature/authentication/domain/usecase/sign_up_usecase.dart';
import 'package:project_education/feature/authentication/presentaion/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  await _initOnboarding();
  await _initAuth();

  // Other features' init calls go here
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

Future<void> _initAuth() async {
  // Bloc — factory: a fresh instance every time a sign-in/sign-up screen is built
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      signInUseCase: sl(),
      signUpUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton<SignInUseCase>(() => SignInUseCase(sl()));
  sl.registerLazySingleton<SignUpUseCase>(() => SignUpUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Only register this if SupabaseClient isn't already registered
  // elsewhere in your DI setup — get_it throws if a type is registered twice.
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
}
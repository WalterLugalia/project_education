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
import 'package:project_education/feature/authentication/domain/usecase/resend_verification_email_usecase.dart';
import 'package:project_education/feature/authentication/domain/usecase/send_password_reset_email_usecase.dart';
import 'package:project_education/feature/authentication/domain/usecase/update_password_usecase.dart';
import 'package:project_education/feature/authentication/domain/usecase/check_email_verified_usecase.dart';
import 'package:project_education/feature/authentication/domain/usecase/get_cached_user_usecase.dart';
import 'package:project_education/feature/authentication/domain/usecase/sign_out_usecase.dart';
import 'package:project_education/feature/authentication/presentaion/bloc/auth_bloc.dart';


// Resources
import 'package:project_education/feature/resources/data/datasource/resource_remote_data_source.dart';
import 'package:project_education/feature/resources/data/datasource/resource_local_data_source.dart';
import 'package:project_education/feature/resources/data/repositories/resource_repository_impl.dart';
import 'package:project_education/feature/resources/domain/repositories/resource_repository.dart';
import 'package:project_education/feature/resources/domain/usecase/get_home_feed_usecase.dart';
import 'package:project_education/feature/resources/domain/usecase/get_categories_usecase.dart';
import 'package:project_education/feature/resources/domain/usecase/toggle_bookmark_usecase.dart';
import 'package:project_education/feature/resources/presentaion/bloc/home_bloc.dart';

// Splash
import 'package:project_education/feature/splash_screen/prsentaion/Bloc/splash_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  await _initOnboarding();
  await _initAuth();
  await _initSplash();
  await _initResources();

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
      resendVerificationEmailUseCase: sl(),
      sendPasswordResetEmailUseCase: sl(),
      updatePasswordUseCase: sl(),
      checkEmailVerifiedUseCase: sl(),
      signOutUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton<SignInUseCase>(() => SignInUseCase(sl()));
  sl.registerLazySingleton<SignUpUseCase>(() => SignUpUseCase(sl()));
  sl.registerLazySingleton<ResendVerificationEmailUseCase>(
    () => ResendVerificationEmailUseCase(sl()),
  );
  sl.registerLazySingleton<SendPasswordResetEmailUseCase>(
    () => SendPasswordResetEmailUseCase(sl()),
  );
  sl.registerLazySingleton<UpdatePasswordUseCase>(
    () => UpdatePasswordUseCase(sl()),
  );
  sl.registerLazySingleton<CheckEmailVerifiedUseCase>(
    () => CheckEmailVerifiedUseCase(sl()),
  );
  sl.registerLazySingleton<GetCachedUserUseCase>(
    () => GetCachedUserUseCase(sl()),
  );
  sl.registerLazySingleton<SignOutUseCase>(() => SignOutUseCase(sl()));

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

Future<void> _initSplash() async {
  // Bloc — factory: a fresh instance every time the splash screen is built
  sl.registerFactory<SplashBloc>(
    () => SplashBloc(
      onboardingBox: sl<Box<bool>>(),
      getCachedUserUseCase: sl(),
      checkEmailVerifiedUseCase: sl(),
      signOutUseCase: sl(),
    ),
  );
}



Future<void> _initResources() async {
  sl.registerFactory<HomeBloc>(
    () => HomeBloc(
      getHomeFeedUseCase: sl(),
      getCategoriesUseCase: sl(),
      toggleBookmarkUseCase: sl(),
    ),
  );

  sl.registerLazySingleton<GetHomeFeedUseCase>(() => GetHomeFeedUseCase(sl()));
  sl.registerLazySingleton<GetCategoriesUseCase>(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton<ToggleBookmarkUseCase>(() => ToggleBookmarkUseCase(sl()));

  sl.registerLazySingleton<ResourceRepository>(
    () => ResourceRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<ResourceRemoteDataSource>(
    () => ResourceRemoteDataSourceImpl(supabaseClient: sl()),
  );

  sl.registerLazySingleton<ResourceLocalDataSource>(
    () => ResourceLocalDataSourceImpl(
      cacheBox: Hive.box<String>(HiveConstants.resourceCacheBox),
    ),
  );
}
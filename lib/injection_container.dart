import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:project_education/feature/resources/presentaion/bloc/reading_bloc/reading_bloc.dart';
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

// Resources — domain
import 'package:project_education/feature/resources/domain/entities/resource_entity.dart';
import 'package:project_education/feature/resources/domain/repositories/resource_repository.dart';
import 'package:project_education/feature/resources/domain/usecase/get_categories_usecase.dart';
import 'package:project_education/feature/resources/domain/usecase/toggle_bookmark_usecase.dart';
import 'package:project_education/feature/resources/domain/usecase/get_continue_reading_usecase.dart';
import 'package:project_education/feature/resources/domain/usecase/get_trending_books_usecase.dart';
import 'package:project_education/feature/resources/domain/usecase/search_resources_usecase.dart';
import 'package:project_education/feature/resources/domain/usecase/download_resource_usecase.dart';
import 'package:project_education/feature/resources/domain/usecase/get_featured_category_trending_usecase.dart';
import 'package:project_education/feature/resources/domain/usecase/get_new_releases_usecase.dart';
import 'package:project_education/feature/resources/domain/usecase/get_related_resources_usecase.dart';
import 'package:project_education/feature/resources/domain/usecase/get_resource_details_usecase.dart';
import 'package:project_education/feature/resources/domain/usecase/is_resource_downloaded_usecase.dart';
import 'package:project_education/feature/resources/domain/usecase/get_readable_content_usecase.dart';
import 'package:project_education/feature/resources/domain/usecase/save_reading_progress_usecase.dart';

// Resources — data
import 'package:project_education/feature/resources/data/datasource/resource_remote_data_source.dart';
import 'package:project_education/feature/resources/data/datasource/resource_local_data_source.dart';
import 'package:project_education/feature/resources/data/repositories/resource_repository_impl.dart';

// Resources — presentation
import 'package:project_education/feature/resources/presentaion/bloc/home_bloc.dart';
import 'package:project_education/feature/resources/presentaion/bloc/search_bloc/search_bloc.dart';
import 'package:project_education/feature/resources/presentaion/bloc/discover_bloc/discover_bloc.dart';
import 'package:project_education/feature/resources/presentaion/bloc/resource_detail_bloc/resource_details_bloc.dart';

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
  // Blocs
  sl.registerFactory<HomeBloc>(
    () => HomeBloc(
      getTrendingBooksUseCase: sl(),
      getContinueReadingUseCase: sl(),
      toggleBookmarkUseCase: sl(),
    ),
  );

  sl.registerFactory<SearchBloc>(() => SearchBloc(searchResourcesUseCase: sl()));

  sl.registerFactory<DiscoverBloc>(
    () => DiscoverBloc(
      getNewReleasesUseCase: sl(),
      getFeaturedCategoryTrendingUseCase: sl(),
      toggleBookmarkUseCase: sl(),
    ),
  );

  sl.registerFactory<ResourceDetailsBloc>(
    () => ResourceDetailsBloc(
      getResourceDetailsUseCase: sl(),
      getRelatedResourcesUseCase: sl(),
      toggleBookmarkUseCase: sl(),
      downloadResourceUseCase: sl(),
      isResourceDownloadedUseCase: sl(),
      repository: sl(),
    ),
  );

  // ReadingBloc needs the selected ResourceEntity at creation time, so it's
  // registered with a factory param rather than sl<ReadingBloc>() directly —
  // called as sl<ReadingBloc>(param1: resource) from ReadingScreen.
  sl.registerFactoryParam<ReadingBloc, ResourceEntity, void>(
    (resource, _) => ReadingBloc(
      getReadableContentUseCase: sl(),
      saveReadingProgressUseCase: sl(),
      resource: resource,
    ),
  );

  // Use cases
  sl.registerLazySingleton<GetTrendingBooksUseCase>(() => GetTrendingBooksUseCase(sl()));
  sl.registerLazySingleton<GetContinueReadingUseCase>(() => GetContinueReadingUseCase(sl()));
  sl.registerLazySingleton<ToggleBookmarkUseCase>(() => ToggleBookmarkUseCase(sl()));
  sl.registerLazySingleton<SearchResourcesUseCase>(() => SearchResourcesUseCase(sl()));
  sl.registerLazySingleton<GetCategoriesUseCase>(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton<GetNewReleasesUseCase>(() => GetNewReleasesUseCase(sl()));
  sl.registerLazySingleton<GetFeaturedCategoryTrendingUseCase>(
    () => GetFeaturedCategoryTrendingUseCase(sl()),
  );
  sl.registerLazySingleton<GetResourceDetailsUseCase>(() => GetResourceDetailsUseCase(sl()));
  sl.registerLazySingleton<GetRelatedResourcesUseCase>(() => GetRelatedResourcesUseCase(sl()));
  sl.registerLazySingleton<DownloadResourceUseCase>(() => DownloadResourceUseCase(sl()));
  sl.registerLazySingleton<IsResourceDownloadedUseCase>(() => IsResourceDownloadedUseCase(sl()));
  sl.registerLazySingleton<GetReadableContentUseCase>(() => GetReadableContentUseCase(sl()));
  sl.registerLazySingleton<SaveReadingProgressUseCase>(() => SaveReadingProgressUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ResourceRepository>(
    () => ResourceRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ResourceRemoteDataSource>(
    () => ResourceRemoteDataSourceImpl(supabaseClient: sl()),
  );

  sl.registerLazySingleton<ResourceLocalDataSource>(
    () => ResourceLocalDataSourceImpl(cacheBox: Hive.box<String>(HiveConstants.resourceCacheBox)),
  );
}
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:project_education/core/constants/hive_constants.dart';
import 'package:project_education/feature/authentication/domain/usecase/check_email_verified_usecase.dart';
import 'package:project_education/feature/authentication/domain/usecase/get_cached_user_usecase.dart';
import 'package:project_education/feature/authentication/domain/usecase/sign_out_usecase.dart';

import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final Box<bool> onboardingBox;
  final GetCachedUserUseCase getCachedUserUseCase;
  final CheckEmailVerifiedUseCase checkEmailVerifiedUseCase;
  final SignOutUseCase signOutUseCase;

  SplashBloc({
    required this.onboardingBox,
    required this.getCachedUserUseCase,
    required this.checkEmailVerifiedUseCase,
    required this.signOutUseCase,
  }) : super(SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
  }

  Future<void> _onSplashStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    final hasSeenOnboarding = onboardingBox.get(
      HiveConstants.hasSeenOnboardingKey,
      defaultValue: false,
    )!;

    if (!hasSeenOnboarding) {
      emit(SplashNavigateToOnboarding());
      return;
    }

    final cachedUser = getCachedUserUseCase();
    if (cachedUser == null) {
      emit(SplashNavigateToSignIn());
      return;
    }

    final connectivity = await Connectivity().checkConnectivity();
    final isOffline = connectivity.contains(ConnectivityResult.none);

    if (isOffline) {
      // Trust the locally restored session without a network round-trip.
      if (cachedUser.isEmailVerified) {
        emit(SplashNavigateToHome());
      } else {
        emit(SplashNavigateToSignInUnverified());
      }
      return;
    }

    try {
      final freshUser = await checkEmailVerifiedUseCase();
      if (freshUser.isEmailVerified) {
        emit(SplashNavigateToHome());
      } else {
        await signOutUseCase();
        emit(SplashNavigateToSignInUnverified());
      }
    } catch (_) {
      // Server/network hiccup during refresh — fall back to cached state
      // rather than stranding the user on the splash screen.
      if (cachedUser.isEmailVerified) {
        emit(SplashNavigateToHome());
      } else {
        emit(SplashNavigateToSignInUnverified());
      }
    }
  }
}
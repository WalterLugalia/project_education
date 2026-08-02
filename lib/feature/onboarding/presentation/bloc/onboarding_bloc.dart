import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_education/feature/onboarding/domain/complete_onboarding_usecase.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final CompleteOnboardingUseCase completeOnboardingUseCase;

  OnboardingBloc({required this.completeOnboardingUseCase})
      : super(OnboardingInitial()) {
    on<CompleteOnboardingRequested>(_onCompleteOnboardingRequested);
  }

  Future<void> _onCompleteOnboardingRequested(
    CompleteOnboardingRequested event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingLoading());
    try {
      await completeOnboardingUseCase();
      emit(OnboardingCompleted());
    } catch (e) {
      emit(OnboardingError(e.toString()));
    }
  }
}
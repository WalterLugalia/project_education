import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Fired by both the "Next" button and the "Skip" link.
class CompleteOnboardingRequested extends OnboardingEvent {
  const CompleteOnboardingRequested();
}
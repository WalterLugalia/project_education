import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_education/core/config/route/app_routes.dart';
import 'package:project_education/core/config/theme/app_colors.dart';
import 'package:project_education/core/utils/shared_widgets/app_button.dart';
import 'package:project_education/feature/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:project_education/feature/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:project_education/feature/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:project_education/injection_container.dart';
import 'package:project_education/shared/widgets/text_widget.dart';


class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OnboardingBloc>(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView();

  void _goToSignIn(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.signInScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor, // fallback: Color(0xFF0E0B1E)
      body: SafeArea(
        child: BlocConsumer<OnboardingBloc, OnboardingState>(
          listener: (context, state) {
            if (state is OnboardingCompleted) {
              _goToSignIn(context);
            }
            if (state is OnboardingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is OnboardingLoading;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // Skip
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () => context
                              .read<OnboardingBloc>()
                              .add(const CompleteOnboardingRequested()),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: AppColors.textBodyColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Illustration
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        'assets/orbit.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Decorative dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      _Dot(active: true),
                      _Dot(),
                      _Dot(),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Eyebrow label
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'YOUR LIBRARY, EVERYWHERE',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: textHeadingWidget(text: 'Save for Offline Reading'),
                  ),
                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: textSubHeadingWidget(
                      text:
                          'Download books, articles, and docs. Read anywhere — even without internet.',
                    ),
                  ),
                  const SizedBox(height: 24),

                  AppButton(
                    text: 'Continue',
                    icon: Icons.arrow_forward,
                    iconFirst: false,
                    isFullWidth: true,
                    isLoading: isLoading,
                    onPressed: () => context
                        .read<OnboardingBloc>()
                        .add(const CompleteOnboardingRequested()),
                  ),
                  const SizedBox(height: 12),

                  // "Continue as ..." label guessed from the cropped screenshot —
                  // update text/behavior once you confirm the real copy.
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => context
                            .read<OnboardingBloc>()
                            .add(const CompleteOnboardingRequested()),
                    child: Text(
                      'Continue as Guest',
                      style: TextStyle(color: AppColors.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({this.active = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: active ? 18 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active
            ? AppColors.primaryColor
            : AppColors.primaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
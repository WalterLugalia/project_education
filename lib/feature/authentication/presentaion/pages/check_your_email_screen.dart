import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:project_education/core/config/route/app_routes.dart';
import 'package:project_education/core/config/theme/app_colors.dart';
import 'package:project_education/core/utils/shared_widgets/app_button.dart';
import 'package:project_education/feature/authentication/presentaion/bloc/auth_bloc.dart';
import 'package:project_education/feature/authentication/presentaion/bloc/auth_event.dart';
import 'package:project_education/feature/authentication/presentaion/bloc/auth_state.dart';
import 'package:project_education/injection_container.dart';
import 'package:project_education/shared/widgets/text_widget.dart';

class CheckYourEmailScreen extends StatelessWidget {
  final String email;

  const CheckYourEmailScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: _CheckYourEmailView(email: email),
    );
  }
}

class _CheckYourEmailView extends StatefulWidget {
  final String email;

  const _CheckYourEmailView({required this.email});

  @override
  State<_CheckYourEmailView> createState() => _CheckYourEmailViewState();
}

class _CheckYourEmailViewState extends State<_CheckYourEmailView> {
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _resendCooldown = 30);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown <= 1) {
        timer.cancel();
        setState(() => _resendCooldown = 0);
      } else {
        setState(() => _resendCooldown -= 1);
      }
    });
  }

  Future<void> _openEmailApp() async {
    // Best-effort: opens the default mail app chooser on Android/iOS.
    final uri = Uri(scheme: 'mailto');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AppAuthState>(
          listener: (context, state) {
            if (state is EmailVerificationConfirmed) {
              Navigator.of(context).pushReplacementNamed(AppRoutes.signInScreen);
            }
            if (state is VerificationEmailResent) {
              _startCooldown();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Verification email resent.')),
              );
            }
          },
          builder: (context, state) {
            final isChecking = state is EmailVerificationChecking;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.mark_email_unread_outlined, size: 56, color: Colors.white70),
                  const SizedBox(height: 16),
                  textHeadingWidget(text: 'Check Your Email', textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  textSubHeadingWidget(
                    text: "We've sent a verification link to\n${widget.email}",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  textSubHeadingWidget(
                    text: 'Please verify your email before signing in.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  if (state is EmailVerificationStillPending) _StatusCard(
                    icon: Icons.error_outline,
                    title: 'Email Not Verified Yet',
                    message: "We couldn't confirm your email.\n\n"
                        '• Check your inbox\n• Check your spam folder\n• Wait a few moments',
                  ),
                  if (state is EmailVerificationOffline) const _StatusCard(
                    icon: Icons.wifi_off,
                    title: 'No internet connection',
                    message: 'Reconnect and try again.',
                  ),
                  if (state is EmailVerificationCheckError) _StatusCard(
                    icon: Icons.warning_amber_outlined,
                    title: "Couldn't check verification",
                    message: 'Please try again shortly.',
                  ),
                  if (state is EmailVerificationStillPending ||
                      state is EmailVerificationOffline ||
                      state is EmailVerificationCheckError)
                    const SizedBox(height: 20),

                  AppButton(
                    text: 'Open Email App',
                    type: AppButtonType.outlined,
                    isFullWidth: true,
                    onPressed: _openEmailApp,
                  ),
                  const SizedBox(height: 12),

                  AppButton(
                    text: isChecking ? 'Checking...' : "I've Verified My Email",
                    isFullWidth: true,
                    isLoading: isChecking,
                    onPressed: () => context
                        .read<AuthBloc>()
                        .add(const CheckEmailVerificationRequested()),
                  ),
                  const SizedBox(height: 12),

                  AppButton(
                    text: _resendCooldown > 0
                        ? 'Resend in ${_resendCooldown}s'
                        : 'Resend Verification Email',
                    type: AppButtonType.text,
                    isFullWidth: true,
                    onPressed: _resendCooldown > 0
                        ? null
                        : () => context
                            .read<AuthBloc>()
                            .add(ResendVerificationRequested(email: widget.email)),
                  ),
                  const SizedBox(height: 8),

                  AppButton(
                    text: 'Back To Sign In',
                    type: AppButtonType.text,
                    isFullWidth: true,
                    onPressed: () =>
                        Navigator.of(context).pushReplacementNamed(AppRoutes.signInScreen),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _StatusCard({required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.orangeAccent, size: 32),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textBodyColor, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
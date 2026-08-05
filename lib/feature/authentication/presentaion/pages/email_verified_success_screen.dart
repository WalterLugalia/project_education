import 'package:flutter/material.dart';
import 'package:project_education/core/config/route/app_routes.dart';
import 'package:project_education/core/config/theme/app_colors.dart';
import 'package:project_education/core/utils/shared_widgets/app_button.dart';
import 'package:project_education/shared/widgets/text_widget.dart';

class EmailVerifiedSuccessScreen extends StatelessWidget {
  const EmailVerifiedSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.check_circle_outline, size: 72, color: Colors.greenAccent),
              const SizedBox(height: 20),
              textHeadingWidget(text: 'Email Verified', textAlign: TextAlign.center),
              const SizedBox(height: 8),
              textSubHeadingWidget(text: 'Your account is ready.', textAlign: TextAlign.center),
              const SizedBox(height: 32),
              AppButton(
                text: 'Continue to Sign In',
                isFullWidth: true,
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed(AppRoutes.signInScreen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
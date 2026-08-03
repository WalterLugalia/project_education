import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:project_education/core/config/theme/app_colors.dart';

class AuthBottomPrompt extends StatelessWidget {
  final String promptText;
  final String actionText;
  final VoidCallback onActionTap;

  const AuthBottomPrompt({
    super.key,
    required this.promptText,
    required this.actionText,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: AppColors.textBodyColor),
          children: [
            TextSpan(text: promptText),
            TextSpan(
              text: actionText,
              style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w600),
              recognizer: TapGestureRecognizer()..onTap = onActionTap,
            ),
          ],
        ),
      ),
    );
  }
}
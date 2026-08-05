import 'package:flutter/material.dart';
import 'package:project_education/feature/authentication/presentaion/sign_up_screen.dart';
import 'package:project_education/feature/authentication/presentaion/signin_page.dart';
import 'package:project_education/feature/authentication/presentaion/pages/check_your_email_screen.dart';
import 'package:project_education/feature/authentication/presentaion/pages/email_verified_success_screen.dart';
import 'package:project_education/feature/authentication/presentaion/pages/forgot_password_screen.dart';
import 'package:project_education/feature/authentication/presentaion/pages/reset_password_screen.dart';
import 'package:project_education/feature/authentication/presentaion/pages/change_password_screen.dart';
import 'package:project_education/feature/home_screen/presentaion/home_screen.dart';
import 'package:project_education/feature/splash_screen/prsentaion/Splash_screen.dart';
import 'package:project_education/feature/onboarding/presentation/onboarding_screen.dart';
import 'app_routes.dart';

class AppRouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _buildRoute(
          const SplashScreen(),
          settings: settings,
        );

      case AppRoutes.onboarding:
        return _buildRoute(
          const OnboardingScreen(),
          settings: settings,
        );

      case AppRoutes.signInScreen:
        return _buildRoute(
          const SignInScreen(),
          settings: settings,
        );

      case AppRoutes.signUp:
        return _buildRoute(
          const SignUpScreen(),
          settings: settings,
        );

      case AppRoutes.home:
        return _buildRoute(
          const HomeScreen(),
          settings: settings,
        );

      case AppRoutes.checkYourEmail:
        final email = settings.arguments as String? ?? '';
        return _buildRoute(
          CheckYourEmailScreen(email: email),
          settings: settings,
        );

      case AppRoutes.emailVerifiedSuccess:
        return _buildRoute(
          const EmailVerifiedSuccessScreen(),
          settings: settings,
        );

      case AppRoutes.forgotPassword:
        return _buildRoute(
          const ForgotPasswordScreen(),
          settings: settings,
        );

      case AppRoutes.resetPassword:
        return _buildRoute(
          const ResetPasswordScreen(),
          settings: settings,
        );

      case AppRoutes.changePassword:
        return _buildRoute(
          const ChangePasswordScreen(),
          settings: settings,
        );

      default:
        return _buildRoute(
          _buildNotFoundPage(),
          settings: settings,
        );
    }
  }

  static PageRoute _buildRoute(
    Widget page, {
    required RouteSettings settings,
  }) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => page,
    );
  }

  static Widget _buildNotFoundPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              '404 - Page Not Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'The requested page could not be found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:project_education/feature/authentication/presentaion/sign_up_screen.dart';
import 'package:project_education/feature/authentication/presentaion/signin_page.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_education/core/config/route/app_navigator.dart';
import 'package:project_education/core/config/route/app_routes.dart';
import 'package:project_education/core/config/theme/app_colors.dart';
import 'package:project_education/shared/widgets/text_widget.dart';
import 'Bloc/splash_bloc.dart';
import 'Bloc/splash_event.dart';
import 'Bloc/splash_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context)=>SplashBloc()..add(SplashStarted()),
    child: BlocListener<SplashBloc, SplashState>(
      listener: (context, state){
        if (state is SplashLoaded) {
          AppNavigator.pushReplacementNamed(AppRoutes.onboarding);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                width: 130,
                height: 150,
              ),
              textHeadingWidget(
                text: 'LearnSHelf',
              ),
              textSubHeadingWidget(
                text: 'Discover. Learn. Grow.',
              )
            ],
          ),
          ),
        ),
      ),
    );
  }
}

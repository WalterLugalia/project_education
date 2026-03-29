import 'package:flutter/material.dart';
import 'core/config/route/app_navigator.dart';
import 'core/config/route/app_route_generator.dart';
import 'core/config/route/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Education',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      navigatorKey: AppNavigator.navigatorKey,

      onGenerateRoute: AppRouteGenerator.generateRoute,

      initialRoute: AppRoutes.splash,
    );
  }
}

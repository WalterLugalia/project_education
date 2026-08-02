import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:project_education/injection_container.dart';
import 'core/config/route/app_navigator.dart';
import 'core/config/route/app_route_generator.dart';
import 'core/config/route/app_routes.dart';
import 'core/constants/hive_constants.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox<bool>(HiveConstants.onboardingBox);

  await initDependencies();

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
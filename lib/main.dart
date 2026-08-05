import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_education/core/constants/supabase_constants.dart';
import 'package:project_education/core/services/deep_link_handler.dart';
import 'package:project_education/injection_container.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/route/app_navigator.dart';
import 'core/config/route/app_route_generator.dart';
import 'core/config/route/app_routes.dart';
import 'core/constants/hive_constants.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox<bool>(HiveConstants.onboardingBox);

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // Initialize dependency injection
  await initDependencies();

  // Start listening for deep links (email verification, password recovery)
  await DeepLinkHandler.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Education',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      navigatorKey: AppNavigator.navigatorKey,
      onGenerateRoute: AppRouteGenerator.generateRoute,
      initialRoute: AppRoutes.splash,
    );
  }
}
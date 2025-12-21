import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'shared/theme/app_theme.dart';

class MalAIriaApp extends StatelessWidget {
  const MalAIriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MalAIria',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}

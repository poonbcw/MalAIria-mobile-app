import 'package:flutter/material.dart';
import '../features/splash/splash_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/auth/login_page.dart';
import '../features/upload/upload_page.dart';

class AppRoutes {
  static const splash = '/';
  static const dashboard = '/dashboard';
  static const upload = '/upload';
  static const login = '/login';

  static final routes = <String, WidgetBuilder>{
    splash: (_) => const SplashPage(),
    dashboard: (_) => const DashboardPage(),
    upload: (_) => const UploadPage(),
    login: (_) => const LoginPage(),
  };
}

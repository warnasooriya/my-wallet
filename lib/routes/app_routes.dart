import 'package:flutter/material.dart';
import 'package:myfinanceapp/screens/home_screen.dart';
import 'package:myfinanceapp/screens/login_screen.dart';
import 'package:myfinanceapp/screens/register_screen.dart';
import 'package:myfinanceapp/splash_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/splash': (context) => SplashScreen(),
      '/login': (context) => LoginScreen(),
      '/register': (context) => RegisterScreen(),
      '/home': (context) => HomePage(),
    };
  }
}

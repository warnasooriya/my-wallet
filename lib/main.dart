import 'package:flutter/material.dart';
import 'package:myfinanceapp/routes/app_routes.dart';
import 'package:myfinanceapp/utils/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Create a global RouteObserver to track route changes
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  final database = openDatabase(
    join(await getDatabasesPath(), 'myfinance.db'),
  );
  runApp(const MyFinance());
}

class MyFinance extends StatelessWidget {
  const MyFinance({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/splash',
      routes: AppRoutes.getRoutes(),
      navigatorObservers: [routeObserver], // Register the RouteObserver
    );
  }
}

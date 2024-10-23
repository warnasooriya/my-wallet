import 'package:flutter/material.dart';
import 'package:myfinanceapp/routes/app_routes.dart';
import 'package:myfinanceapp/services/auth_service.dart';
import 'package:myfinanceapp/services/data_sync_service.dart';
import 'package:myfinanceapp/utils/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:workmanager/workmanager.dart';

// Create a global RouteObserver to track route changes
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
final DataSyncService _dataSyncService = DataSyncService();
final AuthService _authService = AuthService();

Future<bool> isInternetAvailable() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}

Future<void> syncData() async {
  // Call your sync service here
  _authService.getCurrentUser().then((user) {
    String? userId = user['uid'];
    print("Syncing data...");
    _dataSyncService.localDataUploadToFirebase(userId!);
  });
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    bool hasInternet = await isInternetAvailable();
    print("Internet available: $hasInternet");
    if (hasInternet) {
      // Call your sync service here
      await syncData();
    }
    return Future.value(true);
  });
}

void registerSyncTask() {
  Workmanager().registerPeriodicTask(
    "syncTask", // This is the unique task name
    "syncService", // This is the unique task description
    frequency: Duration(minutes: 15), // Define how often the sync should happen
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  final database = openDatabase(
    join(await getDatabasesPath(), 'myfinance.db'),
  );
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true, // change to false for production
  );
  runApp(const MyFinance());
}

class MyFinance extends StatelessWidget {
  const MyFinance({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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

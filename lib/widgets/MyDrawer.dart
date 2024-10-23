import 'package:flutter/material.dart';
import 'package:myfinanceapp/screens/budget_screen.dart';
import 'package:myfinanceapp/screens/expenses_types.dart';
import 'package:myfinanceapp/screens/home_screen.dart';
import 'package:myfinanceapp/screens/income_types.dart';
import 'package:myfinanceapp/screens/transaction_history.dart';
import 'package:myfinanceapp/screens/transaction_screen.dart';
import 'package:myfinanceapp/services/auth_service.dart';
import 'package:myfinanceapp/services/data_sync_service.dart';
import 'package:myfinanceapp/utils/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  File? _profileImage;
  final AuthService _authService = AuthService();
  final DataSyncService _dataSyncService = DataSyncService();
  Map<String, dynamic>? user;
  bool isSyncing = false; // Add a state variable to track sync status

  // Function to pick image from the camera
  Future<void> _pickImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      // Define the path where you want to save the image
      final filePath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';

      // Copy the image to the new path
      File savedImage = await File(pickedFile.path).copy(filePath);
      _profileImage = savedImage;
      prefs.setString('photo', savedImage.path);
      setState(() {
        _profileImage = savedImage;
      });
    }
  }

  // Function to get the current user
  Future<void> getCurrentUser() async {
    var newUser = await _authService.getCurrentUser();
    print(newUser);
    if (newUser['photo'] != null) {
      setState(() {
        _profileImage = File(newUser['photo']!);
      });
    }
    print('image: $_profileImage');

    setState(() {
      user = newUser;
    });
  }

  @override
  void initState() {
    super.initState();
    getProfileData();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Stack(
        children: [
          Column(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(user?['displayName'] ?? 'User'),
                accountEmail: Text(user?['email'] ?? ''),
                currentAccountPicture: GestureDetector(
                  onTap: _pickImage, // Trigger camera to pick an image
                  child: CircleAvatar(
                    backgroundImage: _profileImage != null
                        ? FileImage(
                            _profileImage!) // If you manually upload an image
                        : user?['photoURL'] != null
                            ? NetworkImage(user![
                                'photoURL']!) // If it's from Firebase or another URL
                            : null,
                    child: _profileImage == null && user?['photoURL'] == null
                        ? Text(user?['displayName']?[0] ?? 'U',
                            style: TextStyle(fontSize: 30.0))
                        : null,
                  ),
                ),
                decoration: BoxDecoration(
                  color: primaryColor,
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.dashboard),
                      title: Text('Dashboard'),
                      onTap: () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.account_balance_wallet),
                      title: Text('Transactions'),
                      onTap: () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TransactionScreen()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.history),
                      title: Text('Transaction History'),
                      onTap: () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    TransactionHistoryScreen()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.trending_up),
                      title: Text('Budgets'),
                      onTap: () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BudgetScreen()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.money_sharp),
                      title: Text('Income Types'),
                      onTap: () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => IncomeTypesScreen()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.money_off),
                      title: Text('Expense Types'),
                      onTap: () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ExpensesTypesScreen()));
                      },
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.sync),
                title: Text('Sync Data'),
                onTap: () {
                  syncData(); // Handle sync functionality
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Sign Out'),
                onTap: () {
                  handleLogout(); // Handle sign-out functionality
                },
              ),
            ],
          ),
          if (isSyncing)
            Center(
              child: Stack(
                children: [
                  // ModalBarrier to prevent interactions with the background
                  ModalBarrier(
                    color: Colors.black
                        .withOpacity(0.5), // Semi-transparent overlay
                    dismissible: false, // Prevent dismissing the barrier
                  ),
                  // Loading content
                  Center(
                    child: Container(
                      padding:
                          EdgeInsets.all(24.0), // Padding around the content
                      decoration: BoxDecoration(
                        color:
                            Colors.white, // Background color of the loading box
                        borderRadius:
                            BorderRadius.circular(16.0), // Rounded corners
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26, // Subtle shadow
                            offset: Offset(0, 2),
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                primaryColor), // Brand color
                            strokeWidth: 4.0, // Slightly thicker loader
                          ),
                          SizedBox(height: 20.0),
                          Text(
                            'Syncing Data...',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87, // Darker text color
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            'Please wait while we sync your data with the server.',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors
                                  .black54, // Softer color for additional text
                            ),
                            textAlign: TextAlign.center, // Center the text
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }

  void handleLogout() {
    // Handle sign-out functionality
    // Redirect to login screen
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> getProfileData() async {
    user = await AuthService().getCurrentUser();
    _profileImage = user?['photoURL'] != null && user?['photo'] != null
        ? File(user!['photoURL']!)
        : null;
  }

  Future<void> syncData() async {
    setState(() {
      isSyncing = true; // Start showing the progress indicator
    });

    user = await AuthService().getCurrentUser();
    await _dataSyncService.localDataUploadToFirebase(user?['uid']);

    setState(() {
      isSyncing = false; // Hide the progress indicator after sync is complete
    });
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myfinanceapp/screens/budget_screen.dart';
import 'package:myfinanceapp/screens/expenses_types.dart';
import 'package:myfinanceapp/screens/home_screen.dart';
import 'package:myfinanceapp/screens/income_types.dart';
import 'package:myfinanceapp/screens/transaction_history.dart';
import 'package:myfinanceapp/screens/transaction_screen.dart';
import 'package:myfinanceapp/services/auth_service.dart';
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
  Map<String, dynamic>? user;

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
      child: Column(
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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomePage()));
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
                  leading: Icon(Icons.account_balance_wallet),
                  title: Text('Transaction History'),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TransactionHistoryScreen()));
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
            leading: Icon(Icons.logout),
            title: Text('Sign Out'),
            onTap: () {
              handleLogout();
              // Handle sign-out functionality
            },
          ),
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
    // print(user?['photoURL']);
    _profileImage = user?['photoURL'] != null && user?['photo'] != null
        ? File(user!['photoURL']!)
        : null;
  }
}

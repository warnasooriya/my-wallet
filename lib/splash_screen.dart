import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Timer to navigate to the login page after 3 seconds
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent, // You can choose your theme color
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Background image (optional)
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/logowith-background.webp'), // Add splash image
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.6), // Darken the image slightly
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          // Centered logo and progress indicator
          // Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: <Widget>[
          //     Image.asset(
          //       'assets/logo.webp', // Your app logo here
          //       width: 150,
          //       height: 150,
          //     ),
          //     SizedBox(height: 20),
          //     Text(
          //       'My Finance Manager',
          //       style: TextStyle(
          //         color: Colors.white,
          //         fontSize: 28,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //     SizedBox(height: 20),
          //     CircularProgressIndicator(
          //       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}

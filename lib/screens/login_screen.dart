import 'package:flutter/material.dart';
import 'package:myfinanceapp/services/auth_service.dart';
import 'package:myfinanceapp/utils/constants.dart'; // Import constants for color themes
import 'package:myfinanceapp/utils/helpers.dart'; // Assuming helpers for showing error

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isLoading = false; // Added isLoading state

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var isDarkMode = themeData.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: isLoading, // Disables all interactions when loading
            child: Container(
              decoration: BoxDecoration(
                color: primaryColor,
              ),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    elevation: 8.0,
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon:
                                  Icon(Icons.email, color: primaryColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(color: primaryColor),
                              ),
                            ),
                          ),
                          SizedBox(height: 40),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock, color: primaryColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(color: primaryColor),
                              ),
                            ),
                          ),
                          SizedBox(height: 40),
                          ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    setState(() {
                                      isLoading =
                                          true; // Show loading when pressed
                                    });
                                    final email = _emailController.text;
                                    final password = _passwordController.text;
                                    final user = await _authService.login(
                                        email, password);
                                    setState(() {
                                      isLoading =
                                          false; // Stop loading after login attempt
                                    });
                                    if (user != null) {
                                      Navigator.pushNamed(context, '/home');
                                    } else {
                                      showError(
                                          context, 'Invalid login credentials');
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              backgroundColor:
                                  primaryColor, // Gold for the button
                              foregroundColor: textColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.login, color: Colors.white),
                                SizedBox(width: 10),
                                Text('Login',
                                    style: TextStyle(color: textColorButton)),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    setState(() {
                                      isLoading =
                                          true; // Show loading when pressed
                                    });
                                    if (await _authService.signInWithGoogle()) {
                                      setState(() {
                                        isLoading =
                                            false; // Stop loading after login attempt
                                      });
                                      Navigator.pushNamed(context, '/home');
                                    } else {
                                      setState(() {
                                        isLoading =
                                            false; // Stop loading if sign-in fails
                                      });
                                      showError(context,
                                          'Failed to sign up with Google');
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              backgroundColor: Colors.red,
                              foregroundColor: textColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.plus_one_sharp, color: Colors.white),
                                SizedBox(width: 10),
                                Text('Sign In with Google',
                                    style: TextStyle(color: textColorButton)),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: Text(
                              'Don\'t have an account? Register here',
                              style: TextStyle(
                                  color:
                                      Colors.pinkAccent), // Gold color for text
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isLoading)
            Center(
              child:
                  CircularProgressIndicator(), // Show loading spinner in center
            ),
        ],
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myfinanceapp/services/auth_service.dart';
import 'package:myfinanceapp/utils/constants.dart';
import 'package:myfinanceapp/utils/helpers.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create an Account'),
        backgroundColor: primaryColor, // Gold-like color
        foregroundColor: headerTextColor,
      ),
      body: Container(
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
                    Text('Sign Up',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryColor)),
                    SizedBox(height: 40),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email, color: primaryColor),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: primaryColor)),
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
                            borderSide: BorderSide(color: primaryColor)),
                      ),
                    ),
                    SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () async {
                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();

                        try {
                          // Attempt to register the user
                          final user =
                              await _authService.register(email, password);

                          if (user != null) {
                            // Registration was successful, navigate to login screen
                            Navigator.pushNamed(context, '/home');
                          } else {
                            // In case no user object is returned
                            showError(context,
                                'Registration failed. Please try again.');
                          }
                        } on FirebaseAuthException catch (e) {
                          // Handle different types of FirebaseAuth exceptions
                          String errorMessage;

                          switch (e.code) {
                            case 'weak-password':
                              errorMessage =
                                  'The password provided is too weak.';
                              break;
                            case 'email-already-in-use':
                              errorMessage =
                                  'The account already exists for that email.';
                              break;
                            case 'invalid-email':
                              errorMessage = 'The email address is not valid.';
                              break;
                            default:
                              errorMessage =
                                  'Registration failed. Please try again.';
                          }

                          showError(context, errorMessage);
                        } catch (e) {
                          // Handle any other errors (non-Firebase)
                          showError(context,
                              e.toString()); // Show the error message to the user
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        backgroundColor: primaryColor,
                        foregroundColor: textColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_add, color: Colors.white),
                          SizedBox(width: 10),
                          Text('Create Account',
                              style: TextStyle(color: textColorButton)),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text('Already have an account? Log In',
                          style: TextStyle(color: Colors.pinkAccent)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

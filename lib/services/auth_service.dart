import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Placeholder login method
  Future<User?> login(String email, String password) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final credencials = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      print('credencials: $credencials');
      prefs.setString('userId', credencials.user!.uid);
      prefs.setString('userImageUrl', credencials.user!.photoURL!);
      prefs.setString('userName', credencials.user!.displayName!);
      prefs.setString('userEmail', credencials.user!.email!);

      return credencials.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Placeholder register method
  Future<User?> register(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final credencials = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      prefs.setString('userId', credencials.user!.uid);
      prefs.setString('userImageUrl', credencials.user!.photoURL!);
      prefs.setString('userName', credencials.user!.displayName!);
      prefs.setString('userEmail', credencials.user!.email!);

      return credencials.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> signInWithGoogle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    print(userCredential.user);

    prefs.setString('userId', userCredential.user!.uid);
    prefs.setString('userImageUrl', userCredential.user!.photoURL!);
    prefs.setString('userName', userCredential.user!.displayName!);
    prefs.setString('userEmail', userCredential.user!.email!);

    if (userCredential.user != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> loginWithFacebook() async {
    // Simulate a real login process
    await Future.delayed(Duration(seconds: 2));
    return true;
  }

  Future<bool> signOut() async {
    try {
      await _auth.signOut();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<Map<String, String?>> getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var user = {
      "displayName": prefs.getString("userName"),
      "email": prefs.getString("userEmail"),
      "photoURL": prefs.getString("userImageUrl"),
      "uid": prefs.getString("userId"),
      "photo": prefs.getString("photo")
    };

    return user;
  }
}

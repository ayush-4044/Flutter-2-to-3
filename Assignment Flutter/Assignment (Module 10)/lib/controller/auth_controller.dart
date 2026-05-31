import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../authentication/login_screen.dart';
import '../home_screen.dart';

class AuthController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late Rx<User?> firebaseUser;

  @override
  void onReady() {
    super.onReady();
    firebaseUser = Rx<User?>(auth.currentUser);
    firebaseUser.bindStream(auth.userChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  void _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => const LoginScreen());
    } else {
      Get.offAll(() => const HomeScreen());
    }
  }

  // Human-readable errors for Registration
  Future<void> register(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackbar(
        "Missing Fields",
        "Please enter both email and password.",
      );
      return;
    }

    try {
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage =
          "There was a problem creating your account. Please try again.";

      switch (e.code) {
        case 'weak-password':
          errorMessage =
              "Your password is too weak. Please use at least 6 characters.";
          break;
        case 'email-already-in-use':
          errorMessage = "An account already exists for this email address.";
          break;
        case 'invalid-email':
          errorMessage = "Invalid email format. Please enter a valid email.";
          break;
        case 'network-request-failed':
          errorMessage = "No internet connection. Please check your network.";
          break;
      }
      _showErrorSnackbar("Registration Failed", errorMessage);
    } catch (e) {
      _showErrorSnackbar("Error", "An unknown error occurred: ${e.toString()}");
    }
  }

  // Human-readable errors for Login
  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackbar(
        "Missing Fields",
        "Please enter both email and password.",
      );
      return;
    }

    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Login failed. Please try again.";

      switch (e.code) {
        case 'user-not-found':
          errorMessage = "No account found for this email address.";
          break;
        case 'wrong-password':
          errorMessage = "The password you entered is incorrect.";
          break;
        case 'invalid-credential':
          errorMessage =
              "Invalid email or password. Please check your credentials.";
          break;
        case 'user-disabled':
          errorMessage = "This account has been blocked or disabled.";
          break;
        case 'invalid-email':
          errorMessage = "The email format is incorrect.";
          break;
        case 'network-request-failed':
          errorMessage = "No internet connection. Please check your network.";
          break;
      }
      _showErrorSnackbar("Login Failed", errorMessage);
    } catch (e) {
      _showErrorSnackbar("Error", "An unknown error occurred: ${e.toString()}");
    }
  }

  Future<void> logout() async {
    await auth.signOut();
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent.shade700,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
    );
  }
}

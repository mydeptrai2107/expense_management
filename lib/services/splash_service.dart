import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashService {
  final BuildContext context;

  SplashService(this.context);

  Future<void> checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    User? user = FirebaseAuth.instance.currentUser;

    await Future.delayed(Duration(seconds: 2));

    if (isFirstLaunch) {
      prefs.setBool('isFirstLaunch', false);
      _navigateToIntroduction();
    } else if (user == null) {
      _navigateToLogin();
    } else {
      if (!user.emailVerified) {
        _navigateToLogin();
      } else {
        _navigateToHome();
      }
    }
  }

  void _navigateToIntroduction() {
    Navigator.pushReplacementNamed(context, '/select-language');
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/bottom-navigator');
  }
}

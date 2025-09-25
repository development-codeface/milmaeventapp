import 'dart:async';
import 'package:flutter/material.dart';
import 'package:milma_group/screens/event_list.dart';
import 'package:milma_group/screens/homepage.dart';
import 'package:milma_group/screens/login_page.dart';
import 'package:milma_group/session/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(milliseconds: 1500));
     await _checkSession();
  }

  Future<void> _checkSession() async {
    String? isLoggedIn = await Store.getLoggedIn();
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (isLoggedIn == 'yes') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => EventListScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Colors.white),
        child: Center(
          child: Image.asset(
            "assets/images/logo.png", // Replace with your logo path
            width: MediaQuery.of(context).size.width / 2,
            height: MediaQuery.of(context).size.width / 2,
          ),
        ),
      ),
    );
  }
}

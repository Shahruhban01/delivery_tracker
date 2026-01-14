import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

class DeliveryTrackerApp extends StatelessWidget {
  const DeliveryTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delivery Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        fontFamily: 'Roboto',
      ),
      home: Consumer<AuthService>(
        builder: (context, auth, _) {
          return auth.currentUser != null ? const HomeScreen() : const LoginScreen();
        },
      ),
    );
  }
}

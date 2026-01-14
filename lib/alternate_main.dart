// // alternative main.dart using FirebaseConfig:
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'config/firebase_config.dart';
// import 'app.dart';
// import 'services/auth_service.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   // Initialize Firebase using config helper
//   await FirebaseConfig.initialize();
  
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthService()),
//       ],
//       child: const DeliveryTrackerApp(),
//     ),
//   );
// }

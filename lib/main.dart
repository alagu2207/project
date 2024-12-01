import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project/cart.dart';
import 'package:project/favouriteitem.dart';
import 'package:project/login.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase asynchronously
  try {
    
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
    // Optionally, show an error screen or fallback UI
    // Get.off(ErrorPage()); // You can create an ErrorPage screen for the user.
  }

  // Run the app after Firebase initialization
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => CartProvider()), // CartProvider
        ChangeNotifierProvider(
            create: (context) => FavoriteProvider()), // FavoriteProvider
      ],
      child: const MyApp(),
    ),
  );
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Navigate to Home Screen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Get.off(
          LoginPage()); // Use Get.to() if you don't want to replace the screen.
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.jpg', // Ensure the correct asset path
              height: 200,
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

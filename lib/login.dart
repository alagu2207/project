import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:project/dummy.dart';
import 'Dashboard.dart';
import 'signuppage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false; // State to track loading
  bool _isPasswordVisible = false; // State to toggle password visibility

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color
      body: Center(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Center(
                    child: Image.asset(
                      'assets/logo.jpg',
                      height: 200.0,
                      width: 200.0,
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // Welcome Text
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          "Welcome Back!",
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          "Please log in to continue",
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 20.0),

                        // Email TextField
                        _buildTextField(
                          controller: emailController,
                          labelText: 'Email',
                          iconData: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20.0),

                        // Password TextField with Eye Toggle
                        _buildTextField(
                          controller: passwordController,
                          labelText: 'Password',
                          iconData: Icons.lock,
                          obscureText: !_isPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 10.0),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              // Handle forgot password logic
                            },
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              await _handleLogin(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.black),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                      ],
                    ),
                  ),

                  // Register Prompt
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      TextButton(
                        onPressed: () {
                          Get.offAll(SignUpPage());
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Loading Indicator
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper method for building text fields with icons
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData iconData,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        prefixIcon: Icon(iconData, color: Colors.deepPurple),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.deepPurple, width: 2.0),
        ),
      ),
      keyboardType: keyboardType,
    );
  }

  // Login logic
  // Login logic
Future<void> _handleLogin(BuildContext context) async {
  if (emailController.text.trim().isEmpty ||
      !emailController.text.trim().contains('@')) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter a valid email address.")),
    );
    return;
  }

  if (passwordController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password cannot be empty.")),
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    await Firebase.initializeApp();
    final auth = FirebaseAuth.instance;

    // Perform the login
    UserCredential userCredential = await auth.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    final user = userCredential.user;
    if (user != null) {
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Fetch the user document
      DocumentSnapshot userSnapshot = await userDocRef.get();
      if (userSnapshot.exists) {
        final updatedUserData = userSnapshot.data() as Map<String, dynamic>?;

        final username = updatedUserData?['name'] ?? 'New User';
        final role = updatedUserData?['role'] ?? 'user';  // Fetch the role

        // Show a snack bar greeting the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Welcome, $username!")),
        );

        // Check if the user is an admin
        if (role == 'admin') {
          // Navigate to Admin Dashboard to view all users
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminDashboard(userDetails: {},),  // Add an Admin Dashboard screen
            ),
          );
        } else {
          // Navigate to regular Dashboard for normal users
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Dashboard(userDetails: updatedUserData),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User document not found.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login failed")),
      );
    }
  } catch (e) {
    if (e is FirebaseAuthException) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = "No user found for this email.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password. Please try again.";
      } else {
        errorMessage = "An error occurred. Please try again.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Something went wrong. Please try again.")),
      );
    }
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:project/login.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController doorNoController = TextEditingController();

  String? selectedCity;
  String? selectedState;
  List<String> nearbyStreets = [];

  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Please enable location services in settings")),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permission denied")),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Location permissions are permanently denied")),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print('Position: ${position.latitude}, ${position.longitude}');

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        print('Placemark: $place');
        setState(() {
          cityController.text = place.locality ?? '';
          stateController.text = place.administrativeArea ?? '';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Unable to fetch address from location")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to get location: $e")),
      );
    }
  }

  @override
  void dispose() {
    cityController.dispose();
    stateController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    doorNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white, 
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Create an Account",
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 30.0),
            _buildTextField(nameController, 'Full Name', Icons.person),
            const SizedBox(height: 15.0),
            _buildTextField(emailController, 'Email', Icons.email,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 15.0),
            _buildTextField(phoneController, 'Phone Number', Icons.phone,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 15.0),
            _buildTextField(doorNoController, 'Address', Icons.home),
            const SizedBox(height: 15.0),
            _buildTextField(cityController, 'City', Icons.location_city),
            const SizedBox(height: 15.0),
            _buildTextField(stateController, 'State', Icons.map),
            const SizedBox(height: 15.0),
            _buildTextField(passwordController, 'Password', Icons.lock,
                obscureText: true),
            const SizedBox(height: 15.0),
            _buildTextField(
                confirmPasswordController, 'Confirm Password', Icons.lock,
                obscureText: true),
            const SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await _handleSignUp(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                      vertical: 14.0,
                      horizontal: 24.0), // Added horizontal padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        30.0), // Larger rounded corners for a softer, modern look
                  ),

                  shadowColor: Colors.deepPurpleAccent.withOpacity(
                      0.4), // Subtle shadow effect for a cleaner appearance
                  elevation:
                      6, // Slightly higher elevation for a more prominent button
                  side: BorderSide(
                      color: Colors.deepPurple,
                      width: 1.5), // Optional border for added definition
                ),
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                    fontWeight: FontWeight
                        .w600, // Slightly lighter font weight for a more elegant look
                    letterSpacing:
                        1.2, // Adding some spacing to the text for better readability
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? "),
                TextButton(
                  onPressed: () {
                    Get.offAll(LoginPage());
                  },
                  child: Text(
                    "Log In",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String labelText, IconData iconData,
      {TextInputType keyboardType = TextInputType.text,
      bool obscureText = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        prefixIcon: Icon(iconData, color: Colors.deepPurple),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.deepPurple, width: 2.0),
        ),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
    );
  }

  Future<void> _handleSignUp(BuildContext context) async {
    try {
      await _getCurrentLocation();

      if (!RegExp(r"^[^@]+@[^@]+\.[^@]+")
          .hasMatch(emailController.text.trim())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter a valid email address")),
        );
        return;
      }

      if (phoneController.text.trim().length < 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter a valid phone number")),
        );
        return;
      }

      if (passwordController.text.trim() !=
          confirmPasswordController.text.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match")),
        );
        return;
      }

      final auth = FirebaseAuth.instance;
      final existingUser =
          await auth.fetchSignInMethodsForEmail(emailController.text.trim());

      if (existingUser.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User already exists")),
        );
        return;
      }

      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user == null) {
        throw Exception("Failed to create user");
      }

      final usersCollection = FirebaseFirestore.instance.collection('users');
      await usersCollection.doc(userCredential.user!.uid).set({
        'Id': userCredential.user!.uid,
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'doorNo': doorNoController.text.trim(),
        'city': cityController.text.trim(),
        'state': stateController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }
}

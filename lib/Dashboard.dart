import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:project/Product.dart';
import 'package:project/data.dart';
import 'package:project/drawer.dart';
import 'package:project/items/Cakes.dart';
import 'package:project/items/Snacks.dart';
import 'package:project/items/Sweets.dart';
import 'package:project/login.dart';
import 'package:project/showall.dart';

class Dashboard extends StatefulWidget {
  final Map<String, dynamic>? userDetails;

  const Dashboard({super.key, this.userDetails});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final PageController _pageController = PageController();
  double _rating = 3.0;
  bool _isLiked = false; // To control page view
  final List<String> _images = [
    'assets/dashboard1.jpg',
    'assets/dashboard2.jpg',
    'assets/dashboard3.jpg',
    'assets/dashboard4.jpg',
  ]; // List of image paths
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    const String apiUrl =
        'https://673f182fa9bc276ec4b722c5.mockapi.io/Products'; // Replace with your API
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          // Check if the widget is still in the tree before calling setState
          setState(() {
            _products = data.map((json) => Product.fromJson(json)).toList();
          });
        }
      } else {
        if (mounted) {
          print('Failed to load products');
        }
      }
    } catch (e) {
      if (mounted) {
        print('Error: $e');
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onArrowClicked(bool isNext) {
    setState(() {
      if (isNext) {
        if (_currentIndex < _images.length - 1) {
          _currentIndex++;
          _pageController.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      } else {
        if (_currentIndex > 0) {
          _currentIndex--;
          _pageController.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final username = widget.userDetails?['name'] ?? 'New User';
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          toolbarHeight: screenHeight * 0.1,
          backgroundColor: const Color(0xFFFC0500),
          title: Text(
            "Welcome, $username!",
            style: const TextStyle(
                fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              color: Colors.white,
              icon: const Icon(Icons.logout),
              onPressed: () {
                // Perform logout logic (e.g., clear user session, etc.)
                // Navigate to Login Page
                Get.offAll(
                    LoginPage()); // Assumes a route is defined for '/login'
              },
            ),
            const SizedBox(width: 20),
          ],
        ),
        drawer: Drawer(
          child: Drawers(
            favorites: [], // Pass the favorite items list
            userDetails: widget
                .userDetails, // Pass the userDetails from state or Firebase
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                  child: Container(
                    height: screenHeight * 0.25,
                    color: Colors.blue,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return Image.asset(
                              _images[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            );
                          },
                          onPageChanged: (index) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                        ),
                        Positioned(
                          left: 10,
                          top: screenHeight * 0.1 - 20,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            color: Colors.black.withOpacity(0.5),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white, size: 40),
                              onPressed: () => _onArrowClicked(false),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 10,
                          top: screenHeight * 0.1 - 20,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            color: Colors.black.withOpacity(0.5),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_forward,
                                  color: Colors.white, size: 40),
                              onPressed: () => _onArrowClicked(true),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCategoryItem(
                        'assets/dashboard5.jpg',
                        'SWEETS',
                        screenWidth,
                        Sweets(
                          userDetails: widget.userDetails ?? {},
                        )),
                    buildCategoryItem(
                      'assets/dashboard6.jpg',
                      'CAKES',
                      screenWidth,
                      Cakes(
                        userDetails: widget.userDetails ?? {},
                      ),
                    ),
                    buildCategoryItem(
                        'assets/dashboard7.jpg',
                        'SNACKS',
                        screenWidth,
                        Snacks(
                          userDetails: widget.userDetails ?? {},
                        )),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment:
                            Alignment.centerLeft, // Aligns the text to the left
                        child: Text(
                          'Featured Items',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () {
                        Get.to(() => ProductPage(_products));
                        ; // Assuming `[]` is a placeholder.
                      },
                      child: Text(
                        "See all",
                        style: TextStyle(fontSize: 20),
                      ),
                    )
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _products.map((product) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Data(
                              id: product.id,
                              price: product.price,
                              image: product.image,
                              name: product.name,
                              initialRating: product.initialRating,
                            ),
                            SizedBox(
                              width: 20, // Adjust the width for the gap
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCategoryItem(
      String imagePath, String label, double screenWidth, Widget targetPage) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: screenWidth * 0.3,
          width: screenWidth * 0.3,
          color: Colors.orange,
          child: Stack(
            children: [
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                height: screenWidth * 0.3,
                width: screenWidth * 0.3,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  height: screenWidth * 0.08,
                  width: screenWidth * 0.3,
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

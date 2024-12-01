import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/Cartpage.dart';
import 'package:project/Dashboard.dart';
import 'package:project/Favourite.dart';
import 'package:project/data.dart';
import 'package:project/items/additems.dart';
import 'package:project/items/editdata.dart';
import 'package:project/login.dart';
import 'package:project/orderlist.dart';
import 'package:project/profile.dart';

class Drawers extends StatelessWidget {
  final List<Data> favorites;
  final Map<String, dynamic>? userDetails;

  const Drawers({
    Key? key,
    required this.favorites,
    this.userDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header displaying user information
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFFFC0500)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.blue),
                ),
                const SizedBox(height: 10),
                Text(
                  userDetails?['name'] ?? 'Guest User', // Display name or default 'Guest User'
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  userDetails?['email'] ?? 'guest@example.com', // Display email or default email
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          // Home / Dashboard navigation
          ListTile(
            leading: const Icon(Icons.dashboard), // Dashboard icon
            title: const Text('Home'),
            onTap: () => Get.to(Dashboard(userDetails: userDetails ?? {})),
          ),
          // Favourite items navigation
          ListTile(
            leading: const Icon(Icons.favorite_border), // Favorite icon with border
            title: const Text('Favourite'),
            onTap: () => Get.to(FavouriteScreen(favorites: favorites, userDetails: userDetails ?? {})),
          ),
          // Cart page navigation
          ListTile(
            leading: const Icon(Icons.shopping_bag), // Shopping bag icon for Cart
            title: const Text('Cart'),
            onTap: () => Get.to(CartPage(userDetails: userDetails ?? {})),
          ),
          // User Profile navigation
          ListTile(
            leading: const Icon(Icons.account_circle), // Profile icon
            title: const Text('Profile'),
            onTap: () => Get.to(UserDetails(userDetails: userDetails ?? {})),
          ),
          // Add items to Cart navigation

          // Ordered list navigation
          ListTile(
            leading: const Icon(Icons.list_alt), // Ordered list icon
            title: const Text('Ordered List'),
            onTap: () => Get.to(
              OrderListPage(
                userDetails: userDetails ?? {},
                userId: userDetails?['Id'] ?? '',
              ),
            ),
          ),
          // Edit product data navigation
          

          // Logout button
          
        ],
      ),
    );
  }
}

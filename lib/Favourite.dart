import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/data.dart';
import 'package:project/drawer.dart';

class FavouriteScreen extends StatelessWidget {
  final Map<String, dynamic>? userDetails;
  final List<Data> favorites;

  const FavouriteScreen({
    Key? key,
    required this.userDetails,
    required this.favorites,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
        final username = userDetails?['name'] ?? 'New User';
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Top Favourites',style: const TextStyle(
                fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),)),
        body: const Center(
          child: Text('Please log in to view your top favourites.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFFFC0500),
        title: const Text('Favourites',style: const TextStyle(
                fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
     drawer: Drawer(
  child: Drawers(
    favorites: [],
    userDetails: userDetails,
  ),
),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .orderBy('rating', descending: true) // Sort by highest rating
            .limit(10) // Limit to top 10 favorites
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No top favourites found.'));
          }

          final favoriteDocs = snapshot.data!.docs;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: List.generate(
                  (favoriteDocs.length / 2).ceil(),
                  (index) {
                    int firstProductIndex = index * 2;
                    int secondProductIndex = firstProductIndex + 1;

                    // Extract data for the first and second product
                    final firstProduct = favoriteDocs[firstProductIndex].data()
                        as Map<String, dynamic>;
                    final secondProduct =
                        secondProductIndex < favoriteDocs.length
                            ? favoriteDocs[secondProductIndex].data()
                                as Map<String, dynamic>
                            : null;

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Display the first product
                          Data(
                            id: favoriteDocs[firstProductIndex].id,
                            price: firstProduct['price'],
                            image: firstProduct['image'],
                            name: firstProduct['name'],
                            initialRating: firstProduct['initialRating'] ?? 0,
                          ),
                          const SizedBox(width: 10), // Gap between items
                          // Display the second product if it exists
                          if (secondProduct != null)
                            Data(
                              id: favoriteDocs[secondProductIndex].id,
                              price: secondProduct['price'],
                              image: secondProduct['image'],
                              name: secondProduct['name'],
                              initialRating:
                                  secondProduct['initialRating'] ?? 0,
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/checkoutpage.dart';
import 'package:project/data.dart';
import 'package:project/drawer.dart';

class CartPage extends StatelessWidget {
  final Map<String, dynamic>? userDetails;

  const CartPage({
    Key? key,
    required this.userDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final username = userDetails?['name'] ?? 'New User';
    final user = FirebaseAuth.instance.currentUser;

    // Color constants
    const primaryColor = Colors.blueAccent;

    if (user == null) {
      return const Center(child: Text('User not logged in'));
    }

    return Scaffold(
      appBar: AppBar( 
        title: Text('$username\'s Cart',style: const TextStyle(
                fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
           backgroundColor: const Color(0xFFFC0500),
        elevation: 0,
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
            .collection('cart')
            .orderBy('rating', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No items in your cart.'));
          }

          final cartDocs = snapshot.data!.docs;

          // Calculate total price
          final totalPrice = cartDocs.fold<double>(0.0, (total, doc) {
            final data = doc.data() as Map<String, dynamic>;
            final price = double.tryParse(data['price']?.toString() ?? '0') ?? 0.0;
            final quantity = data['quantity'] ?? 1;
            return total + (price * quantity);
          });

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: cartDocs.length,
                  itemBuilder: (context, index) {
                    final productData =
                        cartDocs[index].data() as Map<String, dynamic>;
                    return _buildCartItem(
                      context,
                      cartDocs[index],
                      productData,
                    );
                  },
                ),
              ),
              // Display total price
              Container(
                padding: const EdgeInsets.all(12.0),
                color: primaryColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: \$${totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
  onPressed: () {
    final cartItems = cartDocs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'name': data['name'],
        'price': data['price'],
        'quantity': data['quantity'],
      };
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          totalAmount: totalPrice,
          userDetails: userDetails ?? {},
          cartItems: cartItems,
        ),
      ),
    );
  },
  style: ElevatedButton.styleFrom(
    foregroundColor: primaryColor,
    backgroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  ),
  child: const Text(
    'Checkout',
    style: TextStyle(fontSize: 16),
  ),
),

                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, DocumentSnapshot cartDoc,
      Map<String, dynamic> productData) {
    int currentQuantity = productData['quantity'] ?? 1;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Data(
              id: cartDoc.id,
              price: productData['price'],
              image: productData['image'],
              name: productData['name'],
              initialRating: productData['intialrating'] ?? 0,
            ),
            const Spacer(),
            DropdownButton<int>(
              value: currentQuantity,
              items: List.generate(
                10,
                (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text('${index + 1}'),
                ),
              ),
              onChanged: (newQuantity) async {
                if (newQuantity != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .collection('cart')
                      .doc(cartDoc.id)
                      .update({'quantity': newQuantity});
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

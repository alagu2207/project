import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this import for formatting the timestamp
import 'package:project/drawer.dart';

class OrderListPage extends StatelessWidget {
  final String userId; // Pass the userId to fetch their orders
  final Map<String, dynamic> userDetails; // User details for the drawer

  const OrderListPage(
      {Key? key, required this.userId, required this.userDetails})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: const Color(0xFFFC0500),
      ),
      drawer: Drawer(
        child: Drawers(
          favorites: [], // Provide the actual data if needed
          userDetails: userDetails, // Use the passed userDetails
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId) // Replace with the actual userId
            .collection('orders')
            .orderBy('timestamp',
                descending: true) // Fetch orders sorted by timestamp
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;

              // Extract order data
              final name = order['name'] ?? 'Unknown';
              final address = order['address'] ?? 'No address';
              final phone = order['phone'] ?? 'No phone number';
              final totalAmount = order['totalAmount']?.toDouble() ?? 0.0;
              final grandTotal = order['grandTotal']?.toDouble() ?? 0.0;
              final timestamp = order['timestamp'];

              // Check if timestamp exists and is a valid Timestamp, then convert
              String formattedTimestamp = '';

              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 5,
                child: InkWell(
                  onTap: () {
                    // Navigate to detailed order view if needed
                    // For example, pass order data to another page
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30.0,
                          backgroundColor: const Color(0xFFFC0500),
                          child: Icon(
                            Icons.shopping_cart,
                            color: Colors.white,
                            size: 30.0,
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'Address: $address',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14.0,
                                ),
                              ),
                              Text(
                                'Phone: $phone',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14.0,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Total: \₹${totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'Grand Total: \₹${grandTotal.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'Order Date: $timestamp',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

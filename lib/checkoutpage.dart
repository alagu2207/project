import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/ordersummary.dart';

class CheckoutPage extends StatelessWidget {
  final double totalAmount;
  final Map<String, dynamic> userDetails;
  final List<Map<String, dynamic>> cartItems;

  const CheckoutPage({
    Key? key,
    required this.totalAmount,
    required this.userDetails,
    required this.cartItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const deliveryCharge = 20.0; // Set a fixed delivery charge
    final grandTotal = totalAmount + deliveryCharge;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: const Color(0xFFFC0500),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Details
            const Text(
              'Delivery Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Address field with icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${userDetails['doorNo']}, ${userDetails['city']}, ${userDetails['state']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditDetailsDialog(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 24, thickness: 1, color: Colors.grey),
            const SizedBox(height: 8),

            // Order Summary
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // List of cart items with better styling
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  final price =
                      double.tryParse(item['price'].toString()) ?? 0.0;
                  final quantity =
                      int.tryParse(item['quantity'].toString()) ?? 0;
                  final totalPrice = price * quantity;

                  return Card(
                    elevation: 3.0,
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      title: Text(item['name'] ?? 'Unknown Product'),
                      subtitle: Text(
                          'Quantity: $quantity  |  Price: \₹${price.toStringAsFixed(2)}'),
                      trailing: Text(
                        '\₹${totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 24, thickness: 1, color: Colors.grey),
            const SizedBox(height: 16),

            // Total Amount Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount:'),
                Text('\₹${totalAmount.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Delivery Charge:'),
                Text('\₹${deliveryCharge.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Grand Total:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '\₹${grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Confirm Order Button
            ElevatedButton(
              onPressed: () {
                final order = Order(
                  name: userDetails['name'] ?? 'Unknown',
                  address:
                      '${userDetails['doorNo']}, ${userDetails['city']}, ${userDetails['state']}',
                  phone: userDetails['phone'] ?? '',
                  cartItems: cartItems,
                  totalAmount: totalAmount,
                  deliveryCharge: deliveryCharge,
                  grandTotal: grandTotal,
                );

                // Convert to JSON or save in your database
                final orderData = order.toJson();
                // Example: Save to Firebase Firestore
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(userDetails['Id']) // Replace with the actual user UID
                    .collection('orders')
                    .add(orderData);
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(userDetails['Id']) // Replace with the actual user UID
                    .collection('cart')
                    .get()
                    .then((querySnapshot) {
                  // Loop through each document in the cart collection and delete them
                  for (var doc in querySnapshot.docs) {
                    doc.reference.delete();
                  }
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order placed successfully!')),
                );

                // Navigate to Order Summary page
                Get.offAll(
                  OrderSummary(
                    name: userDetails['name'] ?? 'Unknown',
                    address:
                        '${userDetails['doorNo']}, ${userDetails['city']}, ${userDetails['state']}',
                    phone: userDetails['phone'] ?? '',
                    cartItems: cartItems,
                    totalAmount: totalAmount,
                    deliveryCharge: deliveryCharge,
                    grandTotal: grandTotal,
                    userDetails: userDetails,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                backgroundColor: const Color(0xFFFC0500),
              ),
              child: const Text(
                'Confirm Order',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'For any queries, contact Customer Care: +1-800-123-4567',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  // Function to show the edit details dialog
  void _showEditDetailsDialog(BuildContext context) {
    final TextEditingController nameController =
        TextEditingController(text: userDetails['name']);
    final TextEditingController addressController = TextEditingController(
        text: '${userDetails['doorNo']}, ${userDetails['city']}, ${userDetails['state']}');
    final TextEditingController phoneController =
        TextEditingController(text: userDetails['phone']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Update the userDetails map with new values
                userDetails['name'] = nameController.text;
                userDetails['address'] = addressController.text;
                userDetails['phone'] = phoneController.text;
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}


class Order {
  final String name;
  final String address;
  final String phone;
  final List<Map<String, dynamic>> cartItems;
  final double totalAmount;
  final double deliveryCharge;
  final double grandTotal;

  Order({
    required this.name,
    required this.address,
    required this.phone,
    required this.cartItems,
    required this.totalAmount,
    required this.deliveryCharge,
    required this.grandTotal,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'cartItems': cartItems,
      'totalAmount': totalAmount,
      'deliveryCharge': deliveryCharge,
      'grandTotal': grandTotal,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

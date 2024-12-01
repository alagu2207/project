import 'package:flutter/material.dart';
import 'package:project/drawer.dart';

class OrderSummary extends StatelessWidget {
  final String name;
  final String address;
  final String phone;
  final List<Map<String, dynamic>> cartItems;
  final double totalAmount;
  final double deliveryCharge;
  final double grandTotal;
  final dynamic userDetails;  // Add this parameter

  const OrderSummary({
    Key? key,
    required this.name,
    required this.address,
    required this.phone,
    required this.cartItems,
    required this.totalAmount,
    required this.deliveryCharge,
    required this.grandTotal,
    required this.userDetails,  // Pass userDetails as a parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Summary'),
        backgroundColor: const Color(0xFFFC0500),
      ),
      drawer: Drawer(
        child: Drawers(
          favorites: [], // Pass the favorite items list
          userDetails: userDetails, // Use userDetails passed as parameter
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Name:', name),
            _buildDetailRow('Address:', address),
            _buildDetailRow('Phone:', phone),
            const SizedBox(height: 16),
            const Text(
              'Order Items:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    child: ListTile(
                      leading: Icon(Icons.shopping_cart, color: Colors.red),
                      title: Text(item['name'] ?? 'Unknown Product'),
                      subtitle: Text(
                          'Quantity: ${item['quantity']}  |  Price: \₹${item['price']}'),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 24, thickness: 2),
            _buildSummaryRow('Total Amount:', totalAmount),
            _buildSummaryRow('Delivery Charge:', deliveryCharge),
            _buildSummaryRow('Grand Total:', grandTotal, isBold: true),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '\₹${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

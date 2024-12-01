import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/items/additems.dart';
import 'package:project/items/editdata.dart';
import 'package:project/login.dart';
class AdminDashboard extends StatelessWidget {
  final Map<String, dynamic> userDetails;
  @override
   AdminDashboard({required this.userDetails});
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Perform logout logic (e.g., clear user session, etc.)
              // Navigate to Login Page
              Get.offAll(LoginPage()); // Assumes a route is defined for '/login'
            },
          ),
          const SizedBox(width: 20),
        ],
        title: Text('Admin '),
        backgroundColor: const Color(0xFFFC0500),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Edit Data'),
              onTap: () => Get.to(
                EditProductPage(
               // Pass userDetails or an empty map if null
                  // Pass null or actual product data if available
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline), // Add items icon
              title: const Text('Add Items to Cart'),
              onTap: () => Get.to(AddItemPage(userDetails: userDetails ?? {})), // Pass userDetails to the AddItemPage
            ),
          ],
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('users').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List<DocumentSnapshot> allUsers = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: allUsers.length,
            itemBuilder: (context, index) {
              final userData = allUsers[index].data() as Map<String, dynamic>;
              final username = userData['name'] ?? 'No Name';
              final email = userData['email'] ?? 'No Email';
              final phone = userData['phone'] ?? 'No Phone';
              final city = userData['city'] ?? 'No City';
              final doorNo = userData['doorNo'] ?? 'No Door No';
              final state = userData['state'] ?? 'No State';
              final role = userData['role'] ?? 'No Role';
              final userId = userData['Id'];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  title: Text(username,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text('Email: $email', style: TextStyle(fontSize: 14)),
                      Text('Phone: $phone', style: TextStyle(fontSize: 14)),
                      Text('City: $city', style: TextStyle(fontSize: 14)),
                      Text('Door No: $doorNo', style: TextStyle(fontSize: 14)),
                      Text('State: $state', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      if (userId != null) {
                        try {
                          // Delete from Firestore
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .delete();

                          // Optionally show a success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('User deleted successfully')),
                          );
                        } catch (e) {
                          print('Error deleting user: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error deleting user')),
                          );
                        }
                      }
                    },
                  ),
                  onTap: () {
                    print('Navigating to details for userId: $userId');
                    if (userId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailPage(userData: userData),
                        ),
                      );
                    } else {
                      print('Error: User ID is null');
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class UserDetailPage extends StatelessWidget {
  final Map<String, dynamic> userData;

  UserDetailPage({required this.userData});

  @override
  Widget build(BuildContext context) {
    final username = userData['name'] ?? 'No Name';
    final email = userData['email'] ?? 'No Email';
    final phone = userData['phone'] ?? 'No Phone';
    final city = userData['city'] ?? 'No City';
    final doorNo = userData['doorNo'] ?? 'No Door No';
    final state = userData['state'] ?? 'No State';
    final role = userData['role'] ?? 'No Role';
    final userId = userData['Id']; // Correctly access 'Id' field for userId

    return Scaffold(
      appBar: AppBar(
        title: Text('$username Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: $username',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Email: $email', style: TextStyle(fontSize: 16)),
            Text('Phone: $phone', style: TextStyle(fontSize: 16)),
            Text('City: $city', style: TextStyle(fontSize: 16)),
            Text('Door No: $doorNo', style: TextStyle(fontSize: 16)),
            Text('State: $state', style: TextStyle(fontSize: 16)),
    
            SizedBox(height: 20),
            Divider(),
            // Wrap the StreamBuilder with Expanded to give it a bounded height
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('orders')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    // Debugging log
                    print('No orders found for user: $userId');
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
                    
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 5,
                        child: InkWell(
                          onTap: () {
  // Navigate to the order detail page and pass the order data
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => OrderDetailPage(orderData: order),
    ),
  );
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
                                      const SizedBox(height: 8.0),
                                      Text('Address: $address'),
                                      Text('Phone: $phone'),
                                      Text('Amount: \₹${totalAmount.toStringAsFixed(2)}'),
                                      Text('Grand Total: \₹${grandTotal.toStringAsFixed(2)}'),
                                      Text('Order Date: $timestamp'),
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
            ),
          ],
        ),
      ),
    );
  }
}











class OrderDetailPage extends StatelessWidget {
  final Map<String, dynamic> orderData;

  OrderDetailPage({required this.orderData});

  @override
  Widget build(BuildContext context) {
    final cartItems = orderData['cartItems'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderDetail('Order Name', orderData['name']),
              _buildOrderDetail('Address', orderData['address']),
              _buildOrderDetail('Phone', orderData['phone']),
              _buildOrderDetail(
                'Amount',
                '₹${_formatAmount(orderData['totalAmount'])}',
              ),
              _buildOrderDetail(
                'Grand Total',
                '₹${_formatAmount(orderData['grandTotal'])}',
              ),
              SizedBox(height: 20),
              Text(
                'Cart Items',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              SizedBox(height: 10),
              if (cartItems.isEmpty)
                Center(child: Text('No items in the cart', style: TextStyle(fontSize: 16, color: Colors.grey))),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 10),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        item['name'] ?? 'Item name',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Row(
                        children: [
                          Text('Qty: ${item['quantity'] ?? '0'} - ', style: TextStyle(fontSize: 14)),
                          Text('₹${_formatAmount(item['price'])}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      trailing: Icon(Icons.shopping_cart_outlined, color: Colors.blue),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom widget to build order details with title and value
  Widget _buildOrderDetail(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        '$title: ${value ?? 'Not available'}',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
      ),
    );
  }

  // Helper method to safely format amounts
  String _formatAmount(dynamic amount) {
    if (amount is String) {
      final parsedAmount = double.tryParse(amount);
      if (parsedAmount != null) {
        return parsedAmount.toStringAsFixed(2);
      }
    } else if (amount is num) {
      return amount.toDouble().toStringAsFixed(2);
    }
    return '0.00';
  }
}




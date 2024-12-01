import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project/drawer.dart';

class UserDetails extends StatefulWidget {
  final Map<String, dynamic> userDetails;

  const UserDetails({Key? key, required this.userDetails}) : super(key: key);

  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  late Map<String, dynamic> userDetails;

  @override
  void initState() {
    super.initState();
    userDetails = widget.userDetails; // Initialize the userDetails
  }

  @override
  Widget build(BuildContext context) {
    final username = userDetails['name'] ?? 'New User';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Details',
          style: TextStyle(
              fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFC0500), Color(0xFFFF5733)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: Drawers(
          favorites: [],
          userDetails: userDetails,
        ),
      ),
      body: userDetails.isEmpty
          ? const Center(
              child: Text(
                'User data not available',
                style: TextStyle(fontSize: 18),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Profile Avatar
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: userDetails['profilePicture'] !=
                                    null
                                ? NetworkImage(userDetails['profilePicture'])
                                : null,
                            child: userDetails['profilePicture'] == null
                                ? Text(
                                    username.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                        fontSize: 40, color: Colors.white),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: IconButton(
                              onPressed: () {
                                _showEditDialog(context);
                              },
                              icon: const Icon(
                                Icons.edit,
                                size: 20,
                                color: Colors.white,
                              ),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFFFC0500),
                                shape: const CircleBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // User Details Card
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildDetails(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  List<Widget> _buildDetails() {
    final fields = {
      "Name": userDetails['name'],
      "Email": userDetails['email'],
      "Phone": userDetails['phone'],
      "Address": userDetails['doorNo'],
      "City": userDetails['city'],
      "State": userDetails['state'],
    };

    return fields.entries.map((entry) {
      return _buildDetailRow(entry.key, entry.value);
    }).toList();
  }

  Widget _buildDetailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info, color: Colors.blueAccent.shade400),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$title: ${value ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final nameController = TextEditingController(text: userDetails['name']);
    final emailController = TextEditingController(text: userDetails['email']);
    final phoneController = TextEditingController(text: userDetails['phone']);
    final addressController =
        TextEditingController(text: userDetails['doorNo']);
    final cityController = TextEditingController(text: userDetails['city']);
    final stateController = TextEditingController(text: userDetails['state']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit User Details'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField('Name', nameController),
                _buildTextField('Phone', phoneController),
                _buildTextField('Address', addressController),
                _buildTextField('City', cityController),
                _buildTextField('State', stateController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _updateUserDetails(
                  nameController.text,
                  emailController.text,
                  phoneController.text,
                  addressController.text,
                  cityController.text,
                  stateController.text,
                );
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Future<void> _updateUserDetails(
    String name,
    String email,
    String phone,
    String address,
    String city,
    String state,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userDetails['Id']) // Ensure `id` is part of `userDetails`
          .update({
        'name': name,
        'phone': phone,
        'doorNo': address,
        'city': city,
        'state': state,
      });

      setState(() {
        userDetails = {
          ...userDetails,
          'name': name,
          'email': email,
          'phone': phone,
          'doorNo': address,
          'city': city,
          'state': state,
        };
      });

      _showSnackBar("User details updated successfully.");
    } catch (e) {
      print("Error updating user details: $e");
      _showSnackBar("Failed to update user details.");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

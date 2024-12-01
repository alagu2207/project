import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project/drawer.dart';

class AddItemPage extends StatefulWidget {
  final dynamic userDetails;

  const AddItemPage({required this.userDetails});

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  double initialRating = 0.0;
  String? selectedCategory;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> uploadProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    const String apiUrl =
        'https://673f182fa9bc276ec4b722c5.mockapi.io/Products';
    final productData = {
      'name': nameController.text,
      'price': priceController.text,
      'image': imageController.text,
      'initialRating': initialRating,
      'items': selectedCategory,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(productData),
      );

      if (response.statusCode == 201) {
        _showSnackBar('Product uploaded successfully!', Colors.green);
        _clearForm();
      } else {
        _showSnackBar('Failed to upload product.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error occurred. Please try again.', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  void _clearForm() {
    nameController.clear();
    priceController.clear();
    imageController.clear();
    setState(() {
      initialRating = 0.0;
      selectedCategory = null;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
        backgroundColor: const Color(0xFFFC0500),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: ListView(
              children: [
                _buildImagePreview(),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: imageController,
                  label: 'Image URL',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter an image URL'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: nameController,
                  label: 'Name',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter a name'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: priceController,
                  label: 'Price',
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter a price'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildRatingSlider(),
                const SizedBox(height: 16),
                _buildDropdown(),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: uploadProduct,
                        child: const Text('Submit'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          // Button color
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(30), // Rounded corners
                          ),
                          elevation: 5,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      width: double.infinity,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.deepPurple.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.deepPurple),
          ),
        ),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildRatingSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Initial Rating',
            style: TextStyle(fontSize: 16, color: Colors.deepPurple)),
        Slider(
          value: initialRating,
          min: 0.0,
          max: 5.0,
          divisions: 5,
          label: initialRating.toStringAsFixed(1),
          onChanged: (value) {
            setState(() {
              initialRating = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedCategory,
      decoration: const InputDecoration(labelText: 'Items Category'),
      items: ['cakes', 'snacks', 'sweets', 'others']
          .map((item) =>
              DropdownMenuItem<String>(value: item, child: Text(item)))
          .toList(),
      onChanged: (value) {
        setState(() {
          selectedCategory = value;
        });
      },
      validator: (value) => value == null ? 'Please select a category' : null,
    );
  }

  Widget _buildImagePreview() {
    return imageController.text.isEmpty
        ? Center(
            child: Container(
              color: Colors.grey[200],
              height: 200,
              width: 200,
              child: const Center(
                  child:
                      Text('No Image', style: TextStyle(color: Colors.grey))),
            ),
          )
        : SizedBox(
            height: 200,
            width: 200,
            child: Center(
              child: Image.network(
                imageController.text,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                      child: Text('Invalid image URL',
                          style: TextStyle(color: Colors.red)));
                },
              ),
            ),
          );
  }
}

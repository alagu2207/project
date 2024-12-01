import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditProductPage extends StatefulWidget {
  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final String apiUrl = 'https://673f182fa9bc276ec4b722c5.mockapi.io/Products/';
  bool _isLoading = true;
  List<dynamic> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        _showSnackBar('Failed to load products.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error occurred. Please try again.', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> deleteProduct(String id) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.delete(Uri.parse('$apiUrl$id'));
      if (response.statusCode == 200) {
        _showSnackBar('Product deleted successfully!', Colors.green);
        fetchProducts(); // Refresh the list after deletion
      } else {
        _showSnackBar('Failed to delete product.', Colors.red);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: product['image'] != null
                        ? Image.network(
                            product['image'],
                            height: 50,
                            width: 50,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.image);
                            },
                          )
                        : const Icon(Icons.image),
                    title: Text(product['name']),
                    subtitle: Column(
                      children: [
                        Text('Price: \₹${product['price']}'),
                         Text('Item category: \₹${product['items']}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final result = await showDialog(
                              context: context,
                              builder: (context) =>
                                  EditProductForm(product: product),
                            );
                            if (result == true) {
                              fetchProducts(); // Refresh the list if the product was updated
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Product'),
                                content: const Text(
                                    'Are you sure you want to delete this product?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      deleteProduct(product['id']);
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class EditProductForm extends StatefulWidget {
  final Map<String, dynamic> product;

  const EditProductForm({Key? key, required this.product}) : super(key: key);

  @override
  _EditProductFormState createState() => _EditProductFormState();
}

class _EditProductFormState extends State<EditProductForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _imageController;
  late String _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product['name']);
    _priceController =
        TextEditingController(text: widget.product['price'].toString());
    _imageController = TextEditingController(text: widget.product['image']);
    _selectedCategory = widget.product['items'] ?? ['items'];
  }

  Future<void> updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final updatedProduct = {
      'name': _nameController.text,
      'price': _priceController.text,
      'image': _imageController.text,
      'items': _selectedCategory,
    };

    try {
      final response = await http.put(
        Uri.parse(
            'https://673f182fa9bc276ec4b722c5.mockapi.io/Products/${widget.product['id']}'),
        body: json.encode(updatedProduct),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Product updated successfully!'),
              backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to update product.'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error occurred. Please try again.'),
            backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Edit Product'),
      ),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Image preview
                      _imageController.text.isEmpty
                          ? const Icon(
                              Icons.image,
                              size: 100,
                              color: Colors.grey,
                            )
                          : Image.network(
                              _imageController.text,
                              height: 100,
                              width: 100,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.broken_image,
                                size: 100,
                                color: Colors.grey,
                              ),
                            ),
                      const SizedBox(height: 16),
                      // Product Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Product Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a product name.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Price
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a price.';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Image URL
                      TextFormField(
                        controller: _imageController,
                        decoration: const InputDecoration(
                          labelText: 'Image URL',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an image URL.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Dropdown Category
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration:
                            const InputDecoration(labelText: 'Items Category'),
                        items: ['cakes', 'snacks', 'sweets', 'others']
                            .map((item) =>
                                DropdownMenuItem<String>(value: item, child: Text(item)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: updateProduct,
                            child: const Text('Update'),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}


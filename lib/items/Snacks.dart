import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project/Product.dart';
import 'package:project/data.dart';
import 'package:project/drawer.dart';

class Snacks extends StatefulWidget {
    final Map<String, dynamic> userDetails;
  const Snacks({super.key, required this.userDetails});

  @override
  State<Snacks> createState() => _CakesState();
}

class _CakesState extends State<Snacks> {
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    const String apiUrl =
        'https://673f182fa9bc276ec4b722c5.mockapi.io/Products?items=snacks';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _products = data.map((json) => Product.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        print('Failed to load products');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(     backgroundColor: const Color(0xFFFC0500),
        title: const Text("Snacks",style: const TextStyle(
                fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      drawer: Drawer(
        child: Drawers(
          favorites: [],
          userDetails: widget.userDetails, // Use widget.userDetails
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(child: Text('No products available'))
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children:
                          List.generate((_products.length / 2).ceil(), (index) {
                        int firstProductIndex = index * 2;
                        int secondProductIndex = firstProductIndex + 1;

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              // Display the first product
                              Data(
                                price: _products[firstProductIndex].price,
                                image: _products[firstProductIndex].image,
                                name: _products[firstProductIndex].name,
                                initialRating:
                                    _products[firstProductIndex].initialRating, id: _products[firstProductIndex].id,
                              ),
                              SizedBox(width: 10), // Gap between items
                              // Display the second product if it exists
                              if (secondProductIndex < _products.length)
                                Data(
                                  price: _products[secondProductIndex].price,
                                  image: _products[secondProductIndex].image,
                                  name: _products[secondProductIndex].name,
                                  initialRating: _products[secondProductIndex]
                                      .initialRating, id: _products[firstProductIndex].id,
                                ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
    );
  }
}

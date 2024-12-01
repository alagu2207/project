import 'package:flutter/material.dart';
import 'package:project/Product.dart';
import 'package:project/data.dart';

class ProductPage extends StatelessWidget {
  final List<Product> products;

  const ProductPage(this.products, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Products",style: const TextStyle(
                fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
           backgroundColor: const Color(0xFFFC0500),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: List.generate(
              (products.length / 2).ceil(), // Create pairs of products
              (index) {
                int firstProductIndex = index * 2;
                int secondProductIndex = firstProductIndex + 1;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // Display the first product
                      Data(
                        id: products[firstProductIndex].id,
                        price: products[firstProductIndex].price,
                        image: products[firstProductIndex].image,
                        name: products[firstProductIndex].name,
                        initialRating:
                            products[firstProductIndex].initialRating,
                      ),
                      SizedBox(width: 10), // Gap between items
                      // Display the second product if it exists
                      if (secondProductIndex < products.length)
                        Data(
                          id: products[secondProductIndex].id,
                          price: products[secondProductIndex].price,
                          image: products[secondProductIndex].image,
                          name: products[secondProductIndex].name,
                          initialRating:
                              products[secondProductIndex].initialRating,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

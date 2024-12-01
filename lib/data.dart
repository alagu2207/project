import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:project/cart.dart';
import 'package:project/favouriteitem.dart';
import 'package:provider/provider.dart';

class Data extends StatefulWidget {
  final String price;
  final String image;
  final String name;
  final String id;
  final double initialRating;

  const Data({
    super.key,
    required this.id,
    required this.price,
    required this.image,
    required this.name,
    required this.initialRating,
  });

  @override
  State<Data> createState() => _DataState();
}

class _DataState extends State<Data> {
  bool _isLiked = false;
  late double _rating;
  bool _isInCart = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
    _checkIfFavorite();
    _checkIfInCart();
  }

  Future<void> _checkIfFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.id);

      final docSnapshot = await docRef.get();
      setState(() {
        _isLiked = docSnapshot.exists;
      });
    }
  }

  Future<void> _checkIfInCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(widget.id);

      final docSnapshot = await docRef.get();
      setState(() {
        _isInCart = docSnapshot.exists;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildContent();
  }

  Widget buildContent() {
    return Container(
      height: 220,
      width: 170,
      child: Stack(
        children: [
          Image.network(
  widget.image, 
  height: 130,
  width: 170,
  fit: BoxFit.cover,
)
,

          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: Icon(
                _isLiked ? Icons.favorite : Icons.favorite_border,
                color: _isLiked ? const Color(0xFFE25E2C) : Colors.white,
                size: 30,
              ),
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'You need to be logged in to manage favorites')),
                  );
                  return;
                }

                final userId = user.uid;
                final docRef = FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('favorites')
                    .doc(widget.id);

                try {
                  final docSnapshot = await docRef.get();

                  if (_isLiked) {
                    // Remove favorite
                    if (docSnapshot.exists) {
                      await docRef.delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('${widget.name} removed from Favorites')),
                      );
                    }
                  } else {
                    // Add to favorites
                    if (!docSnapshot.exists) {
                      await docRef.set({
                        'userId': userId,
                        'name': widget.name,
                        'price': widget.price,
                        'image': widget.image,
                        'rating': widget.initialRating,
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('${widget.name} added to Favorites')),
                      );
                    }
                  }

                  // Toggle _isLiked
                  setState(() {
                    _isLiked = !_isLiked;
                  });
                } catch (error) {}
              },
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 130),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2, // Adjust space ratio
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RatingBar.builder(
                              initialRating: _rating,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 16.0,
                              itemPadding:
                                  const EdgeInsets.symmetric(horizontal: 2.0),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                setState(() {
                                  _rating = rating;
                                });
                              },
                            ),
                            const SizedBox(height: 5),
                            Text(
                              widget.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.price,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.zero, // Round the top-right corner
                          topLeft:
                              Radius.circular(8.0), // Round the top-left corner
                          bottomRight: Radius.zero, // Flat bottom-right corner
                          bottomLeft:
                              Radius.circular(8.0), // Flat bottom-left corner
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isInCart
                              ? Icons.remove_shopping_cart
                              : Icons.add_shopping_cart,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'You need to be logged in to manage cart')),
                            );
                            return;
                          }

                          final userId = user.uid;
                          final docRef = FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .collection('cart')
                              .doc(widget.id);

                          try {
                            final docSnapshot = await docRef.get();

                            if (_isInCart) {
                              // Decrease quantity or remove from cart
                              if (docSnapshot.exists) {
                                final currentQuantity =
                                    docSnapshot['quantity'] ?? 0;
                                if (currentQuantity > 1) {
                                  // Decrease quantity
                                  await docRef.update(
                                      {'quantity': currentQuantity - 1});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'One ${widget.name} removed from cart')),
                                  );
                                } else {
                                  // Remove from cart
                                  await docRef.delete();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            '${widget.name} removed from cart')),
                                  );
                                }
                              }
                            } else {
                              // Add to cart with quantity 1
                              if (!docSnapshot.exists) {
                                await docRef.set({
                                  'userId': userId,
                                  'name': widget.name,
                                  'price': widget.price,
                                  'image': widget.image,
                                  'rating': widget.initialRating,
                                  'quantity': 1, // Initialize quantity to 1
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('${widget.name} added to cart')),
                                );
                              } else {
                                // Item already in cart, just increase quantity
                                final currentQuantity =
                                    docSnapshot['quantity'] ?? 0;
                                await docRef
                                    .update({'quantity': currentQuantity + 1});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Quantity of ${widget.name} increased')),
                                );
                              }
                            }

                            // Toggle _isInCart
                            setState(() {
                              _isInCart = !_isInCart;
                            });
                          } catch (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Failed to manage cart: $error')),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

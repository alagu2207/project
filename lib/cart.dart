import 'package:flutter/material.dart';
// The CartItem model you just created

class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  // Add item to cart or increase quantity if it exists
  void addToCart(CartItem item) {
    final existingItemIndex = _cartItems.indexWhere((cartItem) => cartItem.id == item.id);
    if (existingItemIndex != -1) {
      _cartItems[existingItemIndex].increaseQuantity();
    } else {
      _cartItems.add(item);
    }
    notifyListeners();
  }

  // Get item count in cart
  int getItemCount(CartItem item) {
    return _cartItems.where((cartItem) => cartItem.id == item.id).length;
  }

  // Remove item or decrease quantity
  void removeFromCart(CartItem item) {
    final existingItemIndex = _cartItems.indexWhere((cartItem) => cartItem.id == item.id);
    if (existingItemIndex != -1) {
      if (_cartItems[existingItemIndex].quantity > 1) {
        _cartItems[existingItemIndex].quantity--;
      } else {
        _cartItems.removeAt(existingItemIndex);
      }
    }
    notifyListeners();
  }
}




class CartItem {
  final String id;
  final String name;
  final String price;
  final String image;
  final double rating;
  int quantity; // New field for quantity

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.rating,
    this.quantity = 1, // Default quantity is 1
  });

  // You can also add methods to update the quantity if needed
  void increaseQuantity() {
    quantity++;
  }
}



import 'package:flutter/material.dart';

// Define the FavoriteItem model class
class FavoriteItem {
  final String id;
  final String name;
  final String price;
  final String image;
  final double rating;

  // Constructor to initialize FavoriteItem
  FavoriteItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.rating,
  });

  // Convert the FavoriteItem to a Map (for example, for Firebase or API interaction)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'rating': rating,
    };
  }

  // Create a FavoriteItem from a Map (for example, from Firebase or API response)
  static FavoriteItem fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      image: json['image'],
      rating: json['rating'],
    );
  }
}

// Define the FavoriteProvider class which will manage the state of favorites
class FavoriteProvider with ChangeNotifier {
  // List of favorite items
  List<FavoriteItem> _favorites = [];

  // Getter to access the favorites list
  List<FavoriteItem> get favorites => _favorites;

  // Check if an item is already in the favorites list
  bool isItemInFavorites(String id) {
    return _favorites.any((item) => item.id == id);
  }

  // Add an item to the favorites list if it's not already added
  void addToFavorites(FavoriteItem item) {
    if (!isItemInFavorites(item.id)) {
      _favorites.add(item);
      notifyListeners();
    } else {
      print('Item already in favorites.');
    }
  }

  // Remove an item from the favorites list
  void removeFromFavorites(String id) {
    int index = _favorites.indexWhere((item) => item.id == id);
    if (index != -1) {
      _favorites.removeAt(index);
      notifyListeners();
    } else {
      print('Item not found in favorites.');
    }
  }
}

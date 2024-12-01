class Product {
  final String name;
  final String image;
  final String price;
   final String id;
   
  final double initialRating;
  

  Product({
    required this.name,
    required this.image,
     required this.id,
    required this.price,
    required this.initialRating,
      
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      price: json['price']?.toString() ?? '0.0',
      initialRating: (json['initialRating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

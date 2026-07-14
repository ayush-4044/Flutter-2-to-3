class Product {
  String name;
  double price;

  Product({
    required this.name,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] ?? 'Unknown Product',
      price: json['price']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
    };
  }

  void display() {
    print('Product: $name');
    print('Price: ₹${price.toStringAsFixed(2)}');
    print('-------------------------');
  }
}
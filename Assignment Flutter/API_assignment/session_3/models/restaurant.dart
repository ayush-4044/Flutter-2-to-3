class Restaurant {
  String restaurantName;
  String cuisine;
  double rating;
  String location;
  bool isOpen;

  Restaurant({
    required this.restaurantName,
    required this.cuisine,
    required this.rating,
    required this.location,
    required this.isOpen,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      restaurantName: json['restaurant_name'] ?? 'Unknown',
      cuisine: json['cuisine'] ?? 'Unknown',
      rating: json['rating']?.toDouble() ?? 0.0,
      location: json['location'] ?? 'Unknown',
      isOpen: json['is_open'] ?? false,
    );
  }

  void display() {
    print('Restaurant Name: $restaurantName');
    print('Cuisine: $cuisine');
    print('Rating: $rating');
    print('Location: $location');
    print('Is Open: $isOpen');
    print('-------------------------');
  }
}
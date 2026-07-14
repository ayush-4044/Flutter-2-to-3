class MovieTicket {
  String movieName;
  String theatre;
  String showTime;
  int seatNumber;
  double price;
  bool isBooked;

  MovieTicket({
    required this.movieName,
    required this.theatre,
    required this.showTime,
    required this.seatNumber,
    required this.price,
    required this.isBooked,
  });

  // fromJson - Convert JSON to Object
  factory MovieTicket.fromJson(Map<String, dynamic> json) {
    return MovieTicket(
      movieName: json['movie_name'] ?? 'Unknown',
      theatre: json['theatre'] ?? 'Unknown',
      showTime: json['show_time'] ?? 'Unknown',
      seatNumber: json['seat_number'] ?? 0,
      price: json['price']?.toDouble() ?? 0.0,
      isBooked: json['is_booked'] ?? false,
    );
  }

  // toJson - Convert Object to JSON
  Map<String, dynamic> toJson() {
    return {
      'movie_name': movieName,
      'theatre': theatre,
      'show_time': showTime,
      'seat_number': seatNumber,
      'price': price,
      'is_booked': isBooked,
    };
  }

  void display() {
    print('Movie: $movieName');
    print('Theatre: $theatre');
    print('Show Time: $showTime');
    print('Seat Number: $seatNumber');
    print('Price: ₹${price.toStringAsFixed(2)}');
    print('Status: ${isBooked ? "Booked" : "Available"}');
    print('-------------------------');
  }
}
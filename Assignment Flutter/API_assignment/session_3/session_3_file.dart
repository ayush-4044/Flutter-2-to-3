
import 'dart:convert';

import 'package:flutter/material.dart';

import 'models/movie.dart';
import 'models/playlist.dart';
import 'models/product.dart';
import 'models/restaurant.dart';
import 'models/ticket.dart';

class Session3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Call all test functions
    testTask1();
    testTask2();
    testTask3();
    testTask4();
    testTask5();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Session 3: JSON Parsing',style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.deepPurple,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.code,
                  size: 80,
                  color: Colors.deepPurple,
                ),
                SizedBox(height: 20),
                Text(
                  'Check Console for Output',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'All 5 Tasks Completed ✅',

                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    testTask1();
                    testTask2();
                    testTask3();
                    testTask4();
                    testTask5();
                  },
                  icon: Icon(Icons.play_arrow,color: Colors.white,),
                  label: Text('Run All Tests',style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// TASK 1: Manual JSON Parsing - Zomato Restaurant
void testTask1() {
  print('');
  print('========== TASK 1: ZOMATO RESTAURANT ==========');

  String jsonString = '''
  {
    "restaurant_name": "Spice Garden",
    "cuisine": "North Indian",
    "rating": 4.5,
    "location": "Mumbai",
    "is_open": true
  }
  ''';

  Map<String, dynamic> jsonData = jsonDecode(jsonString);
  Restaurant restaurant = Restaurant.fromJson(jsonData);
  restaurant.display();
  print('================================================');
  print('');
}

// TASK 2: Movie Model with fromJson
void testTask2() {
  print('========== TASK 2: MOVIE MODEL ==========');

  String jsonString = '''
  {
    "title": "The Dark Knight",
    "year": 2008,
    "genre": "Action"
  }
  ''';

  Map<String, dynamic> jsonData = jsonDecode(jsonString);
  Movie movie = Movie.fromJson(jsonData);
  movie.display();
  print('=========================================');
  print('');
}

// TASK 3: Flipkart Products with fromJson
void testTask3() {
  print('========== TASK 3: FLIPKART PRODUCTS ==========');

  String jsonString = '''
  [
    {
      "name": "iPhone 15 Pro Max",
      "price": 159900
    },
    {
      "name": "Samsung Galaxy S24 Ultra",
      "price": 129999
    },
    {
      "name": "OnePlus 12",
      "price": 79999
    },
    {
      "name": "Vivo X100 Pro",
      "price": 89999
    }
  ]
  ''';

  List<dynamic> jsonArray = jsonDecode(jsonString);
  List<Product> products = [];

  for (var item in jsonArray) {
    products.add(Product.fromJson(item));
  }

  print('Total Products: ${products.length}');
  print('');
  for (var product in products) {
    product.display();
  }
  print('===============================================');
  print('');
}

// TASK 4: Spotify Playlist with Song Titles
void testTask4() {
  print('========== TASK 4: SPOTIFY PLAYLIST ==========');

  String jsonString = '''
  {
    "playlist_name": "Bollywood Hits 2024",
    "songs": [
      {
        "title": "Kesariya",
        "artist": "Arijit Singh"
      },
      {
        "title": "Apna Bana Le",
        "artist": "Arijit Singh"
      },
      {
        "title": "Deva Deva",
        "artist": "Shreya Ghoshal"
      },
      {
        "title": "Oo Antava",
        "artist": "Indravathi Chauhan"
      },
      {
        "title": "Naatu Naatu",
        "artist": "Rahul Sipligunj"
      }
    ]
  }
  ''';

  Map<String, dynamic> jsonData = jsonDecode(jsonString);
  Playlist playlist = Playlist.fromJson(jsonData);
  playlist.display();
  print('==============================================');
  print('');
}

// TASK 5: BookMyShow Ticket with toJson
void testTask5() {
  print('========== TASK 5: BOOKMYSHOW TICKET ==========');

  // Create a ticket object
  MovieTicket ticket = MovieTicket(
    movieName: 'Kalki 2898 AD',
    theatre: 'PVR Cinemas',
    showTime: '7:30 PM',
    seatNumber: 12,
    price: 350.0,
    isBooked: true,
  );

  // Display ticket info
  print('----- Ticket Details -----');
  ticket.display();

  // Convert to JSON using toJson
  Map<String, dynamic> jsonData = ticket.toJson();

  print('----- JSON Output -----');
  print(jsonData);

  // Convert back from JSON to verify
  MovieTicket newTicket = MovieTicket.fromJson(jsonData);
  print('');
  print('----- Parsed from JSON -----');
  newTicket.display();

  print('==============================================');
  print('');
}
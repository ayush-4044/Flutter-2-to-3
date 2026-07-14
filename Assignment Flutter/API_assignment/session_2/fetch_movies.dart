import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FetchMovies extends StatefulWidget {
  const FetchMovies({super.key});

  @override
  State<FetchMovies> createState() => _FetchMoviesState();
}

class _FetchMoviesState extends State<FetchMovies> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: fetchMoviesWithMessage,
          child: Text("Fetch Data In Console"),
        ),
      ),
    );
  }
}

void fetchMovie() async {
  try {
    final response = await http.get(Uri.parse('https://api.tvmaze.com/shows'));

    if (response.statusCode == 200) {
      // Convert JSON String to Dart Object
      final jsonData = jsonDecode(response.body);

      // Pretty Print JSON (Like Postman)
      const encoder = JsonEncoder.withIndent('  ');
      final prettyJson = encoder.convert(jsonData);

      print("========== API RESPONSE ==========");
      print(prettyJson);
      print("==================================");
    } else {
      print('Request failed with status: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

void fetchMovies() async {
  try {
    print('========== FETCHING DATA ==========');
    print('Loading...');

    await Future.delayed(const Duration(seconds: 3));

    final response = await http.get(Uri.parse('https://api.tvmaze.com/shows'));

    if (response.statusCode == 200) {
      // Convert JSON to Dart object
      final jsonData = jsonDecode(response.body);

      // Pretty Print JSON (Like Postman)
      const encoder = JsonEncoder.withIndent('  ');
      final prettyJson = encoder.convert(jsonData);

      print('========== API RESPONSE ==========');
      print(prettyJson);
      print('==================================');
    } else {
      print('Request Failed');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

void fetchMoviesWithMessage() async {
  try {
    // Loading message
    print('========== LOADING ==========');
    print('Loading...');

    // Artificial delay
    await Future.delayed(const Duration(seconds: 3));

    // API Call
    final response = await http.get(Uri.parse('https://api.tvmaze.com/shows'));

    if (response.statusCode == 200) {
      // Convert JSON String to Dart Object
      final jsonData = jsonDecode(response.body);

      // Pretty Print JSON (Like Postman)
      const encoder = JsonEncoder.withIndent('  ');
      final prettyJson = encoder.convert(jsonData);

      print('========== API RESPONSE ==========');
      print(prettyJson);
      print('==================================');

      // Done message
      print('Done!');
    } else {
      print('Request failed with status: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

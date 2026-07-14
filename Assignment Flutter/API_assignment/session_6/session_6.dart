import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';



class HomeScreen6 extends StatelessWidget {
  const HomeScreen6({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Error Handling Tasks'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Task 1: IPL Match Data with Status Code Handling
          Card(
            elevation: 4,
            child: ListTile(
              title: const Text('Task 1: IPL Match Data'),
              subtitle: const Text('Handle 400, 401, 500 errors'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const IPLMatchScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Task 2: BookMyShow Trending Movies with Timeout
          Card(
            elevation: 4,
            child: ListTile(
              title: const Text('Task 2: BookMyShow Trending Movies'),
              subtitle: const Text('5 second timeout with SnackBar'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MovieTrendingScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Task 3: Zomato Restaurant List with Retry Button
          Card(
            elevation: 4,
            child: ListTile(
              title: const Text('Task 3: Zomato Restaurant List'),
              subtitle: const Text('Retry button for 500 errors'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RestaurantListScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Task 4: SocketException Explanation
          Card(
            elevation: 4,
            color: Colors.amber[50],
            child: ExpansionTile(
              leading: const Icon(Icons.chat, color: Colors.amber),
              title: const Text('Task 4: SocketException Decoded'),
              subtitle: const Text('Tap to see ChatGPT explanation'),
              children: const [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prompt Used:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '"Given the following error message from a failed API call '
                            'in a Flutter app: "SocketException: Failed host lookup", '
                            'please explain what this error means in simple terms."',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'ChatGPT Response:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '"SocketException: Failed host lookup" means the app tried '
                            'to connect to a server but couldn\'t find the server\'s '
                            'address on the internet. Think of it like trying to call '
                            'someone but you have the wrong phone number or the phone '
                            'company cannot find that number. This typically happens '
                            'when the API URL is incorrect, the server is offline, '
                            'or there are DNS (Domain Name System) issues. In a '
                            'Flutter app, this error often indicates the device has '
                            'internet connectivity problems or the domain name '
                            'cannot be resolved properly.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TASK 1: IPL Match Data with HTTP 400, 401, 500 Error Handling
// ============================================================
class IPLMatchScreen extends StatefulWidget {
  const IPLMatchScreen({super.key});

  @override
  State<IPLMatchScreen> createState() => _IPLMatchScreenState();
}

class _IPLMatchScreenState extends State<IPLMatchScreen> {
  bool _isLoading = false;
  String _errorMessage = '';
  String _statusMessage = '';
  List<dynamic> _matches = [];

  // Simulating different status codes for demonstration
  int _selectedStatusCode = 200; // Default success

  Future<void> _fetchIPLData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _statusMessage = '';
      _matches = [];
    });

    try {
      // Using a mock API endpoint for demonstration
      // In real app, use actual IPL API
      final String url = 'https://jsonplaceholder.typicode.com/posts';

      final response = await http.get(Uri.parse(url));

      // Task 1: Handle different status codes with user-friendly messages
      if (response.statusCode == 200) {
        // Success case
        setState(() {
          _matches = jsonDecode(response.body);
          _isLoading = false;
          _statusMessage = '✅ Data loaded successfully!';
          _matches = _matches.take(5).toList(); // Show only 5 for demo
        });
      }
      // Task 1: Handle 400 Bad Request
      else if (response.statusCode == 400) {
        setState(() {
          _errorMessage = '❌ Invalid request - Please check your input and try again.';
          _isLoading = false;
        });
      }
      // Task 1: Handle 401 Unauthorized
      else if (response.statusCode == 401) {
        setState(() {
          _errorMessage = '🔒 Session expired – please log in again to continue.';
          _isLoading = false;
        });
      }
      // Task 1: Handle 500 Internal Server Error
      else if (response.statusCode == 500) {
        setState(() {
          _errorMessage = '⚠️ Server is down – try again later.';
          _isLoading = false;
        });
      }
      // Task 1: Handle other status codes
      else {
        setState(() {
          _errorMessage = '❌ Something went wrong (Status: ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '⚠️ Network error: $e';
        _isLoading = false;
      });
    }
  }

  // Simulate different error status codes for demonstration
  void _simulateError(int statusCode) {
    setState(() {
      _selectedStatusCode = statusCode;
      // Override the actual response by showing simulated error
      if (statusCode == 400) {
        _errorMessage = '❌ Invalid request - Please check your input and try again.';
        _statusMessage = '';
        _matches = [];
      } else if (statusCode == 401) {
        _errorMessage = '🔒 Session expired – please log in again to continue.';
        _statusMessage = '';
        _matches = [];
      } else if (statusCode == 500) {
        _errorMessage = '⚠️ Server is down – try again later.';
        _statusMessage = '';
        _matches = [];
      } else {
        _errorMessage = '';
        _statusMessage = '✅ Success!';
        _fetchIPLData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IPL Match Data (Task 1)'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Demo buttons to simulate different status codes
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Simulate Errors:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: () => _simulateError(200),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Success'),
                      ),
                      ElevatedButton(
                        onPressed: () => _simulateError(400),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('400 Error'),
                      ),
                      ElevatedButton(
                        onPressed: () => _simulateError(401),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('401 Error'),
                      ),
                      ElevatedButton(
                        onPressed: () => _simulateError(500),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('500 Error'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Task 1: Display status message if success
            if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  _statusMessage,
                  style: const TextStyle(color: Colors.green),
                ),
              ),

            // Task 1: Display error message if error
            if (_errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red[800]),
                      ),
                    ),
                    // Task 1: Retry button for errors
                    IconButton(
                      onPressed: _fetchIPLData,
                      icon: const Icon(Icons.refresh, color: Colors.red),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Display data if loaded
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _matches.isNotEmpty
                  ? ListView.builder(
                itemCount: _matches.length,
                itemBuilder: (context, index) {
                  final match = _matches[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text('${index + 1}'),
                      ),
                      title: Text(match['title'] ?? 'Match'),
                      subtitle: Text(match['body'] ?? 'Details'),
                    ),
                  );
                },
              )
                  : const Center(
                child: Text('No matches available'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TASK 2: BookMyShow Trending Movies with Timeout
// ============================================================
class MovieTrendingScreen extends StatefulWidget {
  const MovieTrendingScreen({super.key});

  @override
  State<MovieTrendingScreen> createState() => _MovieTrendingScreenState();
}

class _MovieTrendingScreenState extends State<MovieTrendingScreen> {
  bool _isLoading = false;
  List<dynamic> _movies = [];
  String _errorMessage = '';

  // Task 2: Fetch with 5 second timeout
  Future<void> _fetchTrendingMovies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _movies = [];
    });

    try {
      // Task 2: Implement 5 second timeout
      final response = await http
          .get(
        Uri.parse('https://api.themoviedb.org/3/trending/movie/day?api_key=demo_key'),
      )
          .timeout(
        const Duration(seconds: 5), // Task 2: 5 second timeout
        onTimeout: () {
          // Task 2: Show timeout SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⏰ Network timeout – please check your connection'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
          throw TimeoutException('Request timed out');
        },
      );

      // Task 2: Process response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _movies = data['results'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load movies (Status: ${response.statusCode})';
          _isLoading = false;
        });
      }
    } on TimeoutException catch (e) {
      // Task 2: Handle timeout exception
      setState(() {
        _errorMessage = '⏰ Request timed out after 5 seconds';
        _isLoading = false;
      });
      print('Task 2 - Timeout: $e');
    } catch (e) {
      setState(() {
        _errorMessage = '⚠️ Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trending Movies (Task 2)'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Task 2: Info about timeout
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'This request will timeout after 5 seconds. '
                          'Check console for timeout simulation.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _isLoading ? null : _fetchTrendingMovies,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Fetch Trending Movies'),
            ),
            const SizedBox(height: 16),

            // Display error message if any
            if (_errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red[800]),
                      ),
                    ),
                    IconButton(
                      onPressed: _fetchTrendingMovies,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Display movies
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _movies.isNotEmpty
                  ? ListView.builder(
                itemCount: _movies.length,
                itemBuilder: (context, index) {
                  final movie = _movies[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        color: Colors.grey[300],
                        child: Icon(Icons.movie, color: Colors.grey[600]),
                      ),
                      title: Text(movie['title'] ?? 'Untitled'),
                      subtitle: Text('⭐ ${movie['vote_average']?.toStringAsFixed(1) ?? 'N/A'}'),
                    ),
                  );
                },
              )
                  : const Center(
                child: Text('No movies loaded'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TASK 3: Zomato Restaurant List with Retry Button for 500 Errors
// ============================================================
class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  List<dynamic> _restaurants = [];
  bool _isLoading = true;
  bool _hasError = false;
  bool _is500Error = false; // Task 3: Track if it's a 500 error
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
  }

  // Task 3: Fetch restaurants with retry logic for 500 errors
  Future<void> _fetchRestaurants() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _is500Error = false;
      _errorMessage = '';
    });

    try {
      // Simulating API call - in real app use actual Zomato API
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts'),
      );

      // Task 3: Check for 500 status code
      if (response.statusCode == 500) {
        setState(() {
          _is500Error = true;
          _hasError = true;
          _errorMessage = '⚠️ Server is down – please try again later.';
          _isLoading = false;
        });
      } else if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          _restaurants = data.take(8).toList(); // Show 8 restaurants for demo
          _isLoading = false;
          _hasError = false;
          _is500Error = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load restaurants (Status: ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = '⚠️ Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant List (Task 3)'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Task 3: Show retry button only for 500 errors
            if (_is500Error)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Column(
                  children: [
                    Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red[800], fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Task 3: Retry button for 500 errors
                    ElevatedButton.icon(
                      onPressed: _fetchRestaurants,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry Request'),
                    ),
                  ],
                ),
              ),

            // Show regular error for non-500 errors
            if (_hasError && !_is500Error)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.orange[800]),
                      ),
                    ),
                    IconButton(
                      onPressed: _fetchRestaurants,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Restaurant list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _restaurants.isEmpty
                  ? const Center(
                child: Text('No restaurants available'),
              )
                  : ListView.builder(
                itemCount: _restaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = _restaurants[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange[100],
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        restaurant['title'] ?? 'Restaurant',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        restaurant['body'] ?? 'Great place to eat!',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TASK 4: SocketException Explanation (in HomeScreen)
// ============================================================
// The explanation is already included in the HomeScreen as ExpansionTile
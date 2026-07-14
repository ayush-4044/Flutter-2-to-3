import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Tasks Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Task 1 & 4 & 5: Song Form
          Card(
            child: ListTile(
              title: const Text('Task 1, 4 & 5: Song Form'),
              subtitle: const Text('With POST request, headers & error handling'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SongFormScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Task 2: Movie Rating Form
          Card(
            child: ListTile(
              title: const Text('Task 2: Movie Rating Form'),
              subtitle: const Text('POST request with Snackbar response'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MovieRatingScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Task 3: Feedback Form (Zomato Style)
          Card(
            child: ListTile(
              title: const Text('Task 3: Feedback Form'),
              subtitle: const Text('Zomato style with AlertDialog response'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FeedbackScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================
// TASK 1, 4 & 5: Song Form with POST, Headers & Error Handling
// ====================================================
class SongFormScreen extends StatefulWidget {
  const SongFormScreen({super.key});

  @override
  State<SongFormScreen> createState() => _SongFormScreenState();
}

class _SongFormScreenState extends State<SongFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _songNameController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  bool _isLoading = false;
  String _responseMessage = '';

  // Task 1: Submit button pressed - collect input and print JSON
  Future<void> _submitSong() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _responseMessage = '';
      });

      // Task 1: Collect input and print as JSON payload
      final songData = {
        'songName': _songNameController.text,
        'artist': _artistController.text,
      };

      // Task 1: Print JSON payload to console
      print('Task 1 - JSON Payload: ${jsonEncode(songData)}');

      // Task 4: Add custom header
      final headers = {
        'Content-Type': 'application/json',
        'x-app-source': 'flutter-demo', // Task 4: Custom header
      };

      // Task 4: Log headers and payload before sending
      print('Task 4 - Headers: $headers');
      print('Task 4 - Payload: ${jsonEncode(songData)}');

      try {
        // Task 5: Simulate error by sending incomplete data
        // Check if data is complete (Task 5)
        if (_songNameController.text.isEmpty || _artistController.text.isEmpty) {
          throw Exception('Missing required fields: songName or artist');
        }

        // Task 5: Test with incomplete data
        // Uncomment below line to simulate incomplete data error
        // final incompleteData = {'songName': 'Test Song'};
        // final response = await http.post(
        //   Uri.parse('https://jsonplaceholder.typicode.com/posts'),
        //   headers: headers,
        //   body: jsonEncode(incompleteData),
        // );

        // Normal POST request with complete data
        final response = await http.post(
          Uri.parse('https://jsonplaceholder.typicode.com/posts'),
          headers: headers,
          body: jsonEncode(songData),
        );

        // Task 5: Handle error response gracefully
        if (response.statusCode == 201) {
          setState(() {
            _responseMessage = '✅ Success! Song added successfully.';
            _isLoading = false;
          });
          print('Task 5 - Success Response: ${response.body}');
        } else {
          // Task 5: Handle non-201 status codes
          throw Exception('Failed with status code: ${response.statusCode}');
        }
      } catch (e) {
        // Task 5: Graceful error handling
        setState(() {
          _responseMessage = '❌ Error: ${e.toString()}';
          _isLoading = false;
        });
        print('Task 5 - Error caught: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Song Form (Tasks 1, 4, 5)'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Task 1: Song Name field
              TextFormField(
                controller: _songNameController,
                decoration: const InputDecoration(
                  labelText: 'Song Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.music_note),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a song name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Task 1: Artist field
              TextFormField(
                controller: _artistController,
                decoration: const InputDecoration(
                  labelText: 'Artist',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an artist name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Task 1: Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitSong,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Submit',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),

              // Task 5: Show response message
              if (_responseMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _responseMessage.contains('Success')
                        ? Colors.green[50]
                        : Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _responseMessage.contains('Success')
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  child: Text(
                    _responseMessage,
                    style: TextStyle(
                      color: _responseMessage.contains('Success')
                          ? Colors.green[800]
                          : Colors.red[800],
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _songNameController.dispose();
    _artistController.dispose();
    super.dispose();
  }
}

// ====================================================
// TASK 2: Movie Rating Form with Snackbar
// ====================================================
class MovieRatingScreen extends StatefulWidget {
  const MovieRatingScreen({super.key});

  @override
  State<MovieRatingScreen> createState() => _MovieRatingScreenState();
}

class _MovieRatingScreenState extends State<MovieRatingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _movieNameController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  bool _isLoading = false;

  // Task 2: Send POST request with favorite movie name and rating
  Future<void> _submitMovieRating() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Task 2: Create JSON data
      final movieData = {
        'movieName': _movieNameController.text,
        'rating': double.parse(_ratingController.text),
      };

      try {
        // Task 2: Send POST request
        final response = await http.post(
          Uri.parse('https://jsonplaceholder.typicode.com/posts'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(movieData),
        );

        setState(() => _isLoading = false);

        // Task 2: Display Snackbar with success or failed message
        if (response.statusCode == 201) {
          // Task 2: Success - Status code 201
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Success'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          print('Task 2 - Success: ${response.body}');
          _clearForm();
        } else {
          // Task 2: Failed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Failed (Status: ${response.statusCode})'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
          print('Task 2 - Failed: ${response.statusCode}');
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        print('Task 2 - Error: $e');
      }
    }
  }

  void _clearForm() {
    _movieNameController.clear();
    _ratingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Rating (Task 2)'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _movieNameController,
                decoration: const InputDecoration(
                  labelText: 'Favorite Movie Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.movie),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a movie name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ratingController,
                decoration: const InputDecoration(
                  labelText: 'Rating (out of 10)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.star),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a rating';
                  }
                  final rating = double.tryParse(value);
                  if (rating == null || rating < 0 || rating > 10) {
                    return 'Rating must be between 0 and 10';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitMovieRating,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Submit Rating',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '💡 Tip: Success (201) or Failed message will appear as Snackbar',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _movieNameController.dispose();
    _ratingController.dispose();
    super.dispose();
  }
}

// ====================================================
// TASK 3: Feedback Form (Zomato Style) with AlertDialog
// ====================================================
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _restaurantController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  bool _isLoading = false;

  // Task 3: Send POST request and show response in AlertDialog
  Future<void> _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Task 3: Create feedback data
      final feedbackData = {
        'restaurantName': _restaurantController.text,
        'review': _reviewController.text,
        'timestamp': DateTime.now().toIso8601String(),
      };

      try {
        // Task 3: Send POST request to mock API
        final response = await http.post(
          Uri.parse('https://jsonplaceholder.typicode.com/posts'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(feedbackData),
        );

        setState(() => _isLoading = false);

        // Task 3: Parse response
        final responseData = jsonDecode(response.body);

        // Task 3: Show AlertDialog with response message
        _showAlertDialog(
          title: response.statusCode == 201 ? '✅ Success!' : '❌ Failed',
          message: response.statusCode == 201
              ? 'Thank you for your feedback!\n\n'
              'Response ID: ${responseData['id']}\n'
              'Restaurant: ${_restaurantController.text}\n'
              'Your review has been submitted successfully.'
              : 'Failed to submit feedback.\nStatus: ${response.statusCode}',
        );

        if (response.statusCode == 201) {
          _clearForm();
        }
      } catch (e) {
        setState(() => _isLoading = false);
        _showAlertDialog(
          title: '❌ Error',
          message: 'Something went wrong:\n$e',
        );
      }
    }
  }

  // Task 3: AlertDialog helper method
  void _showAlertDialog({required String title, required String message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                title.contains('Success') ? Icons.check_circle : Icons.error,
                color: title.contains('Success') ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    _restaurantController.clear();
    _reviewController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback (Task 3 - Zomato Style)'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Zomato style header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.feedback, color: Colors.orange[800]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Share your dining experience with us!',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Task 3: Restaurant name field
              TextFormField(
                controller: _restaurantController,
                decoration: const InputDecoration(
                  labelText: 'Restaurant Name',
                  hintText: 'e.g., The Grand Kitchen',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.restaurant),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a restaurant name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Task 3: Review field
              TextFormField(
                controller: _reviewController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Your Review',
                  hintText: 'Tell us about your experience...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.comment),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please write a review';
                  }
                  if (value.length < 10) {
                    return 'Review must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Task 3: Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Submit Feedback',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const Spacer(),

              // Zomato style footer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Text(
                      '💡 Your feedback matters to us!',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Response will appear in AlertDialog',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _restaurantController.dispose();
    _reviewController.dispose();
    super.dispose();
  }
}
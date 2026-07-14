import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class TrendingMoviesScreen extends StatefulWidget {
  const TrendingMoviesScreen({super.key});

  @override
  State<TrendingMoviesScreen> createState() => _TrendingMoviesScreenState();
}

class _TrendingMoviesScreenState extends State<TrendingMoviesScreen> {
  // State variables
  List<dynamic> movies = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchTrendingMovies(); // Task 1: Fetch movies on app start
  }

  // Task 1: Fetch trending movies from TMDB API
  Future<void> fetchTrendingMovies() async {
    setState(() {
      isLoading = true; // Task 2: Show loading indicator
      hasError = false;
    });

    try {
      const String apiKey = 'YOUR_API_KEY'; // I didn't get api key
      final String url =
          'https://api.themoviedb.org/3/trending/movie/day?api_key=$apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          movies = data['results'] ?? [];
          isLoading = false; // Task 2: Hide loading indicator
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = 'Failed to load movies. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trending Movies'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: fetchTrendingMovies,
        child: _buildBody(), // Task 2, 3, 4: Build appropriate UI based on state
      ),
    );
  }

  Widget _buildBody() {
    // Task 2: Show CircularProgressIndicator while loading
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading trending movies...'),
          ],
        ),
      );
    }

    // Handle error state
    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchTrendingMovies,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Task 3: Handle empty list - display message
    if (movies.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No trending movies found', // Task 3: Display message
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    // Task 1 & 4: Display ListView with movie titles and poster images
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        final title = movie['title'] ?? 'Untitled';
        final posterPath = movie['poster_path'];
        final releaseDate = movie['release_date'] ?? 'Unknown date';
        final voteAverage = movie['vote_average']?.toStringAsFixed(1) ?? 'N/A';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          elevation: 4,
          child: ListTile(
            // Task 4: Display poster image alongside title
            leading: _buildPosterImage(posterPath),
            title: Text(
              title, // Task 1: Display movie title
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Release Date: $releaseDate'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text('Rating: $voteAverage/10'),
                  ],
                ),
              ],
            ),
            isThreeLine: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
          ),
        );
      },
    );
  }

  // Task 4: Build poster image widget
  Widget _buildPosterImage(String? posterPath) {
    if (posterPath == null || posterPath.isEmpty) {
      // Fallback if no poster available
      return Container(
        width: 50,
        height: 75,
        color: Colors.grey[300],
        child: const Icon(
          Icons.movie,
          color: Colors.grey,
        ),
      );
    }

    // Task 4: Build image URL with poster_path
    final imageUrl = 'https://image.tmdb.org/t/p/w200$posterPath';

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        imageUrl,
        width: 50,
        height: 75,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 50,
            height: 75,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 50,
            height: 75,
            color: Colors.grey[300],
            child: const Icon(
              Icons.broken_image,
              color: Colors.grey,
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';


// ============================================================
// MOVIE MODEL
// ============================================================
class Movie {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String overview;
  final double voteAverage;
  final int voteCount;
  final String releaseDate;
  final String? originalLanguage;

  Movie({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.overview,
    required this.voteAverage,
    required this.voteCount,
    required this.releaseDate,
    this.originalLanguage,
  });

  // Task 1: Parse movie from JSON
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown Title',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      overview: json['overview'] ?? 'No overview available',
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      releaseDate: json['release_date'] ?? 'Unknown',
      originalLanguage: json['original_language'],
    );
  }

  // Helper to get poster URL
  String get posterUrl {
    if (posterPath == null || posterPath!.isEmpty) {
      return '';
    }
    return 'https://image.tmdb.org/t/p/w200$posterPath';
  }

  // Helper to get backdrop URL
  String get backdropUrl {
    if (backdropPath == null || backdropPath!.isEmpty) {
      return '';
    }
    return 'https://image.tmdb.org/t/p/w500$backdropPath';
  }
}

// ============================================================
// MAIN SCREEN
// ============================================================
class TrendingMoviesScreen2 extends StatefulWidget {
  const TrendingMoviesScreen2({super.key});

  @override
  State<TrendingMoviesScreen2> createState() => _TrendingMoviesScreen2State();
}

class _TrendingMoviesScreen2State extends State<TrendingMoviesScreen2> {
  // State variables
  List<Movie> _movies = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _hasInternet = true;

  // Task 1: TMDB API Configuration

  static const String _apiKey = 'YOUR_API_KEY_HERE';// again I didn't get api key
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _endpoint = '/trending/movie/day';

  @override
  void initState() {
    super.initState();
    // Task 1: Fetch movies when screen loads
    _fetchTrendingMovies();
  }

  // ============================================================
  // TASK 1 & 2: Fetch trending movies from TMDB API
  // ============================================================
  Future<void> _fetchTrendingMovies() async {
    // Task 3: Show loading spinner
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      // Check internet connection
      _hasInternet = await _checkInternetConnection();
      if (!_hasInternet) {
        // Task 3: Handle no internet
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'No internet connection. Please check your network.';
        });
        return;
      }

      // Task 1: Build API URL
      final String url = '$_baseUrl$_endpoint?api_key=$_apiKey';
      print('🌐 Fetching movies from: $url');

      // Task 1: Make GET request
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
        },
      );

      // Task 3: Handle API response
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Task 4: Check if results array is empty
        final List<dynamic> results = data['results'] ?? [];

        if (results.isEmpty) {
          // Task 4: Display 'No movies found' message
          setState(() {
            _movies = [];
            _isLoading = false;
            _hasError = false;
            _errorMessage = 'No movies found';
          });
          print('📭 API returned empty results');
        } else {
          // Task 2: Parse and update UI with live data
          setState(() {
            _movies = results.map((json) => Movie.fromJson(json)).toList();
            _isLoading = false;
            _hasError = false;
            _errorMessage = '';
          });
          print('✅ Loaded ${_movies.length} trending movies');
        }
      } else if (response.statusCode == 401) {
        // Task 3: Invalid API key
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Invalid API key. Please check your TMDB API key.';
        });
        print('❌ API Error: Invalid API key');
      } else {
        // Task 3: Other API errors
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Failed to load movies (Status: ${response.statusCode})';
        });
        print('❌ API Error: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      // Task 3: Network error
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Network error: $e';
      });
      print('❌ Network Error: $e');
    } catch (e) {
      // Task 3: General error
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Error: $e';
      });
      print('❌ Error: $e');
    }
  }

  // Helper: Check internet connection
  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // Task 5: Refresh data (optional)
  Future<void> _refreshMovies() async {
    await _fetchTrendingMovies();
  }

  // ============================================================
  // BUILD UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trending Movies'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshMovies,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  // ============================================================
  // TASK 3: Loading Spinner & Error Message
  // ============================================================
  Widget _buildBody() {
    // Task 3: Show loading spinner while fetching
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.blue,
              strokeWidth: 3,
            ),
            SizedBox(height: 20),
            Text(
              'Loading trending movies...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // Task 3: Display error message if fetch fails
    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _errorMessage.contains('No internet')
                    ? Icons.wifi_off
                    : Icons.error_outline,
                size: 64,
                color: _errorMessage.contains('No internet')
                    ? Colors.orange
                    : Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _refreshMovies,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Task 4: Show 'No movies found' message if list is empty
    if (_movies.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_creation_outlined,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No movies found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try again later',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // Task 1 & 2: Display movies in ListView
    return RefreshIndicator(
      onRefresh: _refreshMovies,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _movies.length,
        itemBuilder: (context, index) {
          final movie = _movies[index];
          return _buildMovieCard(movie, index);
        },
      ),
    );
  }

  // ============================================================
  // TASK 1 & 4: Movie Card with Title and Poster
  // ============================================================
  Widget _buildMovieCard(Movie movie, int index) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Show movie details on tap
          _showMovieDetails(movie);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task 4: Movie Poster
              _buildPoster(movie),
              const SizedBox(width: 16),

              // Movie details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task 1: Movie Title
                    Text(
                      movie.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Release date
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          movie.releaseDate,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Rating
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          movie.voteAverage.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${movie.voteCount} votes)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Task 1: Movie Overview (preview)
                    Text(
                      movie.overview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Language badge
                    if (movie.originalLanguage != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Text(
                          movie.originalLanguage!.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Index number
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TASK 4: Poster Image Widget
  // ============================================================
  Widget _buildPoster(Movie movie) {
    if (movie.posterPath == null || movie.posterPath!.isEmpty) {
      // Placeholder when no poster available
      return Container(
        width: 60,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.movie,
          color: Colors.grey,
          size: 30,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        movie.posterUrl,
        width: 60,
        height: 90,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 60,
            height: 90,
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
            width: 60,
            height: 90,
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

  // ============================================================
  // Movie Details Dialog
  // ============================================================
  void _showMovieDetails(Movie movie) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(movie.title),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Backdrop image
                if (movie.backdropPath != null && movie.backdropPath!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      movie.backdropUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  movie.overview,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  '⭐ ${movie.voteAverage.toStringAsFixed(1)}/10 (${movie.voteCount} votes)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '📅 ${movie.releaseDate}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'overview': overview,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'release_date': releaseDate,
      'original_language': originalLanguage,
      'cache_timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'] ?? 0,
      title: map['title'] ?? 'Unknown Title',
      posterPath: map['poster_path'],
      backdropPath: map['backdrop_path'],
      overview: map['overview'] ?? 'No overview available',
      voteAverage: (map['vote_average'] ?? 0.0).toDouble(),
      voteCount: map['vote_count'] ?? 0,
      releaseDate: map['release_date'] ?? 'Unknown',
      originalLanguage: map['original_language'],
    );
  }

  String get posterUrl {
    if (posterPath == null || posterPath!.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/w200$posterPath';
  }

  String get backdropUrl {
    if (backdropPath == null || backdropPath!.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/w500$backdropPath';
  }
}

// ============================================================
// DATABASE HELPER
// ============================================================
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/movies.db';
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE movies (
        id INTEGER PRIMARY KEY,
        title TEXT,
        poster_path TEXT,
        backdrop_path TEXT,
        overview TEXT,
        vote_average REAL,
        vote_count INTEGER,
        release_date TEXT,
        original_language TEXT,
        cache_timestamp INTEGER
      )
    ''');
    debugPrint('✅ Movies database created successfully');
  }

  Future<void> saveMovies(List<Movie> movies) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('movies');
      for (var movie in movies) {
        await txn.insert('movies', movie.toMap());
      }
    });
    debugPrint('✅ ${movies.length} movies saved to SQLite');
  }

  Future<List<Movie>> getMovies() async {
    final db = await database;
    final result = await db.query('movies', orderBy: 'id');
    if (result.isEmpty) {
      return [];
    }
    final movies = result.map((map) => Movie.fromMap(map)).toList();
    debugPrint('📂 ${movies.length} movies loaded from SQLite');
    return movies;
  }

  Future<bool> hasCachedData() async {
    final db = await database;
    final result = await db.query('movies', limit: 1);
    return result.isNotEmpty;
  }

  Future<int?> getCacheTimestamp() async {
    final db = await database;
    final result = await db.query('movies', limit: 1);
    if (result.isEmpty) return null;
    return result.first['cache_timestamp'] as int?;
  }

  Future<void> clearCache() async {
    final db = await database;
    await db.delete('movies');
    debugPrint('🗑️ SQLite cache cleared');
  }
}

// ============================================================
// MAIN SCREEN
// ============================================================
class TrendingMoviesScreen3 extends StatefulWidget {
  const TrendingMoviesScreen3({super.key});

  @override
  State<TrendingMoviesScreen3> createState() => _TrendingMoviesScreen3State();
}

class _TrendingMoviesScreen3State extends State<TrendingMoviesScreen3> {
  List<Movie> _movies = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isOffline = false;
  bool _isUsingCache = false;
  String _dataSource = '';

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // FIXED: Use List<ConnectivityResult> for newer version
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  // FIXED: Actually use this variable
  ConnectivityResult _connectivityStatus = ConnectivityResult.none;

  static const String _apiKey = 'YOUR_API_KEY_HERE'; // again i didn't get api key
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _endpoint = '/trending/movie/day';

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _loadMoviesOnStart();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // ============================================================
  // FIXED: Connectivity Methods
  // ============================================================
  Future<void> _initConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectivityStatus(connectivityResult);

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
          (List<ConnectivityResult> result) {
        _updateConnectivityStatus(result);
      },
    );
  }

  // FIXED: Made this async and added await
  void _updateConnectivityStatus(List<ConnectivityResult> results) {
    final bool isConnected = results.any(
            (result) => result != ConnectivityResult.none
    );

    final bool wasOffline = _isOffline;

    setState(() {
      // FIXED: Actually using _connectivityStatus
      _connectivityStatus = isConnected
          ? results.firstWhere((r) => r != ConnectivityResult.none)
          : ConnectivityResult.none;
      _isOffline = !isConnected;
    });

    if (isConnected && wasOffline) {
      debugPrint('📶 Device came online - fetching fresh data');
      _fetchMovies(forceRefresh: true);
    } else if (!isConnected && !wasOffline) {
      debugPrint('📶 Device went offline - loading cached data');
      _loadFromCache();
    }
  }

  // ============================================================
  // MOVIE FETCHING METHODS
  // ============================================================
  void _loadMoviesOnStart() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMovies(forceRefresh: false);
    });
  }

  Future<void> _fetchMovies({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final bool isConnected = connectivityResult.any(
              (result) => result != ConnectivityResult.none
      );
      _isOffline = !isConnected;

      if (!isConnected) {
        await _loadFromCache();
        return;
      }

      if (forceRefresh) {
        debugPrint('🔄 Force refresh - fetching fresh data from API');
        await _fetchFromApi();
        return;
      }

      final hasCache = await _dbHelper.hasCachedData();
      if (hasCache) {
        await _loadFromCache();
        return;
      }

      await _fetchFromApi();

    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Error: $e';
      });
      debugPrint('❌ Error: $e');
    }
  }

  Future<void> _fetchFromApi() async {
    try {
      debugPrint('🌐 Fetching movies from API...');

      final String url = '$_baseUrl$_endpoint?api_key=$_apiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];

        if (results.isEmpty) {
          setState(() {
            _movies = [];
            _isLoading = false;
            _hasError = false;
            _dataSource = 'No movies found';
          });
          return;
        }

        final movies = results.map((json) => Movie.fromJson(json)).toList();
        await _dbHelper.saveMovies(movies);

        setState(() {
          _movies = movies;
          _isLoading = false;
          _hasError = false;
          _isOffline = false;
          _isUsingCache = false;
          _dataSource = '🌐 Live from API';
        });

        debugPrint('✅ ${movies.length} movies fetched from API and saved to SQLite');

      } else if (response.statusCode == 401) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Invalid API key. Please check your TMDB API key.';
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Failed to load movies (Status: ${response.statusCode})';
        });
      }
    } catch (e) {
      final hasCache = await _dbHelper.hasCachedData();
      if (hasCache) {
        await _loadFromCache();
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Failed to fetch and no cache available';
        });
      }
    }
  }

  Future<void> _loadFromCache() async {
    try {
      debugPrint('📂 Loading from SQLite cache...');

      final movies = await _dbHelper.getMovies();
      final timestamp = await _dbHelper.getCacheTimestamp();

      if (movies.isEmpty) {
        setState(() async {
          _movies = [];
          _isLoading = false;
          _isUsingCache = false;
          _dataSource = 'No cached data available';

          final connectivityResult = await Connectivity().checkConnectivity();
          final bool isConnected = connectivityResult.any(
                  (result) => result != ConnectivityResult.none
          );

          if (!isConnected) {
            _hasError = true;
            _errorMessage = 'No cached data available offline';
          }
        });
        return;
      }

      String ageText = '';
      if (timestamp != null) {
        final ageInMinutes =
            (DateTime.now().millisecondsSinceEpoch - timestamp) / 60000;
        ageText = ' (${ageInMinutes.toStringAsFixed(1)} min old)';
      }

      final connectivityResult = await Connectivity().checkConnectivity();
      final bool isConnected = connectivityResult.any(
              (result) => result != ConnectivityResult.none
      );

      setState(() {
        _movies = movies;
        _isLoading = false;
        _hasError = false;
        _isUsingCache = true;
        _isOffline = !isConnected;
        // FIXED: Removed unnecessary braces
        _dataSource = '📂 SQLite Cache$ageText';

        if (!isConnected) {
          _errorMessage = '📴 You are viewing offline data';
        } else {
          _errorMessage = '📦 Using cached data$ageText';
        }
      });

      debugPrint('📂 ${movies.length} movies loaded from SQLite cache');

    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load cache: $e';
      });
      debugPrint('❌ Cache load error: $e');
    }
  }

  Future<void> _refreshMovies() async {
    debugPrint('🔄 Manual refresh triggered');
    await _fetchMovies(forceRefresh: true);
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshMovies,
            tooltip: 'Refresh from API',
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Icon(
              _isOffline ? Icons.wifi_off : Icons.wifi,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isOffline || _isUsingCache)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: _isOffline ? Colors.orange[700] : Colors.blue[700],
              child: Row(
                children: [
                  Icon(
                    _isOffline ? Icons.offline_bolt : Icons.storage,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isOffline
                          ? '📴 Offline - Showing cached data'
                          : '📦 $_dataSource', // FIXED: Removed braces
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (!_isOffline && !_isUsingCache && _dataSource.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              color: Colors.green[50],
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 16),
                  const SizedBox(width: 8),
                  Text(
                    _dataSource,
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 20),
            Text('Loading movies...'),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _errorMessage.contains('offline')
                    ? Icons.wifi_off
                    : Icons.error_outline,
                size: 64,
                color: _errorMessage.contains('offline')
                    ? Colors.orange
                    : Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _refreshMovies,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_movies.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_creation_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No movies found',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text('Try refreshing', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

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

  Widget _buildMovieCard(Movie movie, int index) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPoster(movie),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(movie.releaseDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        movie.voteAverage.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${movie.voteCount} votes)',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.overview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
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
    );
  }

  Widget _buildPoster(Movie movie) {
    if (movie.posterPath == null || movie.posterPath!.isEmpty) {
      return Container(
        width: 60,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.movie, color: Colors.grey, size: 30),
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
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      ),
    );
  }
}
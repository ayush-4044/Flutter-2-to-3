import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';


// ============================================================
// SONG MODEL
// ============================================================
class Song {
  final int id;
  final String title;
  final String artist;
  final String album;
  final double rating;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.rating,
  });

  // Convert to JSON for API
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'artist': artist,
    'album': album,
    'rating': rating,
  };

  // Convert from JSON
  factory Song.fromJson(Map<String, dynamic> json) => Song(
    id: json['id'],
    title: json['title'],
    artist: json['artist'],
    album: json['album'],
    rating: json['rating'].toDouble(),
  );

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'artist': artist,
    'album': album,
    'rating': rating,
  };

  // Convert from Map (SQLite)
  factory Song.fromMap(Map<String, dynamic> map) => Song(
    id: map['id'],
    title: map['title'],
    artist: map['artist'],
    album: map['album'],
    rating: map['rating'].toDouble(),
  );
}

// ============================================================
// DATABASE HELPER CLASS
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
    final path = '${directory.path}/songs.db';
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE songs (
        id INTEGER PRIMARY KEY,
        title TEXT,
        artist TEXT,
        album TEXT,
        rating REAL,
        cache_timestamp INTEGER
      )
    ''');
    print('✅ Database created successfully');
  }

  // Task 3: Save songs to SQLite
  Future<void> insertSongs(List<Song> songs) async {
    final db = await database;
    await db.transaction((txn) async {
      // Clear existing data
      await txn.delete('songs');

      // Insert new songs
      for (var song in songs) {
        await txn.insert('songs', {
          ...song.toMap(),
          'cache_timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
    });
    print('✅ ${songs.length} songs saved to SQLite');
  }

  // Task 3: Load songs from SQLite
  Future<List<Song>> getSongs() async {
    final db = await database;
    final result = await db.query('songs');
    if (result.isEmpty) {
      return [];
    }

    // Task 4: Also get timestamp to check if cache exists
    final songs = result.map((map) => Song.fromMap(map)).toList();
    print('✅ ${songs.length} songs loaded from SQLite');
    return songs;
  }

  // Task 4: Check if SQLite has cached data
  Future<bool> hasCachedData() async {
    final db = await database;
    final result = await db.query('songs', limit: 1);
    return result.isNotEmpty;
  }

  // Task 5: Clear SQLite cache (used by refresh)
  Future<void> clearCache() async {
    final db = await database;
    await db.delete('songs');
    print('🗑️ SQLite cache cleared');
  }
}

// ============================================================
// MAIN SCREEN
// ============================================================
class TopSongsScreen extends StatefulWidget {
  const TopSongsScreen({super.key});

  @override
  State<TopSongsScreen> createState() => _TopSongsScreenState();
}

class _TopSongsScreenState extends State<TopSongsScreen> {
  // Task 2: In-memory caching variables
  List<Song> _cachedSongs = [];
  int _cacheTimestamp = 0;
  static const int _cacheDurationMs = 60000; // 1 minute

  // Task 3: SQLite database helper
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // State variables
  List<Song> _songs = [];
  bool _isLoading = false;
  bool _isOffline = false;
  String _statusMessage = '';
  String _dataSource = '';

  @override
  void initState() {
    super.initState();
    _loadSongsOnStart();
  }

  // ============================================================
  // TASK 1: fetchTopSongs() - Fetch from Mock API
  // ============================================================
  Future<List<Song>> _fetchTopSongs() async {
    print('🌐 Fetching fresh data from API...');

    // Simulating API call with mock data
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    // Mock API response
    final mockSongs = [
      Song(id: 1, title: 'Blinding Lights', artist: 'The Weeknd', album: 'After Hours', rating: 4.8),
      Song(id: 2, title: 'Shape of You', artist: 'Ed Sheeran', album: '÷', rating: 4.7),
      Song(id: 3, title: 'Dance Monkey', artist: 'Tones and I', album: 'The Kids Are Coming', rating: 4.6),
      Song(id: 4, title: 'Believer', artist: 'Imagine Dragons', album: 'Evolve', rating: 4.5),
      Song(id: 5, title: 'Levitating', artist: 'Dua Lipa', album: 'Future Nostalgia', rating: 4.4),
      Song(id: 6, title: 'Starboy', artist: 'The Weeknd', album: 'Starboy', rating: 4.3),
      Song(id: 7, title: 'Bad Guy', artist: 'Billie Eilish', album: 'When We All Fall Asleep', rating: 4.2),
      Song(id: 8, title: 'Uptown Funk', artist: 'Mark Ronson ft. Bruno Mars', album: 'Uptown Special', rating: 4.1),
      Song(id: 9, title: 'Someone Like You', artist: 'Adele', album: '21', rating: 4.0),
      Song(id: 10, title: 'Can\'t Stop the Feeling', artist: 'Justin Timberlake', album: 'Trolls', rating: 3.9),
    ];

    return mockSongs;
  }

  // ============================================================
  // TASK 1: Display in ListView with Loading Indicator
  // ============================================================
  Future<void> _loadSongs({
    bool forceRefresh = false,
    bool ignoreCache = false, // Task 5: For refresh button
  }) async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
      _isOffline = false;
    });

    try {
      // Task 4: Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      final bool isConnected = connectivityResult != ConnectivityResult.none;

      if (!isConnected) {
        // Task 4: Offline mode - show cached data from SQLite
        print('📴 Device is offline');
        final cachedSongs = await _dbHelper.getSongs();
        if (cachedSongs.isNotEmpty) {
          setState(() {
            _songs = cachedSongs;
            _isLoading = false;
            _isOffline = true;
            _dataSource = 'SQLite Cache';
            _statusMessage = '📴 Offline - Showing Cached Data';
          });
          print('📴 Offline - ${cachedSongs.length} songs loaded from SQLite');
          return;
        } else {
          // No cached data available
          setState(() {
            _songs = [];
            _isLoading = false;
            _isOffline = true;
            _dataSource = 'None';
            _statusMessage = '📴 No cached data available offline';
          });
          return;
        }
      }

      // Task 5: Force refresh - ignore cache
      if (ignoreCache) {
        print('🔄 Force refresh - ignoring cache');
        await _fetchAndCacheSongs();
        return;
      }

      // Task 2: Check in-memory cache
      final now = DateTime.now().millisecondsSinceEpoch;
      final cacheAge = now - _cacheTimestamp;
      final bool isCacheValid = _cachedSongs.isNotEmpty && cacheAge < _cacheDurationMs;

      if (isCacheValid && !forceRefresh) {
        // Task 2: Use in-memory cache
        setState(() {
          _songs = _cachedSongs;
          _isLoading = false;
          _dataSource = 'Memory Cache (${(cacheAge / 1000).toStringAsFixed(1)}s old)';
          _statusMessage = '📦 Using cached data (${(cacheAge / 1000).toStringAsFixed(1)}s old)';
        });
        print('📦 Using memory cache - ${_cachedSongs.length} songs');
        return;
      }

      // Task 3: Check SQLite cache if not forcing refresh
      if (!forceRefresh && !isCacheValid) {
        final sqliteSongs = await _dbHelper.getSongs();
        if (sqliteSongs.isNotEmpty) {
          // Task 3: Load from SQLite
          setState(() {
            _songs = sqliteSongs;
            _isLoading = false;
            _dataSource = 'SQLite Cache';
            _statusMessage = '🗄️ Loading from database cache';
          });
          // Also update in-memory cache
          _cachedSongs = sqliteSongs;
          _cacheTimestamp = now;
          print('🗄️ Loaded ${sqliteSongs.length} songs from SQLite');
          return;
        }
      }

      // Task 1 & 5: Fetch fresh data from API
      await _fetchAndCacheSongs();

    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Error: $e';
      });
      print('❌ Error loading songs: $e');
    }
  }

  // Helper: Fetch fresh data and cache it
  Future<void> _fetchAndCacheSongs() async {
    try {
      // Task 1: Fetch from API
      final songs = await _fetchTopSongs();

      setState(() {
        _songs = songs;
        _isLoading = false;
        _isOffline = false;
        _dataSource = 'API (Fresh)';
        _statusMessage = '✅ Loaded ${songs.length} songs from API';
      });

      // Task 2: Update in-memory cache
      _cachedSongs = songs;
      _cacheTimestamp = DateTime.now().millisecondsSinceEpoch;

      // Task 3: Save to SQLite
      await _dbHelper.insertSongs(songs);

      print('✅ ${songs.length} songs fetched and cached');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Error: $e';
      });
      rethrow;
    }
  }

  // Task 5: Refresh button handler
  Future<void> _refreshSongs() async {
    print('🔄 Refresh button pressed - forcing API call');
    await _loadSongs(ignoreCache: true);
  }

  // Load songs on app start
  void _loadSongsOnStart() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSongs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Songs'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Task 5: Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh from API',
            onPressed: _isLoading ? null : _refreshSongs,
          ),
        ],
      ),
      body: Column(
        children: [
          // Task 4: Offline Banner
          if (_isOffline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: Colors.orange[700],
              child: Row(
                children: [
                  const Icon(Icons.offline_bolt, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    _statusMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          // Data source info
          if (_dataSource.isNotEmpty && !_isOffline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              color: Colors.blue[50],
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    _dataSource,
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Status message
          if (_statusMessage.isNotEmpty && !_isOffline)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                _statusMessage,
                style: TextStyle(
                  color: _statusMessage.contains('Error')
                      ? Colors.red
                      : Colors.green[700],
                  fontSize: 13,
                ),
              ),
            ),

          // Task 1: ListView with Loading Indicator
          Expanded(
            child: _isLoading
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading songs...'),
                ],
              ),
            )
                : _songs.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.music_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No songs available',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _refreshSongs,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _songs.length,
              itemBuilder: (context, index) {
                final song = _songs[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    title: Text(
                      song.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🎤 ${song.artist}'),
                        Text('💿 ${song.album}'),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            song.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
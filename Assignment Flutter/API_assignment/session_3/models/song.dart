class Song {
  String title;
  String artist;

  Song({
    required this.title,
    required this.artist,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      title: json['title'] ?? 'Unknown Song',
      artist: json['artist'] ?? 'Unknown Artist',
    );
  }

  void display() {
    print('🎵 $title - $artist');
  }
}
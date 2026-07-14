import 'song.dart';

class Playlist {
  String name;
  List<Song> songs;

  Playlist({
    required this.name,
    required this.songs,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    var songList = json['songs'] as List;
    List<Song> songs = songList.map((song) => Song.fromJson(song)).toList();

    return Playlist(
      name: json['playlist_name'] ?? 'Unknown Playlist',
      songs: songs,
    );
  }

  void display() {
    print('========== SPOTIFY PLAYLIST ==========');
    print('Playlist Name: $name');
    print('Total Songs: ${songs.length}');
    print('');
    for (int i = 0; i < songs.length; i++) {
      print('${i + 1}. ${songs[i].title} - ${songs[i].artist}');
    }
    print('=========================================');
  }
}
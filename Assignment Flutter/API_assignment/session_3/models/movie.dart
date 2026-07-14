class Movie {
  String title;
  int year;
  String genre;

  Movie({
    required this.title,
    required this.year,
    required this.genre,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'] ?? 'Unknown',
      year: json['year'] ?? 0,
      genre: json['genre'] ?? 'Unknown',
    );
  }

  void display() {
    print('Title: $title');
    print('Year: $year');
    print('Genre: $genre');
    print('-------------------------');
  }
}
class Movie {
  final int id;
  final String title;
  final String posterPath;
  final String overView;
  final double voteAverage;
  final String releaseDate;

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.overView,
    required this.voteAverage,
    required this.releaseDate,
  });

  // fromJson

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0, // Default to 0 if ID is missing
      title: json['title'] ?? 'Unknown Title', // Default title
      // Some movies have NO poster, so it comes back null.
      // We set it to an empty string '' so it doesn't crash.
      posterPath: json['poster_path'] ?? '',

      // Obscure movies often have NO release date (null) or empty string.
      releaseDate:
          (json['release_date'] == null || json['release_date'].isEmpty)
          ? 'Unknown'
          : json['release_date'],

      // Handle ratings being int (8) or double (8.5)
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,

      overView: json['overview'] ?? 'No description available.',
    );
  }
}

abstract class MovieEvent {}

class FetchTrendingMovies extends MovieEvent {}

class SearchMovies extends MovieEvent {
  final String query;
  SearchMovies(this.query);
}

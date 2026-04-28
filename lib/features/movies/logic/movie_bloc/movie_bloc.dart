import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/features/movies/data/repository/movie_repo.dart';
import 'package:movie_app/features/movies/logic/movie_bloc/movie_event.dart';
import 'package:movie_app/features/movies/logic/movie_bloc/movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final MovieRepo repo;
  MovieBloc(this.repo) : super(MovieInitial()) {
    // when fetch trending is pressed

    on<FetchTrendingMovies>((event, emit) async {
      emit(MovieLoading());
      try {
        final movies = await repo.getTrendingMovies();
        emit(MovieLoaded(movies));
      } catch (e) {
        emit(MovieError(e.toString()));
      }
    });

    on<SearchMovies>((event, emit) async {
      emit(MovieLoading());
      try {
        final movies = await repo.searchMovies(event.query);
        emit(MovieLoaded(movies));
      } catch (e) {
        emit(MovieError(e.toString()));
      }
    });
  }
}

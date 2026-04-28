import 'package:flutter/material.dart';
import 'package:movie_app/core/constants/api_constants.dart';
import 'package:movie_app/core/service/storage_service.dart';
import 'package:movie_app/features/movies/data/models/movie.dart';
import 'package:movie_app/features/movies/data/repository/movie_repo.dart';
import 'package:movie_app/features/movies/presentation/pages/details_page.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  // This will hold our list of "Future" movies
  Future<List<Movie>>? _favoriteMovies;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    setState(() {
      _favoriteMovies = _fetchMovies();
    });
  }

  Future<List<Movie>> _fetchMovies() async {
    final movieIds = await StorageService.getFavorites();
    // 2. Loop through IDs and fetch details for EACH one
    // This runs all requests at the same time (Parallel)
    final List<Future<Movie>> futures = movieIds
        .map((id) => MovieRepo().getMovieDetails(id))
        .toList();
    // 3. Wait for all of them to finish
    return Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My WatchList')),
      body: FutureBuilder<List<Movie>>(
        future: _favoriteMovies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Favorites yet"));
          }
          final movies = snapshot.data!;
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return GestureDetector(
                onTap: () async {
                  // Navigate to Details and wait for return
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailsPage(movie: movie),
                    ),
                  );
                  // Refresh list when coming back (in case you unliked it!)
                  _loadFavorites();
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    '${ApiConstants.imageBaseUrl}${movie.posterPath}',
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/constants/api_constants.dart';
import 'package:movie_app/features/movies/logic/movie_bloc/movie_bloc.dart';
import 'package:movie_app/features/movies/logic/movie_bloc/movie_event.dart';
import 'package:movie_app/features/movies/logic/movie_bloc/movie_state.dart';
import 'package:movie_app/features/movies/presentation/pages/details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  // we need a timer so the api isn't called on evrystroke of key
  Timer? _debounce;

  // function runs when the user types
  void _onSearchChanged(String query) {
    // Cancel the previous timer if the user types again before 500ms is up
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Start a new timer
    _debounce = Timer(const Duration(milliseconds: 1500), () {
      if (query.isNotEmpty) {
        // 🚀 ONLY fires if you stop typing for 500ms
        context.read<MovieBloc>().add(SearchMovies(query));
      }
    });
  }

  @override
  void dispose() {
    // 1. Kill the text controller to free up memory
    _searchController.dispose();
    _debounce?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search movies...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white54),
          ),
          onChanged: _onSearchChanged, // calls the API when the user types
        ),
      ),
      body: BlocBuilder<MovieBloc, MovieState>(
        builder: (context, state) {
          if (state is MovieLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MovieError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error searching movies ${state.message}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (state is MovieLoaded) {
            if (state.movies.isEmpty) {
              return const Text("No movies found");
            }
            return ListView.builder(
              itemBuilder: (context, index) {
                final movie = state.movies[index];
                return ListTile(
                  leading: SizedBox(
                    width: 50,
                    height: 75, // Give it a fixed height so it looks nice
                    child: movie.posterPath.isEmpty
                        // 1. IF NO POSTER: Show a generic icon immediately (No network call!)
                        ? Container(
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.movie,
                              color: Colors.white54,
                            ),
                          )
                        // 2. IF POSTER EXISTS: Fetch it
                        : Hero(
                            tag: movie.id,
                            child: CachedNetworkImage(
                              imageUrl:
                                  "${ApiConstants.imageBaseUrl}${movie.posterPath}",
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Container(color: Colors.grey[900]),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                  ),
                  title: Text(movie.title),
                  subtitle: Text(movie.releaseDate),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsPage(movie: movie),
                      ),
                    );
                  },
                );
              },
              itemCount: state.movies.length,
            );
          }
          return const Center(child: Text("Type to search..."));
        },
      ),
    );
  }
}

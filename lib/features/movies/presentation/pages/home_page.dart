import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/constants/api_constants.dart';
import 'package:movie_app/features/movies/logic/movie_bloc/movie_bloc.dart';
import 'package:movie_app/features/movies/logic/movie_bloc/movie_event.dart';
import 'package:movie_app/features/movies/logic/movie_bloc/movie_state.dart';
import 'package:movie_app/features/movies/presentation/pages/details_page.dart';
import 'package:movie_app/features/movies/presentation/pages/search_pages.dart';
import 'package:movie_app/features/movies/presentation/watchlist_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // load the treding movies as soon the page loads
    context.read<MovieBloc>().add(FetchTrendingMovies());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CinemaHub 🍿'),
        leading: IconButton(
          onPressed: () {
            context.read<MovieBloc>().add(FetchTrendingMovies());
          },
          icon: Icon(Icons.refresh),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WatchlistPage()),
              );
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              ).then((_) {
                // 🔄 THIS RUNS WHEN YOU COME BACK!
                // It forces the BLoC to fetch trending movies again.
                context.read<MovieBloc>().add(FetchTrendingMovies());
              });
            },
            icon: Icon(Icons.search),
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: BlocBuilder<MovieBloc, MovieState>(
          builder: (context, state) {
            // loading state
            if (state is MovieLoading) {
              return Center(child: CircularProgressIndicator());
            }
            if (state is MovieError) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error Loading Movies :( ${state.message})',
                      textAlign: TextAlign.center,
                    ),
                    OutlinedButton(
                      onPressed: () {
                        context.read<MovieBloc>().add(FetchTrendingMovies());
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (state is MovieLoaded) {
              return RefreshIndicator(
                color: Colors.white,
                backgroundColor: Colors.orange,
                onRefresh: () async {
                  context.read<MovieBloc>().add(FetchTrendingMovies());
                  await Future.delayed(const Duration(seconds: 1));
                },
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 20,
                    // mainAxisExtent: 320,
                  ),
                  itemCount: state.movies.length,
                  itemBuilder: (context, index) {
                    final movies = state.movies[index];
                    return GridTile(
                      footer: GridTileBar(
                        backgroundColor: Colors.black12,
                        // title: Text(movies.title, textAlign: TextAlign.center),
                      ),
                      // the magic image Loader
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsPage(movie: movies),
                            ),
                          );
                        },
                        child: Container(
                          clipBehavior: Clip.hardEdge,

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white54,
                              width: 2.5,
                            ),
                          ),
                          child: Hero(
                            tag: movies.id,
                            child: CachedNetworkImage(
                              imageUrl:
                                  '${ApiConstants.imageBaseUrl}${movies.posterPath}',
                              placeholder: (context, url) =>
                                  Container(color: Colors.grey[900]),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            // default state intial
            return const Center(child: Text("Welcome to CinemaHub"));
          },
        ),
      ),
    );
  }
}

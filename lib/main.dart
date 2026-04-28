import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/features/movies/data/repository/movie_repo.dart';
import 'package:movie_app/features/movies/logic/movie_bloc/movie_bloc.dart';
import 'package:movie_app/features/movies/presentation/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => MovieRepo(),
      child: BlocProvider(
        create: (context) =>
            MovieBloc(RepositoryProvider.of<MovieRepo>(context)),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(),
          home: const HomePage(),
        ),
      ),
    );
  }
}

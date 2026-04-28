import 'dart:convert';

import 'package:movie_app/core/constants/api_constants.dart';
import 'package:movie_app/features/movies/data/models/movie.dart';
import 'package:http/http.dart' as http; // The tool to talk to the internet

class MovieRepo {
  // fetch trending movies

  Future<List<Movie>> getTrendingMovies() async {
    // construct the URL

    final String url =
        "${ApiConstants.baseUrl}/trending/movie/day?api_key=${ApiConstants.apiKey}";

    try {
      // send request

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        List<Map<String, dynamic>> results = List<Map<String, dynamic>>.from(
          data['results'],
        );
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load trending movies");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }

  // search movies
  Future<List<Movie>> searchMovies(String query) async {
    // 🛡️ ENCODING: This turns "Iron Man" into "Iron%20Man" so the URL doesn't break.
    final String safeQuery = Uri.encodeComponent(query);
    // ✅ CORRECT (No '/day')
    final String url =
        "${ApiConstants.baseUrl}/search/movie?api_key=${ApiConstants.apiKey}&query=$safeQuery";

    // print the url to debug
    print("SEARCHING: $url");
    try {
      final response = await http.get(Uri.parse(url));
      // 200 if success
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<Map<String, dynamic>> results =
            List<Map<String, dynamic>>.from(data['results']);
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception(
          "Error Code ${response.statusCode} | Message: ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }

  // get movie detail
  Future<Movie> getMovieDetails(String id) async {
    final String url =
        '${ApiConstants.baseUrl}/movie/$id?api_key=${ApiConstants.apiKey}';
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      return Movie.fromJson(data);
    } else {
      throw Exception(
        "Error Code ${response.statusCode} | Message: ${response.body}",
      );
    }
  }
}

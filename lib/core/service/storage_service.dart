import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // save a list of movie ID's
  static Future<void> saveFavorite(String movieId) async {
    final prefs = await SharedPreferences.getInstance();
    //  get the current list if exist in the folder if not then make a new one
    List<String> favorites = prefs.getStringList('favorite_movies') ?? [];

    // if it's not favorite then add the movie in the favorite list
    if (!favorites.contains(movieId)) {
      favorites.add(movieId);
      await prefs.setStringList('favorite_movies', favorites); // save to disk
      print("✅ Saved Movie ID: $movieId");
    }
  }

  // remove a movie
  static Future<void> removeFavotite(String movieId) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> favorites = prefs.getStringList('favorite_movies') ?? [];

    // if it's favorite then remove the from the favorite list
    if (favorites.contains(movieId)) {
      favorites.remove(movieId);
      await prefs.setStringList('favorite_movies', favorites); // Save to disk
      print("🗑️ Removed Movie ID: $movieId");
    }
  }

  // 3. Check if a movie is already liked (True/False)

  static Future<bool> isFavorite(String movieId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favotite_movie') ?? [];
    return favorites.contains(movieId);
  }

  // get favorites
  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('favorite_movies') ?? [];
  }
}

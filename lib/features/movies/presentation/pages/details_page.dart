import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/core/constants/api_constants.dart';
import 'package:movie_app/core/service/storage_service.dart';
import 'package:movie_app/features/movies/data/models/movie.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key, required this.movie});

  final Movie movie;

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  bool isLiked = false; // 1. Keeps track of the heart color
  @override
  void initState() {
    super.initState();
    _checkIfLiked(); // check as soon as the page loads
  }

  void _checkIfLiked() async {
    bool liked = await StorageService.isFavorite(widget.movie.id.toString());

    // update the UI
    if (mounted) {
      setState(() {
        isLiked = liked;
      });
    }
  }

  void _toogleLike() async {
    if (isLiked) {
      await StorageService.removeFavotite(widget.movie.id.toString());
    } else {
      await StorageService.saveFavorite(widget.movie.id.toString());
    }
    setState(() {
      isLiked = !isLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Hero(
                  tag: widget.movie.id,
                  child: CachedNetworkImage(
                    imageUrl:
                        '${ApiConstants.imageBaseUrl}${widget.movie.posterPath}',
                    height: 400,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                // The "Back Button" needs to be safe from the status bar
                SafeArea(
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(10),
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // title and rating
            Padding(
              padding: EdgeInsetsGeometry.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.movie.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 20),
                      GestureDetector(
                        onTap: _toogleLike,
                        child: Icon(
                          isLiked
                              ? Icons.favorite
                              : Icons.favorite_border, // ❤️ or 🤍
                          color: isLiked ? Colors.red : Colors.grey,
                          size: 35,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      SizedBox(width: 10),
                      Text(
                        '${widget.movie.voteAverage.toStringAsFixed(1)}/10',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // overView
                  Text(
                    'Overview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  // overView
                  Text(
                    widget.movie.overView,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

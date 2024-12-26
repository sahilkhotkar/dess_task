import 'package:flutter/material.dart';
import 'apod_screen.dart';
import 'mars_photos_screen.dart';
import 'earth_image_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Space Explorer")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ApodScreen()));
              },
              child: const Text("Astronomy Picture of the Day"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MarsPhotosScreen()));
              },
              child: const Text("Mars Rover Photos"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => EarthImageScreen()));
              },
              child: const Text("Earth Imagery"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => FavoritesScreen()));
              },
              child: const Text("Favorites"),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:space/helpers/internet_check.dart';
import 'package:space/models/apod.dart';
import 'package:space/provider/favourites_provider.dart';
import 'package:space/provider/theme_provider.dart';
import 'package:space/screens/earth_image_screen.dart';
import 'package:space/screens/favorites_screen.dart';
import 'package:space/screens/mars_photos_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:space/services/api_service.dart';

class ApodScreen extends StatelessWidget {
  final Box apodBox = Hive.box('favorites');

  Future<ApodModel> fetchApodWithInternetCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('apod_response');
    final internetAvailable = await InternetCheck().hasInternet();

    final connectivityResult = await Connectivity().checkConnectivity();
    print(connectivityResult);
    if (connectivityResult == ConnectivityResult.none || !internetAvailable) {
      if (cachedData != null) {
        print("Loading cached data...");
        return ApodModel.fromJson(json.decode(cachedData));
      } else {
        throw Exception("No internet and no cached data available");
      }
    } else {
      print("Fetching new data...");
      final url = Uri.parse(
          "https://api.nasa.gov/planetary/apod?api_key=5LkrhAgiOqYaIPa2EeIQumR5COX7q02Rs44iHAFC");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final apodModel = ApodModel.fromJson(json.decode(response.body));
        await prefs.setString('apod_response', response.body);
        return apodModel;
      } else {
        throw Exception("Failed to load APOD");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Astronomy Picture of the Day",
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.blue,
        iconTheme:
            IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                Icon(Icons.light_mode,
                    color: isDarkMode ? Colors.white : Colors.black),
                Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value);
                  },
                ),
                Icon(Icons.dark_mode,
                    color: isDarkMode ? Colors.white : Colors.black),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        color: isDarkMode ? Colors.black : Colors.white,
        child: FutureBuilder<ApodModel>(
          future: ApiService().fetchApod(),
          builder: (context, snapshot) {
            
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: isDarkMode ? Colors.redAccent : Colors.red),
                ),
              );
            } else if (snapshot.hasData) {
              final apod = snapshot.data!;
              final isFavorite = apodBox.containsKey(apod.url);
              print(apod.url);
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: apod.url,
                          height: MediaQuery.of(context).size.height / 2.5,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
                              size: 30,
                            ),
                            onPressed: () {
                              if (isFavorite) {
                                apodBox.delete(apod.url);
                              } else {
                                apodBox.put(apod.url, apod.toJson());
                              }
                              (context as Element).markNeedsBuild();
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: CircleAvatar(
                            backgroundColor:
                                isDarkMode ? Colors.black : Colors.white,
                            child: IconButton(
                              icon: Icon(
                                Icons.zoom_in,
                                color: isDarkMode ? Colors.white : Colors.black,
                                size: 25,
                              ),
                              onPressed: () {
                                showImageViewer(
                                  context,
                                  NetworkImage(apod.url),
                                  swipeDismissible: true,
                                  doubleTapZoomable: true,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.image,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.white),
                                label: Text("Mars Photos",
                                    style: GoogleFonts.roboto(
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDarkMode
                                      ? Colors.grey[850]
                                      : Colors.blue,
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MarsPhotosScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.terrain,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.white),
                                label: Text("Earth Imagery",
                                    style: GoogleFonts.roboto(
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDarkMode
                                      ? Colors.grey[850]
                                      : Colors.blue,
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EarthImageScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.favorite,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.white),
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("Favorites",
                                        style: GoogleFonts.roboto(
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.white)),
                                    const SizedBox(width: 8),
                                    Consumer<FavoritesProvider>(
                                      builder:
                                          (context, favoritesProvider, child) {
                                        return favoritesProvider
                                                    .getFavoritesCount() >
                                                0
                                            ? CircleAvatar(
                                                radius: 12,
                                                backgroundColor: Colors.red,
                                                child: Text(
                                                  favoritesProvider
                                                      .getFavoritesCount()
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white),
                                                ),
                                              )
                                            : const SizedBox();
                                      },
                                    ),
                                  ],
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDarkMode
                                      ? Colors.grey[850]
                                      : Colors.blue,
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FavoritesScreen(),
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        apod.title,
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        apod.explanation,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Center(
                child: Text(
                  "No data found.",
                  style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

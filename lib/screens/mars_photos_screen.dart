import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:space/helpers/internet_check.dart';
import 'package:space/models/MarsPhoto.dart';
import 'package:space/provider/favourites_provider.dart';
import 'package:space/provider/theme_provider.dart';
import 'package:space/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarsPhotosScreen extends StatefulWidget {
  @override
  _MarsPhotosScreenState createState() => _MarsPhotosScreenState();
}

class _MarsPhotosScreenState extends State<MarsPhotosScreen> {
  final ApiService apiService = ApiService();
  String selectedRover = 'curiosity';
  int selectedSol = 1000;
  String selectedCamera = 'NAVCAM';
  late Future<List<MarsPhoto>> photosFuture;
  final String cacheKey = 'mars_photos_response';

  @override
  void initState() {
    super.initState();
    photosFuture = fetchMarsPhotos();
  }

  Future<List<MarsPhoto>> fetchMarsPhotos() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final internetAvailable = await InternetCheck().hasInternet();

    if (connectivityResult == ConnectivityResult.none || !internetAvailable) {
          
      print("No internet connection, loading cached Mars photos...");
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        final List<dynamic> photos = json.decode(cachedData)['photos'];
        return photos.map((photo) => MarsPhoto.fromJson(photo)).toList();
      } else {
        throw Exception("No cached Mars photos available.");
      }
    } else {
          
      print("Internet available, fetching Mars photos...");
      try {
        final photos = await apiService.fetchMarsPhotos(
            selectedRover, selectedSol, selectedCamera);
            
        final prefs = await SharedPreferences.getInstance();
        prefs.setString(cacheKey, json.encode({'photos': photos}));
        return photos;
      } catch (e) {
        throw Exception("Failed to fetch Mars photos: $e");
      }
    }
  }

  void fetchPhotos() {
    setState(() {
      photosFuture = fetchMarsPhotos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mars Rover Photos"),
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.blue,
        iconTheme:
            IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
      ),
      body: Container(
        color: isDarkMode ? Colors.black : Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      dropdownColor: isDarkMode ? Colors.black : Colors.white,
                      value: selectedRover,
                      onChanged: (value) {
                        setState(() {
                          selectedRover = value!;
                          fetchPhotos();
                        });
                      },
                      items: ['curiosity', 'opportunity', 'spirit']
                          .map((rover) => DropdownMenuItem(
                                value: rover,
                                child: Text(
                                  rover.toUpperCase(),
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  Expanded(
                    child: DropdownButton<String>(
                      dropdownColor: isDarkMode ? Colors.black : Colors.white,
                      value: selectedCamera,
                      onChanged: (value) {
                        setState(() {
                          selectedCamera = value!;
                          fetchPhotos();
                        });
                      },
                      items: ['NAVCAM', 'PANCAM', 'MINITES', 'RHAZ', 'FHAZ']
                          .map((camera) => DropdownMenuItem(
                                value: camera,
                                child: Text(
                                  camera.toUpperCase(),
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: TextEditingController(text: selectedSol.toString()),
                style: TextStyle(
                      
                  color: isDarkMode
                      ? Colors.white
                      : Colors.black,     
                ),
                decoration: InputDecoration(
                  labelText: "Sol (Martian Day)",
                  labelStyle: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black87),
                ),
                keyboardType: TextInputType.number,
                onSubmitted: (value) {
                  setState(() {
                    selectedSol = int.tryParse(value) ?? 1000;
                    fetchPhotos();
                  });
                },
              ),
            ),
            Expanded(
              child: FutureBuilder<List<MarsPhoto>>(
                future: photosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error: ${snapshot.error}",
                        style: GoogleFonts.aBeeZee(
                          color: isDarkMode ? Colors.white : Colors.amber,
                        ),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    final photos = snapshot.data!;
                    if (photos.isEmpty) {
                      return Center(
                          child: Text(
                        "No images found.",
                        style: GoogleFonts.aBeeZee(
                            color: isDarkMode ? Colors.white : Colors.black),
                      ));
                    }
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,     
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: photos.length,
                      itemBuilder: (context, index) {
                        final photo = photos[index];
                        return GestureDetector(
                          onTap: () {
                            showImageViewer(
                              context,
                              NetworkImage(photo.imgSrc),
                              swipeDismissible: true,
                              doubleTapZoomable: true,
                            );
                          },
                          child: Card(
                            elevation: 4,
                            color: isDarkMode ? Colors.grey[900] : Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: photo.imgSrc,
                                  fit: BoxFit
                                      .cover,     
                                  height: 150,     
                                  placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator(
                                      color: isDarkMode
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    photo.camera.fullName,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text("No photos available."));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

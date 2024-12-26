import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:space/helpers/internet_check.dart';
import 'package:space/provider/favourites_provider.dart';
import 'package:space/provider/theme_provider.dart';
import 'package:space/services/api_service.dart';

class EarthImageScreen extends StatefulWidget {
  @override
  _EarthImageScreenState createState() => _EarthImageScreenState();
}

class _EarthImageScreenState extends State<EarthImageScreen> {
  final ApiService apiService = ApiService();
  final Box favoritesBox = Hive.box('favorites');

  double latitude = 29.78;    
  double longitude = -95.33;    
  String date = DateTime.now().toString().substring(0, 10);    
  late Future<String> imageUrlFuture;
  String? currentImageUrl;
  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    fetchEarthImage();
  }

  Future<void> fetchEarthImage() async {
    final cacheKey = "earth_image";
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(cacheKey);

    final connectivityResult = await Connectivity().checkConnectivity();

    setState(() {
      isOffline = connectivityResult == ConnectivityResult.none;

      if (isOffline) {
        currentImageUrl = cachedData;    
      } else {
        imageUrlFuture = apiService.fetchEarthImage(latitude, longitude, date);
        imageUrlFuture.then((url) async {
          setState(() {
            currentImageUrl = url;
            prefs.setString(cacheKey, url);
          });    
        });
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(date),
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != DateTime.parse(date)) {
      setState(() {
        date = pickedDate
            .toIso8601String()
            .substring(0, 10);    
        fetchEarthImage();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Earth Imagery"),
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
                    child: TextField(
                      style: GoogleFonts.aBeeZee(
                          color: isDarkMode ? Colors.white : Colors.black),
                      controller:
                          TextEditingController(text: latitude.toString()),
                      decoration: InputDecoration(
                        labelText: "Latitude",
                        labelStyle: TextStyle(
                            color:
                                isDarkMode ? Colors.white70 : Colors.black87),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        latitude = double.tryParse(value) ?? latitude;
                      },
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      style: GoogleFonts.aBeeZee(
                          color: isDarkMode ? Colors.white : Colors.black),
                      controller:
                          TextEditingController(text: longitude.toString()),
                      decoration: InputDecoration(
                        labelText: "Longitude",
                        labelStyle: TextStyle(
                            color:
                                isDarkMode ? Colors.white70 : Colors.black87),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        longitude = double.tryParse(value) ?? longitude;
                      },
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: "Date (YYYY-MM-DD)",
                            suffixIcon: Icon(Icons.calendar_today,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black87),
                          ),
                          controller: TextEditingController(text: date),
                          readOnly: true,
                          style: TextStyle(
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: fetchEarthImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.blueGrey : Colors.blue,
              ),
              child: Text(
                "Fetch Image",
                style: GoogleFonts.roboto(
                  color: isDarkMode ? Colors.white : Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * .1,
            ),
            Expanded(
              child: currentImageUrl != null
                  ? Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showImageViewer(
                              context,
                              NetworkImage(
                                currentImageUrl!,
                              ),
                              swipeDismissible: true,
                              doubleTapZoomable: true,
                            );
                          },
                          child: CachedNetworkImage(
                            imageUrl: currentImageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,    
                               
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.error,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: GestureDetector(
                            onTap: () {
                              final isFavorite =
                                  favoritesBox.containsKey(currentImageUrl!);
                              setState(() {
                                final favoritesProvider =
                                    Provider.of<FavoritesProvider>(context,
                                        listen: false);
                                if (isFavorite) {
                                  favoritesBox.delete(currentImageUrl!);
                                } else {
                                  favoritesBox.put(currentImageUrl!, {
                                    'imgSrc': currentImageUrl!,
                                    "title": "Earth Imagery ${DateTime.now()}",
                                  });
                                  favoritesProvider.updateCount();
                                }
                              });
                            },
                            child: Icon(
                              favoritesBox.containsKey(currentImageUrl!)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
                              size: 32,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Text(
                        isOffline
                            ? "No internet. Showing cached data."
                            : "Fetching data...",
                        style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:space/helpers/internet_check.dart';
import 'package:space/models/MarsPhoto.dart';
import 'package:space/models/apod.dart';
import 'package:http/http.dart' as http;

class ApiService {
  late String apiKey;

  ApiService() {
    dotenv.load(fileName: ".env");
    apiKey = dotenv.env['NASA_API_KEY'] ?? 'API_KEY NOT FOUND';
  }

  Future<ApodModel> fetchApod() async {
    // final prefs = await SharedPreferences.getInstance();
    // final cachedData = prefs.getString('apod_response');

    // // Check internet connectivity
    // final connectivityResult = await Connectivity().checkConnectivity();

    // if (connectivityResult == ConnectivityResult.none) {
    //   if (cachedData != null) {
    //     print("No internet. Loading cached data...");
    //     return ApodModel.fromJson(json.decode(cachedData));
    //   } else {
    //     throw Exception("No internet and no cached data available.");
    //   }
    // }

    // // If internet is available, fetch new data
    // final url =
    //     Uri.parse("https://api.nasa.gov/planetary/apod?api_key=${apiKey}");
    // print("https://api.nasa.gov/planetary/apod?api_key=${apiKey}");
    // print("Internet available. Fetching new data...");
    // final response = await http.get(url);

    // if (response.statusCode == 200) {
    //   final apodModel = ApodModel.fromJson(json.decode(response.body));
    //   // Cache the response
    //   await prefs.setString('apod_response', response.body);
    //   return apodModel;
    // } else {
    //   throw Exception("Failed to load APOD");
    // }
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
          "https://api.nasa.gov/planetary/apod?api_key=${dotenv.env['NASA_API_KEY']}");
      print(
          "https://api.nasa.gov/planetary/apod?api_key=${dotenv.env['NASA_API_KEY']}");
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

  Future<List<MarsPhoto>> fetchMarsPhotos(
      String rover, int sol, String camera) async {
    final url = Uri.parse(
        "https://api.nasa.gov/mars-photos/api/v1/rovers/$rover/photos?sol=$sol&camera=$camera&api_key=${dotenv.env['NASA_API_KEY']}");
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = "mars_photos_response";
    final cachedData = prefs.getString(cacheKey);
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      if (cachedData != null) {
        print("Loading cached Mars photos...");
        final List<dynamic> photos = json.decode(cachedData)['photos'];
        return photos.map((photo) => MarsPhoto.fromJson(photo)).toList();
      } else {
        throw Exception("No internet connection and no cached data available.");
      }
    }

    print("Fetching new Mars photos...");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> photos = json.decode(response.body)['photos'];
      await prefs.setString(cacheKey, response.body);
      return photos.map((photo) => MarsPhoto.fromJson(photo)).toList();
    } else {
      throw Exception("Failed to load Mars photos");
    }
  }

  Future<String> fetchEarthImage(double lat, double lon, String date) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = "earth_image";
    final cachedData = prefs.getString(cacheKey);
    final internetAvailable = await InternetCheck().hasInternet();
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none || !internetAvailable) {
      print("Loading cached Earth image...");
      return cachedData!;
    }

    final url = Uri.parse(
        "https://api.nasa.gov/planetary/earth/assets?lon=$lon&lat=$lat&date=$date&dim=0.1&api_key=${dotenv.env['NASA_API_KEY']}");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final imageUrl = json.decode(response.body)['url'];
      await prefs.setString(cacheKey, imageUrl);
      return imageUrl;
    } else {
      throw Exception("Imagery Not available for these parameters");
    }
  }
}

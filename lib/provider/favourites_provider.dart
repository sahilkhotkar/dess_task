import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FavoritesProvider with ChangeNotifier {
  final Box favoritesBox = Hive.box('favorites');
  int _favoritesCount = 0;
  int get favoritesCount => _favoritesCount;
  int getFavoritesCount() {
    return favoritesBox.length;
  }

  void updateCount() {
    _favoritesCount = favoritesBox.length;
    notifyListeners(); 
  }
}

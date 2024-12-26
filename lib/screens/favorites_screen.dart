import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:space/provider/favourites_provider.dart';
import 'package:space/provider/theme_provider.dart';

class FavoritesScreen extends StatelessWidget {
  final Box favoritesBox = Hive.box('favorites');

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.blue,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
      ),
      body: Container(
        color: isDarkMode ? Colors.black : Colors.white,
        child: ValueListenableBuilder(
          valueListenable: favoritesBox.listenable(),
          builder: (context, Box box, _) {
            if (box.isEmpty) {
              return  Center(child: Text("No favorite items yet.", style: TextStyle(fontSize: 18,color: isDarkMode?Colors.white:Colors.black)));
            }

            final favoriteItems = box.values.toList();
            print(favoriteItems);
            return ListView.builder(
              itemCount: favoriteItems.length,
              itemBuilder: (context, index) {
                final favorite = favoriteItems[index];
                final title = favorite['title'] ?? favorite['rover'];
                final imageUrl = favorite['url'] ?? favorite['imgSrc'];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: isDarkMode ? Colors.grey[800] : Colors.white,
                  child: ListTile(
                    leading: imageUrl.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              showImageViewer(
                                context,
                                NetworkImage(imageUrl),
                                swipeDismissible: true,
                                doubleTapZoomable: true,
                              );
                            },
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.image_not_supported, size: 50),
                    title: Text(
                      title ?? "",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        box.deleteAt(index);
                        Provider.of<FavoritesProvider>(context, listen: false).updateCount();
                      },
                    ),
                    onTap: () {},
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

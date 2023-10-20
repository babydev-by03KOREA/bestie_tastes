import 'dart:math';

import 'package:bestie_tastes/home/index.dart';
import 'package:bestie_tastes/location/index.dart';
import 'package:bestie_tastes/models/restaurants.dart';
import 'package:bestie_tastes/wishlist/index.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchResultWidget extends StatefulWidget {
  final List<Restaurants> restaurants;
  final double? userLat;
  final double? userLon;
  final DistanceUnit currentUnit;
  final String currentLocationName;
  final TextEditingController searchController;
  final Function(String location, String keyword) onSearch;

  const SearchResultWidget({
    super.key,
    required this.restaurants,
    required this.userLat,
    required this.userLon,
    required this.currentUnit,
    required this.currentLocationName,
    required this.searchController,
    required this.onSearch,
  });

  @override
  State<SearchResultWidget> createState() => _SearchResultWidgetState();
}

class _SearchResultWidgetState extends State<SearchResultWidget> {
  int pageIndex = 0;
  final pageController = PageController();

  List<Widget> get pages =>
      [const HomeWidget(), const LocationWidget(), const WishlistWidget()];

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const int R = 6371;
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distanceInKM = R * c;

    return currentUnit == DistanceUnit.KM
        ? distanceInKM
        : distanceInKM * 0.621371;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildSearchBar(),
            const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
            Expanded(
              child: ListView.builder(
                itemCount: widget.restaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = widget.restaurants[index];

                  double distance =
                      widget.userLat != null && widget.userLon != null
                          ? calculateDistance(widget.userLat!, widget.userLon!,
                              restaurant.latitude, restaurant.longitude)
                          : 0;

                  return Card(
                    child: Column(
                      children: [
                        Stack(children: [
                          SizedBox(
                            height: 200.0,
                            width: double.infinity,
                            child: Image.network(
                              restaurant.imageUrl,
                              fit: BoxFit.cover,
                              alignment: const Alignment(0, 0.6),
                            ),
                          ),
                          Positioned(
                            top: 8.0,
                            right: 8.0,
                            child: IconButton(
                              icon: restaurant.isFavorited ?? false
                                  ? const FaIcon(FontAwesomeIcons.solidHeart)
                                  : const FaIcon(FontAwesomeIcons.heart),
                              onPressed: () {
                                setState(() {
                                  restaurant.toggleFavorite();
                                  debugPrint(
                                      "Clicked Restaurant Info - alias: ${restaurant.alias} & bool: ${restaurant.isFavorited}");

                                  if (restaurant.isFavorited) {
                                    // addToWishlist(restaurant.alias);
                                  }
                                });
                              },
                            ),
                          ),
                        ]),
                        const SizedBox(height: 8.0),
                        Text(restaurant.name),
                        Text(restaurant.categoryTitle),
                        Text(
                            "${distance.toStringAsFixed(2)} ${currentUnit == DistanceUnit.KM ? 'Km' : 'Mile'}"),
                      ],
                    ),
                  );
                },
              ),
            ),
            BottomNavigationBar(
              onTap: (value) {
                if (value == 0) {
                  _navigateToHome();
                  return;
                }
                pageController.jumpToPage(value);
                setState(() {
                  pageIndex = value;
                });
              },
              currentIndex: pageIndex,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: FaIcon(FontAwesomeIcons.houseChimney), label: 'Home'),
                BottomNavigationBarItem(
                    icon: FaIcon(FontAwesomeIcons.mapLocationDot),
                    label: 'Location'),
                BottomNavigationBarItem(
                    icon: FaIcon(FontAwesomeIcons.solidUser), label: 'Account'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const HomeWidget()));
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40.0,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.search, color: Colors.black),
            onPressed: () {
              widget.onSearch(
                  widget.currentLocationName, widget.searchController.text);
            },
          ),
          Expanded(
            child: TextField(
              controller: widget.searchController,
              decoration: const InputDecoration(
                hintText: "Find Your Taste",
                border: InputBorder.none,
              ),
              onSubmitted: (value) {
                widget.onSearch(
                    widget.currentLocationName, widget.searchController.text);
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:math';
import 'package:bestie_tastes/home/details/restaurant_deatil.dart';
import 'package:bestie_tastes/models/restaurants.dart';
import 'package:bestie_tastes/home/search/search_result.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart' as geoCoding;
import 'package:location/location.dart';
import 'package:bestie_tastes/service/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shimmer/shimmer.dart';

enum DistanceUnit { KM, Mile }

DistanceUnit currentUnit = DistanceUnit.KM;

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidget();
}

class _HomeWidget extends State<HomeWidget> {
  final _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  Future<List<Restaurants>>? _restaurantsFuture;
  Location location = Location();

  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;

  String currentLocationName = "No Service Area";

  @override
  void initState() {
    super.initState();

    _restaurantsFuture = fetchRestaurants(currentLocationName);
    _initLocation();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        fetchRestaurants(currentLocationName);
      }
    });
  }

  /// [Permission] Get Location Permission
  Future<void> _initLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled!) {
        _setUnionSquareLocation();
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        _setUnionSquareLocation();
        return;
      }
    }

    try {
      _locationData = await location.getLocation();
      await _updateLocation();
      setState(() {});
    } catch (e) {
      print('Error getting location: $e');
      _setUnionSquareLocation();
    }
  }

  /// [Location] Default Location > Union Square, CA
  void _setUnionSquareLocation() {
    _locationData =
        LocationData.fromMap({'latitude': 37.7879, 'longitude': -122.4074});
    setState(() {});
  }

  Future<String> _updateLocation() async {
    String locationName =
        await _getAreaName(_locationData?.latitude, _locationData?.longitude);

    setState(() {
      currentLocationName = locationName;
      _restaurantsFuture = fetchRestaurants(currentLocationName);
    });

    return locationName;
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

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  Future<String> _getAreaName(double? latitude, double? longitude) async {
    if (latitude == null || longitude == null) return "Unknown";

    List<geoCoding.Placemark> placemarks =
        await geoCoding.placemarkFromCoordinates(latitude, longitude);

    if (placemarks.isNotEmpty) {
      String locationName = placemarks.first.locality ?? "Unknown";
      return locationName;
    }

    return "Unknown";
  }

  @override
  Widget build(BuildContext context) {
    if (currentLocationName == "No Service Area") {
      return Center(child: _buildShimmerSkeleton());
    }
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              _restaurantsFuture = fetchRestaurants(currentLocationName);
              setState(() {});
            },
            child: Column(children: [
              _buildLocationAndUnitSelector(),
              _buildSearchBar(),
              const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              Expanded(
                child: FutureBuilder<List<Restaurants>>(
                  future: _restaurantsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListView.builder(
                        itemCount: 5,
                        itemBuilder: (_, __) => _buildShimmerSkeleton(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      final restaurants = snapshot.data!;

                      return SizedBox(
                        child: ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: restaurants.length,
                          itemBuilder: (context, index) {
                            final restaurant = restaurants[index];

                            double? userLat = _locationData?.latitude;
                            double? userLon = _locationData?.longitude;

                            double distance = userLat != null && userLon != null
                                ? calculateDistance(userLat, userLon,
                                    restaurant.latitude, restaurant.longitude)
                                : 0;

                            return Card(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                      type: PageTransitionType.fade,
                                      child: RestaurantDeatilWidget(
                                        restaurantId: restaurant.id,
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 200.0,
                                      width: double.infinity,
                                      child: Image.network(
                                        restaurant.imageUrl,
                                        fit: BoxFit.cover,
                                        alignment: const Alignment(0, 0.6),
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(restaurant.name,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20)),
                                          ),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: CircleAvatar(
                                              child: Text(
                                                restaurant.rating.toString(),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 15),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                              "${distance.toStringAsFixed(2)} ${currentUnit == DistanceUnit.KM ? 'Km' : 'Mile'}"),
                                          const SizedBox(width: 8.0),
                                          Text(restaurant.categoryTitle),
                                          const SizedBox(width: 8.0),
                                          Text(restaurant.price),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationAndUnitSelector() {
    if (currentLocationName.isEmpty) {
      return _buildShimmerSkeleton();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const FaIcon(FontAwesomeIcons.locationDot, color: Colors.black),
              const SizedBox(width: 8),
              (currentLocationName.isEmpty)
                  ? locationSkeleton()
                  : Text("You're In $currentLocationName"),
            ],
          ),
          ToggleButtons(
            borderRadius: BorderRadius.circular(20.0),
            selectedColor: Colors.white,
            fillColor: Colors.black,
            color: Colors.black,
            children: const <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Text("Km"),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Text("Mile"),
              ),
            ],
            isSelected: [
              currentUnit == DistanceUnit.KM,
              currentUnit == DistanceUnit.Mile
            ],
            onPressed: (int index) {
              setState(() {
                if (index == 0) {
                  currentUnit = DistanceUnit.KM;
                } else {
                  currentUnit = DistanceUnit.Mile;
                }
              });
            },
          ),
        ],
      ),
    );
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
              _handleSearch(currentLocationName, _searchController.text);
            },
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Find Your Taste",
                border: InputBorder.none,
              ),
              onSubmitted: (value) {
                _handleSearch(currentLocationName, _searchController.text);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSearch(String location, String keyword) async {
    debugPrint('User searched for: $location in $keyword');
    try {
      List<Restaurants> results = await searchRestaurant(location, keyword);
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: SearchResultWidget(
            restaurants: results,
            userLat: _locationData?.latitude,
            userLon: _locationData?.longitude,
            currentUnit: DistanceUnit.KM,
            currentLocationName: currentLocationName,
            searchController: _searchController,
            onSearch: _handleSearch,
          ),
        ),
      );
    } catch (error) {
      print("Error fetching restaurants: $error");
    }
  }

  Widget locationSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 200.0,
        height: 20.0,
        color: Colors.white,
      ),
    );
  }

  Widget _buildShimmerSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 150.0,
                color: Colors.white,
              ),
              const SizedBox(height: 8.0),
              Container(
                width: double.infinity,
                height: 10.0,
                color: Colors.white,
              ),
              const SizedBox(height: 8.0),
              Container(
                width: double.infinity,
                height: 10.0,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geoCoding;
import 'package:location/location.dart';
import 'package:bestie_tastes/service/services.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidget();
}

class _HomeWidget extends State<HomeWidget> {
  Location location = Location();

  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _updateLocation() async {
    String areaName =
        await _getAreaName(_locationData?.latitude, _locationData?.longitude);
  }

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
      await _updateLocation(); // 위치를 가져온 후에 콜백을 호출
      setState(() {});
    } catch (e) {
      print('Error getting location: $e');
      _setUnionSquareLocation();
    }
  }

  void _setUnionSquareLocation() {
    _locationData = LocationData.fromMap({
      'latitude': 37.7879, // Union Square의 위도
      'longitude': -122.4074, // Union Square의 경도
    });
    setState(() {});
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

    print('User Lat: $lat1, User Lon: $lon1');
    print('Restaurant Lat: $lat2, Restaurant Lon: $lon2');

    /// @Return result by KM
    return R * c;
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
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: fetchRestaurants(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 4,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final restaurant = snapshot.data![index];

                double? userLat = _locationData?.latitude; // 사용자의 위도
                double? userLon = _locationData?.longitude; // 사용자의 경도

                double restaurantLat = restaurant['coordinates']['latitude'] ??
                    0; // Yelp API로부터 얻은 맛집의 위도
                double restaurantLon = restaurant['coordinates']['longitude'] ??
                    0; // Yelp API로부터 얻은 맛집의 경도

                print("User Location: $_locationData");
                print(
                    "Restaurant Location: ${restaurant['coordinates']['latitude']}, ${restaurant['coordinates']['longitude']}");
                print("reataurant Info: $restaurant");

                double distance = userLat != null && userLon != null
                    ? calculateDistance(
                        userLat, userLon, restaurantLat, restaurantLon)
                    : 0; // 사용자의 위치 정보가 제대로 얻어진 경우에만 거리 계산

                return Card(
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.network(restaurant['image_url']),
                      ),
                      SizedBox(height: 8.0),
                      Text(restaurant['name']),
                      Text(restaurant['categories'][0]['title']),
                      Text(distance.toStringAsFixed(2) + " km"),

                      // FutureBuilder를 사용하여 _getAreaName의 결과를 표시
                      /*FutureBuilder<String>(
                        future: _getAreaName(restaurantLat, restaurantLon),
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return Text('Area: ${snapshot.data}');
                          }
                        },
                      ),*/
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

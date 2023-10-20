import 'dart:convert';
import 'package:bestie_tastes/models/restaurant_details.dart';
import 'package:bestie_tastes/models/restaurants.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

String? YELP_API_KEY = dotenv.env['YELP_API_KEY'];

Future<List<Restaurants>> fetchRestaurants(String location) async {
  debugPrint("location $location");

  final encodedLocation = Uri.encodeFull(location);
  final response = await http.get(
    Uri.parse(
        'https://api.yelp.com/v3/businesses/search?location=$encodedLocation'),
    headers: {
      'Authorization': 'Bearer $YELP_API_KEY',
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> jsonData = json.decode(response.body)['businesses'];
    return jsonData.map((json) => Restaurants.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load restaurants');
  }
}

Future<List<Restaurants>> searchRestaurant(
    String location, String keyword) async {
  debugPrint("location $location");

  final encodedLocation = Uri.encodeFull(location);
  final response = await http.get(
    Uri.parse(
        'https://api.yelp.com/v3/businesses/search?term=$keyword&location=$encodedLocation'),
    headers: {
      'Authorization': 'Bearer $YELP_API_KEY',
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> jsonData = json.decode(response.body)['businesses'];
    for (var business in jsonData) {
      debugPrint(business['name']);
    }
    return jsonData.map((json) => Restaurants.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load restaurants');
  }
}

Future<RestaurantDetails> restaurantDetail(String restaurantId) async {
  final encodedRestaurantId = Uri.encodeFull(restaurantId);
  final response = await http.get(
    Uri.parse('https://api.yelp.com/v3/businesses/$encodedRestaurantId'),
    headers: {
      'Authorization': 'Bearer $YELP_API_KEY',
    },
  );

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonData = json.decode(response.body);
    debugPrint("jsonData: $jsonData");
    return RestaurantDetails.fromJson(jsonData);
  } else {
    throw Exception('Failed to load restaurant details');
  }
}
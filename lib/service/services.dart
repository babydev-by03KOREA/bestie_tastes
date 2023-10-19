import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

String? YELP_API_KEY = dotenv.env['YELP_API_KEY'];

Future<List<dynamic>> fetchRestaurants() async {
  final response = await http.get(
    Uri.parse('https://api.yelp.com/v3/businesses/search?location=san%20francisco'),
    headers: {
      'Authorization': 'Bearer $YELP_API_KEY',
    },
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    return jsonResponse['businesses'];
  } else {
    throw Exception('Failed to load restaurants');
  }
}

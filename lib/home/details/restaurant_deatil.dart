import 'package:bestie_tastes/models/restaurant_details.dart';
import 'package:bestie_tastes/service/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class RestaurantDeatilWidget extends StatefulWidget {
  final String restaurantId;

  const RestaurantDeatilWidget({super.key, required this.restaurantId});

  @override
  State<RestaurantDeatilWidget> createState() => _RestaurantDeatilWidgetState();
}

class _RestaurantDeatilWidgetState extends State<RestaurantDeatilWidget> {
  late Future<RestaurantDetails> restaurantDetails;

  @override
  void initState() {
    super.initState();
    restaurantDetails = restaurantDetail(widget.restaurantId);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: FutureBuilder<RestaurantDetails>(
          future: restaurantDetails,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final details = snapshot.data!;

            return ListView(
              children: [
                Text(details.name,
                    style:
                        const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Image.network(details.imageUrl),
                const SizedBox(height: 20),
                CarouselSlider(
                  options: CarouselOptions(height: 200.0),
                  items: details.photos.map((photoUrl) {
                    return Image.network(photoUrl, fit: BoxFit.cover);
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text("Address: ${details.address}"),
                Text("Rating: ${details.rating}"),
                Text("Reviews: ${details.reviewCount}"),
                Text("Price: ${details.price}"),
              ],
            );
          },
        ),
      ),
    );
  }
}

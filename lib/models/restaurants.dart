class Restaurants {
  /// [JSON] Request JSON
  /// {id: f-m7-hyFzkf0HSEeQ2s-9A, alias: fog-harbor-fish-house-san-francisco-2, name: Fog Harbor Fish House, image_url: https://s3-media2.fl.yelpcdn.com/bphoto/by8Hh63BLPv_HUqRUdsp_w/o.jpg, is_closed: false, url: https://www.yelp.com/biz/fog-harbor-fish-house-san-francisco-2?adjust_creative=MANxPGHXbRPRSpmxB9TXJQ&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=MANxPGHXbRPRSpmxB9TXJQ, review_count: 9824, categories: [{alias: seafood, title: Seafood}, {alias: wine_bars, title: Wine Bars}, {alias: cocktailbars, title: Cocktail Bars}], rating: 4.5, coordinates: {latitude: 37.80889, longitude: -122.41025}, transactions: [restaurant_reservation], price: $$, location: {address1: 39 Pier, address2: null, address3: , city: San Francisco, zip_code: 94133, country: US, state: CA, display_address: [39 Pier, San Francisco, CA 94133]}, phone: +14159692010, display_phone: (415) 969-2010, distance: 5804.678003375963}

  final String id;
  final String imageUrl;
  final String alias;
  final String name;
  final String categoryTitle;
  final double latitude;
  final double longitude;
  final String price;
  final double rating;
  bool isFavorited;

  Restaurants(
      {required this.id,
      required this.imageUrl,
      required this.alias,
      required this.name,
      required this.categoryTitle,
      required this.latitude,
      required this.longitude,
      required this.price,
      required this.rating,
      this.isFavorited = false});

  void toggleFavorite() {
    isFavorited = !isFavorited;
  }

  factory Restaurants.fromJson(Map<String, dynamic> json) {
    return Restaurants(
      id: json['id'],
      imageUrl: json['image_url'],
      alias: json['alias'],
      name: json['name'],
      categoryTitle: json['categories'][0]['title'],
      latitude: json['coordinates']['latitude'] ?? 0,
      longitude: json['coordinates']['longitude'] ?? 0,
      price: json['price'] ?? '',
      rating: json['rating'] ?? 0,
    );
  }
}

class RestaurantDetails {
  final String name;
  final String imageUrl;
  final List<String> photos;
  final String address;
  final double rating;
  final int reviewCount;
  final String price;

  RestaurantDetails({
    required this.name,
    required this.imageUrl,
    required this.photos,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.price,
  });

  factory RestaurantDetails.fromJson(Map<String, dynamic> jsonData) {
    return RestaurantDetails(
      name: jsonData['name'],
      imageUrl: jsonData['image_url'],
      photos: List<String>.from(jsonData['photos']),
      address: jsonData['location']['display_address'].join(", "),
      rating: jsonData['rating'].toDouble(),
      reviewCount: jsonData['review_count'],
      price: jsonData['price'],
    );
  }
}

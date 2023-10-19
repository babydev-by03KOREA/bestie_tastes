class Business {
  final String name;
  final String imageUrl;
  final String category;

  Business({required this.name, required this.imageUrl, required this.category});

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      name: json['name'],
      imageUrl: json['image_url'],
      category: json['categories'][0]['title'],
    );
  }
}
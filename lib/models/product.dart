class Product {
  final String id;
  final String title;
  final double price;
  final double originalPrice;
  final String description;
  final List<String> images;
  final String tag;
  final String sellerName;
  final String condition;
  final String material;
  final String co2Saved;
  final double rating;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.originalPrice,
    required this.description,
    required this.images,
    required this.tag,
    required this.sellerName,
    required this.condition,
    required this.material,
    required this.co2Saved,
    required this.rating,
  });

  // الميثود دي بتاخد الداتا من فايربيز وتحولها لـ Object
  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      title: data['title'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      originalPrice: (data['originalPrice'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      tag: data['tag'] ?? 'Sustainable',
      sellerName: data['sellerName'] ?? 'Unknown',
      condition: data['condition'] ?? '',
      material: data['material'] ?? '',
      co2Saved: data['co2Saved'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
    );
  }
}
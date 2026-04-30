class Seller {
  final String name;
  final double rating;
  final double distanceKm;
  final String location;
  final bool isVerified;
  final String avatarPath;

  const Seller({
    required this.name,
    required this.rating,
    required this.distanceKm,
    required this.location,
    required this.isVerified,
    required this.avatarPath,
  });
}

class Product {
  final String id;
  final String title;
  final String size;
  final double price;
  final String condition;
  final double originalRetailPrice;
  final bool isUpcycled;
  final bool isRecycled;
  final String description;
  final String material;
  final String repairHistory;
  final int co2SavedKg;
  final List<String> categoryTags;
  final List<String> images;
  final Seller seller;

  const Product({
    required this.id,
    required this.title,
    required this.size,
    required this.price,
    required this.condition,
    required this.originalRetailPrice,
    required this.isUpcycled,
    required this.isRecycled,
    required this.description,
    required this.material,
    required this.repairHistory,
    required this.co2SavedKg,
    required this.categoryTags,
    required this.images,
    required this.seller,
  });

  // Mock data representing the UI
  static Product getMockProduct() {
    return const Product(
      id: 'p123',
      title: "Vintage Upcycled Levi's Trucker Jacket",
      size: 'M',
      price: 78.0,
      condition: 'Good — Light Wear',
      originalRetailPrice: 160.0,
      isUpcycled: true,
      isRecycled: true,
      description: 'This vintage Levi\'s trucker jacket has been lovingly repaired and upcycled — original indigo denim with repaired elbows, reinforced internal seams, and a new recycled-cotton lining. Measurements: chest 44", length 24". Suitable for layering, unisex fit.',
      material: '100% Cotton\n(Reclaimed)',
      repairHistory: 'Elbow patches (2024),\nseam reinforcement\n(2023)',
      co2SavedKg: 12,
      categoryTags: ['Jackets', 'Denim'],
      images: [
        'assets/images/ProductDetails/thumbnails.png',
        'assets/images/ProductDetails/thumbnails2.png',
        'assets/images/ProductDetails/thumbnails3.png',
        'assets/images/ProductDetails/thumbnails4.png',
      ],
      seller: Seller(
        name: 'Amina Rahman',
        rating: 4.8,
        distanceKm: 2.3,
        location: 'Cairo',
        isVerified: true,
        avatarPath: 'assets/images/ProductDetails/seller avatar.png',
      ),
    );
  }
}

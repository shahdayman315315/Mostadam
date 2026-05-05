import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mostadam/screens/profile_screen.dart';
import 'package:mostadam/screens/add_listing_screen.dart';
import 'package:mostadam/screens/product_detail_screen.dart';
import 'package:mostadam/models/product.dart';
import 'package:mostadam/screens/settings_screen.dart';
import 'package:mostadam/screens/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Brand colors
  static const _green = Color(0xFF2D5016);
  static const _greenLight = Color(0xFFEAF5ED);
  static const _darkGreen = Color(0xFF287943);
  static const _creamBg = Color(0xFFFDFCF4);
  static const _beige = Color(0xFFFFF9F0);
  static const _pink = Color(0xFFFFF0F0);
  static const _yellow = Color(0xFFFFF9EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: _buildPage()),
      floatingActionButton: _selectedIndex == 0 ? _fab() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _bottomNav(),
    );
  }

  // Show the correct page based on selected tab
  Widget _buildPage() {
    switch (_selectedIndex) {
      case 1:
        return const SearchScreen();
      case 2:
        return const ProfileScreen();
      default:
        return _homePage();
    }
  }

  // ── FAB (Add Listing) ─────────────────────────────────────────────────────
  Widget _fab() => SizedBox(
    height: 60,
    width: 60,
    child: FloatingActionButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddListingScreen()),
      ),
      backgroundColor: const Color(0xFF88D49E),
      elevation: 0,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.black, size: 30),
    ),
  );

  // ── Bottom Navigation ─────────────────────────────────────────────────────
  Widget _bottomNav() => BottomNavigationBar(
    currentIndex: _selectedIndex,
    onTap: (i) => setState(() => _selectedIndex = i),
    type: BottomNavigationBarType.fixed,
    backgroundColor: Colors.white,
    selectedItemColor: Colors.black,
    unselectedItemColor: Colors.grey,
    showSelectedLabels: false,
    showUnselectedLabels: false,
    elevation: 10,
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_filled, size: 28),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.search, size: 28),
        label: 'Search',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person, size: 28),
        label: 'Profile',
      ),
    ],
  );

  // ── Full Home Page ────────────────────────────────────────────────────────
  Widget _homePage() => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _appBar(),
        const SizedBox(height: 16),
        _categories(),
        const SizedBox(height: 24),
        _heroBanner(),
        const SizedBox(height: 16),
        _filtersRow(),
        const SizedBox(height: 16),
        _quickActions(),
        const SizedBox(height: 24),
        _forYouSection(),
        const SizedBox(height: 80),
      ],
    ),
  );

  // ── App Bar ───────────────────────────────────────────────────────────────
  Widget _appBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      children: [
        Icon(Icons.eco, color: _darkGreen, size: 24),
        const SizedBox(width: 8),
        const Text(
          'Mostadam',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 16),
        // Tapping the search bar navigates to SearchScreen
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search pre-loved items...',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.settings, color: _darkGreen),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
        // Show logged-in user avatar or default icon
        StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (_, snap) {
            final user = snap.data;
            return CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE8F1EB),
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? const Icon(Icons.person, color: _darkGreen, size: 20)
                  : null,
            );
          },
        ),
      ],
    ),
  );

  // ── Category Chips ────────────────────────────────────────────────────────
  Widget _categories() {
    const cats = ['Furniture', 'Clothing', 'Electronics', 'Upcycled'];
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: cats.length,
        itemBuilder: (_, i) => GestureDetector(
          // Tapping a category navigates to search with that query
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          ),
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: _greenLight,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              cats[i],
              style: TextStyle(
                color: _darkGreen,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Hero Banner ───────────────────────────────────────────────────────────
  Widget _heroBanner() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seasonal\nRefresh:\nSpring Finds',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Discover lightly-loved\npieces refreshed for\nthe season with up to\n40% off.',
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/home_Image.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Pagination dots (static for banner)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dot(_darkGreen),
              _dot(Colors.grey.shade300),
              _dot(Colors.grey.shade300),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF88D49E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Explore',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _dot(Color c) => Container(
    width: 8,
    height: 8,
    margin: const EdgeInsets.symmetric(horizontal: 3),
    decoration: BoxDecoration(shape: BoxShape.circle, color: c),
  );

  // ── Filters Row ───────────────────────────────────────────────────────────
  Widget _filtersRow() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        const Text(
          'Berlin • Circular Box',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        _filterChip('Nearby', filled: true),
        const SizedBox(width: 8),
        _filterChip('Trending', filled: false),
      ],
    ),
  );

  Widget _filterChip(String label, {required bool filled}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: filled ? const Color(0xFFF5F5F5) : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      border: filled ? null : Border.all(color: Colors.grey.shade300),
    ),
    child: Text(
      label,
      style: const TextStyle(color: Colors.black54, fontSize: 13),
    ),
  );

  // ── Quick Action Cards ────────────────────────────────────────────────────
  Widget _quickActions() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        Expanded(
          child: _actionCard(
            'Sell an Item',
            _yellow,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddListingScreen()),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _actionCard(
            'List Dropoff',
            _greenLight,
            textColor: _darkGreen,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: _actionCard('Sell Locally', _pink, onTap: () {})),
      ],
    ),
  );

  Widget _actionCard(
    String title,
    Color bg, {
    Color? textColor,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 70,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    ),
  );

  // ── For You — Live Firestore Grid ─────────────────────────────────────────
  Widget _forYouSection() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'For you',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Handpicked items based on your activity',
          style: TextStyle(color: Colors.black54, fontSize: 13),
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting)
              return const Center(
                child: CircularProgressIndicator(color: _green),
              );
            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty)
              return const Center(child: Text('No products found yet.'));
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.65,
              ),
              itemBuilder: (_, i) {
                final d = docs[i].data() as Map<String, dynamic>;
                final product = Product(
                  id: docs[i].id,
                  title: d['title'] ?? 'No Title',
                  price: (d['price'] as num?)?.toDouble() ?? 0,
                  originalPrice: (d['originalPrice'] as num?)?.toDouble() ?? 0,
                  description: d['description'] ?? '',
                  // Support both 'images' array and legacy 'imageUrl' field
                  images: d['images'] != null
                      ? List<String>.from(d['images'])
                      : [d['imageUrl'] ?? ''],
                  tag: d['tag'] ?? 'Sustainable',
                  sellerName: d['seller'] ?? d['sellerName'] ?? 'Unknown',
                  condition: d['condition'] ?? '',
                  material: d['material'] ?? '',
                  co2Saved: d['co2Saved'] ?? '',
                  rating: (d['rating'] as num?)?.toDouble() ?? 0,
                );
                return _productCard(product);
              },
            );
          },
        ),
      ],
    ),
  );

  // ── Product Card ──────────────────────────────────────────────────────────
  Widget _productCard(Product product) {
    final img = product.images.isNotEmpty ? product.images[0] : null;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailPage(productId: product.id),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  color: Colors.grey.shade200,
                  image: img != null
                      ? DecorationImage(
                          image: NetworkImage(img),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: img == null
                    ? const Center(
                        child: Icon(Icons.image, color: Colors.white, size: 40),
                      )
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Color(0xFF88D49E),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _greenLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.tag,
                          style: TextStyle(
                            color: _darkGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'by ${product.sellerName}',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.star, color: Colors.orange, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

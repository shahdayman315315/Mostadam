import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mostadam/screens/cart_screen.dart';
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
  String? _selectedCategory;

  // ── Brand Colors ──────────────────────────────────────────────────────────
  static const _green = Color(0xFF2D5016);
  static const _greenLight = Color(0xFFEAF5ED);
  static const _darkGreen = Color(0xFF287943);
  static const _accentGreen = Color(0xFF88D49E);

  // ── Shared Categories (used across the app) ───────────────────────────────
  static const List<String> appCategories = [
    'Furniture',
    'Clothing',
    'Electronics',
    'Upcycled',
    'Books',
    'Sports',
  ];

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

  // ── Page Router ───────────────────────────────────────────────────────────
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
      onPressed: _goToAddListing,
      backgroundColor: _accentGreen,
      elevation: 0,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    ),
  );

  // ── Bottom Navigation ─────────────────────────────────────────────────────
  Widget _bottomNav() => BottomNavigationBar(
    currentIndex: _selectedIndex,
    onTap: (i) => setState(() => _selectedIndex = i),
    type: BottomNavigationBarType.fixed,
    backgroundColor: Colors.white,
    selectedItemColor: _darkGreen,
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

  // ── Full Home Page Layout ─────────────────────────────────────────────────
  Widget _homePage() => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _appBar(),
        const SizedBox(height: 16),
        _categoriesRow(),
        const SizedBox(height: 20),
        _heroBanner(),
        const SizedBox(height: 20),
        _sellItemBanner(),
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
        // Logo
        const Icon(Icons.eco, color: _darkGreen, size: 24),
        const SizedBox(width: 6),
        const Text(
          'Mostadam',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(width: 12),

        // Search bar — navigates to SearchScreen
        Expanded(
          child: GestureDetector(
            onTap: _goToSearch,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: const Text(
                'Search pre-loved items...',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),

        // Cart icon
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, size: 24),
          color: _darkGreen,
          onPressed: _goToCart,
          tooltip: 'Cart',
        ),

        // Settings icon
        IconButton(
          icon: const Icon(Icons.settings_outlined, size: 24),
          color: _darkGreen,
          onPressed: _goToSettings,
          tooltip: 'Settings',
        ),

        // User avatar — taps to profile tab
        StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (_, snap) {
            final user = snap.data;
            return GestureDetector(
              onTap: () => setState(() => _selectedIndex = 2),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: _greenLight,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? const Icon(Icons.person, color: _darkGreen, size: 20)
                    : null,
              ),
            );
          },
        ),
      ],
    ),
  );

  // ── Category Filter Row ───────────────────────────────────────────────────
  Widget _categoriesRow() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'Browse by Category',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: 38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: appCategories.length,
          itemBuilder: (_, i) {
            final cat = appCategories[i];
            final isSelected = _selectedCategory == cat;
            return GestureDetector(
              onTap: () => _onCategoryTap(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: isSelected ? _darkGreen : _greenLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected ? Colors.white : _darkGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );

  // ── Hero Banner ───────────────────────────────────────────────────────────
  Widget _heroBanner() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Spring\nFinds 🌿',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Lightly-loved pieces\nrefreshed for the season\nwith up to 40% off.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
          // Hero image with graceful fallback
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/home_Image.jpg',
              width: 130,
              height: 130,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 130,
                height: 130,
                color: _greenLight,
                child: const Icon(Icons.eco, color: _darkGreen, size: 48),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  // ── Sell Item Banner ──────────────────────────────────────────────────────
  Widget _sellItemBanner() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: GestureDetector(
      onTap: _goToAddListing,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9EB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFE0A0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD966),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.sell_outlined,
                color: Colors.black87,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Got something to sell?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'List your pre-loved item in minutes',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.black45,
            ),
          ],
        ),
      ),
    ),
  );

  // ── For You — Firestore Live Grid ─────────────────────────────────────────
  Widget _forYouSection() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with optional clear filter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'For You',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (_selectedCategory != null)
                  Text(
                    'Category: $_selectedCategory',
                    style: const TextStyle(color: _darkGreen, fontSize: 12),
                  ),
              ],
            ),
            if (_selectedCategory != null)
              TextButton(
                onPressed: () => setState(() => _selectedCategory = null),
                child: const Text('Clear', style: TextStyle(color: _darkGreen)),
              ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Handpicked sustainable items',
          style: TextStyle(color: Colors.black54, fontSize: 13),
        ),
        const SizedBox(height: 16),

        // Live Firestore stream
        StreamBuilder<QuerySnapshot>(
          stream: _buildProductsStream(),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: _green),
                ),
              );
            }
            if (snap.hasError) {
              return Center(
                child: Text(
                  'Error loading products. Please try again.',
                  style: TextStyle(color: Colors.red.shade400),
                  textAlign: TextAlign.center,
                ),
              );
            }
            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _selectedCategory != null
                            ? 'No products in "$_selectedCategory" yet.'
                            : 'No products found yet.',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
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
                try {
                  final d = docs[i].data() as Map<String, dynamic>;
                  final product = _parseProduct(docs[i].id, d);
                  return _productCard(product);
                } catch (_) {
                  return const SizedBox.shrink();
                }
              },
            );
          },
        ),
      ],
    ),
  );

  // ── Firestore Query (filtered by category if selected) ────────────────────
  Stream<QuerySnapshot> _buildProductsStream() {
    Query query = FirebaseFirestore.instance.collection('products');
    if (_selectedCategory != null) {
      query = query.where('tag', isEqualTo: _selectedCategory);
    }
    return query.snapshots();
  }

  // ── Parse Firestore document safely into Product model ────────────────────
  Product _parseProduct(String id, Map<String, dynamic> d) => Product(
    id: id,
    title: (d['title'] as String?) ?? 'No Title',
    price: (d['price'] as num?)?.toDouble() ?? 0.0,
    originalPrice: (d['originalPrice'] as num?)?.toDouble() ?? 0.0,
    description: (d['description'] as String?) ?? '',
    images: d['images'] != null
        ? List<String>.from(d['images'])
        : [(d['imageUrl'] as String?) ?? ''],
    tag: (d['tag'] as String?) ?? 'Sustainable',
    sellerName:
        (d['sellerName'] as String?) ?? (d['seller'] as String?) ?? 'Unknown',
    condition: (d['condition'] as String?) ?? '',
    material: (d['material'] as String?) ?? '',
    co2Saved: (d['co2Saved']?.toString()) ?? '',
    rating: (d['rating'] as num?)?.toDouble() ?? 0.0,
  );

  // ── Product Card ──────────────────────────────────────────────────────────
  Widget _productCard(Product product) {
    final imgUrl = product.images.isNotEmpty && product.images[0].isNotEmpty
        ? product.images[0]
        : null;
    return GestureDetector(
      onTap: () => _goToProductDetail(product.id),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: imgUrl != null
                  ? Image.network(
                      imgUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imagePlaceholder(),
                      loadingBuilder: (_, child, progress) =>
                          progress == null ? child : _imageLoading(),
                    )
                  : _imagePlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
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
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: _accentGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _greenLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          product.tag,
                          style: const TextStyle(
                            color: _darkGreen,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'by ${product.sellerName}',
                          style: const TextStyle(
                            color: Colors.black45,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.orange,
                        size: 13,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.black45,
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

  // ── Image Helpers ─────────────────────────────────────────────────────────
  Widget _imagePlaceholder() => Container(
    color: _greenLight,
    child: const Center(child: Icon(Icons.eco, color: _darkGreen, size: 36)),
  );

  Widget _imageLoading() => Container(
    color: Colors.grey.shade100,
    child: const Center(
      child: CircularProgressIndicator(strokeWidth: 2, color: _accentGreen),
    ),
  );

  // ── Navigation ────────────────────────────────────────────────────────────
  void _goToSearch({String? category}) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => SearchScreen()),
  );

  void _goToCart() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const CartScreen()),
  );

  void _goToSettings() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const SettingsScreen()),
  );

  void _goToAddListing() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const AddListingScreen()),
  );

  void _goToProductDetail(String productId) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => ProductDetailPage(productId: productId)),
  );

  void _onCategoryTap(String category) {
    setState(() {
      _selectedCategory = _selectedCategory == category ? null : category;
    });
  }
}

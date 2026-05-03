import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mostadam/models/product.dart';
import 'package:mostadam/screens/product_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  final Color darkGreen = const Color(0xFF287943);
  final Color lightGreenBg = const Color(0xFFEAF5ED);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.trim();
              });
            },
            decoration: const InputDecoration(
              hintText: "Search items, e.g., 'vintage'...",
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        leading: const BackButton(color: Colors.black),
      ),
      body: _searchQuery.isEmpty
          ? _buildInitialView() // لو لسه مفيش بحث
          : _buildSearchResults(), // لو فيه بحث شغال
    );
  }

  Widget _buildInitialView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "Search for sustainable items",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      // بنعمل سيرش في كوليكشن products بناءً على الـ title
      stream: FirebaseFirestore.instance
          .collection('products')
          .where('title', isGreaterThanOrEqualTo: _searchQuery)
          .where('title', isLessThanOrEqualTo: _searchQuery + '\uf8ff')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildNoResults();
        }

        final productsDocs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: productsDocs.length,
          itemBuilder: (context, index) {
            var data = productsDocs[index].data() as Map<String, dynamic>;
            final product = Product(
              id: productsDocs[index].id,
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

            return _buildResultCard(product);
          },
        );
      },
    );
  }

  Widget _buildResultCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.images[0],
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "\$${product.price}",
                    style: TextStyle(
                      color: darkGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    product.condition,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/no_results.png',
            height: 150,
            errorBuilder: (c, e, s) =>
                const Icon(Icons.search_off, size: 100, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          const Text(
            "No results found for that search",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: Text(
              "Try different keywords or broaden your category.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

// search_screen.dart — Mostadam | Fixed + Null-Safe
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mostadam/models/product.dart';
import 'package:mostadam/screens/product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';
  final _ctrl = TextEditingController();

  static const _green = Color(0xFF2D5016);
  static const _greenLight = Color(0xFFEAF5ED);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Safely build a Product from Firestore data ────────────────────────────
  Product? _toProduct(QueryDocumentSnapshot doc) {
    try {
      final d = doc.data() as Map<String, dynamic>;
      // images must have at least one entry, otherwise skip this doc
      final imgs = List<String>.from(d['images'] ?? []);
      if (imgs.isEmpty) {
        // Fallback: use single 'image' field if present
        final single = d['image'] as String?;
        if (single != null && single.isNotEmpty) imgs.add(single);
      }
      return Product(
        id: doc.id,
        title: d['title'] as String? ?? 'Untitled',
        price: (d['price'] as num?)?.toDouble() ?? 0.0,
        originalPrice: (d['originalPrice'] as num?)?.toDouble() ?? 0.0,
        description: d['description'] as String? ?? '',
        images: imgs,
        tag: d['tag'] as String? ?? 'Sustainable',
        sellerName: d['sellerName'] as String? ?? 'Unknown',
        condition: d['condition'] as String? ?? '',
        material: d['material'] as String? ?? '',
        co2Saved: d['co2Saved']?.toString() ?? '0',
        rating: (d['rating'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      debugPrint('Product parse error for ${doc.id}: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _ctrl,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: (v) => setState(() => _query = v.trim()),
            decoration: InputDecoration(
              hintText: "Search items, e.g., 'vintage'...",
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              // Clear button — only visible when there is text
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        _ctrl.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      body: _query.isEmpty ? _buildInitialView() : _buildResults(),
    );
  }

  // ── Initial empty state ───────────────────────────────────────────────────
  Widget _buildInitialView() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_outlined, size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        const Text(
          'Search for sustainable items',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    ),
  );

  // ── Live Firestore search results ─────────────────────────────────────────
  Widget _buildResults() {
    // Firestore prefix search on 'title' field (case-sensitive)
    final stream = FirebaseFirestore.instance
        .collection('products')
        .where('title', isGreaterThanOrEqualTo: _query)
        .where('title', isLessThanOrEqualTo: '$_query\uf8ff')
        .limit(30) // cap results to avoid large reads
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _green));
        }
        if (snap.hasError) {
          return _buildMessage(
            icon: Icons.error_outline,
            title: 'Something went wrong',
            subtitle: 'Please try again.',
          );
        }

        // Parse docs, skip any that can't be parsed (null-safe)
        final products = (snap.data?.docs ?? [])
            .map(_toProduct)
            .whereType<Product>()
            .toList();

        if (products.isEmpty) return _buildNoResults();

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: products.length,
          itemBuilder: (_, i) => _buildCard(products[i]),
        );
      },
    );
  }

  // ── Result card ───────────────────────────────────────────────────────────
  Widget _buildCard(Product p) {
    final hasImage = p.images.isNotEmpty;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailPage(productId: p.id)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Product image — safe fallback if URL is missing/broken
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: hasImage
                  ? Image.network(
                      p.images.first,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imgFallback(),
                    )
                  : _imgFallback(),
            ),
            const SizedBox(width: 14),

            // Text info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${p.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: _green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (p.condition.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      p.condition,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 4),
                  // Eco / category tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _greenLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      p.tag,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _green,
                      ),
                    ),
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

  // ── No results state ──────────────────────────────────────────────────────
  Widget _buildNoResults() => _buildMessage(
    icon: Icons.search_off_rounded,
    title: 'No results found',
    subtitle: 'Try different keywords or check your spelling.',
  );

  // ── Generic message widget ────────────────────────────────────────────────
  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String subtitle,
  }) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    ),
  );

  // ── Image fallback ────────────────────────────────────────────────────────
  Widget _imgFallback() => Container(
    width: 72,
    height: 72,
    color: _greenLight,
    child: const Icon(Icons.eco_outlined, color: _green, size: 28),
  );
}

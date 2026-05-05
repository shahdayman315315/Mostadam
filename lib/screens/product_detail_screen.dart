import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ── Colors ────────────────────────────────────────────────────────────────────
class AppColors {
  static const bg = Color(0xFFF7F5F0);
  static const green = Color(0xFF2D5016);
  static const greenLight = Color(0xFFE8F0DC);
  static const greenMid = Color(0xFF4A7C2F);
  static const amber = Color(0xFFE8A820);
  static const card = Color(0xFFFFFFFF);
  static const divider = Color(0xFFE0DDD6);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSec = Color(0xFF6B6B6B);
}

// ── Screen — receives a Firestore product document ID ─────────────────────────
class ProductDetailPage extends StatefulWidget {
  final String productId; // pass the Firestore doc ID from the listing grid
  const ProductDetailPage({super.key, required this.productId});
  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _imgIndex = 0;
  bool _descExpanded = false;
  bool _addingToCart = false;

  final _pageCtrl = PageController();

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  // ── Add to Cart ───────────────────────────────────────────────────────────
  Future<void> _addToCart(Map<String, dynamic> d) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _snack('Please login first.');
      return;
    }

    setState(() => _addingToCart = true);
    try {
      final db = FirebaseFirestore.instance;
      // Check for duplicates first
      final existing = await db
          .collection('cart')
          .where('userId', isEqualTo: user.uid)
          .where('productId', isEqualTo: widget.productId)
          .get();

      if (existing.docs.isNotEmpty) {
        await existing.docs.first.reference.update({
          'quantity': FieldValue.increment(1),
        });
        _snack('Quantity updated in cart 🛒');
      } else {
        final images = List<String>.from(d['images'] ?? []);
        await db.collection('cart').add({
          'userId': user.uid,
          'productId': widget.productId,
          'title': d['title'] ?? '',
          'price': d['price'] ?? 0,
          'image': images.isNotEmpty ? images[0] : '',
          'sellerName': d['sellerName'] ?? d['seller'] ?? 'Unknown',
          'quantity': 1,
          'addedAt': FieldValue.serverTimestamp(),
        });
        _snack('Added to cart! 🛒');
      }
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _addingToCart = false);
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      // Live stream of the product document from Firestore
      stream: FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting)
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.green),
            ),
          );

        if (!snap.hasData || !snap.data!.exists)
          return const Scaffold(
            body: Center(child: Text('Product not found.')),
          );

        final d = snap.data!.data() as Map<String, dynamic>;
        final images = List<String>.from(d['images'] ?? []);
        final title = d['title'] ?? '';
        final price = (d['price'] as num?)?.toDouble() ?? 0;
        final origP = (d['originalPrice'] as num?)?.toDouble() ?? 0;
        final cond = d['condition'] ?? '';
        final desc = d['description'] ?? '';
        final mat = d['material'] ?? '';
        final repair = d['repairHistory'] ?? '';
        final co2 = (d['co2Saved'] as num?)?.toDouble() ?? 0;
        final seller = d['sellerName'] ?? d['seller'] ?? 'Unknown';
        final rating = (d['rating'] as num?)?.toDouble() ?? 0;
        final tag = d['tag'] ?? 'Sustainable';

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  _appBar(),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _carousel(images),
                        _thumbs(images),
                        const SizedBox(height: 16),
                        _titleSection(title, price, origP, cond, tag),
                        const SizedBox(height: 12),
                        _sellerCard(seller, rating),
                        const SizedBox(height: 12),
                        _description(desc),
                        const SizedBox(height: 12),
                        _detailCards(mat, repair),
                        const SizedBox(height: 12),
                        _co2Badge(co2),
                        const SizedBox(height: 12),
                        _trustBadges(),
                        const SizedBox(height: 12),
                        _negotiateBox(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
              _bottomBar(d),
            ],
          ),
        );
      },
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────
  SliverAppBar _appBar() => SliverAppBar(
    backgroundColor: AppColors.bg,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    pinned: true,
    leading: Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.share_outlined,
              size: 18,
              color: AppColors.textPrimary,
            ),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ),
      ),
    ],
  );

  // ── Image Carousel ────────────────────────────────────────────────────────
  Widget _carousel(List<String> images) {
    if (images.isEmpty)
      return Container(
        height: 300,
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
        ),
      );

    return SizedBox(
      height: 300,
      child: PageView.builder(
        controller: _pageCtrl,
        itemCount: images.length,
        onPageChanged: (i) => setState(() => _imgIndex = i),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => _showFullImage(images, i),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFDDD9D0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    images[i],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF8FA6C2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 48,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ),
                ),
                // Upcycled tag
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.greenMid,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.autorenew_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Upcycled',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Counter
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_imgIndex + 1}/${images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Zoom hint
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.zoom_in_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Tap to zoom',
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFullImage(List<String> images, int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: Center(
                child: Image.network(
                  images[index],
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image_outlined,
                    size: 80,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Thumbnails ────────────────────────────────────────────────────────────
  Widget _thumbs(List<String> images) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(
      children: List.generate(images.length, (i) {
        final active = i == _imgIndex;
        return GestureDetector(
          onTap: () {
            _pageCtrl.animateToPage(
              i,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            setState(() => _imgIndex = i);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 52,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: active ? AppColors.green : Colors.transparent,
                width: 2.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                images[i],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF8FA6C2),
                  child: const Icon(
                    Icons.checkroom_rounded,
                    size: 20,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    ),
  );

  // ── Title Section ─────────────────────────────────────────────────────────
  Widget _titleSection(
    String title,
    double price,
    double orig,
    String cond,
    String tag,
  ) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '\$${price.toInt()}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Original \$${orig.toInt()}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSec,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.greenLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.greenMid.withOpacity(0.3)),
              ),
              child: Text(
                cond,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.greenMid,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.autorenew_rounded,
              size: 14,
              color: AppColors.greenMid,
            ),
            const SizedBox(width: 4),
            Text(
              tag,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.greenMid,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  // ── Seller Card (no Message button — feature removed) ─────────────────────
  Widget _sellerCard(String seller, double rating) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.amber.withOpacity(0.3),
          child: Text(
            seller.isNotEmpty ? seller[0].toUpperCase() : 'S',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    seller,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.verified_rounded,
                    size: 14,
                    color: AppColors.greenMid,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: AppColors.amber,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.location_on_outlined,
                    size: 13,
                    color: AppColors.textSec,
                  ),
                  const SizedBox(width: 3),
                  const Text(
                    '2.3 km',
                    style: TextStyle(fontSize: 12, color: AppColors.textSec),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Follow only — Message button removed
        GestureDetector(
          onTap: () {
            /* TODO: follow seller */
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.green, width: 1.5),
            ),
            child: const Text(
              'Follow',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.green,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  // ── Description ───────────────────────────────────────────────────────────
  Widget _description(String desc) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: _descExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: Text(
            desc,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSec,
              height: 1.6,
            ),
          ),
          secondChild: Text(
            desc,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSec,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() => _descExpanded = !_descExpanded),
          child: Text(
            _descExpanded ? 'Show less' : 'Read more',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.green,
            ),
          ),
        ),
      ],
    ),
  );

  // ── Detail Cards ──────────────────────────────────────────────────────────
  Widget _detailCards(String mat, String repair) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        Expanded(
          child: _detailCard(
            AppColors.greenLight,
            'Material',
            mat,
            Icons.recycling_rounded,
            AppColors.greenMid,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _detailCard(
            const Color(0xFFFFF8E6),
            'Repair History',
            repair,
            Icons.build_circle_outlined,
            AppColors.amber,
          ),
        ),
      ],
    ),
  );

  Widget _detailCard(
    Color bg,
    String title,
    String val,
    IconData icon,
    Color iconColor,
  ) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: iconColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          val.isEmpty ? '—' : val,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ],
    ),
  );

  // ── CO2 Badge ─────────────────────────────────────────────────────────────
  Widget _co2Badge(double co2) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF3A6B20), AppColors.green],
      ),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        const Icon(Icons.eco_rounded, color: Colors.white, size: 28),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '~${co2.toInt()} kg CO₂ saved',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'compared to buying new',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ],
    ),
  );

  // ── Trust Badges ──────────────────────────────────────────────────────────
  Widget _trustBadges() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _trustBadge(
          Icons.lock_outline_rounded,
          'Secure\nCheckout',
          'Encrypted',
        ),
        _trustBadge(Icons.replay_rounded, '14-day\nReturns', 'Money back'),
        _trustBadge(
          Icons.verified_user_outlined,
          'Verified\nSeller',
          'ID verified',
        ),
      ],
    ),
  );

  Widget _trustBadge(IconData icon, String title, String sub) => Column(
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.greenLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 22, color: AppColors.greenMid),
      ),
      const SizedBox(height: 6),
      Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.3,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        sub,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.textSec,
          height: 1.3,
        ),
      ),
    ],
  );

  // ── Negotiate Box ─────────────────────────────────────────────────────────
  Widget _negotiateBox() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.divider),
    ),
    child: Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Want to negotiate?',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Send an offer to negotiate price.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSec,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {
            /* TODO: offer flow */
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text(
            'Negotiate',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
      ],
    ),
  );

  // ── Bottom Bar ────────────────────────────────────────────────────────────
  Widget _bottomBar(Map<String, dynamic> d) => Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.bg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _addingToCart ? null : () => _addToCart(d),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.green,
                    side: const BorderSide(color: AppColors.green, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _addingToCart
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: AppColors.green,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Add to Cart',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    /* TODO: buy now — navigate to checkout */
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Buy Now',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 12,
                color: AppColors.textSec,
              ),
              SizedBox(width: 4),
              Text(
                'Secure payment',
                style: TextStyle(fontSize: 11, color: AppColors.textSec),
              ),
              SizedBox(width: 12),
              Text(
                'Price includes local taxes',
                style: TextStyle(fontSize: 11, color: AppColors.textSec),
              ),
              SizedBox(width: 12),
              Text(
                'Make Offer',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

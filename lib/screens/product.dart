import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Upcycled Market',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D5016),
          brightness: Brightness.light,
        ),
        fontFamily: 'Georgia',
        useMaterial3: true,
      ),
      home: const ProductDetailPage(),
    );
  }
}

// ─────────────────────────────────────────────
//  DATA MODEL
// ─────────────────────────────────────────────
class ProductModel {
  final String title;
  final double price;
  final double originalPrice;
  final String condition;
  final String conditionDetail;
  final String description;
  final String material;
  final String repairHistory;
  final double co2Saved;
  final double sellerRating;
  final int sellerSales;
  final double sellerDistance;
  final String sellerName;
  final bool isVerified;

  const ProductModel({
    required this.title,
    required this.price,
    required this.originalPrice,
    required this.condition,
    required this.conditionDetail,
    required this.description,
    required this.material,
    required this.repairHistory,
    required this.co2Saved,
    required this.sellerRating,
    required this.sellerSales,
    required this.sellerDistance,
    required this.sellerName,
    required this.isVerified,
  });
}

const kProduct = ProductModel(
  title: "Vintage Upcycled Levi's Trucker Jacket — Size M",
  price: 78,
  originalPrice: 160,
  condition: 'Good',
  conditionDetail: 'Light Wear',
  description:
      'This vintage Levi\'s trucker jacket has been lovingly repaired and upcycled — original indigo denim with repaired elbows, reinforced internal seams, and a recycled-cotton lining. Measurements: chest 44", length 24". Suitable for layering, unisex fit.',
  material: '100% Cotton (Reclaimed)',
  repairHistory: 'Elbow patches (2024), seam reinforcement (2023)',
  co2Saved: 12,
  sellerRating: 4.8,
  sellerSales: 120,
  sellerDistance: 2.3,
  sellerName: 'Amina Rahman',
  isVerified: true,
);

// ─────────────────────────────────────────────
//  COLOURS
// ─────────────────────────────────────────────
class AppColors {
  static const bg = Color(0xFFF7F5F0);
  static const green = Color(0xFF2D5016);
  static const greenLight = Color(0xFFE8F0DC);
  static const greenMid = Color(0xFF4A7C2F);
  static const amber = Color(0xFFE8A820);
  static const recycled = Color(0xFF5A8A3C);
  static const card = Color(0xFFFFFFFF);
  static const divider = Color(0xFFE0DDD6);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B6B6B);
  static const upcycledTag = Color(0xFF4A7C2F);
}

// ─────────────────────────────────────────────
//  الصور — حط مساراتهم هنا
//  في pubspec.yaml أضف:
//    flutter:
//      assets:
//        - assets/images/jacket_1.jpg
//        - assets/images/jacket_2.jpg
//        - assets/images/jacket_3.jpg
//        - assets/images/jacket_4.jpg
// ─────────────────────────────────────────────
const List<String> kProductImages = [
  'assets/images/jacket.png',
  'assets/images/jean.jpg',
  'assets/images/milk.jpg',
];

// ─────────────────────────────────────────────
//  MAIN PAGE
// ─────────────────────────────────────────────
class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _currentImage = 0;
  bool _descExpanded = false;

  // Controller عشان نتحكم في الـ PageView من الـ thumbnails
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageCarousel(),
                    _buildThumbnails(),
                    const SizedBox(height: 16),
                    _buildTitleSection(),
                    const SizedBox(height: 12),
                    _buildSellerSection(),
                    const SizedBox(height: 12),
                    _buildDescriptionSection(),
                    const SizedBox(height: 12),
                    _buildDetailsGrid(),
                    const SizedBox(height: 12),
                    _buildCO2Badge(),
                    const SizedBox(height: 12),
                    _buildTrustBadges(),
                    const SizedBox(height: 12),
                    _buildNegotiateSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ── App Bar ──────────────────────────────────
  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () {},
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
  }

  // ── Image Carousel ───────────────────────────
  Widget _buildImageCarousel() {
    return SizedBox(
      height: 300,
      child: PageView.builder(
        controller: _pageController,
        itemCount: kProductImages.length,
        onPageChanged: (i) => setState(() => _currentImage = i),
        itemBuilder: (_, i) {
          return GestureDetector(
            // تكبير الصورة عند الضغط
            onTap: () => _showFullImage(i),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFDDD9D0), // fallback لو الصورة بطيئة
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // ── الصورة الفعلية ──
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      kProductImages[i],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      // لو الصورة مش موجودة بيبان placeholder بدلها
                      errorBuilder: (_, __, ___) => Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF8FA6C2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.image_not_supported_outlined,
                                size: 48,
                                color: Colors.white.withOpacity(0.6),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                kProductImages[i],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Upcycled tag ──
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.upcycledTag,
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
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Image counter ──
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
                        '${_currentImage + 1}/${kProductImages.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // ── Tap to zoom hint ──
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
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Full screen image viewer ─────────────────
  void _showFullImage(int index) {
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
              maxScale: 4.0,
              child: Center(
                child: Image.asset(
                  kProductImages[index],
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

  // ── Thumbnails ───────────────────────────────
  Widget _buildThumbnails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: List.generate(kProductImages.length, (i) {
          final active = i == _currentImage;
          return GestureDetector(
            onTap: () {
              // الضغط على الـ thumbnail يحرك الـ PageView
              _pageController.animateToPage(
                i,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              setState(() => _currentImage = i);
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
                child: Image.asset(
                  kProductImages[i],
                  fit: BoxFit.cover,
                  // fallback لو الصورة مش موجودة
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF8FA6C2),
                    child: Icon(
                      Icons.checkroom_rounded,
                      size: 20,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Title Section ────────────────────────────
  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kProduct.title,
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
                '\$${kProduct.price.toInt()}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Original retail \$${kProduct.originalPrice.toInt()}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const Spacer(),
              _conditionBadge(),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.autorenew_rounded,
                size: 14,
                color: AppColors.recycled,
              ),
              const SizedBox(width: 4),
              Text(
                'Recycled',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.recycled,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _conditionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.greenMid.withOpacity(0.3)),
      ),
      child: Text(
        '${kProduct.condition} · ${kProduct.conditionDetail}',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.greenMid,
        ),
      ),
    );
  }

  // ── Seller Section ───────────────────────────
  Widget _buildSellerSection() {
    return Container(
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
            child: const Text(
              'A',
              style: TextStyle(
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
                Text(
                  kProduct.sellerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
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
                      '${kProduct.sellerRating}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.shopping_bag_outlined,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${kProduct.sellerSales}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${kProduct.sellerDistance} km',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (kProduct.isVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.verified_rounded,
                        size: 14,
                        color: AppColors.greenMid,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              _sellerBtn(label: 'Follow', outlined: true, onTap: () {}),
              const SizedBox(width: 8),
              _sellerBtn(label: 'Message', outlined: false, onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sellerBtn({
    required String label,
    required bool outlined,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : AppColors.green,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: outlined ? AppColors.green : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: outlined ? AppColors.green : Colors.white,
          ),
        ),
      ),
    );
  }

  // ── Description ──────────────────────────────
  Widget _buildDescriptionSection() {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${kProduct.description.length * 4} characters',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedCrossFade(
            firstChild: Text(
              kProduct.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            secondChild: Text(
              kProduct.description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            crossFadeState: _descExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
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
  }

  // ── Details Grid ─────────────────────────────
  Widget _buildDetailsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _detailCard(
              color: AppColors.greenLight,
              title: 'Material',
              value: kProduct.material,
              icon: Icons.recycling_rounded,
              iconColor: AppColors.greenMid,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _detailCard(
              color: const Color(0xFFFFF8E6),
              title: 'Repair History',
              value: kProduct.repairHistory,
              icon: Icons.build_circle_outlined,
              iconColor: AppColors.amber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailCard({
    required Color color,
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
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
            value,
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
  }

  // ── CO2 Badge ────────────────────────────────
  Widget _buildCO2Badge() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3A6B20), Color(0xFF2D5016)],
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
                '~${kProduct.co2Saved.toInt()} kg CO₂ saved',
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
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Text(
                  'vs',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
                SizedBox(width: 4),
                Text(
                  'Jackets  Denim',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Trust Badges ─────────────────────────────
  Widget _buildTrustBadges() {
    return Container(
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
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _TrustBadge(
            icon: Icons.lock_outline_rounded,
            title: 'Secure\nCheckout',
            subtitle: 'Encrypted\npayment',
          ),
          _TrustBadge(
            icon: Icons.replay_rounded,
            title: '14-day\nReturns',
            subtitle: 'or money\nback',
          ),
          _TrustBadge(
            icon: Icons.verified_user_outlined,
            title: 'Verified\nSeller',
            subtitle: 'ID verified',
          ),
        ],
      ),
    );
  }

  // ── Negotiate Section ────────────────────────
  Widget _buildNegotiateSection() {
    return Container(
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
                  'Send an offer or start a chat to negotiate price and delivery.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              elevation: 0,
            ),
            child: const Text(
              'Negotiate',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Bar ───────────────────────────────
  Widget _buildBottomBar() {
    return Positioned(
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
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.green,
                      side: const BorderSide(
                        color: AppColors.green,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
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
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Buy Now',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
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
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 4),
                Text(
                  'Secure payment',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Price includes local taxes',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
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
}

// ─────────────────────────────────────────────
//  TRUST BADGE WIDGET
// ─────────────────────────────────────────────
class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TrustBadge({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

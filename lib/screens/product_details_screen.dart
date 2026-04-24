import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/product.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final Color creamBg = const Color(0xFFFDFCF4);
  final Color mostadamGreen = const Color(0xFF287943);
  final Color mostadamYellow = const Color(0xFFFCF6CE);
  final Color darkGreen = const Color(0xFF287943);
  final Color lightGreenBg = const Color(0xFFEAF5ED);
  final Color greyPillBg = const Color(0xFFF3F3F3);
  final Color beigeBg = const Color(0xFFF6EFE2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildThumbnailsStrip(),
                      const SizedBox(height: 16),
                      _buildProductHeader(),
                      const SizedBox(height: 24),
                      _buildSellerCard(),
                      const SizedBox(height: 24),
                      _buildDescriptionSection(),
                      const SizedBox(height: 24),
                      _buildTrustBadges(),
                      const SizedBox(height: 24),
                      _buildNegotiationCard(),
                      const SizedBox(height: 140), // Spacer for bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomActionBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 450.0,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leadingWidth: 80,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            const Text('Back', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.black),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              widget.product.images[0],
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
            Positioned(
              top: 100,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('1/5', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
              ),
            ),
            Positioned(
              top: 100,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: lightGreenBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset('assets/images/ProductDetails/leaf.svg', height: 16, width: 16),
                    const SizedBox(width: 4),
                    Text('Upcycled', style: TextStyle(color: darkGreen, fontWeight: FontWeight.w500, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailsStrip() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildThumbnail(widget.product.images[0], isSelected: true),
            const SizedBox(width: 8),
            _buildThumbnail(widget.product.images[1]),
            const SizedBox(width: 8),
            _buildThumbnail(widget.product.images[2]),
          ],
        ),
        const Text(
          "Tap image to zoom",
          style: TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildThumbnail(String path, {bool isSelected = false}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
        image: DecorationImage(
          image: AssetImage(path),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProductHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${widget.product.title} — Size ${widget.product.size}",
          style: const TextStyle(
            fontSize: 22,
            fontFamily: 'serif',
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "\$${widget.product.price.toInt()}",
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: greyPillBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.product.condition,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Original retail \$${widget.product.originalRetailPrice.toInt()}",
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: lightGreenBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  SvgPicture.asset('assets/images/ProductDetails/Recycled.svg', height: 14, width: 14),
                  const SizedBox(width: 4),
                  Text('Recycled', style: TextStyle(color: darkGreen, fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSellerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: AssetImage(widget.product.seller.avatarPath),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.seller.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text("${widget.product.seller.rating}", style: const TextStyle(fontSize: 13, color: Colors.black87)),
                        const Text(" • ", style: TextStyle(color: Colors.black54)),
                        const Icon(Icons.location_on, color: Colors.black54, size: 14),
                        Text(" ${widget.product.seller.distanceKm} km", style: const TextStyle(fontSize: 13, color: Colors.black54)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        SvgPicture.asset('assets/images/ProductDetails/verified seller.svg', height: 14, width: 14),
                        const SizedBox(width: 4),
                        const Text("Verified Seller", style: TextStyle(fontSize: 13, color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      side: BorderSide(color: darkGreen),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      minimumSize: const Size(80, 36),
                    ),
                    child: Text('Follow', style: TextStyle(color: darkGreen, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkGreen,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      minimumSize: const Size(80, 36),
                    ),
                    child: const Text('Message', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Description", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("${widget.product.description.length} characters", style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.product.description,
            style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {},
            child: Text("Read more", style: TextStyle(color: darkGreen, fontWeight: FontWeight.w500, fontSize: 14)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: mostadamYellow, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Material", style: TextStyle(fontSize: 12, color: Colors.black54)),
                      const SizedBox(height: 4),
                      Text(widget.product.material, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: lightGreenBg, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Repair History", style: TextStyle(fontSize: 12, color: Colors.black54)),
                      const SizedBox(height: 4),
                      Text(widget.product.repairHistory, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: lightGreenBg, borderRadius: BorderRadius.circular(4)),
                child: Row(
                  children: [
                    SvgPicture.asset('assets/images/ProductDetails/leaf.svg', height: 14, width: 14, colorFilter: ColorFilter.mode(darkGreen, BlendMode.srcIn)),
                    const SizedBox(width: 4),
                    Text("-${widget.product.co2SavedKg} kg CO2 saved", style: TextStyle(color: darkGreen, fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text("compared to\nnew", style: TextStyle(fontSize: 11, color: Colors.black54, height: 1.2)),
              const Spacer(),
              _buildTag(widget.product.categoryTags[0]),
              const SizedBox(width: 6),
              _buildTag(widget.product.categoryTags[1]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: greyPillBg, borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: const TextStyle(fontSize: 13)),
    );
  }

  Widget _buildTrustBadges() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTrustItem('assets/images/ProductDetails/secure checkout.svg', 'Secure\nCheckout', 'Encrypted\npayment'),
          _buildTrustItem('assets/images/ProductDetails/Returns.svg', '14-day\nReturns', 'or money back'),
          _buildTrustItem('assets/images/ProductDetails/verified seller.svg', 'Verified\nSeller', 'ID verified'),
        ],
      ),
    );
  }

  Widget _buildTrustItem(String iconPath, String title, String subtitle) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(iconPath, height: 20, width: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.2)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.black54, height: 1.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNegotiationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Want to negotiate?", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text(
                  "Send an offer or start a chat to negotiate price and delivery.",
                  style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: beigeBg,
                  elevation: 0,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(100, 36),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text('Make Offer', style: TextStyle(fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkGreen,
                  elevation: 0,
                  minimumSize: const Size(100, 36),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text('Negotiate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkGreen,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Add to Cart", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: beigeBg,
                    elevation: 0,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Buy Now", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 12, color: Colors.black54),
              const SizedBox(width: 4),
              const Text("Secure payment", style: TextStyle(fontSize: 11, color: Colors.black54)),
              const SizedBox(width: 12),
              const Text("Price includes local taxes", style: TextStyle(fontSize: 11, color: Colors.black54)),
              const SizedBox(width: 12),
              Text("Make Offer", style: TextStyle(fontSize: 11, color: darkGreen, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

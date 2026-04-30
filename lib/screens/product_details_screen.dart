import 'package:flutter/material.dart';
import 'package:mostadam/models/product.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  // Colors
  final Color mostadamGreen = const Color(0xFF88D49E);
  final Color darkGreen = const Color(0xFF287943);
  final Color lightGreenBg = const Color(0xFFEAF5ED);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text("Back", style: TextStyle(color: Colors.black, fontSize: 16)),
        titleSpacing: 0,
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_horiz, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Main Image Slider (with index update)
                _buildMainSlider(),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. Clickable Thumbnails Row
                      _buildThumbnailsRow(),
                      const SizedBox(height: 20),

                      // 3. Product Title & Tags
                      Text(
                        widget.product.title,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildPriceSection(),
                      const SizedBox(height: 20),

                      // 4. Seller Card
                      _buildSellerCard(),
                      const SizedBox(height: 20),

                      // 5. Description
                      _buildDescriptionSection(),
                      const SizedBox(height: 20),

                      // 6. Material & Repair Cards
                      Row(
                        children: [
                          _buildDetailCard("Material", widget.product.material, const Color(0xFFFFF9EB)),
                          const SizedBox(width: 12),
                          _buildDetailCard("Repair History", "Elbow patches (2024), seam reinforcement", const Color(0xFFEAF5ED)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 7. Carbon Impact
                      _buildCarbonImpact(),
                      const SizedBox(height: 20),

                      // 8. Trust Badges
                      _buildTrustBadges(),
                      const SizedBox(height: 20),

                      // 9. Negotiation Box
                      _buildNegotiationBox(),
                      
                      const SizedBox(height: 120), // Space for bottom buttons
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 10. Fixed Bottom Action Buttons
          _buildBottomPersistentButtons(),
        ],
      ),
    );
  }

  Widget _buildMainSlider() {
    return Stack(
      children: [
        SizedBox(
          height: 350,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: widget.product.images.length,
            itemBuilder: (context, index) {
              return Image.network(
                widget.product.images[index], 
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade200),
              );
            },
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(8)),
            child: Text(
              "${_currentImageIndex + 1}/${widget.product.images.length}", 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: lightGreenBg, borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                Icon(Icons.eco, color: darkGreen, size: 16),
                const SizedBox(width: 4),
                Text(widget.product.tag, style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnailsRow() {
    return Row(
      children: [
        ...List.generate(
          widget.product.images.length,
          (index) => GestureDetector(
            onTap: () {
              // يحرك السلايدر للصورة المختارة بنعومة
              _pageController.animateToPage(
                index, 
                duration: const Duration(milliseconds: 300), 
                curve: Curves.easeInOut
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _currentImageIndex == index ? darkGreen : Colors.grey.shade300, 
                  width: 2
                ),
                image: DecorationImage(
                  image: NetworkImage(widget.product.images[index]), 
                  fit: BoxFit.cover
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
        const Text("Tap image to zoom", style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("\$${widget.product.price}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: Text(widget.product.condition, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        Text("Original retail \$${widget.product.originalPrice}", style: const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough, fontSize: 14)),
      ],
    );
  }

  Widget _buildSellerCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const CircleAvatar(radius: 25, backgroundImage: NetworkImage("https://via.placeholder.com/150")),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.product.sellerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Text("Cairo • 2.3 km", style: TextStyle(color: Colors.grey, fontSize: 12)),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 14),
                    Text(" ${widget.product.rating}", style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 8),
                    Icon(Icons.check_circle, color: darkGreen, size: 14),
                    const Text(" Verified Seller", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          OutlinedButton(onPressed: () {}, child: const Text("Follow")),
          const SizedBox(width: 4),
          ElevatedButton(
            onPressed: () {}, 
            style: ElevatedButton.styleFrom(
              backgroundColor: darkGreen,
              foregroundColor: Colors.white, // نص الزر أبيض
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ), 
            child: const Text("Message")
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("2,140 characters", style: TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 8),
        Text(widget.product.description, style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5)),
        TextButton(
          onPressed: () {}, 
          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 30), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          child: Text("Read more", style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold))
        ),
      ],
    );
  }

  Widget _buildDetailCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 11, color: Colors.black54)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildCarbonImpact() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(Icons.eco_outlined, color: darkGreen, size: 22),
          const SizedBox(width: 8),
          Text("~${widget.product.co2Saved} CO2 saved", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const Spacer(),
          const Text("compared to new", style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTrustBadges() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: Colors.grey.shade100))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _badgeItem(Icons.security, "Secure\nCheckout"),
          _badgeItem(Icons.replay, "14-day\nReturns"),
          _badgeItem(Icons.verified_user, "Verified\nSeller"),
        ],
      ),
    );
  }

  Widget _badgeItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: darkGreen),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildNegotiationBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade100), 
        borderRadius: BorderRadius.circular(16)
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Want to negotiate?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text("Send an offer or chat", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFFFF9EB), borderRadius: BorderRadius.circular(8)),
                child: const Text("Make Offer", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: darkGreen, 
                foregroundColor: Colors.white, // النص أبيض
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              child: const Text("Negotiate", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPersistentButtons() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkGreen, 
                    foregroundColor: Colors.white, // النص أبيض
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  child: const Text("Add to Cart", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2F1EC), 
                    foregroundColor: Colors.black, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  child: const Text("Buy Now", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:mostadam/screens/product_details_screen.dart';
import 'package:mostadam/models/product.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final Color creamBg = const Color(0xFFFDFCF4);
  final Color mostadamGreen = const Color(0xFF88D49E); // Lighter green for buttons as in design
  final Color darkGreen = const Color(0xFF287943); // Dark text green
  final Color lightGreenBg = const Color(0xFFEAF5ED);
  final Color beigeBg = const Color(0xFFFFF9F0);
  final Color pinkishBg = const Color(0xFFFFF0F0);
  final Color lightYellowBg = const Color(0xFFFFF9EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(),
              const SizedBox(height: 16),
              _buildCategories(),
              const SizedBox(height: 24),
              _buildHeroBanner(),
              const SizedBox(height: 16),
              _buildFiltersRow(),
              const SizedBox(height: 16),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildForYouSection(context),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        height: 60,
        width: 60,
        margin: const EdgeInsets.only(top: 30),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: mostadamGreen,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.black, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled, size: 28), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search, size: 28), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded, size: 28), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.person, size: 28), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.eco, color: darkGreen, size: 24),
          const SizedBox(width: 8),
          const Text("Mostadam", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search pre-loved & u",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFE8F1EB),
            child: Icon(Icons.person, color: Color(0xFF287943), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = ['Furniture', 'Clothing', 'Electronics', 'Upcycled'];
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: lightGreenBg,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              categories[index],
              style: TextStyle(color: darkGreen, fontWeight: FontWeight.w500, fontSize: 14),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Seasonal\nRefresh:\nSpring Finds",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Discover lightly-loved\npieces refreshed for\nthe season with up to\n40% off.",
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade300,
                  ),
                  child: const Center(
                    child: Icon(Icons.image, size: 50, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: darkGreen)),
                const SizedBox(width: 6),
                Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade300)),
                const SizedBox(width: 6),
                Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade300)),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: mostadamGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text("Explore", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const Text("Berlin • Circular Box", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text("Nearby", style: TextStyle(color: Colors.black54, fontSize: 13)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text("Trending", style: TextStyle(color: Colors.black54, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(child: _buildActionCard("Sell an Item", lightYellowBg)),
          const SizedBox(width: 8),
          Expanded(child: _buildActionCard("List Dropoff", lightGreenBg, textColor: darkGreen)),
          const SizedBox(width: 8),
          Expanded(child: _buildActionCard("Sell Locally", pinkishBg)),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, Color bgColor, {Color? textColor}) {
    return Container(
      height: 70,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor,
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
    );
  }

  Widget _buildForYouSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("For you", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text("Handpicked items based on your activity", style: TextStyle(color: Colors.black54, fontSize: 13)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.65,
            children: [
              _buildProductCard(
                title: "Walnut Side Table",
                price: "€48",
                seller: "Lotte's Finds",
                rating: "4.8",
                tag: "Recycled",
              ),
              _buildProductCard(
                title: "Embroidered Denim Jacket",
                price: "€65",
                seller: "Patch & Thread",
                rating: "4.9",
                tag: "Upcycled",
                isLinkedProduct: true,
                context: context,
              ),
              _buildProductCard(
                title: "Reclaimed Oak Speakers",
                price: "€120",
                seller: "Audio Vintage",
                rating: "4.7",
                tag: "Recycled",
              ),
              _buildProductCard(
                title: "Botanical Upcycled Wall Art",
                price: "€30",
                seller: "Green Decor",
                rating: "5.0",
                tag: "Upcycled",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard({
    required String title,
    required String price,
    required String seller,
    required String rating,
    required String tag,
    bool isLinkedProduct = false,
    BuildContext? context,
  }) {
    return GestureDetector(
      onTap: isLinkedProduct && context != null
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailsScreen(product: Product.getMockProduct()),
                ),
              );
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  color: Colors.grey.shade200,
                  image: isLinkedProduct 
                      ? const DecorationImage(
                          image: AssetImage('assets/images/ProductDetails/thumbnails.png'),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: !isLinkedProduct ? const Center(child: Icon(Icons.image, color: Colors.white, size: 40)) : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, height: 1.2),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(price, style: TextStyle(color: mostadamGreen, fontWeight: FontWeight.bold, fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: lightGreenBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(tag, style: TextStyle(color: darkGreen, fontSize: 10, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text("by $seller", style: const TextStyle(color: Colors.black54, fontSize: 11), overflow: TextOverflow.ellipsis),
                      ),
                      const Icon(Icons.star, color: Colors.orange, size: 12),
                      const SizedBox(width: 2),
                      Text(rating, style: const TextStyle(color: Colors.black54, fontSize: 11)),
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

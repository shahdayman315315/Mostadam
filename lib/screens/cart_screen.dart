import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mostadam/screens/checkout_screen.dart';

// ── Brand Colors (consistent across app) ─────────────────────────────────────
class _AppColors {
  static const bg = Color(0xFFF7F5F0);
  static const green = Color(0xFF2D5016);
  static const darkGreen = Color(0xFF287943);
  static const accentGreen = Color(0xFF88D49E);
  static const greenLight = Color(0xFFEAF5ED);
  static const card = Colors.white;
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //context is address of current screen
    final user = FirebaseAuth.instance.currentUser;
    // Authorized : user must be logged in
    if (user == null) {
      return Scaffold(
        backgroundColor: _AppColors.bg,
        appBar: _buildAppBar(context),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              //Conditional Rendering based on authentication status
              Text(
                'Please log in to view your cart.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
    //if user is authenticated, show cart items
    return Scaffold(
      backgroundColor: _AppColors.bg,
      appBar: _buildAppBar(context),
      body: StreamBuilder<QuerySnapshot>(
        // Stream cart items belonging to current user
        //Data between firebase and app is synced in real-time
        stream: FirebaseFirestore.instance
            .collection('cart')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          //connectionState.waiting: show loading indicator while fetching data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              // CircularProgressIndicator is a widget that shows a spinning circle to indicate loading
              child: CircularProgressIndicator(color: _AppColors.green),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading cart. Please try again.',
                style: TextStyle(color: Colors.red.shade400),
              ),
            );
          }

          final cartItems = snapshot.data?.docs ?? [];
          if (cartItems.isEmpty)
            return _buildEmptyState(); // Show empty state if no items in cart

          // Calculate total price dynamically
          final double total = cartItems.fold(0.0, (sum, item) {
            final data = item.data() as Map<String, dynamic>;
            final price = (data['price'] as num?)?.toDouble() ?? 0.0;
            final qty = (data['quantity'] as num?)?.toInt() ?? 1;
            return sum + (price * qty);
          });
          // Show list of cart items and summary at the bottom
          return Column(
            children: [
              Expanded(
                //ava area for list of cart items
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: cartItems.length,
                  itemBuilder: (_, i) => _CartItemCard(doc: cartItems[i]),
                ),
              ),
              _CartSummary(total: total, cartItems: cartItems),
            ],
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) => AppBar(
    title: const Text(
      'Your Cart',
      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    ),
    backgroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () => Navigator.pop(context), // Go back to previous screen
    ),
  );

  //if cart is empty, show this widget

  Widget _buildEmptyState() => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
        SizedBox(height: 16),
        Text(
          'Your cart is empty',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
        SizedBox(height: 8),
        Text(
          'Browse products and add items to your cart.',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    ),
  );
}

// This widget represents a single item card in the shopping cart ────────────────────────────────
class _CartItemCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  const _CartItemCard({required this.doc});

  // Increment or decrement quantity in Firestore
  Future<void> _updateQty(int change) async {
    final data = doc.data() as Map<String, dynamic>;
    final currentQty = (data['quantity'] as num?)?.toInt() ?? 1;
    // Prevention: Don't allow quantity to go below 1
    if (currentQty + change > 0) {
      // Perform an atomic increment/decrement on the server side to avoid race conditions
      await doc.reference.update({'quantity': FieldValue.increment(change)});
    }
  }

  // Show confirmation dialog before deleting
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Item'),
        content: const Text('Remove this item from your cart?'),
        actions: [
          TextButton(
            // Close the dialog without doing anything
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            // Proceed with deletion from Firestore
            onPressed: () {
              doc.reference.delete();
              Navigator.pop(ctx);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final title = (data['title'] as String?) ?? 'Product';
    final seller = (data['sellerName'] as String?) ?? 'Unknown';
    final price = (data['price'] as num?)?.toDouble() ?? 0.0;
    final qty = (data['quantity'] as num?)?.toInt() ?? 1;
    final imageUrl = (data['image'] as String?) ?? '';

    // Card layout for each cart item with image, title, seller info, price, quantity controls, and delete button
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Row layout: Image on the left, details in the middle, delete button on the right
      child: Row(
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 14),

          // Product info + quantity controls
          Expanded(
            child: Column(
              // Align text to the left
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Seller: $seller',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Row(
                  // Space between price and quantity controls
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: _AppColors.darkGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    // Quantity controls (minus button, quantity text, plus button)
                    Row(
                      children: [
                        _qtyButton(Icons.remove, () => _updateQty(-1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            '$qty',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        _qtyButton(Icons.add, () => _updateQty(1)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Delete button to remove item from cart
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }

  // Placeholder widget for when product image fails to load or is missing
  // to maintain UI consistency
  Widget _placeholder() => Container(
    width: 80,
    height: 80,
    color: _AppColors.greenLight,
    child: const Icon(Icons.eco, color: _AppColors.darkGreen),
  );

  Widget _qtyButton(IconData icon, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(6),
    child: Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 18, color: Colors.black87),
    ),
  );
}

// ── Cart Summary + Checkout Button ────────────────────────────────────────────
// The Bottom Sheet for Total Amount and Payment Action
class _CartSummary extends StatelessWidget {
  final double total;
  final List<QueryDocumentSnapshot> cartItems;

  const _CartSummary({required this.total, required this.cartItems});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            // Subtle shadow to give the summary section a lifted appearance
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Total row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount:',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                // Display total price with 2 decimal places and a dollar sign
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  color: _AppColors.green,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Proceed to checkout
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _AppColors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CheckoutScreen()),
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

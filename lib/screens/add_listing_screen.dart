// add_listing_screen.dart — Mostadam | Direct Image URL Version
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ── Brand Colors ──────────────────────────────
class _C {
  static const green = Color(0xFF2D5016);
  static const darkGreen = Color(0xFF287943);
  static const greenLight = Color(0xFFEAF5ED);
  static const bg = Color(0xFFF5F6F2);
  static const card = Colors.white;
}

const List<String> _categories = [
  'Furniture',
  'Clothing',
  'Electronics',
  'Upcycled',
  'Books',
  'Sports',
];

// ═════════════════════════════════════════════════════════════════════════════
class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});
  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  // ── Controllers ──────────────────────────────────────────────────────────
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _origPriceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _materialCtrl = TextEditingController();
  final _sizeCtrl = TextEditingController();
  final _storyCtrl = TextEditingController();
  final _co2Ctrl = TextEditingController();
  // ── NEW: replaces XFile list + ImagePicker ────────────────────────────────
  final _imageUrlCtrl = TextEditingController();

  // ── State ─────────────────────────────────────────────────────────────────
  String _condition = 'Good';
  String _repairBg = 'Repaired';
  String _category = 'Clothing';
  bool _allowOffers = true;
  bool _isLoading = false;

  // Holds the URL currently shown in the preview (updates on every edit)
  String _previewUrl = '';

  @override
  void initState() {
    super.initState();
    // Rebuild preview whenever the URL field changes
    _imageUrlCtrl.addListener(() {
      setState(() => _previewUrl = _imageUrlCtrl.text.trim());
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _origPriceCtrl.dispose();
    _descCtrl.dispose();
    _materialCtrl.dispose();
    _sizeCtrl.dispose();
    _storyCtrl.dispose();
    _co2Ctrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────────────
  String? _validate() {
    if (_titleCtrl.text.trim().isEmpty) return 'Please enter a title.';
    if (_priceCtrl.text.trim().isEmpty) return 'Please enter a price.';
    if (double.tryParse(_priceCtrl.text.trim()) == null)
      return 'Price must be a valid number.';
    // ── URL validation (replaces "at least one photo" check) ──────────────
    final url = _imageUrlCtrl.text.trim();
    if (url.isEmpty) return 'Please enter an image URL.';
    if (!url.startsWith('http://') && !url.startsWith('https://'))
      return 'Image URL must start with http:// or https://';
    return null;
  }

  // ── Publish product to Firestore (no Storage upload) ─────────────────────
  Future<void> _publish() async {
    // 1. Validate
    final error = _validate();
    if (error != null) {
      _snack(error);
      return;
    }

    // 2. Auth guard
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _snack('You must be logged in to publish a listing.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final imageUrl = _imageUrlCtrl.text.trim();

      // 3. Build Firestore document
      //    'image'  → single String  (HomeScreen / CartScreen)
      //    'images' → List<String>   (ProductDetailPage)
      final productDoc = <String, dynamic>{
        // Core fields
        'title': _titleCtrl.text.trim(),
        'price': double.parse(_priceCtrl.text.trim()),
        'originalPrice': double.tryParse(_origPriceCtrl.text.trim()) ?? 0.0,
        'description': _descCtrl.text.trim(),
        'material': _materialCtrl.text.trim(),
        'size': _sizeCtrl.text.trim(),
        'story': _storyCtrl.text.trim(),
        'repairHistory': _repairBg,
        'co2Saved': double.tryParse(_co2Ctrl.text.trim()) ?? 0.0,
        'condition': _condition,
        // ── Images: URL string stored in both fields ───────────────────────
        'image': imageUrl, // Single string for list cards
        'images': [imageUrl], // List for detail/gallery views
        // Category / meta
        'tag': _category,
        'allowOffers': _allowOffers,
        // Seller info
        'userId': user.uid,
        'sellerName': user.displayName ?? 'Seller',
        'sellerEmail': user.email ?? '',
        // Defaults
        'rating': 0.0,
        'visible': true,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // 4. Save to main products collection
      final productRef = await FirebaseFirestore.instance
          .collection('products')
          .add(productDoc);
      debugPrint('✅ Product saved → ${productRef.id}');

      // 5. Mirror into seller's listings subcollection
      await FirebaseFirestore.instance
          .collection('listings')
          .doc(user.uid)
          .collection('items')
          .doc(productRef.id)
          .set({...productDoc, 'productId': productRef.id});

      // 6. Increment seller's totalListed counter
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'totalListed': FieldValue.increment(1),
      }, SetOptions(merge: true));

      if (mounted) {
        _snack('Listing published! 🌿', success: true);
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.pop(context);
      }
    } on FirebaseException catch (e) {
      debugPrint('🔥 Firestore error: ${e.code} — ${e.message}');
      _snack('Firebase error: ${e.message ?? e.code}');
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      _snack('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── SnackBar ──────────────────────────────────────────────────────────────
  void _snack(String msg, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: success ? _C.darkGreen : Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Stack(
        children: [
          // ── Main scrollable content ────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 18),
                  _buildImageUrlCard(), // ← replaces _buildPhotosCard()
                  const SizedBox(height: 16),
                  _buildDetailsCard(),
                  const SizedBox(height: 16),
                  _buildCategoryCard(),
                  const SizedBox(height: 16),
                  _buildPricingCard(),
                  const SizedBox(height: 16),
                  _buildStoryCard(),
                  const SizedBox(height: 24),
                  _buildActions(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // ── Loading overlay (no progress bar needed — no upload) ───────
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: _C.darkGreen),
                      SizedBox(height: 16),
                      Text(
                        'Publishing listing…',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) => Row(
    children: [
      IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _isLoading ? null : () => Navigator.pop(context),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _C.darkGreen,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.eco, color: Colors.white, size: 20),
      ),
      const SizedBox(width: 10),
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Listing',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text('Mostadam', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    ],
  );

  // ── Image URL Card (replaces Photos Card) ─────────────────────────────────
  Widget _buildImageUrlCard() => _card(
    title: 'Product Image',
    subtitle: 'Paste a public image URL — a live preview will appear below.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── URL input row ────────────────────────────────────────────────
        _label('Image URL *'),
        TextField(
          controller: _imageUrlCtrl,
          keyboardType: TextInputType.url,
          autocorrect: false,
          decoration: InputDecoration(
            hintText: 'https://example.com/product-photo.jpg',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            // Clear button — handy when pasting a new link
            suffixIcon: _previewUrl.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      _imageUrlCtrl.clear();
                      setState(() => _previewUrl = '');
                    },
                  )
                : const Icon(Icons.link, color: Colors.grey, size: 18),
          ),
        ),

        const SizedBox(height: 16),

        // ── Live preview ─────────────────────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _previewUrl.isEmpty
              // Placeholder when no URL entered yet
              ? Container(
                  key: const ValueKey('placeholder'),
                  height: 180,
                  decoration: BoxDecoration(
                    color: _C.greenLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _C.darkGreen.withOpacity(0.25),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 40,
                          color: _C.darkGreen,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Preview will appear here',
                          style: TextStyle(color: _C.darkGreen, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              // Live network preview
              : ClipRRect(
                  key: ValueKey(_previewUrl),
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    _previewUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    // While loading
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 180,
                        color: _C.greenLight,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                : null,
                            color: _C.darkGreen,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    // If URL is invalid / unreachable
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_outlined,
                            size: 36,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Could not load image.\nCheck the URL.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red.shade400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ],
    ),
  );

  // ── Details Card ──────────────────────────────────────────────────────────
  Widget _buildDetailsCard() => _card(
    title: 'Item Details',
    subtitle: 'Help buyers know what you are selling.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Title *'),
        _field(_titleCtrl, 'e.g., Vintage Denim Jacket'),
        const SizedBox(height: 14),
        _label('Condition *'),
        Wrap(
          spacing: 8,
          children: ['New', 'Good', 'Fair'].map((c) {
            final sel = _condition == c;
            return ChoiceChip(
              label: Text(c),
              selected: sel,
              selectedColor: _C.darkGreen,
              labelStyle: TextStyle(color: sel ? Colors.white : Colors.black),
              onSelected: (_) => setState(() => _condition = c),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        _label('Material'),
        _field(_materialCtrl, 'Cotton, Leather, Wood...'),
        const SizedBox(height: 14),
        _label('Size / Dimensions'),
        _field(_sizeCtrl, 'M / 120×80 cm'),
        const SizedBox(height: 14),
        _label('Description'),
        _field(_descCtrl, 'Describe notable details...', maxLines: 3),
      ],
    ),
  );

  // ── Category Card ─────────────────────────────────────────────────────────
  Widget _buildCategoryCard() => _card(
    title: 'Category',
    subtitle: 'Choose the most fitting category.',
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((cat) {
        final sel = _category == cat;
        return GestureDetector(
          onTap: () => setState(() => _category = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: sel ? _C.darkGreen : _C.greenLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              cat,
              style: TextStyle(
                color: sel ? Colors.white : _C.darkGreen,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );

  // ── Pricing Card ──────────────────────────────────────────────────────────
  Widget _buildPricingCard() => _card(
    title: 'Pricing & Impact',
    subtitle: 'Set a fair price and show your sustainability impact.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Selling Price (USD) *'),
        _field(_priceCtrl, '0.00', keyboard: TextInputType.number),
        const SizedBox(height: 14),
        _label('Original Price (USD)'),
        _field(
          _origPriceCtrl,
          'Original retail price',
          keyboard: TextInputType.number,
        ),
        const SizedBox(height: 14),
        _label('CO₂ Saved (kg)'),
        _field(_co2Ctrl, 'e.g. 15.5', keyboard: TextInputType.number),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _C.greenLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                size: 20,
                color: _C.darkGreen,
              ),
              SizedBox(width: 10),
              Text(
                'Standard Shipping Included',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Allow Offers',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Switch(
              value: _allowOffers,
              activeColor: _C.darkGreen,
              onChanged: (v) => setState(() => _allowOffers = v),
            ),
          ],
        ),
      ],
    ),
  );

  // ── Story Card ────────────────────────────────────────────────────────────
  Widget _buildStoryCard() => _card(
    title: 'Sustainability Story',
    subtitle: "Share the item's history and repair background.",
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('The Story'),
        _field(
          _storyCtrl,
          'Where did you get it? How was it used?',
          maxLines: 3,
        ),
        const SizedBox(height: 14),
        _label('Repair / Recycle Background'),
        Wrap(
          spacing: 8,
          children: ['Repaired', 'Upcycled', 'Recycled'].map((r) {
            final sel = _repairBg == r;
            return ChoiceChip(
              label: Text(r),
              selected: sel,
              selectedColor: _C.darkGreen,
              labelStyle: TextStyle(color: sel ? Colors.white : Colors.black),
              onSelected: (_) => setState(() => _repairBg = r),
            );
          }).toList(),
        ),
      ],
    ),
  );

  // ── Action Buttons ────────────────────────────────────────────────────────
  Widget _buildActions(BuildContext context) => Row(
    children: [
      Expanded(
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _C.darkGreen,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _isLoading ? null : _publish,
          child: const Text(
            'Publish',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ],
  );

  // ── Shared Helpers ────────────────────────────────────────────────────────
  Widget _card({
    required String title,
    required String subtitle,
    required Widget child,
  }) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: _C.card,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 16),
        child,
      ],
    ),
  );

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      t,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
    ),
  );

  Widget _field(
    TextEditingController c,
    String hint, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) => TextField(
    controller: c,
    maxLines: maxLines,
    keyboardType: keyboard,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

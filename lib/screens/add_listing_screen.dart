// add_listing_screen.dart — Mostadam | Fixed Firebase Add Product Flow
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

// ── Categories ────────────────────────────────
const List<String> _categories = [
  'Furniture',
  'Clothing',
  'Electronics',
  'Upcycled',
  'Books',
  'Sports',
];

// ═════════════════════════════════════════════
class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});
  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  // ── Controllers ───────────────────────────
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _origPriceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _materialCtrl = TextEditingController();
  final _sizeCtrl = TextEditingController();
  final _storyCtrl = TextEditingController();
  final _co2Ctrl = TextEditingController();

  // ── State ─────────────────────────────────
  String _condition = 'Good';
  String _repairBg = 'Repaired';
  String _category = 'Clothing';
  bool _allowOffers = true;
  bool _isLoading = false;
  List<XFile> _images = [];

  final _picker = ImagePicker();

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
    super.dispose();
  }

  // ── Validation ────────────────────────────
  String? _validate() {
    if (_titleCtrl.text.trim().isEmpty) return 'Please enter a title.';
    if (_priceCtrl.text.trim().isEmpty) return 'Please enter a price.';
    if (double.tryParse(_priceCtrl.text.trim()) == null)
      return 'Price must be a valid number.';
    if (_images.isEmpty) return 'Please add at least one photo.';
    return null;
  }

  // ── Image Picker ──────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 1200,
      );
      if (picked != null) setState(() => _images.add(picked));
    } on Exception catch (e) {
      debugPrint('Image picker error: $e');
      _snack(
        'Could not open ${source == ImageSource.camera ? "camera" : "gallery"}. Check permissions.',
      );
    }
  }

  // ── Upload Images to Storage ──────────────
  Future<List<String>> _uploadImages() async {
    final List<String> urls = [];
    final storageRef = FirebaseStorage.instance.ref();

    for (int i = 0; i < _images.length; i++) {
      final xFile = _images[i];
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i';
      final ref = storageRef.child('products/$fileName.jpg');

      try {
        UploadTask task;

        if (kIsWeb) {
          // Web: use bytes
          final bytes = await xFile.readAsBytes();
          task = ref.putData(
            bytes,
            SettableMetadata(contentType: 'image/jpeg'),
          );
        } else {
          // Mobile/Desktop: use File
          final file = File(xFile.path);
          if (!await file.exists()) {
            debugPrint('File not found: ${xFile.path}');
            continue;
          }
          task = ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
        }

        final snapshot = await task;
        final url = await snapshot.ref.getDownloadURL();
        urls.add(url);
        debugPrint('Uploaded image $i → $url');
      } on FirebaseException catch (e) {
        debugPrint('Storage error on image $i: ${e.code} — ${e.message}');
        _snack('Upload failed for image ${i + 1}: ${e.message}');
        rethrow;
      }
    }
    return urls;
  }

  // ── Publish to Firestore ──────────────────
  Future<void> _publish() async {
    // 1. Validate
    final error = _validate();
    if (error != null) {
      _snack(error);
      return;
    }

    // 2. Auth check
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _snack('You must be logged in.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 3. Upload images
      final imageUrls = await _uploadImages();
      if (imageUrls.isEmpty) {
        _snack('Image upload failed. Please try again.');
        setState(() => _isLoading = false);
        return;
      }

      // 4. Build Firestore document
      final doc = <String, dynamic>{
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
        'images': imageUrls,
        'image': imageUrls.first, // convenience field used in cart/home
        'tag': _category,
        'allowOffers': _allowOffers,
        'userId': user.uid,
        'sellerName': user.displayName ?? 'Seller',
        'sellerEmail': user.email ?? '',
        'rating': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
        'visible': true,
      };

      // 5. Save to Firestore
      final ref = await FirebaseFirestore.instance
          .collection('products')
          .add(doc);
      debugPrint('Product saved → ${ref.id}');

      // 6. Also mirror into seller's listings subcollection (used by ProfileScreen)
      await FirebaseFirestore.instance
          .collection('listings')
          .doc(user.uid)
          .collection('items')
          .doc(ref.id)
          .set({...doc, 'productId': ref.id});

      // 7. Update seller's totalListed counter
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'totalListed': FieldValue.increment(1),
      }, SetOptions(merge: true));

      if (mounted) {
        _snack('Listing published! 🌿', success: true);
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.pop(context);
      }
    } on FirebaseException catch (e) {
      debugPrint('Firestore error: ${e.code} — ${e.message}');
      _snack('Firebase error: ${e.message ?? e.code}');
    } on Exception catch (e) {
      debugPrint('Unexpected error: $e');
      _snack('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── SnackBar helper ───────────────────────
  void _snack(String msg, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? _C.darkGreen : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 18),
                  _buildPhotosCard(),
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
          // Loading overlay — prevents double-submit
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Uploading & publishing...',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────
  Widget _buildHeader(BuildContext context) => Row(
    children: [
      IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
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

  // ── Photos Card ───────────────────────────
  Widget _buildPhotosCard() => _card(
    title: 'Add Photos',
    subtitle: 'Clear photos get more buyers. At least 1 required.',
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _imgBtn(
                Icons.camera_alt_outlined,
                'Camera',
                () => _pickImage(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _imgBtn(
                Icons.photo_library_outlined,
                'Gallery',
                () => _pickImage(ImageSource.gallery),
              ),
            ),
          ],
        ),
        if (_images.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              itemBuilder: (_, i) => Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade200,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: kIsWeb
                          ? Image.network(_images[i].path, fit: BoxFit.cover)
                          : Image.file(
                              File(_images[i].path),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 12,
                    child: GestureDetector(
                      onTap: () => setState(() => _images.removeAt(i)),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    ),
  );

  // ── Details Card ──────────────────────────
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

  // ── Category Card ─────────────────────────
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

  // ── Pricing Card ──────────────────────────
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

  // ── Story Card ────────────────────────────
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

  // ── Action Buttons ────────────────────────
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

  // ── Shared Helpers ────────────────────────
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

  Widget _imgBtn(IconData icon, String label, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: _C.darkGreen),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    ),
  );
}

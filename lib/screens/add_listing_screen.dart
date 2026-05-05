import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

// ── Shared Brand Colors ───────────────────────────────────────────────────────
class _Colors {
  static const green = Color(0xFF2D5016);
  static const darkGreen = Color(0xFF287943);
  static const accentGreen = Color(0xFF88D49E);
  static const greenLight = Color(0xFFEAF5ED);
  static const bg = Color(0xFFF5F6F2);
  static const card = Colors.white;
}

// ── Category list consistent with HomeScreen ──────────────────────────────────
const List<String> _appCategories = [
  'Furniture',
  'Clothing',
  'Electronics',
  'Upcycled',
  'Books',
  'Sports',
];

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  // ── Form Controllers ──────────────────────────────────────────────────────
  final _titleCtrl = TextEditingController();
  final _materialCtrl = TextEditingController();
  final _sizeCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _storyCtrl = TextEditingController();
  final _originalPriceCtrl = TextEditingController();
  final _co2Ctrl = TextEditingController();

  // ── State ─────────────────────────────────────────────────────────────────
  String _condition = 'Good';
  String _recyclingBg = 'Repaired';
  String _selectedCategory = 'Clothing';
  bool _allowOffers = true;
  bool _isLoading = false;
  List<XFile> _selectedImages = [];

  final _picker = ImagePicker();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _materialCtrl.dispose();
    _sizeCtrl.dispose();
    _descriptionCtrl.dispose();
    _priceCtrl.dispose();
    _storyCtrl.dispose();
    _originalPriceCtrl.dispose();
    _co2Ctrl.dispose();
    super.dispose();
  }

  // ── Pick Image ────────────────────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (image != null) setState(() => _selectedImages.add(image));
    } catch (e) {
      _snack('Could not pick image: $e');
    }
  }

  // ── Publish Listing ───────────────────────────────────────────────────────
  Future<void> _publishListing() async {
    // Basic validation
    if (_titleCtrl.text.trim().isEmpty) {
      _snack('Please enter a title.');
      return;
    }
    if (_priceCtrl.text.trim().isEmpty) {
      _snack('Please enter a price.');
      return;
    }
    if (_selectedImages.isEmpty) {
      _snack('Please add at least one photo.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not logged in');

      // Upload all images to Firebase Storage
      final List<String> imageUrls = [];
      for (final image in _selectedImages) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${imageUrls.length}';
        final ref = FirebaseStorage.instance.ref().child('products/$fileName');
        await ref.putFile(File(image.path));
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      }

      // Save product to Firestore
      await FirebaseFirestore.instance.collection('products').add({
        'title': _titleCtrl.text.trim(),
        'price': double.tryParse(_priceCtrl.text.trim()) ?? 0.0,
        'originalPrice': double.tryParse(_originalPriceCtrl.text.trim()) ?? 0.0,
        'condition': _condition,
        'material': _materialCtrl.text.trim(),
        'size': _sizeCtrl.text.trim(),
        'description': _descriptionCtrl.text.trim(),
        'story': _storyCtrl.text.trim(),
        'repairHistory': _recyclingBg,
        'co2Saved': double.tryParse(_co2Ctrl.text.trim()) ?? 0.0,
        'images': imageUrls,
        'sellerName': user.displayName ?? 'User',
        'userId': user.uid,
        'tag': _selectedCategory, // category = tag for filtering
        'allowOffers': _allowOffers,
        'createdAt': FieldValue.serverTimestamp(),
        'rating': 5.0,
      });

      if (mounted) {
        _snack('Listing published! 🌿', success: true);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _snack('Error publishing listing: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg, {bool success = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: success ? _Colors.darkGreen : null,
          behavior: SnackBarBehavior.floating,
        ),
      );

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Colors.bg,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                children: [
                  _buildHeader(),
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
                  _buildActionButtons(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() => Row(
    children: [
      IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _Colors.darkGreen,
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

  // ── Photos Card ───────────────────────────────────────────────────────────
  Widget _buildPhotosCard() => _sectionCard(
    title: 'Add Photos',
    subtitle: 'Clear photos get more buyers.',
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _imageBtn(
                Icons.camera_alt_outlined,
                'Camera',
                () => _pickImage(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _imageBtn(
                Icons.photo_library_outlined,
                'Gallery',
                () => _pickImage(ImageSource.gallery),
              ),
            ),
          ],
        ),
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
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
                          ? Image.network(
                              _selectedImages[i].path,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(_selectedImages[i].path),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  // Remove image button
                  Positioned(
                    top: 2,
                    right: 12,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedImages.removeAt(i)),
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

  // ── Details Card ──────────────────────────────────────────────────────────
  Widget _buildDetailsCard() => _sectionCard(
    title: 'Item Details',
    subtitle: 'Help buyers know what you are selling.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Title *'),
        _textField(_titleCtrl, 'e.g., Vintage Denim Jacket'),
        const SizedBox(height: 14),
        _label('Condition *'),
        _conditionChips(),
        const SizedBox(height: 14),
        _label('Material'),
        _textField(_materialCtrl, 'Cotton, Leather, Wood...'),
        const SizedBox(height: 14),
        _label('Size / Dimensions'),
        _textField(_sizeCtrl, 'M / 120x80cm...'),
        const SizedBox(height: 14),
        _label('Description'),
        _textField(
          _descriptionCtrl,
          'Describe notable details...',
          maxLines: 3,
        ),
      ],
    ),
  );

  // ── Category Card ─────────────────────────────────────────────────────────
  Widget _buildCategoryCard() => _sectionCard(
    title: 'Category',
    subtitle: 'Choose the most fitting category.',
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _appCategories.map((cat) {
        final isSelected = _selectedCategory == cat;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? _Colors.darkGreen : _Colors.greenLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              cat,
              style: TextStyle(
                color: isSelected ? Colors.white : _Colors.darkGreen,
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
  Widget _buildPricingCard() => _sectionCard(
    title: 'Pricing & Impact',
    subtitle: 'Set a fair price and show your sustainability impact.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Selling Price (USD) *'),
        _textField(_priceCtrl, '0.00', keyboard: TextInputType.number),
        const SizedBox(height: 14),
        _label('Original Price (USD)'),
        _textField(
          _originalPriceCtrl,
          'Original retail price',
          keyboard: TextInputType.number,
        ),
        const SizedBox(height: 14),
        _label('CO₂ Saved (kg)'),
        _textField(_co2Ctrl, 'e.g. 15.5', keyboard: TextInputType.number),
        const SizedBox(height: 14),
        // Shipping info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _Colors.greenLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                size: 20,
                color: _Colors.darkGreen,
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
        // Allow offers toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Allow Offers',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Switch(
              value: _allowOffers,
              activeColor: _Colors.darkGreen,
              onChanged: (v) => setState(() => _allowOffers = v),
            ),
          ],
        ),
      ],
    ),
  );

  // ── Story Card ────────────────────────────────────────────────────────────
  Widget _buildStoryCard() => _sectionCard(
    title: 'Sustainability Story',
    subtitle: "Share the item's history and your repair background.",
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('The Story'),
        _textField(
          _storyCtrl,
          'Where did you get it? How was it used?',
          maxLines: 3,
        ),
        const SizedBox(height: 14),
        _label('Repair / Recycle Background'),
        Wrap(
          spacing: 8,
          children: ['Repaired', 'Upcycled', 'Recycled'].map((r) {
            final isSelected = _recyclingBg == r;
            return ChoiceChip(
              label: Text(r),
              selected: isSelected,
              selectedColor: _Colors.darkGreen,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
              onSelected: (_) => setState(() => _recyclingBg = r),
            );
          }).toList(),
        ),
      ],
    ),
  );

  // ── Action Buttons ────────────────────────────────────────────────────────
  Widget _buildActionButtons() => Row(
    children: [
      Expanded(
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _Colors.darkGreen,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _isLoading ? null : _publishListing,
          child: const Text(
            'Publish',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ],
  );

  // ── Reusable Widgets ──────────────────────────────────────────────────────
  Widget _sectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: _Colors.card,
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

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
    ),
  );

  Widget _textField(
    TextEditingController ctrl,
    String hint, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) => TextField(
    controller: ctrl,
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

  Widget _conditionChips() => Row(
    children: ['New', 'Good', 'Fair'].map((c) {
      final isSelected = _condition == c;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(c),
          selected: isSelected,
          selectedColor: _Colors.darkGreen,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
          onSelected: (_) => setState(() => _condition = c),
        ),
      );
    }).toList(),
  );

  Widget _imageBtn(IconData icon, String label, VoidCallback onTap) => InkWell(
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
          Icon(icon, size: 20, color: _Colors.darkGreen),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _storyController = TextEditingController();

  // ✅ الجديد (لينك الصورة)
  final TextEditingController _imageUrlController = TextEditingController();

  // State
  String _condition = 'Good';
  String _recyclingBackground = 'Repaired';
  bool _allowOffers = true;
  List<XFile> _selectedImages = [];
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  // ================== LOGIC ==================

  Future<void> _publishListing() async {
    if (_titleController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _imageUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ بدل الرفع ناخد اللينك
      List<String> imageUrls = [
        _imageUrlController.text.trim()
      ];

      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('products').add({
        'title': _titleController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'condition': _condition,
        'material': _materialController.text.trim(),
        'size': _sizeController.text.trim(),
        'description': _descriptionController.text.trim(),
        'story': _storyController.text.trim(),
        'recyclingBackground': _recyclingBackground,
        'allowOffers': _allowOffers,
        'images': imageUrls,

        'sellerName': user?.displayName ?? user?.email ?? 'Unknown',
        'userId': user?.uid,

        'createdAt': FieldValue.serverTimestamp(),
        'rating': 0.0,
        'tag': 'Sustainable',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully ✅')),
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() => _selectedImages.add(image));
    }
  }

  // ================== UI ==================

  @override
  Widget build(BuildContext context) {
    const Color darkGreen = Color(0xFF216B41);
    const Color softGreen = Color(0xFFF3F8EF);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F2),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                children: [
                  _buildHeader(darkGreen),
                  const SizedBox(height: 18),

                  // Step 1
                  _buildSectionCard(
                    title: 'Add Photos',
                    subtitle: 'Showcase your item with clear images.',
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildImageBtn(
                                Icons.camera_alt_outlined,
                                'Take Photo',
                                () => _pickImage(ImageSource.camera),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildImageBtn(
                                Icons.photo_library_outlined,
                                'Gallery',
                                () => _pickImage(ImageSource.gallery),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ✅ حقل لينك الصورة
                        _buildLabel('Image URL'),
                        _buildTextField(
                          _imageUrlController,
                          'Paste image link here...',
                        ),

                        const SizedBox(height: 12),
                        _buildImageGrid(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Step 2
                  _buildSectionCard(
                    title: 'Details',
                    subtitle: 'Describe your item clearly.',
                    stepLabel: 'Step 2',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Title'),
                        _buildTextField(
                            _titleController, 'e.g., Vintage Jacket'),
                        const SizedBox(height: 16),
                        _buildLabel('Condition'),
                        _buildConditionChips(darkGreen),
                        const SizedBox(height: 16),
                        _buildLabel('Material'),
                        _buildTextField(
                            _materialController, 'Leather, Cotton...'),
                        const SizedBox(height: 16),
                        _buildLabel('Short Description'),
                        _buildTextField(_descriptionController,
                            'Share notable details...',
                            maxLines: 3),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Step 3
                  _buildSectionCard(
                    title: 'Pricing & Shipping',
                    subtitle: 'Set a fair price.',
                    stepLabel: 'Step 3',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Price (USD)'),
                        _buildTextField(_priceController, '0',
                            keyboard: TextInputType.number),
                        const SizedBox(height: 16),
                        _buildShippingCard(softGreen),
                        const SizedBox(height: 16),
                        _buildToggle('Allow Offers', _allowOffers,
                            (v) => setState(() => _allowOffers = v), darkGreen),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Step 4
                  _buildSectionCard(
                    title: 'Sustainability & Story',
                    subtitle: 'Share the item’s history.',
                    stepLabel: 'Step 4',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('The Story'),
                        _buildTextField(_storyController,
                            'How did you get it?',
                            maxLines: 3),
                        const SizedBox(height: 16),
                        _buildRecycleChips(darkGreen),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Back'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkGreen,
                            padding: const EdgeInsets.all(16),
                          ),
                          onPressed:
                              _isLoading ? null : _publishListing,
                          child: const Text(
                            'Publish',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

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

  // ================= UI HELPERS =================

  Widget _buildHeader(Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.eco, color: Colors.white),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mostadam',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('New Listing',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    String? stepLabel,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17)),
              if (stepLabel != null)
                Text(stepLabel,
                    style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold))
            ],
          ),
          Text(subtitle,
              style: const TextStyle(
                  color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    return _selectedImages.isEmpty
        ? const SizedBox.shrink()
        : SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (ctx, i) => Container(
                margin: const EdgeInsets.only(right: 10),
                width: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
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
            ),
          );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint,
      {int maxLines = 1,
      TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      );

  Widget _buildConditionChips(Color color) {
    return Row(
      children: ['New', 'Good', 'Fair']
          .map((c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(c),
                  selected: _condition == c,
                  selectedColor: color,
                  labelStyle: TextStyle(
                      color: _condition == c
                          ? Colors.white
                          : Colors.black),
                  onSelected: (s) =>
                      setState(() => _condition = c),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildRecycleChips(Color color) {
    return Wrap(
      spacing: 8,
      children: ['Repaired', 'Upcycled', 'Recycled']
          .map((r) => ChoiceChip(
                label: Text(r),
                selected: _recyclingBackground == r,
                selectedColor: color,
                labelStyle: TextStyle(
                    color: _recyclingBackground == r
                        ? Colors.white
                        : Colors.black),
                onSelected: (s) => setState(
                    () => _recyclingBackground = r),
              ))
          .toList(),
    );
  }

  Widget _buildShippingCard(Color softGreen) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: softGreen,
          borderRadius: BorderRadius.circular(12)),
      child: const Row(
        children: [
          Icon(Icons.local_shipping_outlined, size: 20),
          SizedBox(width: 10),
          Text('Standard Shipping Included',
              style: TextStyle(fontSize: 13))
        ],
      ),
    );
  }

  Widget _buildToggle(String title, bool val,
      Function(bool) onChange, Color color) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Switch(
            value: val,
            activeColor: color,
            onChanged: onChange)
      ],
    );
  }

  Widget _buildImageBtn(
      IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(label)
          ],
        ),
      ),
    );
  }
}
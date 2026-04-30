import 'package:flutter/material.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _storyController = TextEditingController();
  String _condition = 'Good';
  String _recyclingBackground = 'Repaired';
  bool _allowOffers = true;

  @override
  void dispose() {
    _titleController.dispose();
    _materialController.dispose();
    _sizeController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color darkGreen = const Color(0xFF216B41);
    final Color softGreen = const Color(0xFFF3F8EF);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(darkGreen),
              const SizedBox(height: 18),
              _buildSectionCard(
                title: 'Add Photos',
                subtitle:
                    'Showcase your item with clear images. Natural light and multiple angles help buyers trust the listing.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              side: const BorderSide(color: Colors.black12),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Take Photo'),
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              side: const BorderSide(color: Colors.black12),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Choose from Gallery'),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Thumbnails (drag to reorder)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 4,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return Container(
                            width: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Center(
                              child: index == 3
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.add,
                                          size: 28,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Add more',
                                          style: TextStyle(color: Colors.grey),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    )
                                  : const Icon(
                                      Icons.image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _buildSectionCard(
                title: 'Details',
                subtitle:
                    'Describe your item clearly. Accurate categories and condition help buyers find it.',
                stepLabel: 'Step 2',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Title'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _titleController,
                      hint: 'e.g., Vintage Leather Jacket - Medium',
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Category'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Clothing > Jackets'),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Condition'),
                    const SizedBox(height: 8),
                    Row(
                      children: ['New', 'Good', 'Fair'].map((option) {
                        final bool selected = _condition == option;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(option),
                              selected: selected,
                              selectedColor: darkGreen,
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                color: selected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.black12),
                              ),
                              onSelected: (_) {
                                setState(() {
                                  _condition = option;
                                });
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Material'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _materialController,
                      hint: 'Leather, Cotton, Linen...',
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Size'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _sizeController,
                      hint: 'M / Size 10 / Adjustable...',
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Short Description'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _descriptionController,
                      hint:
                          'Share notable details: year, repairs, scent-free, fits',
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _buildSectionCard(
                title: 'Pricing & Shipping',
                subtitle:
                    'Set a fair price and choose how you’ll ship. Offering pickup increases local discoverability.',
                stepLabel: 'Step 3',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Price (USD)'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _priceController,
                      hint: '0',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Shipping Options'),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black12),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Local pickup'),
                              Icon(Icons.check_circle, color: Colors.green),
                            ],
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: softGreen,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text('Calculated shipping rates'),
                                  Icon(Icons.edit, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Allow Offers',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Switch(
                          value: _allowOffers,
                          activeThumbColor: darkGreen,
                          onChanged: (value) {
                            setState(() {
                              _allowOffers = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Estimated payout',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$244.00',
                      style: TextStyle(
                        color: darkGreen,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _buildSectionCard(
                title: 'Sustainability & Story',
                subtitle:
                    'Share how this item was previously loved, repaired or upcycled to boost discoverability.',
                stepLabel: 'Step 4',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Tell the item’s story'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _storyController,
                      hint:
                          'e.g., Restored 2010 biker jacket — patched & cleaned for a second life',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Recycling / Upcycle Background'),
                    const SizedBox(height: 8),
                    Row(
                      children: ['Repaired', 'Upcycled', 'Recycled'].map((
                        option,
                      ) {
                        final bool selected = _recyclingBackground == option;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(option),
                              selected: selected,
                              selectedColor: darkGreen,
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                color: selected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.black12),
                              ),
                              onSelected: (_) {
                                setState(() {
                                  _recyclingBackground = option;
                                });
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.black12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sustainability Boost',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: softGreen,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.eco_rounded,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Vintage Brown Leather Jacket',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Patina from gentle wear. Repaired collar in 2022. Great fall staple.',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Sustainable',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '120',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.black12),
                      ),
                      onPressed: () {},
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {},
                      child: const Text('Next'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Save Draft'),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Publish'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color darkGreen) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: darkGreen,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.eco_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Mostadam',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 4),
              Text('Step 1 of 4', style: TextStyle(color: Colors.black54)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF7E9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Photos',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              if (stepLabel != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF7E9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    stepLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D702D),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF7F8F5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color.fromRGBO(0, 0, 0, 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color.fromRGBO(0, 0, 0, 0.08)),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
    );
  }
}

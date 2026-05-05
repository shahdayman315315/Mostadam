import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ── Shared Brand Colors ───────────────────────────────────────────────────────
class AppColors {
  static const bg = Color(0xFFF7F5F0);
  static const green = Color(0xFF2D5016);
  static const darkGreen = Color(0xFF287943);
  static const accentGreen = Color(0xFF88D49E);
  static const greenLight = Color(0xFFEAF5ED);
  static const card = Colors.white;
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B6B6B);
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _step = 0;
  bool _ecoPackaging = false;
  bool _processing = false;
  String _payment = 'Credit Card';

  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // Cache cart snapshot for order placement at step 3
  List<QueryDocumentSnapshot> _cartItems = [];
  double _total = 0;

  @override
  void dispose() {
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ── Step Validation ───────────────────────────────────────────────────────
  bool _validateStep() {
    if (_step == 0 && _cartItems.isEmpty) {
      _snack('Your cart is empty.');
      return false;
    }
    if (_step == 1) {
      if (_addressCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty) {
        _snack('Please fill in address and phone number.');
        return false;
      }
      if (!RegExp(r'^\+?[0-9\s\-]{7,15}$').hasMatch(_phoneCtrl.text.trim())) {
        _snack('Enter a valid phone number.');
        return false;
      }
    }
    return true;
  }

  void _snack(String msg, {bool success = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: success ? AppColors.darkGreen : null,
          behavior: SnackBarBehavior.floating,
        ),
      );

  // ── Place Order ───────────────────────────────────────────────────────────
  Future<void> _placeOrder() async {
    setState(() => _processing = true);
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('Not logged in');

      // Save order to Firestore
      await _db.collection('orders').add({
        'userId': uid,
        'items': _cartItems.map((d) {
          final data = d.data() as Map<String, dynamic>;
          return {
            'productId': d.id,
            'title': data['title'] ?? '',
            'price': data['price'] ?? 0,
            'quantity': data['quantity'] ?? 1,
            'image': data['image'] ?? '',
          };
        }).toList(),
        'totalPrice': _total,
        'shippingAddress': _addressCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'paymentMethod': _payment,
        'ecoPackaging': _ecoPackaging,
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear cart in batch
      final batch = _db.batch();
      for (final doc in _cartItems) batch.delete(doc.reference);
      await batch.commit();

      if (mounted) {
        _snack('Order placed successfully! 🌿', success: true);
        // Pop all screens back to root
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
    } catch (e) {
      if (mounted) _snack('Error placing order: $e');
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _processing
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.green),
            )
          : Stepper(
              type: StepperType.horizontal,
              currentStep: _step,
              elevation: 0,
              onStepContinue: () {
                if (!_validateStep()) return;
                if (_step < 3) setState(() => _step++);
              },
              onStepCancel: () {
                if (_step > 0) setState(() => _step--);
              },
              controlsBuilder: _buildControls,
              steps: [
                _makeStep(0, 'Review', _buildReviewStep()),
                _makeStep(1, 'Address', _buildAddressStep()),
                _makeStep(2, 'Payment', _buildPaymentStep()),
                _makeStep(3, 'Confirm', _buildConfirmStep()),
              ],
            ),
    );
  }

  Step _makeStep(int index, String title, Widget content) => Step(
    isActive: _step >= index,
    state: _step > index ? StepState.complete : StepState.indexed,
    title: Text(title, style: const TextStyle(fontSize: 12)),
    content: content,
  );

  // ── Step 0: Review Cart ───────────────────────────────────────────────────
  Widget _buildReviewStep() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return const Text('Not logged in.');
    }
    return StreamBuilder<QuerySnapshot>(
      stream: _db
          .collection('cart')
          .where('userId', isEqualTo: uid)
          .snapshots(),
      builder: (ctx, snap) {
        if (!snap.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.green),
          );
        }
        _cartItems = snap.data!.docs;

        final subtotal = _cartItems.fold<double>(0, (s, d) {
          final data = d.data() as Map<String, dynamic>;
          return s +
              ((data['price'] as num?)?.toDouble() ?? 0) *
                  ((data['quantity'] as num?)?.toInt() ?? 1);
        });
        final discount = _ecoPackaging ? 5.0 : 0.0;
        _total = subtotal - discount;

        if (_cartItems.isEmpty) {
          return const Center(
            child: Text(
              'Your cart is empty.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return Column(
          children: [
            ..._cartItems.map(_buildCartTile),
            const Divider(height: 24),
            _buildEcoToggle(),
            const SizedBox(height: 8),
            _priceRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
            if (_ecoPackaging)
              _priceRow('Eco Discount', '-\$5.00', color: Colors.green),
            _priceRow('Total', '\$${_total.toStringAsFixed(2)}', bold: true),
          ],
        );
      },
    );
  }

  Widget _buildCartTile(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final imageUrl = (data['image'] as String?) ?? '';
    return Card(
      color: AppColors.card,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _tileImagePlaceholder(),
                )
              : _tileImagePlaceholder(),
        ),
        title: Text(
          (data['title'] as String?) ?? 'Product',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Qty: ${(data['quantity'] as num?)?.toInt() ?? 1}'),
        trailing: Text(
          '\$${(data['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _tileImagePlaceholder() => Container(
    width: 50,
    height: 50,
    color: AppColors.greenLight,
    child: const Icon(Icons.eco, color: AppColors.darkGreen, size: 20),
  );

  Widget _buildEcoToggle() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.greenLight,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.eco, color: AppColors.green),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Eco-friendly packaging\n(Saves \$5.00)',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        Switch(
          value: _ecoPackaging,
          activeColor: AppColors.green,
          onChanged: (v) => setState(() => _ecoPackaging = v),
        ),
      ],
    ),
  );

  // ── Step 1: Shipping Address ──────────────────────────────────────────────
  Widget _buildAddressStep() => Column(
    children: [
      TextField(
        controller: _addressCtrl,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: 'Full Shipping Address',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _phoneCtrl,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: 'Phone Number',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    ],
  );

  // ── Step 2: Payment Method ────────────────────────────────────────────────
  Widget _buildPaymentStep() => Column(
    children: [
      _paymentOption('Credit Card', Icons.credit_card),
      _paymentOption('Apple Pay', Icons.apple),
      _paymentOption('Cash on Delivery', Icons.money),
    ],
  );

  Widget _paymentOption(String label, IconData icon) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: _payment == label ? AppColors.greenLight : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: _payment == label ? AppColors.darkGreen : Colors.grey.shade300,
      ),
    ),
    child: RadioListTile<String>(
      value: label,
      groupValue: _payment,
      title: Text(label),
      secondary: Icon(icon, color: AppColors.green),
      activeColor: AppColors.green,
      onChanged: (v) => setState(() => _payment = v!),
    ),
  );

  // ── Step 3: Confirm ───────────────────────────────────────────────────────
  Widget _buildConfirmStep() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Summary',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        _infoRow(Icons.location_on_outlined, 'Address', _addressCtrl.text),
        _infoRow(Icons.phone_outlined, 'Phone', _phoneCtrl.text),
        _infoRow(Icons.payment_outlined, 'Payment', _payment),
        _infoRow(
          Icons.eco_outlined,
          'Packaging',
          _ecoPackaging ? 'Eco-friendly 🌿' : 'Standard',
        ),
        _infoRow(Icons.attach_money, 'Total', '\$${_total.toStringAsFixed(2)}'),
        const SizedBox(height: 24),
        const Center(
          child: Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppColors.green,
          ),
        ),
        const Center(
          child: Text(
            'Everything looks good!',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    ),
  );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : '—',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    ),
  );

  // ── Price Row ─────────────────────────────────────────────────────────────
  Widget _priceRow(
    String label,
    String value, {
    bool bold = false,
    Color? color,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 17 : 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 17 : 14,
            fontWeight: FontWeight.bold,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    ),
  );

  // ── Stepper Controls ──────────────────────────────────────────────────────
  Widget _buildControls(BuildContext ctx, ControlsDetails details) {
    final isLast = _step == 3;
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          if (_step > 0) ...[
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: details.onStepCancel,
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isLast ? _placeOrder : details.onStepContinue,
              child: Text(
                isLast ? 'Place Order' : 'Next',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

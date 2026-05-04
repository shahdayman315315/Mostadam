import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppColors {
  static const bg = Color(0xFFF7F5F0);
  static const green = Color(0xFF2D5016);
  static const greenLight = Color(0xFFE8F0DC);
  static const card = Color(0xFFFFFFFF);
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

  // Cached cart snapshot for order placement
  List<QueryDocumentSnapshot> _cartItems = [];
  double _total = 0;

  @override
  void dispose() {
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ── Validation ──────────────────────────────────────────────
  bool _validateStep() {
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
    if (_step == 0 && _cartItems.isEmpty) {
      _snack('Your cart is empty.');
      return false;
    }
    return true;
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // ── Place Order ──────────────────────────────────────────────
  Future<void> _placeOrder() async {
    setState(() => _processing = true);
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('Not logged in');

      await _db.collection('orders').add({
        'userId': uid,
        'items': _cartItems
            .map(
              (d) => {
                'productId': d.id,
                'title': d['title'],
                'price': d['price'],
                'quantity': d['quantity'],
                'image': d['image'],
              },
            )
            .toList(),
        'totalPrice': _total,
        'shippingAddress': _addressCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'paymentMethod': _payment,
        'ecoPackaging': _ecoPackaging,
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      final batch = _db.batch();
      for (final doc in _cartItems) batch.delete(doc.reference);
      await batch.commit();

      if (mounted) {
        _snack('Order placed successfully! 🌿');
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
    } catch (e) {
      if (mounted) _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  // ── Build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
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
    title: Text(title),
    content: content,
  );

  // ── Step 1: Review ───────────────────────────────────────────
  Widget _buildReviewStep() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db
          .collection('cart')
          .where('userId', isEqualTo: _auth.currentUser?.uid)
          .snapshots(),
      builder: (ctx, snap) {
        if (!snap.hasData) return const CircularProgressIndicator();
        _cartItems = snap.data!.docs;

        double subtotal = _cartItems.fold(
          0,
          (s, d) => s + (d['price'] as num) * (d['quantity'] as num),
        );
        double discount = _ecoPackaging ? 5.0 : 0.0;
        _total = subtotal - discount;

        return Column(
          children: [
            ..._cartItems.map(_buildCartTile),
            const Divider(height: 24),
            _buildEcoToggle(),
            const SizedBox(height: 8),
            _priceRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
            if (_ecoPackaging)
              _priceRow('Eco-Discount', '-\$5.00', color: Colors.green),
            _priceRow('Total', '\$${_total.toStringAsFixed(2)}', bold: true),
          ],
        );
      },
    );
  }

  Widget _buildCartTile(QueryDocumentSnapshot doc) => Card(
    color: AppColors.card,
    elevation: 0,
    margin: const EdgeInsets.symmetric(vertical: 4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          doc['image'],
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
        ),
      ),
      title: Text(
        doc['title'],
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      subtitle: Text('Qty: ${doc['quantity']}'),
      trailing: Text(
        '\$${doc['price']}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
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

  // ── Step 2: Address ──────────────────────────────────────────
  Widget _buildAddressStep() => Column(
    children: [
      TextField(
        controller: _addressCtrl,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Full Shipping Address',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _phoneCtrl,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          labelText: 'Phone Number',
          border: OutlineInputBorder(),
        ),
      ),
    ],
  );

  // ── Step 3: Payment ──────────────────────────────────────────
  Widget _buildPaymentStep() => Column(
    children: [
      _paymentOption('Credit Card', Icons.credit_card),
      _paymentOption('Apple Pay', Icons.apple),
      _paymentOption('Cash on Delivery', Icons.money),
    ],
  );

  Widget _paymentOption(String label, IconData icon) => RadioListTile<String>(
    value: label,
    groupValue: _payment,
    title: Text(label),
    secondary: Icon(icon),
    activeColor: AppColors.green,
    onChanged: (v) => setState(() => _payment = v!),
  );

  // ── Step 4: Confirm ──────────────────────────────────────────
  Widget _buildConfirmStep() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
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
        const SizedBox(height: 12),
        _infoRow(Icons.location_on, 'Address', _addressCtrl.text),
        _infoRow(Icons.payment, 'Payment', _payment),
        _infoRow(
          Icons.eco,
          'Packaging',
          _ecoPackaging ? 'Eco-friendly 🌿' : 'Standard',
        ),
        _infoRow(Icons.attach_money, 'Total', '\$${_total.toStringAsFixed(2)}'),
        const SizedBox(height: 20),
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
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
      ],
    ),
  );

  // ── Helpers ──────────────────────────────────────────────────
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

  Widget _buildControls(BuildContext ctx, ControlsDetails details) {
    final isLast = _step == 3;
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          if (_step > 0) ...[
            Expanded(
              child: OutlinedButton(
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
              ),
              onPressed: isLast ? _placeOrder : details.onStepContinue,
              child: Text(isLast ? 'Place Order' : 'Next Step'),
            ),
          ),
        ],
      ),
    );
  }
}

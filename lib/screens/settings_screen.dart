import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Brand colors constants
  static const _green = Color(0xFF2D5016);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _yellow = Color(0xFFFFD600);
  static const _cardBg = Color(0xFFF7F7F7);
  static const _divider = Color(0xFFE0E0E0);

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _reasonCtrl = TextEditingController();

  bool _loading = true;
  bool _isProcessing = false; // To prevent multiple taps during saves

  // Profile data
  String _name = '';
  String _photoUrl = '';

  // Settings state variables
  bool _emailNotif = true;
  bool _pushNotif = false;
  bool _promotions = true;
  bool _twoFactor = true;
  bool _autoOffers = true;
  String _language = 'English';
  String _currency = 'USD';
  String _units = 'Metric';
  String _co2 = '0';

  List<Map<String, dynamic>> _blockedUsers = [];
  List<Map<String, dynamic>> _cards = [];

  String get _uid => _auth.currentUser?.uid ?? '';
  DocumentReference get _userRef => _db.collection('users').doc(_uid);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  // Helper to show "Coming Soon" or generic feedback
  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ── Data Loading ──────────────────────────────────────────────────────────
  Future<void> _loadData() async {
    if (_uid.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final results = await Future.wait([
        _userRef.get(),
        _userRef.collection('blockedUsers').get(),
        _userRef.collection('paymentMethods').get(),
      ]);

      final userDoc = results[0] as DocumentSnapshot;
      final blockedSnap = results[1] as QuerySnapshot;
      final cardsSnap = results[2] as QuerySnapshot;

      if (userDoc.exists) {
        final d = userDoc.data() as Map<String, dynamic>;
        _name = d['name'] ?? _auth.currentUser?.displayName ?? 'User';
        _photoUrl = d['photoUrl'] ?? '';
        _emailNotif = d['emailNotifications'] ?? true;
        _pushNotif = d['pushNotifications'] ?? false;
        _promotions = d['inAppPromotions'] ?? true;
        _twoFactor = d['twoFactorAuth'] ?? true;
        _autoOffers = d['autoApproveOffers'] ?? true;
        _language = d['language'] ?? 'English';
        _currency = d['currency'] ?? 'USD';
        _units = d['units'] ?? 'Metric';
        _co2 = d['co2Saved']?.toString() ?? '0';
      }

      _blockedUsers = blockedSnap.docs.map((d) {
        final data = d.data() as Map<String, dynamic>;
        return {
          'id': d.id,
          'name': data['name'] ?? 'Unknown',
          'since': data['since'] ?? '',
        };
      }).toList();

      _cards = cardsSnap.docs.map((d) {
        final data = d.data() as Map<String, dynamic>;
        return {
          'id': d.id,
          'type': data['type'] ?? 'Card',
          'last4': data['last4'] ?? '••••',
          'expires': data['expires'] ?? '',
          'primary': data['primary'] ?? false,
        };
      }).toList();
    } catch (e) {
      debugPrint('Settings load error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Database Operations ───────────────────────────────────────────────────
  Future<void> _save(String field, dynamic value) async {
    if (_uid.isEmpty) return;
    try {
      await _userRef.set({field: value}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Save error: $e');
    }
  }

  Future<void> _unblock(String docId) async {
    try {
      setState(() => _blockedUsers.removeWhere((u) => u['id'] == docId));
      await _userRef.collection('blockedUsers').doc(docId).delete();
    } catch (e) {
      _loadData(); // Revert on failure
    }
  }

  Future<void> _removeCard(String docId) async {
    try {
      setState(() => _cards.removeWhere((c) => c['id'] == docId));
      await _userRef.collection('paymentMethods').doc(docId).delete();
    } catch (e) {
      _loadData(); // Revert on failure
    }
  }

  // ── UI Components ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: _green)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header('Account'),
            _profileTile(),
            const SizedBox(height: 12),
            _verificationTile(),
            _dividerWidget(),

            _header('Notifications'),
            _toggle(
              'Email Notifications',
              'Order updates and offers',
              _emailNotif,
              (v) {
                setState(() => _emailNotif = v);
                _save('emailNotifications', v);
              },
            ),
            _toggle('Push Notifications', 'Live alerts', _pushNotif, (v) {
              setState(() => _pushNotif = v);
              _save('pushNotifications', v);
            }),
            _toggle('In-app Promotions', 'Personalized picks', _promotions, (
              v,
            ) {
              setState(() => _promotions = v);
              _save('inAppPromotions', v);
            }),
            const SizedBox(height: 12),
            _prefsRow(),
            _dividerWidget(),

            _header('Privacy & Security'),
            _rowTile(
              'Change Password',
              'Last changed 2 months ago',
              btn: OutlinedButton(
                onPressed: _showComingSoon,
                style: _outlineStyle(),
                child: const Text('Update'),
              ),
            ),
            _toggle(
              'Two-Factor Authentication',
              'SMS or authenticator',
              _twoFactor,
              (v) {
                setState(() => _twoFactor = v);
                _save('twoFactorAuth', v);
              },
            ),
            const SizedBox(height: 16),

            _header('Blocked Users'),
            if (_blockedUsers.isEmpty)
              const Text(
                'No blocked users.',
                style: TextStyle(color: Colors.black45, fontSize: 13),
              )
            else
              ..._blockedUsers.map(_blockedTile),

            const SizedBox(height: 12),
            _rowTile(
              'Data Export',
              'Download your listings history',
              btn: OutlinedButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Export requested! Check your email.'),
                  ),
                ),
                style: _outlineStyle(),
                child: const Text('Request'),
              ),
            ),
            _dividerWidget(),

            _header('Payment Methods'),
            if (_cards.isEmpty)
              const Text(
                'No saved cards.',
                style: TextStyle(color: Colors.black45, fontSize: 13),
              )
            else
              _cardsRow(),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showComingSoon,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _yellow,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Add Payment Method',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            _dividerWidget(),

            _header('Support'),
            _navTile('Help Center', 'FAQs and guides'),
            _navTile('Terms & Privacy', 'View legal documents'),
            _dividerWidget(),

            _header('Account Deactivation'),
            _deactivationSection(),
            const SizedBox(height: 24),

            _sustainabilityCard(),
            const SizedBox(height: 30),
            const Center(
              child: Text(
                'Mostadam v2.3.1 • © 2026',
                style: TextStyle(color: Colors.black38, fontSize: 12),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── Helper Widgets (Styling) ───────────────────────────────────────────────

  Widget _header(String t) => Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 10),
    child: Text(
      t,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    ),
  );

  Widget _dividerWidget() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 16),
    child: Divider(color: _divider, height: 1),
  );

  ButtonStyle _outlineStyle() => OutlinedButton.styleFrom(
    foregroundColor: Colors.black,
    side: const BorderSide(color: _divider),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  );

  Widget _profileTile() => Row(
    children: [
      _avatar(26),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              _auth.currentUser?.email ?? '',
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ],
        ),
      ),
      OutlinedButton(
        onPressed: _showComingSoon,
        style: _outlineStyle(),
        child: const Text('Edit'),
      ),
    ],
  );

  Widget _avatar(double r) {
    final init = _name.isNotEmpty ? _name[0].toUpperCase() : 'U';
    return CircleAvatar(
      radius: r,
      backgroundColor: _lightGreen,
      backgroundImage: _photoUrl.isNotEmpty ? NetworkImage(_photoUrl) : null,
      child: _photoUrl.isEmpty
          ? Text(
              init,
              style: TextStyle(
                color: _green,
                fontWeight: FontWeight.bold,
                fontSize: r * 0.8,
              ),
            )
          : null,
    );
  }

  Widget _verificationTile() => Row(
    children: [
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verification',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            Text(
              'ID verified • Email',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ],
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _lightGreen,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Verified',
          style: TextStyle(
            color: _green,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    ],
  );

  Widget _toggle(
    String title,
    String sub,
    bool val,
    ValueChanged<bool> onChange,
  ) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
    ),
    subtitle: Text(
      sub,
      style: const TextStyle(color: Colors.black54, fontSize: 13),
    ),
    value: val,
    activeColor: _green,
    onChanged: onChange,
  );

  Widget _rowTile(String title, String sub, {required Widget btn}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Text(
                sub,
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ],
          ),
        ),
        btn,
      ],
    ),
  );

  Widget _navTile(String title, String sub) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
    ),
    subtitle: Text(
      sub,
      style: const TextStyle(color: Colors.black54, fontSize: 13),
    ),
    trailing: const Icon(Icons.chevron_right, color: Colors.black54),
    onTap: _showComingSoon,
  );

  Widget _prefsRow() => Row(
    children: [
      _prefCell('Language', _language),
      const SizedBox(width: 24),
      _prefCell('Currency', _currency),
      const SizedBox(width: 24),
      _prefCell('Units', _units),
    ],
  );

  Widget _prefCell(String label, String val) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
      Text(
        val,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    ],
  );

  Widget _blockedTile(Map<String, dynamic> u) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey.shade300,
          child: const Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            u['name'] ?? 'User',
            style: const TextStyle(fontSize: 14),
          ),
        ),
        OutlinedButton(
          onPressed: () => _unblock(u['id']),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
          ),
          child: const Text('Unblock', style: TextStyle(fontSize: 12)),
        ),
      ],
    ),
  );

  Widget _cardsRow() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: _cards
          .map(
            (c) => Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c['type'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('•••• ${c['last4']}'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _removeCard(c['id']),
                    child: const Text(
                      'Remove',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    ),
  );

  Widget _deactivationSection() => Column(
    children: [
      TextField(
        controller: _reasonCtrl,
        decoration: InputDecoration(
          hintText: 'Reason for leaving (optional)',
          filled: true,
          fillColor: _cardBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      const SizedBox(height: 12),
      ElevatedButton(
        onPressed: _isProcessing
            ? null
            : () async {
                setState(() => _isProcessing = true);
                try {
                  if (_reasonCtrl.text.isNotEmpty)
                    await _save('deactivationReason', _reasonCtrl.text);
                  await _save('status', 'deactivated');
                  await _auth.signOut();
                  if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
                } finally {
                  if (mounted) setState(() => _isProcessing = false);
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          elevation: 0,
          minimumSize: const Size(double.infinity, 45),
        ),
        child: _isProcessing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Deactivate Account'),
      ),
    ],
  );

  Widget _sustainabilityCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: _lightGreen,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sustainability Impact',
                style: TextStyle(fontSize: 12),
              ),
              Text(
                '$_co2 kg CO₂ saved',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _green,
                ),
              ),
              const Text(
                'Great job keeping items out of landfills!',
                style: TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
        ),
        const Icon(Icons.eco, color: _green, size: 40),
      ],
    ),
  );
}

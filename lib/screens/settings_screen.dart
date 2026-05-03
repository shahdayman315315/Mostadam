import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ── Color palette ──────────────────────────────────────────────
  static const Color _green = Color(0xFF2E7D32);
  static const Color _lightGreen = Color(0xFFE8F5E9);
  static const Color _yellow = Color(0xFFFFD600);
  static const Color _cardBg = Color(0xFFF7F7F7);
  static const Color _divider = Color(0xFFE0E0E0);

  // ── Firebase ───────────────────────────────────────────────────
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // ── Loading state ──────────────────────────────────────────────
  bool _isLoading = true;

  // ── User profile (from Firestore) ─────────────────────────────
  String _displayName = '';
  String _photoUrl = '';

  // ── Notification toggles (from Firestore) ─────────────────────
  bool _emailNotifications = true;
  bool _pushNotifications = false;
  bool _inAppPromotions = true;

  // ── Security toggles (from Firestore) ─────────────────────────
  bool _twoFactorAuth = true;

  // ── Selling tools (from Firestore) ────────────────────────────
  bool _autoApproveOffers = true;

  // ── Preferences (from Firestore) ──────────────────────────────
  String _language = 'English';
  String _currency = 'USD';
  String _units = 'Metric';

  // ── Sustainability (from Firestore) ───────────────────────────
  String _co2Saved = '0';

  // ── Blocked users (from Firestore sub-collection) ─────────────
  List<Map<String, String>> _blockedUsers = [];

  // ── Payment cards (from Firestore sub-collection) ─────────────
  List<Map<String, dynamic>> _cards = [];

  // ── Deactivation reason controller ────────────────────────────
  final TextEditingController _reasonController = TextEditingController();

  // ══════════════════════════════════════════════════════════════
  //  LIFECYCLE
  // ══════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════
  //  DATA LOADING — fetches main doc + both sub-collections
  // ══════════════════════════════════════════════════════════════

  Future<void> _loadAllData() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      // Run all three fetches in parallel for speed
      final results = await Future.wait([
        _firestore.collection('Users').doc(uid).get(),
        _firestore
            .collection('Users')
            .doc(uid)
            .collection('blockedUsers')
            .get(),
        _firestore
            .collection('Users')
            .doc(uid)
            .collection('paymentMethods')
            .get(),
      ]);

      final userDoc = results[0] as DocumentSnapshot<Map<String, dynamic>>;
      final blockedSnap = results[1] as QuerySnapshot<Map<String, dynamic>>;
      final cardsSnap = results[2] as QuerySnapshot<Map<String, dynamic>>;

      // ── Parse main user document ───────────────────────────────
      if (userDoc.exists) {
        final data = userDoc.data()!;
        setState(() {
          // Profile
          _displayName = data['displayName'] ??
              _auth.currentUser?.displayName ??
              _auth.currentUser?.email?.split('@')[0] ??
              'User';
          _photoUrl = data['photoUrl'] ?? '';

          // Notification toggles
          _emailNotifications = data['emailNotifications'] ?? true;
          _pushNotifications = data['pushNotifications'] ?? false;
          _inAppPromotions = data['inAppPromotions'] ?? true;

          // Security
          _twoFactorAuth = data['twoFactorAuth'] ?? true;

          // Selling tools
          _autoApproveOffers = data['autoApproveOffers'] ?? true;

          // Preferences
          _language = data['language'] ?? 'English';
          _currency = data['currency'] ?? 'USD';
          _units = data['units'] ?? 'Metric';

          // Sustainability
          _co2Saved = data['co2Saved']?.toString() ?? '0';
        });
      }

      // ── Parse blockedUsers sub-collection ─────────────────────
      final blocked = blockedSnap.docs.map((d) {
        return {
          'id': d.id,
          'name': (d.data()['name'] ?? 'Unknown') as String,
          'since': (d.data()['since'] ?? '') as String,
        };
      }).toList();

      // ── Parse paymentMethods sub-collection ───────────────────
      final cards = cardsSnap.docs.map((d) {
        final data = d.data();
        return {
          'id': d.id,
          'type': data['type'] ?? 'Card',
          'last4': data['last4'] ?? '••••',
          'expires': data['expires'] ?? '',
          'primary': data['primary'] ?? false,
        };
      }).toList();

      if (mounted) {
        setState(() {
          _blockedUsers = blocked
              .map((e) => e.map((k, v) => MapEntry(k, v.toString())))
              .toList();
          _cards = cards;
        });
      }
    } catch (e) {
      // Defaults remain — screen still renders
      debugPrint('SettingsScreen load error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  FIRESTORE WRITE HELPERS
  // ══════════════════════════════════════════════════════════════

  /// Update a single field on the Users/{uid} document
  Future<void> _updateField(String field, dynamic value) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore
        .collection('Users')
        .doc(uid)
        .set({field: value}, SetOptions(merge: true));
  }

  /// Delete a document from the blockedUsers sub-collection + optimistic UI
  Future<void> _unblockUser(String docId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    setState(() => _blockedUsers.removeWhere((u) => u['id'] == docId));
    await _firestore
        .collection('Users')
        .doc(uid)
        .collection('blockedUsers')
        .doc(docId)
        .delete();
  }

  /// Delete a document from the paymentMethods sub-collection + optimistic UI
  Future<void> _removeCard(String docId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    setState(() => _cards.removeWhere((c) => c['id'] == docId));
    await _firestore
        .collection('Users')
        .doc(uid)
        .collection('paymentMethods')
        .doc(docId)
        .delete();
  }

  // ══════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildAvatarWidget(radius: 18),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Account ───────────────────────────────────────────
            _buildSectionHeader('Account'),
            _buildProfileTile(),
            const SizedBox(height: 12),
            _buildVerificationTile(),
            const SizedBox(height: 16),
            _buildSectionHeader('Linked Accounts'),
            _buildLinkedAccounts(),

            _buildDivider(),

            // ── Notifications & Preferences ───────────────────────
            _buildSwitchTile(
              title: 'Email Notifications',
              subtitle: 'Order updates and offers',
              value: _emailNotifications,
              onChanged: (v) {
                setState(() => _emailNotifications = v);
                _updateField('emailNotifications', v);
              },
            ),
            _buildSwitchTile(
              title: 'Push Notifications',
              subtitle: 'Live messages and alerts',
              value: _pushNotifications,
              onChanged: (v) {
                setState(() => _pushNotifications = v);
                _updateField('pushNotifications', v);
              },
            ),
            _buildSwitchTile(
              title: 'In-app Promotions',
              subtitle: 'Personalized sustainable picks',
              value: _inAppPromotions,
              onChanged: (v) {
                setState(() => _inAppPromotions = v);
                _updateField('inAppPromotions', v);
              },
            ),
            const SizedBox(height: 12),
            _buildPreferencesRow(),

            _buildDivider(),

            // ── Privacy & Security ────────────────────────────────
            _buildSectionHeader('Privacy & Security'),
            _buildChangePasswordTile(),
            _buildSwitchTile(
              title: 'Two-Factor Authentication',
              subtitle: 'Use SMS or authenticator app',
              value: _twoFactorAuth,
              onChanged: (v) {
                setState(() => _twoFactorAuth = v);
                _updateField('twoFactorAuth', v);
              },
            ),
            const SizedBox(height: 12),

            // ── Blocked Users ─────────────────────────────────────
            _buildSectionHeader('Blocked Users'),
            if (_blockedUsers.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'No blocked users.',
                  style: TextStyle(color: Colors.black45, fontSize: 13),
                ),
              )
            else
              ..._blockedUsers.map(_buildBlockedUserTile),
            const SizedBox(height: 8),
            _buildDataExportTile(),

            _buildDivider(),

            // ── Selling Tools ─────────────────────────────────────
            _buildSectionHeader('Selling Tools'),
            _buildSwitchTile(
              title: 'Auto-approve Offers',
              subtitle: 'Automatically accept offers under \$15',
              value: _autoApproveOffers,
              onChanged: (v) {
                setState(() => _autoApproveOffers = v);
                _updateField('autoApproveOffers', v);
              },
            ),
            _buildDefaultShippingTile(),

            _buildDivider(),

            // ── Payment Methods ───────────────────────────────────
            _buildSectionHeader('Payment Methods'),
            const Text(
              'Saved cards',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            if (_cards.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'No saved cards yet.',
                  style: TextStyle(color: Colors.black45, fontSize: 13),
                ),
              )
            else
              _buildPaymentCards(),
            const SizedBox(height: 12),
            _buildAddPaymentButton(),

            _buildDivider(),

            // ── Support ───────────────────────────────────────────
            _buildSectionHeader('Support'),
            _buildNavTile('Help Center', 'FAQs and guides', onTap: () {}),
            _buildReportIssueTile(),
            _buildNavTile('Terms & Privacy', 'View legal documents',
                onTap: () {}),

            _buildDivider(),

            // ── Account Deactivation ──────────────────────────────
            _buildSectionHeader('Account Deactivation'),
            _buildDeactivationSection(),

            _buildDivider(),

            // ── Sustainability Impact ─────────────────────────────
            _buildSustainabilityCard(),
            const SizedBox(height: 16),

            // ── Footer ────────────────────────────────────────────
            _buildFooter(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  REUSABLE LAYOUT HELPERS
  // ══════════════════════════════════════════════════════════════

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Divider(color: _divider, height: 1),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title,
          style:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      subtitle: Text(subtitle,
          style: const TextStyle(color: Colors.black54, fontSize: 13)),
      value: value,
      activeColor: _green,
      onChanged: onChanged,
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  ACCOUNT SECTION
  // ══════════════════════════════════════════════════════════════

  /// Shared avatar: uses Firestore photoUrl if present, else shows initial
  Widget _buildAvatarWidget({double radius = 26}) {
    final initial =
        _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'U';

    if (_photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(_photoUrl),
        onBackgroundImageError: (_, __) {},
        backgroundColor: _lightGreen,
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: _lightGreen,
      child: Text(
        initial,
        style: TextStyle(
          color: _green,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }

  Widget _buildProfileTile() {
    final email = _auth.currentUser?.email ?? '';

    return Row(
      children: [
        _buildAvatarWidget(radius: 26),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _displayName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 2),
              Text(
                email,
                style: const TextStyle(
                    color: Colors.black54, fontSize: 13),
              ),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            side: const BorderSide(color: _divider),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('Edit',
              style: TextStyle(fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildVerificationTile() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Verification',
                  style: TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 14)),
              SizedBox(height: 2),
              Text('ID verified • Email',
                  style:
                      TextStyle(color: Colors.black54, fontSize: 13)),
            ],
          ),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _lightGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Verified',
            style: TextStyle(
                color: _green,
                fontWeight: FontWeight.bold,
                fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildLinkedAccounts() {
    return Row(
      children: [
        _linkedAccountBtn(
          label: 'Google',
          icon: Icons.g_mobiledata,
          iconColor: Colors.red,
          bgColor: Colors.orange.shade50,
          connected: true,
        ),
        const SizedBox(width: 10),
        _linkedAccountBtn(
          label: 'Facebook',
          icon: Icons.facebook,
          iconColor: const Color(0xFF1877F2),
          bgColor: Colors.blue.shade50,
          connected: false,
        ),
      ],
    );
  }

  Widget _linkedAccountBtn({
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required bool connected,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 6),
          Text(
            '$label${connected ? 'Connected' : 'Connect'}',
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  PREFERENCES ROW
  // ══════════════════════════════════════════════════════════════

  Widget _buildPreferencesRow() {
    return Row(
      children: [
        _prefCell('Language', _language),
        const SizedBox(width: 24),
        _prefCell('Currency', _currency),
        const SizedBox(width: 24),
        _prefCell('Units', _units),
      ],
    );
  }

  Widget _prefCell(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(color: Colors.black54, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w500, fontSize: 14)),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  PRIVACY & SECURITY
  // ══════════════════════════════════════════════════════════════

  Widget _buildChangePasswordTile() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Change Password',
                    style: TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14)),
                SizedBox(height: 2),
                Text('Last changed 2 months ago',
                    style: TextStyle(
                        color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(color: _divider),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Update',
                style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  BLOCKED USERS — real Firestore data + live unblock
  // ══════════════════════════════════════════════════════════════

  Widget _buildBlockedUserTile(Map<String, String> user) {
    final name = user['name'] ?? 'Unknown';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade300,
            child: Text(
              initial,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14)),
                Text(user['since'] ?? '',
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 12)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => _unblockUser(user['id']!),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const Text('Unblock',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildDataExportTile() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Data Export',
                    style: TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14)),
                SizedBox(height: 2),
                Text(
                  'Download a copy of your listings,\nmessages, and transactions. This\nmay take up to 24 hours.',
                  style:
                      TextStyle(color: Colors.black54, fontSize: 12),
                ),
                SizedBox(height: 4),
                Text('Last: Jul 12',
                    style: TextStyle(
                        color: Colors.black38, fontSize: 11)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(color: _divider),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Request Export',
                style: TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  SELLING TOOLS
  // ══════════════════════════════════════════════════════════════

  Widget _buildDefaultShippingTile() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Default Shipping',
                    style: TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14)),
                SizedBox(height: 2),
                Text('Standard (3-5 business days)',
                    style: TextStyle(
                        color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(color: _divider),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Edit',
                style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  PAYMENT METHODS — real Firestore data + live remove
  // ══════════════════════════════════════════════════════════════

  Widget _buildPaymentCards() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _cards
            .map((card) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildPaymentCard(card),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> card) {
    final isPrimary = card['primary'] as bool? ?? false;

    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(card['type'] ?? '',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text('•••• ${card['last4'] ?? ''}',
              style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 2),
          Text('Expires ${card['expires'] ?? ''}',
              style: const TextStyle(
                  color: Colors.black54, fontSize: 11)),
          const SizedBox(height: 6),
          if (isPrimary)
            const Text('Primary',
                style: TextStyle(
                    color: _green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold))
          else
            GestureDetector(
              onTap: () => _removeCard(card['id'] as String),
              child: const Text('Remove',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
            ),
        ],
      ),
    );
  }

  Widget _buildAddPaymentButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: _yellow,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text(
          'Add Payment Method',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  SUPPORT
  // ══════════════════════════════════════════════════════════════

  Widget _buildNavTile(String title, String subtitle,
      {required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title,
          style:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      subtitle: Text(subtitle,
          style: const TextStyle(
              color: Colors.black54, fontSize: 13)),
      trailing:
          const Icon(Icons.chevron_right, color: Colors.black54),
      onTap: onTap,
    );
  }

  Widget _buildReportIssueTile() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Report an Issue',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      subtitle: const Text('Send feedback or report a bug',
          style: TextStyle(color: Colors.black54, fontSize: 13)),
      trailing: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          side: const BorderSide(color: _divider),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        ),
        child: const Text('Send',
            style: TextStyle(
                fontWeight: FontWeight.w500, fontSize: 13)),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  ACCOUNT DEACTIVATION
  // ══════════════════════════════════════════════════════════════

  Widget _buildDeactivationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Are you sure you want to deactivate your account?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 6),
        const Text(
          'Deactivating will hide your profile and listings. You will '
          'lose access to messages, saved drafts, and be removed from '
          'active seller programs. This action is reversible within 30 days.',
          style: TextStyle(color: Colors.black54, fontSize: 13),
        ),
        const SizedBox(height: 14),
        const Text(
          'Help us improve (optional)',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _reasonController,
          decoration: InputDecoration(
            hintText: 'What made you leave?',
            hintStyle:
                const TextStyle(color: Colors.black38, fontSize: 13),
            filled: true,
            fillColor: _cardBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: _divider),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                child: const Text('Cancel',
                    style: TextStyle(fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: _yellow,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                child: const Text(
                  'Deactivate Account',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  SUSTAINABILITY — reads _co2Saved from Firestore
  // ══════════════════════════════════════════════════════════════

  Widget _buildSustainabilityCard() {
    return Container(
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
                  style:
                      TextStyle(color: Colors.black54, fontSize: 12),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Cumulative CO2 saved',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_co2Saved kg CO2',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _green),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Equivalent to taking a car off\nthe road for 6 months',
                  style:
                      TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.eco, color: _green, size: 48),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  FOOTER
  // ══════════════════════════════════════════════════════════════

  Widget _buildFooter() {
    return const Center(
      child: Text(
        'Mostadam v2.3.1        © 2026 Mostadam',
        style: TextStyle(color: Colors.black38, fontSize: 12),
      ),
    );
  }
}
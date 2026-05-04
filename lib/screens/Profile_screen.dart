import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ── Colors ────────────────────────────────────────────────────────────────────
class AppColors {
  static const bg = Color(0xFFF7F5F0);
  static const green = Color(0xFF2D5016);
  static const greenLight = Color(0xFFE8F0DC);
  static const greenMid = Color(0xFF4A7C2F);
  static const amber = Color(0xFFE8A820);
  static const card = Color(0xFFFFFFFF);
  static const divider = Color(0xFFE0DDD6);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSec = Color(0xFF6B6B6B);
}

// ── Profile Screen ────────────────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  int _tab = 0;
  int _navIndex = 3;
  bool _hideBanner = false;

  User? get _user => _auth.currentUser;
  String get _uid => _user?.uid ?? '';

  // Firestore references
  DocumentReference get _userRef => _db.collection('users').doc(_uid);
  CollectionReference get _listingsRef =>
      _db.collection('listings').doc(_uid).collection('items');
  Query get _activityQuery => _db
      .collection('activity')
      .where('sellerId', isEqualTo: _uid)
      .orderBy('timestamp', descending: true)
      .limit(5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: _buildBottomNav(),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userRef.snapshots(),
        builder: (ctx, snap) {
          final u = snap.data?.data() as Map<String, dynamic>? ?? {};
          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(u),
                  _buildTabBar(),
                  _buildStatCards(u),
                  if (!_hideBanner && u['verified'] != true)
                    _buildVerifyBanner(),
                  _sectionTitle('My Listings'),
                  _buildListings(),
                  _sectionTitle('Recent Activity'),
                  _buildActivity(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(Map<String, dynamic> u) {
    final name = u['name'] ?? _user?.displayName ?? 'User';
    final wallet = (u['wallet'] as num?)?.toDouble() ?? 0.0;
    final followers = (u['followers'] as num?)?.toInt() ?? 0;
    final following = (u['following'] as num?)?.toInt() ?? 0;
    final sales = (u['totalSold'] as num?)?.toInt() ?? 0;
    final verified = u['verified'] == true;
    final rating = (u['rating'] as num?)?.toDouble() ?? 4.8;

    return Container(
      color: AppColors.card,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Avatar row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: AppColors.amber.withOpacity(0.2),
                    backgroundImage: _user?.photoURL != null
                        ? NetworkImage(_user!.photoURL!)
                        : null,
                    child: _user?.photoURL == null
                        ? Text(
                            name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: AppColors.green,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.green,
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (verified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: AppColors.greenMid,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        _pill(
                          'Eco Seller',
                          AppColors.greenLight,
                          AppColors.greenMid,
                        ),
                        const SizedBox(width: 6),
                        _pill(
                          '⭐ ${rating.toStringAsFixed(1)}',
                          const Color(0xFFFFF3CC),
                          Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      u['memberSince'] ?? 'Member',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSec,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.settings_outlined,
                  color: AppColors.textSec,
                  size: 22,
                ),
                onPressed: () {
                  /* TODO: navigate to settings */
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stats + Edit button row
          Row(
            children: [
              _statPill('$followers', 'Followers'),
              const SizedBox(width: 16),
              _statPill('$following', 'Following'),
              const SizedBox(width: 16),
              _statPill('$sales', 'Sales'),
              const Spacer(),
              OutlinedButton(
                onPressed: () {
                  /* TODO: edit profile */
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.green,
                  side: const BorderSide(color: AppColors.green, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Wallet card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3A6B20), AppColors.green],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Wallet Balance',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${wallet.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        /* TODO: start selling flow */
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.amber,
                        foregroundColor: AppColors.green,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        '+ Start Selling',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        /* TODO: withdraw flow */
                      },
                      child: const Text(
                        'Withdraw →',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab Bar ───────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    const tabs = ['Listings', 'Purchases', 'Reviews', 'Saved'];
    return Container(
      color: AppColors.card,
      child: Column(
        children: [
          const Divider(height: 1, color: AppColors.divider),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: List.generate(tabs.length, (i) {
                final active = i == _tab;
                return GestureDetector(
                  onTap: () => setState(() => _tab = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: active ? AppColors.green : AppColors.bg,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      tabs[i],
                      style: TextStyle(
                        color: active ? Colors.white : AppColors.textSec,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stat Cards ────────────────────────────────────────────────────────────
  Widget _buildStatCards(Map<String, dynamic> u) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
    child: Row(
      children: [
        Expanded(
          child: _statCard(
            Icons.inventory_2_outlined,
            'Listed',
            '${u['totalListed'] ?? 0}',
            AppColors.greenMid,
            AppColors.greenLight,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            Icons.shopping_bag_outlined,
            'Sold',
            '${u['totalSold'] ?? 0}',
            const Color(0xFF5C6BC0),
            const Color(0xFFEDE7F6),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            Icons.eco_rounded,
            'CO₂ Saved',
            '${u['co2Saved'] ?? 0}kg',
            AppColors.greenMid,
            const Color(0xFFDCEDC8),
          ),
        ),
      ],
    ),
  );

  // ── Verify Banner ─────────────────────────────────────────────────────────
  Widget _buildVerifyBanner() => Container(
    margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF8E1),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.amber.withOpacity(0.5)),
    ),
    child: Row(
      children: [
        const Icon(Icons.shield_outlined, color: AppColors.amber, size: 28),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verify Your Identity',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Get a badge & unlock higher selling limits.',
                style: TextStyle(fontSize: 11, color: AppColors.textSec),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          children: [
            ElevatedButton(
              onPressed: () {
                /* TODO: verification flow */
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amber,
                foregroundColor: Colors.white,
                elevation: 0,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Verify',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _hideBanner = true),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Later',
                style: TextStyle(fontSize: 11, color: AppColors.textSec),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  // ── Listings (live Firestore stream) ──────────────────────────────────────
  Widget _buildListings() => StreamBuilder<QuerySnapshot>(
    stream: _listingsRef.snapshots(),
    builder: (ctx, snap) {
      if (snap.connectionState == ConnectionState.waiting) return _loader();
      if (!snap.hasData || snap.data!.docs.isEmpty)
        return _empty('No listings yet', Icons.inventory_2_outlined);
      return Column(children: snap.data!.docs.map(_listingCard).toList());
    },
  );

  Widget _listingCard(QueryDocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final visible = d['visible'] as bool? ?? true;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              d['image'] ?? '',
              width: 76,
              height: 76,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 76,
                height: 76,
                color: AppColors.greenLight,
                child: const Icon(
                  Icons.checkroom_rounded,
                  color: AppColors.greenMid,
                  size: 30,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d['title'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '\$${d['price'] ?? 0}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: AppColors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _pill(
                      d['condition'] ?? 'Good',
                      AppColors.greenLight,
                      AppColors.greenMid,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _miniBtn(
                      'Edit',
                      Icons.edit_outlined,
                      outlined: true,
                      onTap: () {
                        /* TODO */
                      },
                    ),
                    const SizedBox(width: 6),
                    _miniBtn(
                      'Manage',
                      Icons.tune_rounded,
                      outlined: false,
                      onTap: () {
                        /* TODO */
                      },
                    ),
                    const Spacer(),
                    // Toggle listing visibility directly in Firestore
                    Transform.scale(
                      scale: 0.78,
                      child: Switch(
                        value: visible,
                        activeColor: AppColors.green,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (v) => doc.reference.update({'visible': v}),
                      ),
                    ),
                    Text(
                      visible ? 'Visible' : 'Hidden',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: visible ? AppColors.greenMid : AppColors.textSec,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Activity (live Firestore stream) ──────────────────────────────────────
  Widget _buildActivity() => StreamBuilder<QuerySnapshot>(
    stream: _activityQuery.snapshots(),
    builder: (ctx, snap) {
      if (snap.connectionState == ConnectionState.waiting) return _loader();
      if (!snap.hasData || snap.data!.docs.isEmpty)
        return _empty('No recent activity', Icons.notifications_none_rounded);
      return Column(
        children: snap.data!.docs.map((doc) {
          final d = doc.data() as Map<String, dynamic>;
          final isOffer = d['type'] == 'offer';
          return Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF5C6BC0).withOpacity(0.15),
                  backgroundImage: d['buyerAvatar'] != null
                      ? NetworkImage(d['buyerAvatar'])
                      : null,
                  child: d['buyerAvatar'] == null
                      ? Text(
                          (d['buyerName'] ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF5C6BC0),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                          children: [
                            TextSpan(
                              text: '${d['buyerName'] ?? 'Someone'} ',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(text: d['message'] ?? ''),
                          ],
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _timeAgo(d['timestamp']),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSec,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _miniBtn(
                  isOffer ? 'View' : 'Reply',
                  isOffer ? Icons.visibility_outlined : Icons.reply_rounded,
                  outlined: !isOffer,
                  onTap: () {
                    /* TODO */
                  },
                ),
              ],
            ),
          );
        }).toList(),
      );
    },
  );

  // ── Bottom Navigation ─────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    const items = [
      ['Home', Icons.home_outlined, Icons.home_rounded],
      ['Search', Icons.search_outlined, Icons.search_rounded],
      ['Sell', Icons.add_circle_outline, Icons.add_circle_rounded],
      ['Profile', Icons.person_outline, Icons.person_rounded],
      ['Messages', Icons.chat_bubble_outline, Icons.chat_bubble_rounded],
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final active = i == _navIndex;
              // Sell button gets a special circular style
              if (i == 2)
                return GestureDetector(
                  onTap: () => setState(() => _navIndex = i),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      items[i][2] as IconData,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                );
              return GestureDetector(
                onTap: () => setState(() => _navIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: active ? AppColors.greenLight : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        active
                            ? items[i][2] as IconData
                            : items[i][1] as IconData,
                        size: 22,
                        color: active ? AppColors.green : AppColors.textSec,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i][0] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: active ? AppColors.green : AppColors.textSec,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ── Shared Helpers ────────────────────────────────────────────────────────
  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          t,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            fontFamily: 'Georgia',
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            'See all →',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.greenMid,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _statCard(
    IconData icon,
    String label,
    String value,
    Color iconColor,
    Color bg,
  ) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: bg,
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSec),
        ),
      ],
    ),
  );

  Widget _pill(String label, Color bg, Color text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: text),
    ),
  );

  Widget _statPill(String count, String label) => Column(
    children: [
      Text(
        count,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),
      ),
      Text(
        label,
        style: const TextStyle(fontSize: 10, color: AppColors.textSec),
      ),
    ],
  );

  Widget _miniBtn(
    String label,
    IconData icon, {
    required bool outlined,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : AppColors.green,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: outlined ? AppColors.divider : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: outlined ? AppColors.textSec : Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: outlined ? AppColors.textSec : Colors.white,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _loader() => const Padding(
    padding: EdgeInsets.all(24),
    child: Center(child: CircularProgressIndicator(color: AppColors.green)),
  );

  Widget _empty(String msg, IconData icon) => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      children: [
        Icon(icon, size: 48, color: AppColors.greenLight),
        const SizedBox(height: 10),
        Text(
          msg,
          style: const TextStyle(color: AppColors.textSec, fontSize: 13),
        ),
      ],
    ),
  );

  // Converts a Firestore Timestamp to a human-readable "X ago" string
  String _timeAgo(dynamic ts) {
    if (ts == null) return '';
    final dt = (ts as Timestamp).toDate();
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

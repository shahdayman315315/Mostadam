import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // 1. Instances من الفايربيز
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 2. الحصول على بيانات المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  // 3. دالة تسجيل الدخول (Sign In)
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return result.user;
    } catch (e) {
      print("Error in SignIn: ${e.toString()}");
      return null;
    }
  }

  // 4. دالة إنشاء حساب جديد (Sign Up) مع إنشاء الـ Firestore Document
  Future<User?> signUp(String email, String password, {String? name}) async {
    try {
      // أ- إنشاء الحساب في Authentication
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      User? user = result.user;

      if (user != null) {
        // ب- تحديث الاسم في ملف الـ Auth
        if (name != null) {
          await user.updateDisplayName(name);
          await user.reload();
          user = _auth.currentUser;
        }

        // ج- إنشاء الـ Document الأساسي في Firestore بالقيم الافتراضية (Default Settings)
        await _firestore.collection('Users').doc(user!.uid).set({
          'displayName': name ?? 'New User',
          'email': email,
          'photoUrl': '', // قيمة افتراضية فارغة
          'emailNotifications': true,
          'pushNotifications': false,
          'inAppPromotions': true,
          'twoFactorAuth': true,
          'autoApproveOffers': true,
          'language': 'English',
          'currency': 'USD',
          'units': 'Metric',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // د- إضافة بيانات تجريبية في الـ Sub-collections (كما في الصورة)
        
        // 1. إضافة أول بطاقة دفع افتراضية
        await _firestore
            .collection('Users')
            .doc(user.uid)
            .collection('paymentMethods')
            .add({
          'type': 'Visa',
          'last4': '4242',
          'expires': '08/26',
          'primary': true,
        });

        // 2. إضافة يوزر محظور تجريبي (اختياري - عشان تشوفي الشكل في الـ UI)
        await _firestore
            .collection('Users')
            .doc(user.uid)
            .collection('blockedUsers')
            .add({
          'name': 'Omar Rahman',
          'since': 'Joined recently',
        });
      }

      return user;
    } catch (e) {
      print("Error in SignUp: ${e.toString()}");
      return null;
    }
  }

  // 5. دالة تسجيل الخروج (Sign Out)
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Error in SignOut: ${e.toString()}");
    }
  }

  // 6. تتبع حالة المستخدم
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
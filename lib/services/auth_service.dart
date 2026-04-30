import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // 1. بناخد Instance من الفايربيز عشان نقدر نستخدم وظائفه
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 2. دالة الحصول على بيانات المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  // 3. دالة تسجيل الدخول (Sign In)
  // بنستخدم Future لأن العملية بتاخد وقت وبترجع مستخدم أو null
  Future<User?> signIn(String email, String password) async {
    try {
      // بننادي الدالة الجاهزة من الفايربيز وبنديها الإيميل والباسورد
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return result.user; // لو العملية نجحت بنرجع بيانات المستخدم
    } catch (e) {
      print("Error in SignIn: ${e.toString()}"); // لو حصل إيرور بنطبعه في الكونسول
      return null;
    }
  }

  // 4. دالة إنشاء حساب جديد (Sign Up) 
  // تم تعديلها لاستقبال الاسم وحفظه في البروفايل
  Future<User?> signUp(String email, String password, {String? name}) async {
    try {
      // إنشاء الحساب بالإيميل والباسورد
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      User? user = result.user;

      // لو تم إنشاء الحساب بنجاح وعايزين نسيف الاسم
      if (user != null && name != null) {
        await user.updateDisplayName(name);
        await user.reload(); // بنعمل تحديث عشان البيانات الجديدة تظهر
        user = _auth.currentUser; // بنجيب نسخة المستخدم المحدثة
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

  // 6. تتبع حالة المستخدم (هل هو مسجل دخول ولا لا)
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
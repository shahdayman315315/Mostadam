import 'package:firebase_auth/firebase_auth.dart'; // بنستدعي مكتبة الفايربيز اللي نزلناها

class AuthService {
  // 1. بناخد Instance (نسخة) من الفايربيز عشان نقدر نستخدم وظائفه
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 2. دالة تسجيل الدخول (Sign In)
  // بنستخدم Future لأن العملية بتاخد وقت (Asynchronous) وبترجع مستخدم أو null
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

  // 3. دالة إنشاء حساب جديد (Sign Up)
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      return result.user;
    } catch (e) {
      print("Error in SignUp: ${e.toString()}");
      return null;
    }
  }
}
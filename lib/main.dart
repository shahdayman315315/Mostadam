import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // مكتبة الفايربيز
import 'firebase_options.dart'; // الملف السحري اللي عملناه في الـ CMD
import 'screens/login_screen.dart'; // استدعاء شاشة اللوجين
import 'package:mostadam/screens/register_screen.dart'; //استدعاء الريجستر

void main() async {
  // 1. لازم نتأكد إن كل إعدادات فلاتر جاهزة
  WidgetsFlutterBinding.ensureInitialized();

  // 2. تشغيل الفايربيز باستخدام الإعدادات الخاصة بمشروع مستدام
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mostadam - مستدام',
      debugShowCheckedModeBanner: false, // شيل العلامة الحمراء اللي فوق
      // في ملف main.dart
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1DB954), // الأخضر اللي جيبتيه بالظبط
          primary: const Color(0xFF1DB954), // اللون الأساسي للأزرار
          secondary: const Color(0xFFFBF851), // اللون الأصفر للتبديل
          surface: const Color(0xFFFDFCF4), // لون الخلفية الكريمي
        ),
        scaffoldBackgroundColor: const Color(0xFFFDFCF4),
      ),
      // التعديل هنا: خليناه يفتح فوراً على شاشة الريجستر اللي عملناها
      home: const RegisterScreen(),
      // home: const LoginScreen(),
    );
  }
}

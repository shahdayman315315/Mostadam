import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. تعريف الكنترولرز والخدمة
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _auth = AuthService();
  
  bool _isLoading = false; // متغير لحالة التحميل

  final Color creamBg = const Color(0xFFFBF5EA);
  final Color pureWhite = Colors.white;
  final Color mostadamGreen = const Color(0xFF24B759);
  final Color mostadamYellow = const Color(0xFFFBF851);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- الجزء العلوي: اللوجو وصورة المباني ---
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 320,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: mostadamYellow,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.storefront,
                                  size: 20,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Mostadam",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: pureWhite,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "Back",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: Image.asset(
                            'assets/images/loginimage.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 50),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: pureWhite,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                ),
              ],
            ),

            // --- محتوى الفورم ---
            Container(
              color: pureWhite,
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // تابات التبديل
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: pureWhite,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: const Center(
                              child: Text(
                                "Login",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: mostadamYellow,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: const Center(
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Fill in your details to join Mostadam.",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // الحقول
                  const Text("Full Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  _buildTextField("Enter your full name", _nameController),

                  const SizedBox(height: 20),
                  const Text("Email", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  _buildTextField("you@email.com", _emailController),

                  const SizedBox(height: 20),
                  const Text("Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  _buildTextField("Create a strong password", _passwordController, isPassword: true),

                  const SizedBox(height: 30),

                  // زر إنشاء الحساب
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mostadamGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _isLoading ? null : _handleSignUp,
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                    ),
                  ),

                  const SizedBox(height: 25),
                  Center(
                    child: InkWell(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      ),
                      child: const Text(
                        "Already have an account? Login",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة التعامل مع الـ Sign Up
  Future<void> _handleSignUp() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // استدعاء دالة الـ Sign Up من الـ Service مع تمرير الاسم
    var user = await _auth.signUp(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      name: _nameController.text.trim(), // تم إضافة الاسم هنا
    );

    setState(() => _isLoading = false);

    if (user != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully!")),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration failed. Email might be in use or password too weak.")),
        );
      }
    }
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: pureWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black12, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
      ),
    );
  }
}
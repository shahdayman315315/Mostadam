import 'package:flutter/material.dart';
// --- 1. الـ Imports المطلوبة للربط ---
import 'login_screen.dart'; 
import 'onboarding_second_screen.dart'; 

class OnboardingOneScreen extends StatelessWidget {
  const OnboardingOneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color creamBg = const Color(0xFFFBF5EA); 
    final Color lightGreenCard = const Color(0xFFE8F1EB); 
    final Color deepGreen = const Color(0xFF2E7D32); 

    return Scaffold(
      backgroundColor: creamBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. الهيدر (اللوجو وكلمة Skip)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.eco_rounded, size: 24, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 8),
                      const Text(
                        "Mostadam", 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)
                      ),
                    ],
                  ),
                  GestureDetector(
                    // --- تعديل زرار Skip (التخطي) ---
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      "Skip", 
                      style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500)
                    ),
                  ),
                ],
              ),
            ),

            // 2. الصورة
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 300,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/FirstOnboardingScreen.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text("Image not found in assets/images/"));
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 3. الكارت الأخضر
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: lightGreenCard,
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    const Text(
                      "Find Quality Pre-Loved Goods",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26, 
                        fontWeight: FontWeight.bold, 
                        color: Color(0xFF003D2B),
                        height: 1.2
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Discover curated secondhand items inspected for quality – save money while giving products a second life.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: deepGreen.withOpacity(0.8), 
                        fontSize: 15, 
                        height: 1.5
                      ),
                    ),

                    const SizedBox(height: 25),

                    // النقاط (Indicator)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDot(true, deepGreen), 
                        _buildDot(false, Colors.grey),
                        _buildDot(false, Colors.grey),
                      ],
                    ),

                    const SizedBox(height: 35),

                    // --- تعديل زرار Get Started (ينقل للاسكرينة التانية) ---
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: deepGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OnboardingTwoScreen()),
                          );
                        },
                        child: const Text(
                          "Next", 
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // --- تعديل زرار Sign In (ينقل للوجين مباشرة) ---
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        "Sign In", 
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive, Color activeColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 10 : 10,
      decoration: BoxDecoration(
        color: isActive ? activeColor : Colors.grey.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
    );
  }
}
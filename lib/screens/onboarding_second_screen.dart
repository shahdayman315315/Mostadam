import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'onboarding_third_screen.dart'; // فكي الكومنت لما تعملي الشاشة التالتة

class OnboardingTwoScreen extends StatelessWidget {
  const OnboardingTwoScreen({super.key});

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
            // 1. الهيدر (Mostadam & Skip)
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

            // 2. الصورة الجديدة (image_b1df87.png)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 300,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/SecondOnboardingScreen.png', // اسم الصورة التانية عندك
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.eco, size: 100, color: Colors.green),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 3. الكارت الأخضر (العنوان والوصف)
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
                      "Measure Your Sustainability Impact", // العنوان الجديد
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
                      "Track how many kilograms of CO2 and resources you save by buying and listing pre-owned items.", // الوصف الجديد
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: deepGreen.withOpacity(0.8), 
                        fontSize: 15, 
                        height: 1.5
                      ),
                    ),

                    const SizedBox(height: 25),

                    // النقاط (Indicator) - النقطة التانية هي اللي نشطة
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDot(false, deepGreen), 
                        _buildDot(true, deepGreen), // التانية Active
                        _buildDot(false, Colors.grey),
                      ],
                    ),

                    const SizedBox(height: 35),

                    // زرار Continue (ينقل للشاشة التالتة)
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
                            MaterialPageRoute(builder: (context) => const OnboardingThreeScreen()),
                          );
                        },
                        child: const Text(
                          "Continue", 
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // زرار Sign In
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
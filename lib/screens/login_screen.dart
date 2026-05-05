import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Ensure this path matches your project structure
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Controllers to capture email and password input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 2. Instance of our custom Authentication Service
  final AuthService _auth = AuthService();

  // 3. UI State variables
  bool _isLoading = false;
  bool _isPasswordVisible = false; // To toggle password eye icon

  // 4. Mostadam Branding Colors
  final Color creamBg = const Color(0xFFFBF5EA);
  final Color pureWhite = Colors.white;
  final Color mostadamGreen = const Color(0xFF24B759);
  final Color mostadamYellow = const Color(0xFFFBF851);

  @override
  void dispose() {
    // Clean up controllers to avoid memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Core Login Method
  Future<void> _handleLogin() async {
    // Simple Validation
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Calling the signIn method from AuthService
      var user = await _auth.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Welcome back!")));
          // Navigate to Home and clear the login screen from history
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      // Displaying error message from Firebase
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Top Section: Logo & Image Header ---
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: mostadamYellow,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.storefront, size: 20),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Mostadam",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Image.asset(
                          'assets/images/loginimage.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
                // Decorative rounded transition to the form
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

            // --- Form Content Section ---
            Container(
              color: pureWhite,
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tab selector: Login (Active) | Sign Up
                  Row(
                    children: [
                      Expanded(child: _buildTab("Login", isActive: true)),
                      const SizedBox(width: 15),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          ),
                          child: _buildTab("Sign Up", isActive: false),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),
                  const Text(
                    "Welcome back",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Enter your details to manage your sustainable products.",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),

                  const SizedBox(height: 35),

                  // Email Field
                  const Text(
                    "Email Address",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildTextField("you@email.com", _emailController),

                  const SizedBox(height: 20),

                  // Password Field
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Password",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "Forgot?",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    "Enter your password",
                    _passwordController,
                    isPassword: true,
                    isVisible: _isPasswordVisible,
                    toggleVisibility: () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // Main Sign In Button
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
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text(
                              "Sign In",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 50), // Bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI Helper: Tab Style
  Widget _buildTab(String label, {required bool isActive}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? mostadamYellow : pureWhite,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black12),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // UI Helper: Customized Text Field
  Widget _buildTextField(
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? toggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !isVisible,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade50,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: mostadamGreen, width: 1.5),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: toggleVisibility,
              )
            : null,
      ),
    );
  }
}

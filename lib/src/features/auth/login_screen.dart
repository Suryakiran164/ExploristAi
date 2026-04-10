import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLoading = false;
  bool isLoginTab = true; // For the Login/Sign up toggle
  bool obscurePass = true;

  final Color primaryBlue = const Color(0xFF004781);
  final Color inputFill = const Color(0xFFF3F4F6);

  Future<void> _handleAuth() async {
    setState(() => isLoading = true);
    try {
      if (isLoginTab) {
        await ref.read(firebaseAuthProvider).signInWithEmailAndPassword(
            email: emailCtrl.text.trim(), password: passCtrl.text.trim());
      } else {
        await ref.read(firebaseAuthProvider).createUserWithEmailAndPassword(
            email: emailCtrl.text.trim(), password: passCtrl.text.trim());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo & Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.explore, color: primaryBlue, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'Explorist AI',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Welcome Back',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please enter your details to sign in.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Login/Sign up Toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _toggleButton("Login", isLoginTab, () => setState(() => isLoginTab = true)),
                      _toggleButton("Sign up", !isLoginTab, () => setState(() => isLoginTab = false)),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),

                // Form Fields
                _inputLabel("EMAIL ADDRESS"),
                _customField(emailCtrl, "alex@example.com", Icons.email_outlined),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _inputLabel("PASSWORD"),
                    TextButton(
                      onPressed: () {}, 
                      child: const Text("Forgot?", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))
                    ),
                  ],
                ),
                _customField(passCtrl, "••••••••", Icons.lock_outline, isPass: true),
                
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: false, 
                      onChanged: (v) {}, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))
                    ),
                    const Text("Keep me signed in", style: TextStyle(fontSize: 14)),
                  ],
                ),

                const SizedBox(height: 24),
                
                // Main Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: isLoading 
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(
                            color: Colors.white, 
                            strokeWidth: 2.0,
                          ),
                        )
                      : Text(
                          isLoginTab ? 'Sign In' : 'Sign Up', 
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                  ),
                ),
                
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(isLoginTab ? "Don't have an account? " : "Already have an account? "),
                    GestureDetector(
                      onTap: () => setState(() => isLoginTab = !isLoginTab),
                      child: Text(
                        isLoginTab ? "Create Account" : "Login",
                        style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggleButton(String title, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.black : Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _inputLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
      ),
    );
  }

  Widget _customField(TextEditingController ctrl, String hint, IconData icon, {bool isPass = false}) {
    return TextField(
      controller: ctrl,
      obscureText: isPass ? obscurePass : false,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: isPass ? IconButton(
          icon: Icon(obscurePass ? Icons.visibility_off : Icons.visibility, size: 20),
          onPressed: () => setState(() => obscurePass = !obscurePass),
        ) : null,
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}
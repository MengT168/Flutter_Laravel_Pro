import 'package:flutter/material.dart';
import 'package:lara_flutter_pro/screens/dashboard_screen.dart';
import 'package:lara_flutter_pro/screens/main_screen.dart';
import 'package:lara_flutter_pro/screens/register_screen.dart';
import '../auth/auth_service.dart';

class LoginScreen extends StatefulWidget {
  // This parameter tells the screen how it was opened.
  final bool isFromProfile;

  const LoginScreen({super.key, this.isFromProfile = false});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isPasswordVisible = false;
  bool _isLoggingIn = false;

  void _login() async {
    if (_isLoggingIn) return; // Prevent multiple login attempts
    setState(() => _isLoggingIn = true);

    // No need for a separate dialog, we can show a loading indicator on the button

    final Map<String, dynamic>? loginData = await _authService.login(
      _nameController.text,
      _passwordController.text,
    );

    // Re-enable the button
    if (mounted) {
      setState(() => _isLoggingIn = false);
    }

    if (loginData != null) {
      final bool isAdmin = loginData['is_admin'] == true;

      // Highest priority: If the user is an admin, always go to the dashboard.
      if (isAdmin) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
                (Route<dynamic> route) => false, // This removes all previous screens
          );
        }
        return; // Stop the function here
      }

      // If not an admin, check if we came from the profile screen.
      if (widget.isFromProfile) {
        if (mounted) {
          // Go back to the profile screen that is waiting.
          Navigator.pop(context);
        }
      } else {
        // Fallback for a normal user logging in for the first time.
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      }
    } else {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Failed. Please check your credentials.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('assets/images/login.jpg', height: 200),
                const SizedBox(height: 32),
                const Text('Login', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Please Sign in to continue.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 32),
                TextField(
                  controller: _nameController,
                  decoration: _buildInputDecoration('Name', Icons.person_outline),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: _buildInputDecoration('Password', Icons.lock_outline).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoggingIn ? null : _login, // Disable button while logging in
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF1E232C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoggingIn
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Sign in', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?", style: TextStyle(color: Colors.grey)),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                      child: const Text('Sign Up', style: TextStyle(color: Color(0xFF1E232C), fontWeight: FontWeight.bold)),
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

  InputDecoration _buildInputDecoration(String labelText, IconData prefixIcon) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(prefixIcon, color: Colors.grey),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
    );
  }
}
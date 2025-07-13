import 'package:flutter/material.dart';
import 'package:lara_flutter_pro/screens/dashboard_screen.dart';
import 'package:lara_flutter_pro/screens/main_screen.dart';
import 'package:lara_flutter_pro/screens/register_screen.dart';
import '../auth/auth_service.dart';

class LoginScreen extends StatefulWidget {
  /// If true, the screen will pop back on a successful login, returning 'true'.
  /// If false (default), it will navigate to the main app screen.
  final bool isPoppingOnSuccess;

  const LoginScreen({super.key, this.isPoppingOnSuccess = false});

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
    // Prevent multiple clicks while logging in
    if (_isLoggingIn) return;
    setState(() => _isLoggingIn = true);

    final Map<String, dynamic>? userData = await _authService.login(
      _nameController.text,
      _passwordController.text,
    );

    // Re-enable the button after the API call is complete
    if (mounted) {
      setState(() => _isLoggingIn = false);
    }

    if (userData != null) {
      // THE FIX: Correctly check for the boolean 'true'
      final bool isAdmin = userData['is_admin'] == true;

      // Highest priority: If the user is an admin, always go to the dashboard.
      if (isAdmin) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
                (Route<dynamic> route) => false, // This removes all previous screens
          );
        }
        return; // Stop the function here.
      }

      // If not an admin, check how this screen was opened.
      if (widget.isPoppingOnSuccess) {
        if (mounted) {
          // Go back to the screen that opened it (e.g., ProductDetailScreen)
          // and return 'true' to indicate success.
          Navigator.pop(context, true);
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
      if (mounted) {
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
      appBar: AppBar(
        // Only show a back button if this screen was pushed on top of another
        automaticallyImplyLeading: widget.isPoppingOnSuccess,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 32.0),
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
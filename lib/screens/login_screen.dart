import 'package:flutter/material.dart';
import 'package:lara_flutter_pro/screens/dashboard_screen.dart';
import 'package:lara_flutter_pro/screens/main_screen.dart';
import 'package:lara_flutter_pro/screens/register_screen.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final bool isPoppingOnSuccess;
  const LoginScreen({super.key, this.isPoppingOnSuccess = false});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoggingIn = false;
  bool _isFacebookLoggingIn = false; // New state for the Facebook button

  String? _logoUrl;
  bool _isLogoLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLogo();
  }

  Future<void> _fetchLogo() async {
    // No need for setState here, we'll manage with _isLogoLoading
    final authService = context.read<AuthService>();
    final logos = await authService.getActiveLogos();
    if (mounted) {
      setState(() {
        if (logos.isNotEmpty) {
          _logoUrl = logos[0]['thumbnail_url'];
        }
        _isLogoLoading = false;
      });
    }
  }

  // Your existing login method is unchanged
  void _login() async {
    if (_isLoggingIn || _isFacebookLoggingIn) return;
    setState(() => _isLoggingIn = true);

    final authService = context.read<AuthService>();
    final userData = await authService.login(
      _nameController.text,
      _passwordController.text,
    );

    if (mounted) setState(() => _isLoggingIn = false);

    if (userData != null) {
      _handleLoginSuccess(userData);
    } else {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Failed. Please check your credentials.')),
        );
      }
    }
  }

  // void _loginWithFacebook() async {
  //   if (_isFacebookLoggingIn || _isLoggingIn) return;
  //   setState(() => _isFacebookLoggingIn = true);
  //
  //   final authService = context.read<AuthService>();
  //   final userData = await authService.loginWithFacebook();
  //
  //   if (mounted) setState(() => _isFacebookLoggingIn = false);
  //
  //   if (userData != null) {
  //     _handleLoginSuccess(userData);
  //   } else {
  //     if(mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Facebook Login Failed. Please try again.')),
  //       );
  //     }
  //   }
  // }

  void _handleLoginSuccess(Map<String, dynamic> userData) {
    final bool isAdmin = userData['is_admin'] == true;
    if (isAdmin) {
      if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const DashboardScreen()), (route) => false);
    } else {
      if (widget.isPoppingOnSuccess) {
        if (mounted) Navigator.pop(context, true);
      } else {
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
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
      SizedBox(
        height: 200,
        child: _isLogoLoading
            ? const Center(child: CircularProgressIndicator())
            : (_logoUrl != null && _logoUrl!.isNotEmpty)
            ? Image.network(
          _logoUrl!,
          fit: BoxFit.contain,
          errorBuilder: (c, e, s) => Image.asset('assets/images/login.jpg', fit: BoxFit.contain),
        )
            : Image.asset('assets/images/login.jpg', fit: BoxFit.contain),
      ),
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
    onPressed: _isLoggingIn || _isFacebookLoggingIn ? null : _login,
    style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 16),
    backgroundColor: const Color(0xFF1E232C),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    child: _isLoggingIn
    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
        : const Text('Sign in', style: TextStyle(fontSize: 18, color: Colors.white)),
    ),

    // === ADD THE FACEBOOK BUTTON HERE ===
    const SizedBox(height: 16),
    // ElevatedButton.icon(
    // icon: const Icon(Icons.facebook, color: Colors.white),
    // label: _isFacebookLoggingIn
    // ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
    //     : const Text('Login with Facebook', style: TextStyle(fontSize: 18, color: Colors.white)),
    // onPressed: _isLoggingIn || _isFacebookLoggingIn ? null : _loginWithFacebook,
    // style: ElevatedButton.styleFrom(
    // padding: const EdgeInsets.symmetric(vertical: 16),
    // backgroundColor: const Color(0xFF1877F2), // Facebook Blue
    // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    // ),
    // ),
    // =====================================


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

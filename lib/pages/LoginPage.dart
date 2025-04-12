import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _showPassword = false;
  bool _rememberMe = false;
  String? _error;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
        _error = null;
      });

      // Using push instead of pushReplacement to allow back navigation
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.of(context).pushNamed('/location-permission');
      });
    }
  }

  void _handleGoogleSignIn() {
    setState(() {
      _isSubmitting = true;
    });

    // Using push instead of pushReplacement to allow back navigation
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isSubmitting = false;
      });
      Navigator.of(context).pushNamed('/location-permission');
    });
  }

  void _handleBackButton() {
    // Using pushNamed as requested
    Navigator.of(context).pushNamed('/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0E6D2), Color(0xFFD9C9A8)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(top: 20, left: 20, child: _buildBackButton(context)),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildLoginForm(),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(height: 1, color: const Color(0x4DD3D3D3)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.blue.shade100, shape: BoxShape.circle),
          child: const Text('🚌', style: TextStyle(fontSize: 38)),
        ),
        const SizedBox(height: 16),
        const Text(
          'Welcome Back',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
        ),
        const SizedBox(height: 4),
        const Text(
          'Sign in to continue your journey',
          style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _handleBackButton,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.8),
        foregroundColor: const Color.fromARGB(255, 39, 33, 33),
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.2),
      ),
      child: const Icon(Icons.arrow_back, size: 24),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null) _buildErrorMessage(),
            const Text('Email Address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF555555))),
            const SizedBox(height: 8),
            _buildEmailField(),
            const SizedBox(height: 20),
            const Text('Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF555555))),
            const SizedBox(height: 8),
            _buildPasswordField(),
            const SizedBox(height: 16),
            _buildRememberForgotRow(),
            const SizedBox(height: 24),
            _buildLoginButton(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: [
                  Expanded(child: Divider(color: Color(0xFFDDDDDD))),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Or continue with', style: TextStyle(color: Color(0xFF888888), fontSize: 14)),
                  ),
                  Expanded(child: Divider(color: Color(0xFFDDDDDD))),
                ],
              ),
            ),
            _buildGoogleButton(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? ", style: TextStyle(color: Color(0xFF666666))),
                GestureDetector(
                  onTap: () {
                    // Using pushNamed instead of pushReplacementNamed
                    Navigator.of(context).pushNamed('/signup');
                  },
                  child: const Text(
                    'Sign up',
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: Colors.red.shade500, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade500, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(_error!, style: TextStyle(color: Colors.red.shade700, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: _buildInputDecoration(hintText: 'Enter your email', icon: Icons.email_outlined),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter your email';
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_showPassword,
      decoration: _buildInputDecoration(
        hintText: 'Enter your password',
        icon: Icons.lock_outline,
        suffixIcon: IconButton(
          icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: () {
            setState(() {
              _showPassword = !_showPassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter your password';
        return null;
      },
    );
  }

  InputDecoration _buildInputDecoration({required String hintText, required IconData icon, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icon, color: Colors.grey),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.blue, width: 2)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.8),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }

  Widget _buildRememberForgotRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
              activeColor: Colors.blue,
            ),
            const Text('Remember me', style: TextStyle(color: Color(0xFF555555), fontSize: 14)),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed('/forgot-password'),
          child: const Text('Forgot password?', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue.shade500,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
        ),
        child: _isSubmitting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  const Text('Logging in...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ],
              )
            : const Text('Sign In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _handleGoogleSignIn,
        icon: const Icon(FontAwesomeIcons.google, color: Colors.red),
        label: const Text(
          'Sign in with Google',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFDDDDDD)),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}
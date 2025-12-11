import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/auth_service.dart';
import '../services/loading_service.dart';
import '../services/snackbar_service.dart';
import 'sign_up_screen.dart';
import 'main_navigation_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      LoadingService.show(context, message: 'Signing in...');

      final result = await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      LoadingService.hide();

      if (result.success) {
        if (mounted) {
          SnackBarService.showSuccess(context, 'Welcome back!');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
          );
        }
      } else {
        if (mounted) {
          SnackBarService.showError(context, result.errorMessage ?? 'Sign in failed');
        }
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      SnackBarService.showError(context, 'Please enter your email address first');
      return;
    }

    LoadingService.show(context, message: 'Sending reset email...');

    final result = await _authService.sendPasswordResetEmail(email: _emailController.text.trim());

    LoadingService.hide();

    if (result.success) {
      if (mounted) {
        SnackBarService.showSuccess(context, result.message ?? 'Reset email sent');
      }
    } else {
      if (mounted) {
        SnackBarService.showError(context, result.errorMessage ?? 'Failed to send reset email');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Login',
          style: TextStyle(color: Color(0xFF2D2D2D), fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    'Sign in to your account',
                    style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
                  ),
                ),

                const SizedBox(height: 40),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: SvgPicture.asset(
                        'assets/icons/mail.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(Color(0xFF9E9E9E), BlendMode.srcIn),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE91E63)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),

                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF9E9E9E)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off_outlined,
                        color: const Color(0xFF9E9E9E),
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE91E63)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),

                const SizedBox(height: 12),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _resetPassword,
                    child: const Text(
                      'Forgot password ?',
                      style: TextStyle(color: Color(0xFFE91E63), fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Or divider
                const Row(
                  children: [
                    Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Or', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14)),
                    ),
                    Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                  ],
                ),

                const SizedBox(height: 24),

                // Social Sign In
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Sign in via | ', style: TextStyle(color: Color(0xFF757575), fontSize: 14)),
                    TextButton(
                      onPressed: () {
                        SnackBarService.showInfo(context, 'Social login coming soon!');
                      },
                      child: const Text(
                        'social login',
                        style: TextStyle(color: Color(0xFFE91E63), fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "You don't have an account ? ",
                      style: TextStyle(color: Color(0xFF757575), fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        );
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(color: Color(0xFFE91E63), fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

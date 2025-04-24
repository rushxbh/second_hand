import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  AuthPageState createState() => AuthPageState();
}

class AuthPageState extends State<AuthPage> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _ageController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _cityController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = null;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      User? user;
      if (_isLogin) {
        // Login with email and password
        user = await _authService.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        // Sign up with email and password
        user = await _authService.signUp(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _nameController.text.trim(),
            _cityController.text.trim());
      }

      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(
            () => _errorMessage = "Authentication failed. Please try again.");
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      User? user = await _authService.signInWithGoogle();
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        setState(() => _errorMessage = "Google sign-in cancelled.");
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF6A1B9A),
                  const Color(0xFF4527A0),
                ],
              ),
            ),
          ),

          // Background pattern
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -50,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),

                    // App logo and name
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.shop_2,
                          size: 60,
                          color: Color(0xFF6A1B9A),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Thrifty',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _isLogin ? 'Welcome back!' : 'Create your account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Auth form
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Email input
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(color: Colors.grey[700]),
                                prefixIcon: const Icon(Icons.email_outlined,
                                    color: Color(0xFF6A1B9A)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 16),

                            // Password input
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(color: Colors.grey[700]),
                                prefixIcon: const Icon(Icons.lock_outline,
                                    color: Color(0xFF6A1B9A)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              obscureText: true,
                            ),

                            if (!_isLogin) ...[
                              const SizedBox(height: 16),

                              // Name input
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Full Name',
                                  labelStyle:
                                      TextStyle(color: Colors.grey[700]),
                                  prefixIcon: const Icon(Icons.person_outline,
                                      color: Color(0xFF6A1B9A)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                validator: (value) =>
                                    value!.isEmpty ? 'Enter your name' : null,
                              ),

                              const SizedBox(height: 16),

                              // City input
                              TextFormField(
                                controller: _cityController,
                                decoration: InputDecoration(
                                  labelText: 'City',
                                  labelStyle:
                                      TextStyle(color: Colors.grey[700]),
                                  prefixIcon: const Icon(Icons.location_city,
                                      color: Color(0xFF6A1B9A)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                validator: (value) =>
                                    value!.isEmpty ? 'Enter your city' : null,
                              ),

                              const SizedBox(height: 16),

                              // Age input
                              TextFormField(
                                controller: _ageController,
                                decoration: InputDecoration(
                                  labelText: 'Age',
                                  labelStyle:
                                      TextStyle(color: Colors.grey[700]),
                                  prefixIcon: const Icon(Icons.cake_outlined,
                                      color: Color(0xFF6A1B9A)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value!.isEmpty ||
                                      int.tryParse(value) == null) {
                                    return 'Enter a valid age';
                                  }
                                  return null;
                                },
                              ),
                            ],

                            if (_errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ],

                            const SizedBox(height: 24),

                            // Login/Sign up button
                            ElevatedButton(
                              onPressed: _isLoading ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6A1B9A),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Text(
                                      _isLogin ? 'Log In' : 'Create Account',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),

                            const SizedBox(height: 16),

                            // Sign in with Google button
                            OutlinedButton.icon(
                              onPressed:
                                  _isLoading ? null : _handleGoogleSignIn,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Colors.white,
                              ),
                              icon: Image.network(
                                'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                height: 16,
                                width: 16,
                              ),
                              label: const Text(
                                'Continue with Google',
                                style: TextStyle(
                                  color: Color(0xFF424242),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Toggle login/signup mode
                    TextButton(
                      onPressed: _toggleAuthMode,
                      child: Text(
                        _isLogin
                            ? 'Don\'t have an account? Sign up'
                            : 'Already have an account? Log in',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

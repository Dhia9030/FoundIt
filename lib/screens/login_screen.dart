import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foundita/providers/login_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> _loginWithEmail(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final loginProvider = Provider.of<LoginProvider>(context, listen: false);

    try {
      await loginProvider.loginWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        });
      }
    } catch (e) {
      // Error is handled by the provider, displayed via Consumer
    }
  }

  Future<void> _loginWithGoogle(BuildContext context) async {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);

    try {
      await loginProvider.loginWithGoogle();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google login successful!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        });
      }
    } catch (e) {
      // Error is handled by the provider
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set a consistent background color
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60), // Increased space at the top
                  // App Logo or Title
                  Text(
                    'FoundIt',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          letterSpacing: 1.5, // Added letter spacing for style
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your go-to app for lost & found items',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 60), // Increased space before fields
                  // Email Field
                  _buildEmailField(),
                  const SizedBox(height: 20), // Increased space between fields
                  // Password Field
                  _buildPasswordField(),
                  const SizedBox(height: 32), // Adjusted space after password field
                  // Error or Loading Indicator
                  Consumer<LoginProvider>(
                    builder: (context, loginProvider, _) {
                      return Column(
                        children: [
                          if (loginProvider.error != null)
                            _buildErrorMessage(loginProvider.error!),
                          if (loginProvider.isLoading)
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                            )
                          else
                            _buildLoginButton(context),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24), // Space before social buttons
                  // Social Login Buttons
                  _buildSocialLoginButtons(context),
                  const SizedBox(height: 32), // Space before register link
                  // Register Link
                  _buildRegisterButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Enter your email address',
        prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // Remove default border
        ),
        enabledBorder: OutlineInputBorder( // Custom enabled border
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder( // Custom focused border
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50], // Lighter fill color
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Invalid email format';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      obscureText: _obscurePassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters long';
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor, // Use primary color for button
          foregroundColor: Colors.white, // Text color
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5, // Add a subtle shadow
        ),
        onPressed: () => _loginWithEmail(context),
        child: const Text(
          'Login',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSocialLoginButtons(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Or log in with',
            style: TextStyle(color: Colors.grey[700], fontSize: 15),
          ),
        ),
        Center( // Center the single Google button
          child: SizedBox( // Give the button a defined width
            width: MediaQuery.of(context).size.width * 0.7, // Example: 70% of screen width
            child: OutlinedButton.icon(
              onPressed: () => _loginWithGoogle(context),
              icon: Image.asset(
                'assets/images/google_logo.png', // Add Google logo in assets
                height: 24,
              ),
              label: const Text(
                'Google',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.grey.shade300, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red[50], // Lighter red for error background
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200), // Subtle red border
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, '/register');
      },
      child: RichText(
        text: TextSpan(
          text: 'Don\'t have an account? ',
          style: TextStyle(color: Colors.grey[700], fontSize: 16),
          children: [
            TextSpan(
              text: 'Sign Up',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
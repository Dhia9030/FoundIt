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
            content: Text('Connexion réussie !'),
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
            content: Text('Connexion Google réussie !'),
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

  Future<void> _loginWithFacebook(BuildContext context) async {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);

    try {
      await loginProvider.loginWithFacebook();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connexion Facebook réussie !'),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // App Logo or Title
                  Text(
                    'Foundita',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  const SizedBox(height: 40),
                  // Email Field
                  _buildEmailField(),
                  const SizedBox(height: 16),
                  // Password Field
                  _buildPasswordField(),
                  const SizedBox(height: 8),
                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement password reset navigation
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fonctionnalité de réinitialisation à venir'),
                          ),
                        );
                      },
                      child: const Text('Mot de passe oublié ?'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Error or Loading Indicator
                  Consumer<LoginProvider>(
                    builder: (context, loginProvider, _) {
                      return Column(
                        children: [
                          if (loginProvider.error != null)
                            _buildErrorMessage(loginProvider.error!),
                          if (loginProvider.isLoading)
                            const CircularProgressIndicator()
                          else
                            _buildLoginButton(context),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Social Login Buttons
                  _buildSocialLoginButtons(context),
                  const SizedBox(height: 24),
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
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer votre email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Email invalide';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Mot de passe',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      obscureText: _obscurePassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer votre mot de passe';
        }
        if (value.length < 6) {
          return 'Le mot de passe doit faire au moins 6 caractères';
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => _loginWithEmail(context),
        child: const Text(
          'Se connecter',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSocialLoginButtons(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Ou connectez-vous avec',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google Button
            OutlinedButton.icon(
              onPressed: () => _loginWithGoogle(context),
              icon: Image.asset(
                'assets/images/google_logo.png', // Add Google logo in assets
                height: 24,
              ),
              label: const Text('Google'),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Facebook Button
            OutlinedButton.icon(
              onPressed: () => _loginWithFacebook(context),
              icon: Image.asset(
                'assets/images/facebook_logo.png', // Add Facebook logo in assets
                height: 24,
              ),
              label: const Text('Facebook'),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
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
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
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
      child: const Text(
        'Pas de compte ? Inscrivez-vous',
        style: TextStyle(fontSize: 16),
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
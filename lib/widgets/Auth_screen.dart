import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../models/theme_provider.dart';

// Base Auth Screen (Common elements for both forms)
class AuthScreen extends StatelessWidget {
  final String title;
  final Widget formContent;
  final String footerText;
  final String footerActionText;
  final VoidCallback onFooterAction;

  const AuthScreen({
    required this.title,
    required this.formContent,
    required this.footerText,
    required this.footerActionText,
    required this.onFooterAction,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final darkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: darkMode ? const Color(0xFF1B262C) : const Color(0xFFD1ECFF),
      body: Stack(
        children: [
          // Background Blobs
          Positioned(
            top: -50,
            right: -50,
            child: Image.asset(
              darkMode ? 'assets/images/blob-auth-1.png' : 'assets/images/blob-auth-light-1.png',
              width: 200,
              height: 200,
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Image.asset(
              darkMode ? 'assets/images/blob-auth-2.png' : 'assets/images/blob-auth-light-2.png',
              width: 300,
              height: 300,
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 80),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    color: darkMode ? Colors.white : const Color(0xFF415FCC),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                formContent,
                const SizedBox(height: 30),
                _buildAuthFooter(darkMode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthFooter(bool darkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          footerText,
          style: TextStyle(
            fontFamily: 'Montserrat',
            color: darkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        TextButton(
          onPressed: onFooterAction,
          child: Text(
            footerActionText,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              color: const Color(0xFF7996FF),
            ),
          ),
        ),
      ],
    );
  }
}

// Sign In Form
class SignInForm extends StatefulWidget {
  const SignInForm({Key? key}) : super(key: key);

  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final darkMode = themeProvider.isDarkMode;

    return AuthScreen(
      title: 'Welcome Back!',
      formContent: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildAuthField(
              label: 'Email',
              controller: _emailController,
              icon: 'assets/icons/email.svg',
              darkMode: darkMode,
              validator: (value) => value!.contains('@') ? null : 'Enter valid email',
            ),
            const SizedBox(height: 20),
            _buildPasswordField(darkMode),
            const SizedBox(height: 30),
            _buildAuthButton(
              text: 'Sign In',
              onPressed: _handleSignIn,
              darkMode: darkMode,
            ),
          ],
        ),
      ),
      footerText: "Don't have an account?",
      footerActionText: "Sign Up",
      onFooterAction: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignUpForm()),
      ),
    );
  }

  Widget _buildPasswordField(bool darkMode) {
    return TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: TextStyle(
        fontFamily: 'Montserrat',
        color: darkMode ? Colors.white : Colors.black,
    ),
    decoration: InputDecoration(
    labelText: 'Password',
    labelStyle: TextStyle(
    fontFamily: 'Montserrat',
    color: darkMode ? Colors.white70 : Colors.black54,
    ),
    prefixIcon: Padding(
    padding: const EdgeInsets.all(12.0),
    child: SvgPicture.asset(
    'assets/icons/lock.svg',
    width: 24,
    height: 24,
    color: darkMode ? Colors.white : const Color(0xFF415FCC),
    ),
    ),
    suffixIcon: IconButton(
    icon: Icon(
    _obscurePassword ? Icons.visibility_off : Icons.visibility,
    color: darkMode ? Colors.white70 : Colors.black54,
    ),
    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
    ),
    filled: true,
    fillColor: darkMode ? const Color(0xFF0F4C75) : Colors.white,
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: const BorderSide(
    color: Color(0xFF7996FF),
    width: 2,
    ),
    ),
    ));
  }

  Widget _buildAuthButton({required String text, required VoidCallback onPressed, required bool darkMode}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          colors: [Color(0xFF7996FF), Color(0xFF415FCC)],
        ),
        boxShadow: [
          BoxShadow(
            color: darkMode ? Colors.black54 : const Color(0x3F535353),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
                color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _handleSignIn() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signing in...', style: TextStyle(fontFamily: 'Montserrat')),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// Sign Up Form
class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final darkMode = themeProvider.isDarkMode;

    return AuthScreen(
      title: 'Create Account',
      formContent: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildAuthField(
              label: 'Full Name',
              controller: _nameController,
              icon: 'assets/icons/user.svg',
              darkMode: darkMode,
              validator: (value) => value!.isEmpty ? 'Enter your name' : null,
            ),
            const SizedBox(height: 20),
            _buildAuthField(
              label: 'Email',
              controller: _emailController,
              icon: 'assets/icons/email.svg',
              darkMode: darkMode,
              validator: (value) => value!.contains('@') ? null : 'Enter valid email',
            ),
            const SizedBox(height: 20),
            _buildAuthField(
              label: 'Phone Number',
              controller: _phoneController,
              icon: 'assets/icons/phone.svg',
              darkMode: darkMode,
              validator: (value) => value!.length >= 8 ? null : 'Enter valid number',
            ),
            const SizedBox(height: 20),
            _buildPasswordField(darkMode),
            const SizedBox(height: 30),
            _buildAuthButton(
              text: 'Sign Up',
              onPressed: _handleSignUp,
              darkMode: darkMode,
            ),
          ],
        ),
      ),
      footerText: "Already have an account?",
      footerActionText: "Sign In",
      onFooterAction: () => Navigator.pop(context),
    );
  }

  Widget _buildPasswordField(bool darkMode) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: TextStyle(
        fontFamily: 'Montserrat',
        color: darkMode ? Colors.white : Colors.black,
      ),
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: TextStyle(
          fontFamily: 'Montserrat',
          color: darkMode ? Colors.white70 : Colors.black54,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            'assets/icons/lock.svg',
            width: 24,
            height: 24,
            color: darkMode ? Colors.white : const Color(0xFF415FCC),
          ),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: darkMode ? Colors.white70 : Colors.black54,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        filled: true,
        fillColor: darkMode ? const Color(0xFF0F4C75) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFF7996FF),
            width: 2,
          ),
        ),
      ),
      validator: (value) => value!.length >= 6 ? null : 'Minimum 6 characters',
    );
  }

  Widget _buildAuthButton({required String text, required VoidCallback onPressed, required bool darkMode}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          colors: [Color(0xFF7996FF), Color(0xFF415FCC)],
        ),
        boxShadow: [
          BoxShadow(
            color: darkMode ? Colors.black54 : const Color(0x3F535353),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
                color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Creating account...', style: TextStyle(fontFamily: 'Montserrat')),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}

Widget _buildAuthField({
  required String label,
  required TextEditingController controller,
  required String icon,
  required bool darkMode,
  required String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    style: TextStyle(
      fontFamily: 'Montserrat',
      color: darkMode ? Colors.white : Colors.black,
    ),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontFamily: 'Montserrat',
        color: darkMode ? Colors.white70 : Colors.black54,
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SvgPicture.asset(
          icon,
          width: 24,
          height: 24,
          color: darkMode ? Colors.white : const Color(0xFF415FCC),
        ),
      ),
      filled: true,
      fillColor: darkMode ? const Color(0xFF0F4C75) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFF7996FF),
          width: 2,
        ),
      ),
    ),
    validator: validator,
  );
}
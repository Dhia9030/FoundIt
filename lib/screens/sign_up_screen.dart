import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foundita/providers/login_provider.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  String? _successMessage;

  Future<void> _registerWithEmail(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final loginProvider = Provider.of<LoginProvider>(context, listen: false);

    try {
      await loginProvider.registerWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );

      setState(() {
        _successMessage = 'Inscription réussie !';
      });

      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/home');
      });

    } catch (e) {
      // Errors handled by provider
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inscription')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_successMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _successMessage!,
                      style: TextStyle(color: Colors.green, fontSize: 16),
                    ),
                  ),

                Consumer<LoginProvider>(
                  builder: (context, loginProvider, _) {
                    return Column(
                      children: [
                        if (loginProvider.error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              loginProvider.error!,
                              style: TextStyle(color: Colors.red, fontSize: 16),
                            ),
                          ),

                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Nom complet',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre nom';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 20),

                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
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
                        ),

                        SizedBox(height: 20),

                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un mot de passe';
                            }
                            if (value.length < 6) {
                              return 'Le mot de passe doit faire au moins 6 caractères';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 20),

                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirmer le mot de passe',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Les mots de passe ne correspondent pas';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 30),

                        if (loginProvider.isLoading)
                          CircularProgressIndicator()
                        else
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 15),
                              ),
                              onPressed: () => _registerWithEmail(context),
                              child: Text(
                                'S\'inscrire',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),

                        SizedBox(height: 20),

                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: Text('Déjà un compte ? Connectez-vous ici'),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
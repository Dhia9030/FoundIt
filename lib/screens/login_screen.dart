import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foundita/providers/login_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _successMessage;

  Future<void> _loginWithEmail(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    
    try {
      await loginProvider.loginWithEmailAndPassword(
        email: _emailController.text.trim(), // .trim() pour supprimer les espaces
        password: _passwordController.text,
      );
      
      // Si la connexion réussit, afficher un message et naviguer si nécessaire
      setState(() {
        _successMessage = 'Connexion réussie !';
      });

      // Exemple : Redirection après 2 secondes
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/home'); // Remplacez par votre route
      });

    } catch (e) {
      // L'erreur est déjà gérée par le LoginProvider, pas besoin de setState ici
      // Le Consumer affichera automatiquement loginProvider.error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView( // Pour éviter les overflow sur petits écrans
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
                              return 'Veuillez entrer votre mot de passe';
                            }
                            if (value.length < 6) {
                              return 'Le mot de passe doit faire au moins 6 caractères';
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
                              onPressed: () => _loginWithEmail(context),
                              child: Text(
                                'Se connecter',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),

                        SizedBox(height: 20),

                        TextButton(
                          onPressed: () {
                            // Navigation vers l'écran d'inscription
                            Navigator.pushNamed(context, '/register');
                          },
                          child: Text('Pas de compte ? Inscrivez-vous'),
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
    super.dispose();
  }
}
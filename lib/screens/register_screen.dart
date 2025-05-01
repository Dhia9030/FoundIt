import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foundita/providers/registerprovider.dart';

// class RegistrationScreen extends StatefulWidget {
//   @override
//   _RegistrationScreenState createState() => _RegistrationScreenState();
// }
//
// class _RegistrationScreenState extends State<RegistrationScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _nameController = TextEditingController();
//   final _phoneController = TextEditingController();
//
//   Future<void> _register(BuildContext context) async {
//     if (!_formKey.currentState!.validate()) return;
//
//     final registerProvider = Provider.of<RegisterProvider>(context, listen: false);
//
//     try {
//       await registerProvider.registerWithEmailAndPassword(
//         email: _emailController.text,
//         password: _passwordController.text,
//         name: _nameController.text,
//         phoneNumber: _phoneController.text,
//       );
//
//       // Navigate to home screen after successful registration
//       Navigator.pushReplacementNamed(context, '/home');
//     } catch (e) {
//       // Error is already handled in the provider, no need to do anything here
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Register')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Consumer<RegisterProvider>(
//           builder: (context, registerProvider, child) {
//             return Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   if (registerProvider.error != null)
//                     Text(
//                       registerProvider.error!,
//                       style: TextStyle(color: Colors.red),
//                     ),
//                   TextFormField(
//                     controller: _nameController,
//                     decoration: InputDecoration(labelText: 'Full Name'),
//                     validator: (value) => value!.isEmpty ? 'Required' : null,
//                   ),
//                   TextFormField(
//                     controller: _emailController,
//                     decoration: InputDecoration(labelText: 'Email'),
//                     validator: (value) =>
//                         !value!.contains('@') ? 'Enter a valid email' : null,
//                   ),
//                   TextFormField(
//                     controller: _passwordController,
//                     decoration: InputDecoration(labelText: 'Password'),
//                     obscureText: true,
//                     validator: (value) =>
//                         value!.length < 6 ? 'Minimum 6 characters' : null,
//                   ),
//                   TextFormField(
//                     controller: _phoneController,
//                     decoration: InputDecoration(labelText: 'Phone Number'),
//                     validator: (value) => value!.isEmpty ? 'Required' : null,
//                   ),
//                   SizedBox(height: 20),
//                   registerProvider.isLoading
//                       ? CircularProgressIndicator()
//                       : ElevatedButton(
//                           onPressed: () => _register(context),
//                           child: Text('Register'),
//                         ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }


class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _register(BuildContext context) async {
    print(context);
    // if (!_formKey.currentState!.validate()) return;
    //
    // final registerProvider =
    // Provider.of<RegisterProvider>(context, listen: false);
    //
    // try {
    //   await registerProvider.registerWithEmailAndPassword(
    //     email: _emailController.text.trim(),
    //     password: _passwordController.text.trim(),
    //     name: _nameController.text.trim(),
    //     phoneNumber: _phoneController.text.trim(),
    //   );
    //
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //         content: Text('Inscription réussie! Bienvenue!'),
    //         backgroundColor: Colors.green,
    //         duration: Duration(seconds: 2),
    //       ),
    //     );
    //
    //     Future.delayed(const Duration(seconds: 2), () {
    //       if (mounted) {
    //         Navigator.pushReplacementNamed(context, '/home');
    //       }
    //     });
    //   }
    // } catch (e) {
    //   // Error handled by provider
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<RegisterProvider>(
            builder: (context, registerProvider, _) {
              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (registerProvider.error != null)
                        _buildErrorMessage(registerProvider.error!),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nom complet',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Veuillez entrer votre nom'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                        !value!.contains('@') ? 'Email invalide' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(() {
                              _obscurePassword = !_obscurePassword;
                            }),
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value!.length < 6) {
                            return 'Minimum 6 caractères';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirmer le mot de passe',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(() {
                              _obscureConfirmPassword =
                              !_obscureConfirmPassword;
                            }),
                          ),
                        ),
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Les mots de passe ne correspondent pas';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Numéro de téléphone',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value!.isEmpty) return 'Champ requis';
                          // Basic phone number validation (adjust as needed)
                          if (!RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$')
                              .hasMatch(value)) {
                            return 'Numéro invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: registerProvider.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () => _register(context),
                          child: const Text('S\'inscrire'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Déjà un compte? Connectez-vous'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
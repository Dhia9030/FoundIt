import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foundita/providers/registerprovider.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  Future<void> _register(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final registerProvider = Provider.of<RegisterProvider>(context, listen: false);
    
    try {
      await registerProvider.registerWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        phoneNumber: _phoneController.text,
      );

      // Navigate to home screen after successful registration
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      // Error is already handled in the provider, no need to do anything here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<RegisterProvider>(
          builder: (context, registerProvider, child) {
            return Form(
              key: _formKey,
              child: Column(
                children: [
                  if (registerProvider.error != null)
                    Text(
                      registerProvider.error!,
                      style: TextStyle(color: Colors.red),
                    ),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Full Name'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    validator: (value) =>
                        !value!.contains('@') ? 'Enter a valid email' : null,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) =>
                        value!.length < 6 ? 'Minimum 6 characters' : null,
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: 'Phone Number'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: 20),
                  registerProvider.isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () => _register(context),
                          child: Text('Register'),
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

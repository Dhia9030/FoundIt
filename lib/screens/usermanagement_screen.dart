import 'package:flutter/material.dart';
import 'package:foundita/providers/usermanagement_provider.dart';
import 'package:provider/provider.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Force le chargement des utilisateurs au démarrage de l'écran
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserManagementProvider>(context, listen: false).loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des Utilisateurs')),
      body: Consumer<UserManagementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Erreur: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadUsers(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (provider.users.isEmpty) {
            return const Center(
              child: Text('Aucun utilisateur trouvé'),
            );
          }

          return ListView.builder(
            itemCount: provider.users.length,
            itemBuilder: (context, index) {
              final user = provider.users[index];
              return ListTile(
                title: Text(user.name),
                subtitle: Text(user.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(user.isBanned ? 'Banni' : 'Actif'),
                    Switch(
                      value: !user.isBanned,
                      onChanged: (value) async {
                        if (value) {
                          await provider.unbanUser(user.userId!);
                        } else {
                          await provider.banUser(user.userId!);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Provider.of<UserManagementProvider>(context, listen: false).loadUsers(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
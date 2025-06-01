import 'package:flutter/material.dart';
import 'package:foundita/providers/usermanagement_provider.dart';
import 'package:foundita/providers/login_provider.dart';
import 'package:foundita/models/administrator.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loginProvider = Provider.of<LoginProvider>(context, listen: false);
      if (loginProvider.currentAccountHolder is Administrator) {
        Provider.of<UserManagementProvider>(context, listen: false).loadUsers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LoginProvider, UserManagementProvider>(
      builder: (context, loginProvider, userManagementProvider, child) {
        if (loginProvider.currentAccountHolder == null || !(loginProvider.currentAccountHolder is Administrator)) {
          return Scaffold(
            appBar: AppBar(title: const Text('Access Denied')),
            body: const Center(
              child: Text('You do not have permission to access this page.', style: TextStyle(fontSize: 18)),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Gestion des Utilisateurs')),
          body: Builder(
            builder: (context) {
              if (userManagementProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (userManagementProvider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Erreur: ${userManagementProvider.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => userManagementProvider.loadUsers(),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                );
              }

              if (userManagementProvider.users.isEmpty) {
                return const Center(
                  child: Text('Aucun utilisateur trouvé'),
                );
              }

              return ListView.builder(
                itemCount: userManagementProvider.users.length,
                itemBuilder: (context, index) {
                  final user = userManagementProvider.users[index];
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
                              await userManagementProvider.unbanUser(user.userId!);
                            } else {
                              await userManagementProvider.banUser(user.userId!);
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
            onPressed: () => userManagementProvider.loadUsers(),
            child: const Icon(Icons.refresh),
          ),
        );
      },
    );
  }
}
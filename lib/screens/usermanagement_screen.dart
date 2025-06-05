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
      // Load users only if the current account holder is an Administrator
      if (loginProvider.currentAccountHolder is Administrator) {
        Provider.of<UserManagementProvider>(context, listen: false).loadUsers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LoginProvider, UserManagementProvider>(
      builder: (context, loginProvider, userManagementProvider, child) {
        // Display "Access Denied" if the user is not an administrator
        if (loginProvider.currentAccountHolder == null || !(loginProvider.currentAccountHolder is Administrator)) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Access Denied', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.redAccent, // Strong color for denial
              centerTitle: true,
            ),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 100, // Larger icon
                      color: Colors.grey,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'You do not have permission to access this page.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, color: Colors.black87, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Please log in with an administrator account.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Main User Management Screen for Administrators
        return Scaffold(
          appBar: AppBar(
            title: const Text('User Management', style: TextStyle(color: Colors.white)),
            backgroundColor: Theme.of(context).primaryColor,
            centerTitle: true,
            elevation: 4, // Add a subtle shadow
            // Optionally add actions like search or filters here
          ),
          body: RefreshIndicator( // Allows pull-to-refresh
            onRefresh: () => userManagementProvider.loadUsers(),
            child: Builder(
              builder: (context) {
                if (userManagementProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (userManagementProvider.error != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 80, // Larger error icon
                            color: Colors.redAccent,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Error: ${userManagementProvider.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18, color: Colors.redAccent, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton.icon(
                            onPressed: () => userManagementProvider.loadUsers(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry', style: TextStyle(fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (userManagementProvider.users.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off_outlined,
                            size: 100, // Larger icon
                            color: Colors.grey,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'No users found.',
                            style: TextStyle(fontSize: 20, color: Colors.black87, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Pull down to refresh or tap the button below.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12.0), // Increased padding
                  itemCount: userManagementProvider.users.length,
                  itemBuilder: (context, index) {
                    final user = userManagementProvider.users[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                      elevation: 5, // Slightly more elevation
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0), // More rounded corners
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0), // Increased padding
                        leading: CircleAvatar(
                          backgroundColor: user.isBanned ? Colors.redAccent : Colors.green,
                          radius: 24, // Slightly larger avatar
                          child: Icon(user.isBanned ? Icons.block : Icons.person, color: Colors.white, size: 28),
                        ),
                        title: Text(
                          user.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        subtitle: Text(
                          user.email,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              user.isBanned ? 'Banned' : 'Active',
                              style: TextStyle(
                                color: user.isBanned ? Colors.red : Colors.green[700], // Deeper green for active
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Switch(
                              value: !user.isBanned, // Switch is ON if user is NOT banned (Active)
                              onChanged: (value) async {
                                if (value) {
                                  // If switch is turned ON, unban the user
                                  await userManagementProvider.unbanUser(user.userId!);
                                } else {
                                  // If switch is turned OFF, ban the user
                                  await userManagementProvider.banUser(user.userId!);
                                }
                              },
                              activeColor: Colors.green,
                              inactiveThumbColor: Colors.redAccent,
                              inactiveTrackColor: Colors.redAccent.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => userManagementProvider.loadUsers(),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Users'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white, // Ensure text/icon is white
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // More pill-shaped
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Center the FAB
        );
      },
    );
  }
}
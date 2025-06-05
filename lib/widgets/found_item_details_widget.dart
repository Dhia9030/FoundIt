import 'package:flutter/material.dart';
import 'package:foundita/models/found_item.dart';
import 'package:foundita/services/usermanagement_service.dart';
import 'package:foundita/widgets/image_widget.dart';
import 'package:intl/intl.dart';
import 'package:foundita/models/user.dart' as app_user;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // <--- ADD THIS IMPORT
import 'package:foundita/screens/chat_screen.dart'; // <--- ADD THIS IMPORT

class FoundItemDetailsScreen extends StatefulWidget {
  final FoundItem item;

  const FoundItemDetailsScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<FoundItemDetailsScreen> createState() => _FoundItemDetailsScreenState();
}

class _FoundItemDetailsScreenState extends State<FoundItemDetailsScreen> {
  final UserManagementService _userService = UserManagementService();
  app_user.User? _reporter;
  bool _isLoadingUser = true;
  String? _userError;

  @override
  void initState() {
    super.initState();
    _fetchReporterDetails();
  }

  Future<void> _fetchReporterDetails() async {
    setState(() {
      _isLoadingUser = true;
      _userError = null;
    });
    try {
      final user = await _userService.getUserById(widget.item.userId);
      setState(() {
        _reporter = user;
        _isLoadingUser = false;
      });
    } catch (e) {
      setState(() {
        _userError = 'Failed to load reporter details: $e';
        _isLoadingUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user's ID
    final currentUserId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    // Check if the current user is the one who reported the item
    final isCurrentUserReporter = currentUserId == widget.item.userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.item.itemName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            if (widget.item.photo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 250, // Added a height for consistent image display
                  child: ImageFromBackend(blobName: widget.item.photo, fit: BoxFit.cover),
                ),
              ),
            Text(
              'Description:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(widget.item.description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 10),
            Text(
              'Category:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(widget.item.type.toString().split('.').last.toUpperCase(),
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 10),
            Text(
              'Color:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(widget.item.color, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 10),
            Text(
              'Found Date:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.item.foundDate),
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 10),
            Text(
              'Reported Date:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.item.date),
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 10),
            Text(
              'Reporter:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (_isLoadingUser)
              const CircularProgressIndicator()
            else if (_userError != null)
              Text(_userError!, style: const TextStyle(color: Colors.red))
            else if (_reporter != null && _reporter!.name != null)
              Text(_reporter!.name!, style: Theme.of(context).textTheme.bodyLarge)
            else
              Text('Reporter information not available', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),

            // --- ADD THIS BLOCK ---
            (currentUserId != null && !isCurrentUserReporter)
                ? Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to the ChatScreen, passing the reporter's userId
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(otherUserId: widget.item.userId),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat),
                        label: const Text('Chat with Reporter'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50), // Make button wide
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16), // Space after the button
                    ],
                  )
                : (currentUserId != null && isCurrentUserReporter)
                    ? Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          'You reported this item.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          'Log in to chat with the reporter.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      ),
            // --- END ADDITION ---

            const SizedBox(height: 16), // Final spacing
          ],
        ),
      ),
    );
  }
}
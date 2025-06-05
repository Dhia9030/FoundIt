import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/conversation_provider.dart';

class ChatScreen extends StatefulWidget {
  // Changed to StatefulWidget
  final String otherUserId;

  const ChatScreen({super.key, required this.otherUserId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController =
      TextEditingController(); // Controller for text input

  @override
  void initState() {
    super.initState();
    // Initialize chat on first load
    // The Provider will be initialized in build, so this is the correct place to call startChat.
    // We get the provider with listen: false because we don't need to rebuild _this_ widget immediately
    // based on provider changes triggered by startChat. The StreamBuilder will react to _currentChatId.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<ConversationProvider>(context, listen: false);
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;
      provider.startChat(currentUserId, widget.otherUserId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose(); // Dispose the controller
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty)
      return; // Don't send empty messages

    final provider = Provider.of<ConversationProvider>(context, listen: false);
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    provider.sendMessage(_messageController.text.trim(), currentUserId);
    _messageController.clear(); // Clear input field after sending
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    // Listen to the provider to react when _currentChatId changes
    final provider =
        Provider.of<ConversationProvider>(context); // default listen: true

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            // Conditionally build StreamBuilder only when currentChatId is available
            child: provider.currentChatId == null ||
                    provider.currentChatId!.isEmpty
                ? const Center(
                    child:
                        CircularProgressIndicator()) // Show loading until chat ID is set
                : StreamBuilder<QuerySnapshot>(
                    stream: provider.messages,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        print(
                            'Chat stream error: ${snapshot.error}'); // Log errors
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text('No messages yet. Start chatting!'));
                      }
                      final messages = snapshot.data!.docs;
                      return ListView.builder(
                        reverse: true, // Show latest messages at the bottom
                        itemCount: messages.length,
                        itemBuilder: (ctx, index) {
                          final msg = messages[index];
                          final isMe = msg['senderId'] == currentUserId;
                          return Align(
                            // Align messages to left/right
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    isMe ? Colors.blueAccent : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                msg['content'],
                                style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController, // Assign controller
                    decoration:
                        const InputDecoration(hintText: 'Type a message'),
                    onSubmitted: (_) => _sendMessage(), // Use _sendMessage
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage, // Use _sendMessage
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

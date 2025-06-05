import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/conversation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/conversation_provider.dart';

class ChatScreen extends StatelessWidget {
  final String otherUserId;

  const ChatScreen({super.key, required this.otherUserId});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final provider = Provider.of<ConversationProvider>(context, listen: false);

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final themeProvider = Provider.of<ThemeProvider>(context);
    // final darkMode = themeProvider.isDarkMode;
    final conversationProvider = Provider.of<ConversationProvider>(context);
    // Initialize chat on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.startChat(currentUserId, otherUserId);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: provider.messages,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (ctx, index) {
                    final msg = messages[index];
                    return ListTile(
                      title: Text(msg['content']),
                      subtitle: Text(msg['senderId'] == currentUserId
                          ? 'You'
                          : 'Other'),
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
                    decoration: const InputDecoration(hintText: 'Type a message'),
                    onSubmitted: (text) {
                      provider.sendMessage(text, currentUserId);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // Implement send from controller
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
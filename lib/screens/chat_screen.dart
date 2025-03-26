// screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/conversation.dart';
import '../providers/theme_provider.dart';
import '../providers/conversation_provider.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String notificationId;

  const ChatScreen({
    Key? key,
    required this.conversationId,
    required this.notificationId,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late Conversation _conversation;

  @override
  void initState() {
    super.initState();
    // In a real app, we would fetch the conversation here
    final provider = Provider.of<ConversationProvider>(context, listen: false);
    _conversation = provider.conversations.firstWhere(
          (c) => c.id == widget.conversationId,
      orElse: () => Conversation(
        id: widget.conversationId,
        notificationId: widget.notificationId,
        participant1Id: 'currentUserId', // Replace with actual user ID
        participant2Id: 'otherUserId',   // Replace with actual user ID
        itemId: 'itemId',                // Replace with actual item ID
        messages: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final darkMode = themeProvider.isDarkMode;
    final conversationProvider = Provider.of<ConversationProvider>(context);

    return Scaffold(
      backgroundColor: darkMode ? const Color(0xFF1B262C) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Chat'),
        backgroundColor: darkMode ? const Color(0xFF354349) : Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: EdgeInsets.all(16),
              itemCount: _conversation.messages.length,
              itemBuilder: (context, index) {
                final message = _conversation.messages.reversed.toList()[index];
                final isMe = message.senderId == 'currentUserId'; // Replace with actual check

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe
                          ? (darkMode ? const Color(0xFF539DF3) : const Color(0xFF539DF3))
                          : (darkMode ? const Color(0xFF354349) : Colors.white),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(isMe ? 16 : 0),
                        topRight: Radius.circular(isMe ? 0 : 16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      message.content,
                      style: TextStyle(
                        color: isMe ? Colors.white : (darkMode ? Colors.white : Colors.black),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildMessageInput(conversationProvider),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ConversationProvider provider) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final darkMode = themeProvider.isDarkMode;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: darkMode ? const Color(0xFF354349) : Colors.white,
        border: Border(
          top: BorderSide(
            color: darkMode ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              if (_messageController.text.trim().isNotEmpty) {
                provider.sendMessage(
                  conversationId: widget.conversationId,
                  senderId: 'currentUserId', // Replace with actual user ID
                  content: _messageController.text.trim(),
                );
                _messageController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
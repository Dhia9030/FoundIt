import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/conversation.dart';
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
  final ScrollController _scrollController = ScrollController();

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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final themeProvider = Provider.of<ThemeProvider>(context);
    // final darkMode = themeProvider.isDarkMode;
    final conversationProvider = Provider.of<ConversationProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF222E34), // White background as per design
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFD8D8D8),
              radius: 20,
            ),
            const SizedBox(width: 12),
            const Text(
              'Quiche Hollandaise',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF54ABEC), // Green header from design
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _conversation.messages.length + 2, // +2 for date headers
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildDateHeader("Just Now");
                } else if (index == _conversation.messages.length / 2 + 1) {
                  return _buildDateHeader("sunday");
                }

                final adjustedIndex = index - 1;
                if (adjustedIndex >= _conversation.messages.length) {
                  return const SizedBox.shrink();
                }

                final message = _conversation.messages.reversed.toList()[adjustedIndex];
                final isMe = message.senderId == 'currentUserId'; // Replace with actual check

                // Add audio message for demo
                if (isMe && adjustedIndex == 2) {
                  return _buildAudioMessage(isMe);
                }

                return _buildMessageBubble(message, isMe, adjustedIndex == 0);
              },
            ),
          ),
          _buildMessageInput(conversationProvider),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF77838F),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(dynamic message, bool isMe, bool showReaction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              backgroundColor: const Color(0xFFD8D8D8),
              radius: 16,
            ),
            const SizedBox(width: 8),
          ],
          if (!isMe) const SizedBox(width: 8),
          Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.65,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isMe
                      ? const Color(0xFF55ACEE) // Blue bubble for outgoing messages
                      : const Color(0xFFEFEEF4), // Light gray for incoming
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isMe ? 16 : 0),
                    topRight: Radius.circular(isMe ? 0 : 16),
                    bottomLeft: const Radius.circular(16),
                    bottomRight: const Radius.circular(16),
                  ),
                ),
                child: Text(
                  message.content,
                  style: TextStyle(
                    color: isMe ? Colors.white : const Color(0xFF1E2022),
                    fontSize: 16,
                  ),
                ),
              ),
              if (showReaction && !isMe)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(Icons.favorite, color: Colors.red, size: 16),
                ),
            ],
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              "01:15 PM",
              style: TextStyle(
                color: const Color(0xFF77838F),
                fontSize: 12,
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildAudioMessage(bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              backgroundColor: const Color(0xFFD8D8D8),
              radius: 16,
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.65,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isMe
                      ? const Color(0xFF55ACEE) // Blue bubble for outgoing messages
                      : const Color(0xFFEFEEF4), // Light gray for incoming
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isMe ? 16 : 0),
                    topRight: Radius.circular(isMe ? 0 : 16),
                    bottomLeft: const Radius.circular(16),
                    bottomRight: const Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Image.asset(
                        'assets/waveform.png', // You'll need to add this asset
                        height: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.pause,
                        color: const Color(0xFF55ACEE),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              "01:18 PM",
              style: TextStyle(
                color: const Color(0xFF77838F),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ConversationProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF222E34),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF53AAEA),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.attach_file,
            color: const Color(0xFFF7FAFB),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              style: const TextStyle(color: Colors.white),
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a Message',
                hintStyle: TextStyle(
                  color: const Color(0xFFF0F9FF),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.mic,
            color: const Color(0xFF55ACEE),
            size: 24,
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF55ACEE),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.send,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
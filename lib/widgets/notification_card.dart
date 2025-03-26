import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/mock_notification.dart';
import '../providers/conversation_provider.dart';
import '../screens/chat_screen.dart';
import '../models/conversation.dart';// Ensure this import is correct

class NotificationCard extends StatelessWidget {
  final MockNotification notification;
  final VoidCallback onTap;

  const NotificationCard({
    Key? key,
    required this.notification,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isFoundItem = notification.type == 'FOUND_YOUR_ITEM';
    final Color cardColor = isFoundItem
        ? const Color(0xFFEDFFE7).withOpacity(0.9)
        : const Color(0xFFEBE7FF).withOpacity(0.9);
    final Color checkColor = isFoundItem
        ? const Color(0xFF0BD62A)
        : const Color(0xFF5233EB);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            try {
              final conversationProvider = Provider.of<ConversationProvider>(
                context,
                listen: false,
              );

              // Create a new conversation or get existing one
              final conversation = Conversation(
                id: 'conv_${notification.id}',
                notificationId: notification.id,
                participant1Id: 'current_user_id', // Replace with actual user ID
                participant2Id: notification.senderId,
                itemId: notification.itemId,
                messages: [
                  Message(
                    id: '1',
                    senderId: notification.senderId,
                    content: isFoundItem
                        ? "Hello! I think I found your item"
                        : "Hello! I'm looking for a similar item",
                    timestamp: DateTime.now(),
                  ),
                ],
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

              // Navigate to chat screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    conversationId: conversation.id,
                    notificationId: notification.id,
                  ),
                ),
              );
            } catch (e) {
              print('Error navigating to chat: $e');
            }

            onTap();
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Profile image with error handling
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/images/profile.png'),

                    ),
                    const SizedBox(width: 12),

                    // Notification text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.urbanist(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: "Dhia ",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: isFoundItem
                                      ? "most likely found your lost item : "
                                      : "is looking for the item : ",
                                ),
                                TextSpan(
                                  text: isFoundItem ? "Jacket" : "Mobile Phone",
                                  style: const TextStyle(fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Check icon
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: checkColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Chat prompt
                Center(
                  child: Text(
                    "Tap to chat with him",
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
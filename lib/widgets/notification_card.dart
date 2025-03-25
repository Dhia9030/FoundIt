import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mock_notification.dart';

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
        ? const Color(0xFFEDFFE7).withOpacity(0.7)
        : const Color(0xFFEBE7FF).withOpacity(0.7);
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Profile image
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/images/profile.jpg'),
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
                                  style: const TextStyle(fontWeight: FontWeight.bold),
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
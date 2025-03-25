import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mock_notification.dart';
import '../services/mock_notification_service.dart';
import '../widgets/notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MockNotificationService _notificationService = MockNotificationService();
  List<MockNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate loading notifications
    await Future.delayed(const Duration(milliseconds: 800));
    
    setState(() {
      _notifications = _notificationService.getMockNotifications();
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCDDDFF),
      body: Stack(
        children: [
          // Background blob
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: const BoxDecoration(
                color: Color(0xFF8AAFDF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    "Notifications",
                    style: GoogleFonts.urbanist(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B262C),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Tab bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: const Color(0xFF539DF3),
                          width: 3.0,
                        ),
                      ),
                    ),
                    labelColor: const Color(0xFF539DF3),
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(
                        child: Text(
                          "All",
                          style: GoogleFonts.urbanist(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "Your items",
                          style: GoogleFonts.urbanist(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "People's Items",
                          style: GoogleFonts.urbanist(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // All notifications tab
                      _buildNotificationsList(_notifications),
                      
                      // Your items tab
                      _buildNotificationsList(_notifications.where((n) => n.type == 'FOUND_YOUR_ITEM').toList()),
                      
                      // People's items tab
                      _buildNotificationsList(_notifications.where((n) => n.type == 'LOOKING_FOR_ITEM').toList()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<MockNotification> notifications) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF539DF3),
        ),
      );
    }
    
    if (notifications.isEmpty) {
      return Center(
        child: Text(
          "No notifications",
          style: GoogleFonts.urbanist(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return NotificationCard(
          notification: notifications[index],
          onTap: () {
            // Navigate to chat screen
            print("Navigate to chat with notification ID: ${notifications[index].id}");
          },
        );
      },
    );
  }
}
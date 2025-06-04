import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/app_notification.dart'; 
import '../providers/notification_provider.dart'; 
import '../providers/theme_provider.dart';
import '../widgets/notification_card.dart';
import '../widgets/menu_drawer.dart';
import '../widgets/bottom_navbar.dart';
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isMenuOpen = false;
  int _currentNavIndex = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _toggleMenu() {
    setState(() => isMenuOpen = !isMenuOpen);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleNavTap(int index) {
    if (index == _currentNavIndex) return;

    setState(() {
      _currentNavIndex = index;
      if (isMenuOpen) _toggleMenu();
    });

    // Handle navigation based on the selected tab
    switch (index) {
      case 0: // Search
        Navigator.pushReplacementNamed(context, '/search');
        break;
      case 1: // Home
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 2: // Notifications
        Navigator.pushReplacementNamed(context, '/notifications');
        break;
      case 3: // Profile
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final darkMode = themeProvider.isDarkMode;

    final notificationProvider = Provider.of<NotificationProvider>(context);
    final notifications =
        notificationProvider.notifications;
    final yourItemsNotifications =
        notifications.where((n) => n.type == 'lost_item_found_match').toList();
    final peoplesNotifications =
        notifications.where((n) => n.type == 'found_item_lost_match').toList();

    return Scaffold(
      backgroundColor:
          darkMode ? const Color(0xFF1B262C) : const Color(0xFFCDDDFF),
      body: Stack(
        children: [
    
          Positioned(
            top: -50,
            right: -50,
            child: Image.asset(
              darkMode
                  ? 'assets/images/blob-1.png'
                  : 'assets/images/blob2-1.png',
              width: 250,
              height: 250,
            ),
          ),
          Positioned(
            top: 150,
            left: -100,
            child: Image.asset(
              darkMode
                  ? 'assets/images/blob-2.png'
                  : 'assets/images/blob2-2.png',
              width: 290,
              height: 290,
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Image.asset(
              darkMode
                  ? 'assets/images/blob-3.png'
                  : 'assets/images/blob2-3.png',
              width: 290,
              height: 290,
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    "Notifications",
                    style: GoogleFonts.urbanist(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: darkMode ? Colors.white : const Color(0xFF1B262C),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24.0),
                  decoration: BoxDecoration(
                    color: darkMode ? const Color(0xFF354349) : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(darkMode ? 0.1 : 0.05),
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
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                    labelColor: const Color(0xFF539DF3),
                    unselectedLabelColor:
                        darkMode ? Colors.grey[400] : Colors.grey,
                    tabs: const [
                      Tab(text: "All"),
                      Tab(text: "Your items"),
                      Tab(text: "People's"),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildNotificationsList(notifications, darkMode,
                          notificationProvider),
                      _buildNotificationsList(yourItemsNotifications, darkMode,
                          notificationProvider),
                      _buildNotificationsList(peoplesNotifications, darkMode,
                          notificationProvider),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu Overlay
          if (isMenuOpen)
            GestureDetector(
              onTap: _toggleMenu,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),

          // Menu Drawer
          MenuDrawer(
            isMenuOpen: isMenuOpen,
            onMenuToggle: _toggleMenu,
          ),
        ],
      ),
      /*bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _handleNavTap,
      ),*/
    );
  }

  Widget _buildNotificationsList(List<AppNotification> notifications,
      bool darkMode, NotificationProvider notificationProvider) {
    if (notifications.isEmpty) {
      return Center(
        child: Text(
          "No notifications",
          style: GoogleFonts.urbanist(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: darkMode ? Colors.grey[400] : Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return NotificationCard(
          notification: notification,
          darkMode: darkMode,
          onTap: () {
            print("Notification tapped: ${notification.id}");
            notificationProvider.markAsRead(notification.id);
  
          },
        );
      },
    );
  }
}

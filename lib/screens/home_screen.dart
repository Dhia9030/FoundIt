import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'report_lost_screen.dart'; // Import the describe item screen
import 'report_found_screen.dart'; // Import the report found item screen
import '../widgets/bottom_navbar.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final darkMode = themeProvider.isDarkMode;
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode? const Color(0xFF1B262C) : const Color(
          0xFFD1ECFF),
      body: Stack(
        children: [
          // Blobs (Positioned behind the buttons)
          Positioned(
            top: -5,
            right: -5,
            child: Image.asset(darkMode?
            'assets/images/blob-1.png': 'assets/images/blob2-1.png',
              width: 200,
              height: 200,
            ),
          ),

          Positioned(
            top: 150,
            left: -100,
            child: Image.asset(darkMode?
            'assets/images/blob-2.png': 'assets/images/blob2-2.png',
              width: 290,
              height: 290,
            ),
          ),
          Positioned(
            top: 500,
            right:-110,
            child: Image.asset(darkMode?
            'assets/images/blob-3.png': 'assets/images/blob2-3.png',
              width: 290,
              height: 290,
            ),
          ),

          // Report Found Item Button (Positioned at the very right)
          Positioned(
            top: 260,
            right: -30,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportFoundItemScreen()),
                );
              },
              child: Container(
                width: 300,
                height: 143,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: ShapeDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(1.37, 0.21),
                    end: Alignment(0.30, 0.72),
                    colors: [const Color(0xFF7996FF), const Color(0xFF415FCC)],
                  ),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1),
                    borderRadius: BorderRadius.circular(35),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Color(0x3F535353),
                      blurRadius: 4,
                      offset: Offset(15, 15),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 8),
                    Text.rich(
                      TextSpan(
                        text: 'Report Found Item',
                        style: TextStyle(
                            fontSize: 22,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Icon positioned outside the Report Found Item button (left of the button)
          Positioned(
            top: 306,
            right: 295,
            child: SvgPicture.asset(
              'assets/icons/location.svg',
              width: 60,
              height: 60,
            ),
          ),
          
          // Chat Button (New addition - positioned in the middle)
          Positioned(
            top: 360,
            left: MediaQuery.of(context).size.width / 2 - 75, // Centered horizontally
            child: GestureDetector(
              onTap: () {
                // Navigate to chat screen with a dummy user ID
                Navigator.pushNamed(
                  context,
                  '/chat',
                  arguments: {
                    'otherUserId': 'Y5Kb2cgUy0VQQHkbaT9vO61XGLn1', // Replace with actual user ID in your app
                  },
                );
              },
              child: Container(
                width: 150,
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: ShapeDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
                  ),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1),
                    borderRadius: BorderRadius.circular(35),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Color(0x3F535353),
                      blurRadius: 4,
                      offset: Offset(5, 5),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.chat, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Chat',
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Updated star icon with shadow
          Positioned(
            top: 30,
            right: 30,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3F535353),
                    blurRadius: 4,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: SvgPicture.asset(
                'assets/icons/star.svg',
                width: 28,
                height: 28,
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 70,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3F535353),
                    blurRadius: 4,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: SvgPicture.asset(
                'assets/icons/star.svg',
                width: 40,
                height: 40,
              ),
            ),
          ),
          Positioned(
            top: 80,
            right: 30,
            child: Container(
              child: SvgPicture.asset(
                'assets/icons/star.svg',
                width: 55,
                height: 55,
              ),
            ),
          ),
          Positioned(
            top: 110,
            right: 210,
            child: SvgPicture.asset(
              'assets/icons/moon.svg',
              width: 90,
              height: 90,
            ),
          ),
          Positioned(
            top: 200,
            left: 10,
            child: SvgPicture.asset(
              'assets/icons/star.svg',
              width: 45,
              height: 45,
            ),
          ),
          Positioned(
            top: 250,
            left: 30,
            child: SvgPicture.asset(
              'assets/icons/star.svg',
              width: 25,
              height: 25,
            ),
          ),
          // Report Lost Item Button (Positioned at the very left)
          Positioned(
            top: 450,
            left: -30,
            child: GestureDetector(
              onTap: () {
                // Navigate to the DescribeItemScreen when this button is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DescribeItemScreen(),
                  ),
                );
              },
              child: Container(
                width: 300,
                height: 143,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: ShapeDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.17, 0.78),
                    end: Alignment(1.34, 0.78),
                    colors: [const Color(0xE0F34266), const Color(0xFFD90041)],
                  ),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1),
                    borderRadius: BorderRadius.circular(35),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Color(0x4C655B7F),
                      blurRadius: 8,
                      offset: Offset(0, 15),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: 'Report Lost Item',
                        style: TextStyle(
                            fontSize: 22,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w900,
                            color: Colors.white
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Icon positioned outside the Report Lost Item button (right of the button)
          Positioned(
            top: 495,
            left: 300,
            child: SvgPicture.asset(
              'assets/icons/volume.svg',
              width: 60,
              height: 60,
            ),
          ),
        ],
      ),
    );
  }
}
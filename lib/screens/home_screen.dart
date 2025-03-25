import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg for SVG support
import 'package:provider/provider.dart';
import '../models/theme_provider.dart'; // Import the ThemeProvider class
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final darkMode = themeProvider.isDarkMode;
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode? const Color(0xFF1B262C) : const Color(
          0xFFD1ECFF), // Changed background color to 1B262C
      body: Stack(
        children: [
          // Blobs (Positioned behind the buttons)
          Positioned(
            top: -5, // Adjust top position
            right: -5, // Adjust left position
            child: Image.asset(darkMode?
              'assets/images/blob-1.png': 'assets/images/blob2-1.png', // Use Image.asset for PNG blobs
              width: 200, // Adjust size
              height: 200, // Adjust size
            ),
          ),

          Positioned(
            top: 150, // Adjust top position
            left: -100, // Adjust left position
            child: Image.asset(darkMode?
            'assets/images/blob-2.png': 'assets/images/blob2-2.png',
              width: 290, // Adjust size
              height: 290, // Adjust size
            ),
          ),
          Positioned(
            top: 500, // Adjust top position
            right:-110, // Adjust left position
            child: Image.asset(darkMode?
            'assets/images/blob-3.png': 'assets/images/blob2-3.png',
              width: 290, // Adjust size
              height: 290, // Adjust size
            ),
          ),

          // Report Found Item Button (Positioned at the very right)
          Positioned(
            top: 260, // Adjust vertical position
            right: -30, // Place button at the very right
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
                        fontFamily: 'Montserrat', // Use Montserrat font
                        fontWeight: FontWeight.bold,
                          color: Colors.white// Thicker font
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Icon positioned outside the Report Found Item button (left of the button)
          Positioned(
            top: 306, // Adjust vertical position to match the button
            right: 295, // Adjust horizontal position
            child: SvgPicture.asset(
              'assets/icons/location.svg', // Use SvgPicture for SVG icons
              width: 60,
              height: 60,
            ),
          ),
          // Updated star icon with shadow
          Positioned(
            top: 30, // Adjust vertical position to match the button
            right: 30, // Adjust horizontal position
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3F535353),
                    blurRadius: 4,
                    offset: Offset(2, 4), // Shadow position
                  ),
                ],
              ),
              child: SvgPicture.asset(
                'assets/icons/star.svg', // Use SvgPicture for SVG icons
                width: 28,
                height: 28,
              ),
            ),
          ),
          Positioned(
            top: 40, // Adjust vertical position to match the button
            right: 70, // Adjust horizontal position
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
                'assets/icons/star.svg', // Use SvgPicture for SVG icons
                width: 40,
                height: 40,
              ),
            ),
          ),
          Positioned(
            top: 80, // Adjust vertical position to match the button
            right: 30, // Adjust horizontal position
            child: Container(

              child: SvgPicture.asset(
                'assets/icons/star.svg', // Use SvgPicture for SVG icons
                width: 55,
                height: 55,
              ),
            ),
          ),
          Positioned(
            top: 110, // Adjust vertical position to match the button
            right: 210, // Adjust horizontal position
            child: SvgPicture.asset(
              'assets/icons/moon.svg', // Use SvgPicture for SVG icons
              width: 90,
              height: 90,
            ),
          ),
          Positioned(
            top: 200, // Adjust vertical position to match the button
            left: 10, // Adjust horizontal position
            child: SvgPicture.asset(
              'assets/icons/star.svg', // Use SvgPicture for SVG icons
              width: 45,
              height: 45,
            ),
          ),
          Positioned(
            top: 250, // Adjust vertical position to match the button
            left: 30, // Adjust horizontal position
            child: SvgPicture.asset(
              'assets/icons/star.svg', // Use SvgPicture for SVG icons
              width: 25,
              height: 25,
            ),
          ),
          // Report Lost Item Button (Positioned at the very left)
          Positioned(
            top: 450, // Adjust vertical position
            left: -30, // Place button at the very left
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
                        fontFamily: 'Montserrat', // Use Montserrat font
                        fontWeight: FontWeight.w900,
                        color: Colors.white// Thicker font
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Icon positioned outside the Report Lost Item button (right of the button)
          Positioned(
            top: 495, // Adjust vertical position to match the button
            left: 300, // Adjust horizontal position
            child: SvgPicture.asset(
              'assets/icons/volume.svg', // Use SvgPicture for SVG icons
              width: 60,
              height: 60,
            ),
          ),
        ],
      ),
    );
  }
}

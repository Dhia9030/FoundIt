import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B7B7B).withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 20,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: const Color(0xFF131417),
          selectedItemColor: const Color(0xFF539DF3),
          unselectedItemColor: Colors.white,
          showSelectedLabels: true,
          showUnselectedLabels: false, // Only show label when active
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/search.svg',
                width: 24,
                height: 24,
                color: currentIndex == 0
                    ? const Color(0xFF539DF3)
                    : Colors.white,
              ),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/home.svg',
                width: 24,
                height: 24,
                color: currentIndex == 1
                    ? const Color(0xFF539DF3)
                    : Colors.white,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/icons/clock.svg',
                width: 24,
                height: 24,
                color: currentIndex == 2
                    ? const Color(0xFF539DF3)
                    : Colors.white,
              ),
              label: 'History',
            ),
        BottomNavigationBarItem(
        icon: SvgPicture.asset(
        'assets/icons/user.svg',
    width: 24,
    height: 24,
        color: currentIndex == 3
        ? const Color(0xFF539DF3)
        : Colors.white,
    ),
    label: 'Profile',
    ),

          ],
        ),
      ),
    );
  }
}
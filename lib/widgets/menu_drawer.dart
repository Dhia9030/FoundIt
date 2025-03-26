import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class MenuDrawer extends StatefulWidget {
  final bool isMenuOpen;
  final VoidCallback onMenuToggle;

  const MenuDrawer({
    Key? key,
    required this.isMenuOpen,
    required this.onMenuToggle,
  }) : super(key: key);

  @override
  _MenuDrawerState createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(covariant MenuDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMenuOpen) {
      _rotationController.forward();
    } else {
      _rotationController.reverse();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final rotation = Tween(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeOut),
    );

    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          top: 0,
          left: widget.isMenuOpen ? 0 : -280,
          child: Container(
            width: 280,
            height: MediaQuery.of(context).size.height,
            color: themeProvider.isDarkMode ? const Color(0xFF1B262C) : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/moon.svg',
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(width: 15),
                    Text(
                      'John Doe',
                      style: TextStyle(
                        color: themeProvider.isDarkMode ? Colors.blue : Colors.blue[800],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                _buildMenuItem(
                  icon: 'sun.svg',
                  text: 'Dark Mode',
                  textColor: themeProvider.isDarkMode ? Colors.white : Colors.black,
                  iconColor: themeProvider.isDarkMode ? Colors.white : Colors.black,
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) => themeProvider.toggleDarkMode(),
                    activeColor: const Color(0xFF3869F1),
                  ),
                ),
                Divider(color: themeProvider.isDarkMode ? Colors.grey : Colors.grey[400], height: 30),
                _buildMenuItem(
                  icon: 'info-circle.svg',
                  text: 'Account',
                  textColor: themeProvider.isDarkMode ? Colors.white : Colors.black,
                  iconColor: themeProvider.isDarkMode ? Colors.white : Colors.black,
                  onTap: () => print('Account Info'),
                ),
                _buildMenuItem(
                  icon: 'lock.svg',
                  text: 'Password',
                  textColor: themeProvider.isDarkMode ? Colors.white : Colors.black,
                  iconColor: themeProvider.isDarkMode ? Colors.white : Colors.black,
                  onTap: () => print('Password'),
                ),
                _buildMenuItem(
                  icon: 'settings.svg',
                  text: 'Settings',
                  textColor: themeProvider.isDarkMode ? Colors.white : Colors.black,
                  iconColor: themeProvider.isDarkMode ? Colors.white : Colors.black,
                  onTap: () => print('Settings'),
                ),
                const SizedBox(height: 200),
                _buildMenuItem(
                  icon: 'logout.svg',
                  text: 'Logout',
                  textColor: Colors.red,
                  iconColor: Colors.red,
                  onTap: () => print('Logout'),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 60,
          left: 20,
          child: GestureDetector(
            onTap: widget.onMenuToggle,
            child: RotationTransition(
              turns: rotation,
              child: Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/icons/menu.svg',
                  width: 50,
                  height: 50,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required String icon,
    required String text,
    Color? textColor,
    Color? iconColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    double iconWidth = 24.0;
    double iconHeight = 24.0;

    if (icon == 'sun.svg') {
      iconWidth = 30.0;
      iconHeight = 30.0;
    }
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/$icon',
              width: iconWidth,
              height: iconHeight,
              color: iconColor,
            ),
            const SizedBox(width: 15),
            Text(
              text,
              style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w900
              ),
            ),
            if (trailing != null) ...[const Spacer(), trailing]
          ],
        ),
      ),
    );
  }
}
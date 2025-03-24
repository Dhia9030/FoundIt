import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MenuDrawer extends StatefulWidget {
  final bool isMenuOpen;
  final VoidCallback onMenuToggle;
  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  const MenuDrawer({
    Key? key,
    required this.isMenuOpen,
    required this.onMenuToggle,
    required this.darkMode,
    required this.onDarkModeChanged,
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
    final rotation = Tween(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeOut),
    );

    return Stack(
      children: [
        // Slide-in Drawer
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          top: 0,
          left: widget.isMenuOpen ? 0 : -280,
          child: Container(
            width: 280,
            height: MediaQuery.of(context).size.height,
            color: const Color(0xFF1B262C),
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80), // Adjusted to start lower

                // User Profile with Correct SVG Usage
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/moon.svg',
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      'John Doe',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat', // Font applied here
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Dark Mode
                _buildMenuItem(
                  icon: 'sun.svg',
                  text: 'Dark Mode',
                  trailing: Switch(
                    value: widget.darkMode,
                    onChanged: widget.onDarkModeChanged,
                    activeColor: Color(0xFF81C784), // Lighter Green
                  ),
                ),
                const Divider(color: Colors.grey, height: 30),

                // Other Menu Items
                _buildMenuItem(icon: 'info-circle.svg', text: 'Account', onTap: () => print('Account Info')),
                _buildMenuItem(icon: 'lock.svg', text: 'Password', onTap: () => print('Password')),
                _buildMenuItem(icon: 'settings.svg', text: 'Settings', onTap: () => print('Settings')),

                const SizedBox(height: 200),

                // Logout
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

        // Menu Button (Always Visible)
        Positioned(
          top: 60, // Adjusted lower
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
    Color textColor = Colors.white,
    Color iconColor = Colors.white,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/$icon',
              width: 24,
              height: 24,
              color: iconColor,
            ),
            const SizedBox(width: 15),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontFamily: 'Montserrat', // Font applied here as well
              ),
            ),
            if (trailing != null) ...[const Spacer(), trailing]
          ],
        ),
      ),
    );
  }
}

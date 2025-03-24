import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/menu_drawer.dart';
import 'package:provider/provider.dart';
import '../models/theme_provider.dart';
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _isMenuOpen = false;
  bool _darkMode = false;

  final List<Widget> _pages = [
    const Center(child: Text('Search Page', style: TextStyle(color: Colors.white))),
    HomeScreen(), // Updated to reference HomeScreen
    const Center(child: Text('Profile Page', style: TextStyle(color: Colors.white))),
    const Center(child: Text('History Page', style: TextStyle(color: Colors.white))),
  ];

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  void _handleNavTap(int index) {
    setState(() {
      _currentIndex = index;
      if (_isMenuOpen) _toggleMenu();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B262C), // Changed background color to 1B262C
      body: Stack(
        children: [
          // Main Content
          _pages[_currentIndex],

          // Menu Overlay
          if (_isMenuOpen)
            GestureDetector(
              onTap: _toggleMenu,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),

          // Menu Drawer Component
          MenuDrawer(
            isMenuOpen: _isMenuOpen,
            onMenuToggle: _toggleMenu,
            darkMode: _darkMode,
            onDarkModeChanged: (value) {
              setState(() => _darkMode = value);
            },
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _handleNavTap,
      ),
    );
  }
}

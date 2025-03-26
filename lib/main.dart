import 'package:flutter/material.dart';
import 'package:foundita/widgets/Auth_screen.dart';
import 'package:foundita/widgets/found_item_form.dart';
import 'package:provider/provider.dart';
import 'models/theme_provider.dart';
import 'screens/home_screen.dart';
import 'widgets/bottom_navbar.dart';
import 'widgets/menu_drawer.dart';
import 'widgets/Auth_screen.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _isMenuOpen = false;

  final List<Widget> _pages = [
    const Center(child: Text('Search Page')),
    HomeScreen(),
    const Center(child: Text('History Page')),
    const Center(child: Text('Account Page')),
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
      body: Stack(
        children: [
          // Main Content
          _pages[_currentIndex],

          // Menu Overlay (only visible when menu is open)
          if (_isMenuOpen)
            GestureDetector(
              onTap: _toggleMenu,
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),

          // Menu Drawer (always in the tree but positioned off-screen when closed)
          MenuDrawer(
            isMenuOpen: _isMenuOpen,
            onMenuToggle: _toggleMenu,
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
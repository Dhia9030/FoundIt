import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/report_lost_screen.dart';
import 'widgets/bottom_navbar.dart';
import 'widgets/menu_drawer.dart';
import 'models/item_provider.dart';
import 'providers/conversation_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => ItemProvider()),
        ChangeNotifierProvider(create: (context) => ConversationProvider()),
      ],
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
      routes: {

        '/home': (context) => const HomePage(initialTabIndex: 1),
        '/search': (context) => const HomePage(initialTabIndex: 0),
        '/notifications': (context) => const HomePage(initialTabIndex: 2),
        '/profile': (context) => const HomePage(initialTabIndex: 3),
        '/report-lost': (context) => const DescribeItemScreen(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  final int? initialTabIndex;

  const HomePage({super.key, this.initialTabIndex});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _currentIndex;
  bool _isMenuOpen = false;

  final List<Widget> _pages = [
    const Center(child: Text('Search Page')), // Index 0: Search
     HomeScreen(),                       // Index 1: Home
    const NotificationsScreen(),              // Index 2: Notifications
    const Center(child: Text('Profile Page')), // Index 3: Profile
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex ?? 1;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Handle route arguments if any
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs is int) {
      setState(() {
        _currentIndex = routeArgs;
      });
    }
  }

  void _toggleMenu() {
    setState(() => _isMenuOpen = !_isMenuOpen);
  }

  void _handleNavTap(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
      if (_isMenuOpen) _toggleMenu();
    });

    // Navigate to the corresponding route
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/search');
        break;
      case 1:
        Navigator.pushNamed(context, '/home');
        break;
      case 2:
        Navigator.pushNamed(context, '/notifications');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _pages[_currentIndex],
          if (_isMenuOpen)
            GestureDetector(
              onTap: _toggleMenu,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foundita/firebase_options.dart';
import 'package:foundita/providers/location_provider.dart';
import 'package:foundita/screens/map_picker_screen.dart';
import 'package:foundita/screens/register_screen.dart';
import 'package:foundita/screens/login_screen.dart';
import 'package:foundita/services/location_service.dart';
import 'package:foundita/services/lost_item_service.dart';
import 'package:foundita/services/usermanagement_service.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/report_lost_screen.dart';
import 'screens/login_screen.dart';
import 'screens/usermanagement_screen.dart';
import 'widgets/bottom_navbar.dart';
import 'widgets/menu_drawer.dart';
import 'models/item_provider.dart';
import 'providers/conversation_provider.dart';
import 'providers/registerprovider.dart';
import 'providers/login_provider.dart';
import 'providers/usermanagement_provider.dart';
import 'services/register_service.dart';
import 'services/login_service.dart';

import 'screens/report_lost_test.dart';
import 'services/usermanagement_service.dart';
import 'providers/lost_item_provider.dart';
import "screens/usermanagement_screen.dart";
import "providers/usermanagement_provider.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Connect to Firebase Emulators (for local testing)
  if (kDebugMode) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => ItemProvider()),
        ChangeNotifierProvider(create: (context) => ConversationProvider()),
        ChangeNotifierProvider(
          create: (context) => RegisterProvider(regService: RegisterService()),
        ),
          ChangeNotifierProvider(
      create: (context) => LoginProvider(loginService: LoginService()),
    ),
     ChangeNotifierProvider(
          create: (context) => UserManagementProvider(
            userManagementService: UserManagementService(),
          ),
      
          
),
        ChangeNotifierProvider(
          create: (context) => LostItemProvider(
            lostItemService: LostItemService(locationService: LocationService()),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => LocationProvider(locationService: LocationService()),
        ),
       
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
        '/register': (context) => RegistrationScreen(),
        '/login': (context) => LoginScreen(),
        '/report-lost-test': (context) => const ReportLostItemScreen(),
        '/user-management': (context) => const UserManagementScreen(),
        '/map-picker': (context) => const MapPickerScreen(),  // Add this line
        
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
    HomeScreen(), // Index 1: Home
    const NotificationsScreen(), // Index 2: Notifications
    const Center(child: Text('Profile Page')),
    const Center(child: Text('Register')), // Index 3: Profile
    const Center(child: Text('Login'))
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
      case 4:
        Navigator.pushNamed(context, '/register');
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

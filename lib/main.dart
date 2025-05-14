import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:foundita/firebase_options.dart';
import 'package:foundita/providers/found_item_provider.dart';
import 'package:foundita/providers/location_provider.dart';
import 'package:foundita/screens/chat_screen.dart';
import 'package:foundita/screens/map_picker_screen.dart';
import 'package:foundita/screens/map_screen.dart';
import 'package:foundita/screens/register_screen.dart';
import 'package:foundita/screens/login_screen.dart';
import 'package:foundita/screens/report_found_screen.dart';
import 'package:foundita/services/found_item_service.dart';
import 'package:foundita/services/location_service.dart';
import 'package:foundita/services/lost_item_service.dart';
import 'package:foundita/services/usermanagement_service.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/report_lost_screen.dart';
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
import 'providers/lost_item_provider.dart';
import 'services/profile_service.dart'; // Import ProfileService
import 'providers/profile_provider.dart'; // Import ProfileProvider
import 'screens/profile_screen.dart'; // Import ProfileScreen
import 'package:foundita/providers/dashboard_provider.dart';
import 'package:foundita/services/dashboard_service.dart';
import 'package:foundita/screens/dashboard_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load(fileName: '.env');

  // Create the LocationService instance once
  final locationService = LocationService();

  runApp(
    MultiProvider(
      providers: [
        Provider<LocationService>(create: (_) => LocationService()),
        Provider<FoundItemService>(create: (context) => FoundItemService(locationService: Provider.of<LocationService>(context, listen: false))),
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
        // Provide LocationService
        ChangeNotifierProvider(
          create: (context) => LocationProvider(locationService: locationService),
        ),
        // Now, providers that depend on LocationService can access it
        ChangeNotifierProvider(
          create: (context) => LostItemProvider(
            lostItemService: LostItemService(locationService: locationService),
          ),
        ),
        ChangeNotifierProxyProvider<LocationProvider, FoundItemProvider>(
          create: (context) => FoundItemProvider(
            foundItemService: FoundItemService(locationService: locationService),
            locationProvider: Provider.of<LocationProvider>(context, listen: false),
          ),
          update: (context, locationProvider, previous) => FoundItemProvider(
            foundItemService: FoundItemService(locationService: locationService),
            locationProvider: locationProvider,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => UserManagementProvider(
            userManagementService: UserManagementService(),
          ),
        ),
        Provider<ProfileService>( // Add ProfileService
          create: (context) => ProfileService(),
        ),
        ChangeNotifierProvider<ProfileProvider>( // Add ProfileProvider
          create: (context) => ProfileProvider(profileService: context.read<ProfileService>()),
        ),
        Provider(create: (_) => AdminDashboardService()),
    ChangeNotifierProvider(
      create: (context) => DashboardProvider(
        adminDashboardService: context.read<AdminDashboardService>(),
      ),
    ),
      ],
      child: const MyApp(),));
  }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: const AuthWrapper(),
      routes: {
        '/home': (context) => const HomePage(initialTabIndex: 1),
        '/search': (context) => const HomePage(initialTabIndex: 0),
        '/notifications': (context) => const HomePage(initialTabIndex: 2),
        '/profile': (context) => const ProfileScreen(), // Add ProfileScreen route
        '/report-lost': (context) => const DescribeItemScreen(),
        '/register': (context) => RegistrationScreen(),
        '/login': (context) => const LoginScreen(),
        '/report-lost-test': (context) => const ReportLostItemScreen(),
        '/user-management': (context) => const UserManagementScreen(),
        '/map-picker': (context) => const MapPickerScreen(),
        '/report-found': (context) => ReportFoundItemScreen(),
        '/map': (context) => const FoundItemsMapPage(),
        '/dashboard': (context) => const DashboardScreen(),
         '/chat': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ChatScreen(otherUserId: args['otherUserId']);
        },
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
    const FoundItemsMapPage(), // Index 1: Home
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
        Navigator.pushNamed(context, '/profile'); // Navigate to profile route
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

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;

    return StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomePage();
        }
        return const LoginScreen();
      },
    );
  }
}
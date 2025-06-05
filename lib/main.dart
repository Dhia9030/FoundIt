import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:foundita/firebase_options.dart';
import 'package:foundita/providers/found_item_provider.dart';
import 'package:foundita/providers/location_provider.dart';
import 'package:foundita/screens/chat_screen.dart';
import 'package:foundita/screens/dashboard_screen.dart';
import 'package:foundita/screens/map_picker_screen.dart';
import 'package:foundita/screens/map_screen.dart';
import 'package:foundita/screens/register_screen.dart';
import 'package:foundita/screens/login_screen.dart';
import 'package:foundita/screens/report_found_screen.dart';
import 'package:foundita/services/found_item_service.dart';
import 'package:foundita/services/location_service.dart';
import 'package:foundita/services/lost_item_service.dart';
import 'package:foundita/services/usermanagement_service.dart';
import 'package:foundita/screens/search_screen.dart';
import 'package:foundita/screens/sign_up_screen.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/search_screen.dart';
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
import 'services/profile_service.dart';
import 'providers/profile_provider.dart';
import 'screens/profile_screen.dart';
import 'package:foundita/providers/dashboard_provider.dart';
import 'package:foundita/services/dashboard_service.dart';
import 'package:google_fonts/google_fonts.dart';

// Import the new notification files
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'providers/notification_provider.dart';
import 'services/notification_service.dart';

// This needs to be a top-level function for Firebase Messaging background messages
// It must be outside any class.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're using Firebase services in the background, you must ensure Firebase is initialized.
  // This is especially important for Android.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");

  // Retrieve the current user's ID. In background, this relies on Firebase Auth's persistence.
  final userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId != null) {
    // Use the NotificationService to add the notification to Firestore
    final notificationService = NotificationService();
    await notificationService.addNotificationToFirestore(userId, message.data);
    print('Background notification saved to Firestore for user $userId.');
  } else {
    print(
        'Background: User not authenticated. Notification not saved to Firestore.');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load(fileName: '.env');
  print('--- Debugging .env values in main.dart ---');
  print('BACKEND_UPLOAD_URL: "${dotenv.env['BACKEND_UPLOAD_URL']}"');
  print('UPLOAD_API_KEY: "${dotenv.env['UPLOAD_API_KEY']}"');
  print(
      'Is BACKEND_UPLOAD_URL null? ${dotenv.env['BACKEND_UPLOAD_URL'] == null}');
  print('Is UPLOAD_API_KEY null? ${dotenv.env['UPLOAD_API_KEY'] == null}');
  print('--- End .env Debug ---');

  // Register the background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize FCM for foreground and opened-app messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final notificationService = NotificationService();
      await notificationService.addNotificationToFirestore(
          userId, message.data);
    } else {
      print(
          'Foreground: User not authenticated. Notification not saved to Firestore.');
    }

    // You can also display a local notification here if you want a pop-up
    // For example, using flutter_local_notifications (requires adding the package)
    // if (message.notification != null) {
    //   // display local notification
    // }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    print(
        'Message opened app from terminated/background state: ${message.data}');
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final notificationService = NotificationService();
      await notificationService.addNotificationToFirestore(
          userId, message.data);
      // You can add navigation logic here if you want to go to a specific screen
      // Navigator.pushNamed(context, '/notifications');
    }
  });

  // Create the LocationService instance once
  final locationService = LocationService();

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
          create: (context) =>
              LocationProvider(locationService: locationService),
        ),
        ChangeNotifierProvider(
          create: (context) => LostItemProvider(
            lostItemService: LostItemService(locationService: locationService),
          ),
        ),
        ChangeNotifierProxyProvider<LocationProvider, FoundItemProvider>(
          create: (context) => FoundItemProvider(
            foundItemService:
                FoundItemService(locationService: locationService),
            locationProvider:
                Provider.of<LocationProvider>(context, listen: false),
          ),
          update: (context, locationProvider, previous) => FoundItemProvider(
            foundItemService:
                FoundItemService(locationService: locationService),
            locationProvider: locationProvider,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => UserManagementProvider(
            userManagementService: UserManagementService(),
          ),
        ),
        Provider<ProfileService>(
          create: (context) => ProfileService(),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (context) =>
              ProfileProvider(profileService: context.read<ProfileService>()),
        ),
        Provider(create: (_) => AdminDashboardService()),
        ChangeNotifierProvider(
          create: (context) => DashboardProvider(
            adminDashboardService: context.read<AdminDashboardService>(),
          ),
        ),
        // --- ADD YOUR NEW NOTIFICATION PROVIDER HERE ---
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeData = themeProvider.themeData;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData.copyWith(
        textTheme: GoogleFonts.montserratTextTheme(themeData.textTheme),
        primaryTextTheme:
            GoogleFonts.montserratTextTheme(themeData.primaryTextTheme),
      ),
      home: const AuthWrapper(),
      routes: {
        '/home': (context) => const HomePage(initialTabIndex: 1),
        '/search': (context) => const HomePage(initialTabIndex: 0),
        '/notifications': (context) =>
            const NotificationsScreen(), // <--- USE YOUR NEW SCREEN
        '/profile': (context) => const ProfileScreen(),
        '/report-lost': (context) => const DescribeItemScreen(),
        '/report-found': (context) => ReportFoundItemScreen(),
        '/register': (context) => RegistrationScreen(),
        '/login': (context) => LoginScreen(),
        '/report-lost-test': (context) => const ReportLostItemScreen(),
        '/user-management': (context) => const UserManagementScreen(),
        '/map-picker': (context) => const MapPickerScreen(),
        '/map': (context) => const FoundItemsMapPage(),
        '/dashboard': (context) => const DashboardScreen(),
        '/chat': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return ChatScreen(otherUserId: args['otherUserId']);
        },
        '/sign-up': (context) => RegisterScreen(),
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
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  final List<Widget> _pages = [
    const FoundItemsMapPage(), // Index 0: Search
    HomeScreen(), // Index 1: Home
    const NotificationsScreen(), // Index 2: Notifications - <--- USE YOUR NEW SCREEN
    const ProfileScreen(), // Index 3: Profile
    const Center(child: Text('Register')), // Index 4: Register
    const Center(child: Text('Login')) // Index 5: Login
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex ?? 1;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // No change needed here for notifications, as the provider now handles user ID.
  }

  void _toggleMenu() {
    setState(() => _isMenuOpen = !_isMenuOpen);
  }

  void _handleNavTap(int index) {
    if (index == _currentIndex) return;

    // If we're on a screen that's not in the main navigation
    if (_navigatorKey.currentState?.canPop() ?? false) {
      _navigatorKey.currentState?.pop(); // Close any modals/dialogs
    }
    setState(() {
      _currentIndex = index;
      if (_isMenuOpen) _toggleMenu();
    });

    // If we're on a non-main page (like report lost), pop back to home first

    /*switch (index) {
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
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _pages[_currentIndex], // This will display the selected page
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
          // User is logged in, ensure FCM token is registered/updated
          // The NotificationProvider's constructor now handles this when authStateChanges() fires
          // No need to call updateFCMTokenForUser here directly if NotificationProvider handles it
          return HomePage(initialTabIndex: 1);
        }
        return const LoginScreen();
      },
    );
  }
}

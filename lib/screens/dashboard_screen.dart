import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foundita/providers/theme_provider.dart';
import 'package:foundita/providers/dashboard_provider.dart';
import 'package:foundita/providers/login_provider.dart';
import 'package:foundita/models/administrator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loginProvider = Provider.of<LoginProvider>(context, listen: false);
      if (loginProvider.currentAccountHolder is Administrator) {
        Provider.of<DashboardProvider>(context, listen: false).loadInitialStats();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final darkMode = themeProvider.isDarkMode;

    return Consumer2<LoginProvider, DashboardProvider>(
      builder: (context, loginProvider, dashboardProvider, child) {
        if (loginProvider.currentAccountHolder == null || !(loginProvider.currentAccountHolder is Administrator)) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Access Denied'),
              backgroundColor: Theme.of(context).colorScheme.errorContainer, // Themed for error
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 80, color: Theme.of(context).colorScheme.error),
                    const SizedBox(height: 20),
                    Text(
                      'You do not have permission to access this page.',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.popUntil(context, ModalRoute.withName('/login')); // Navigate back to login
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Go Back'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: darkMode ? const Color(0xFF1B262C) : const Color(0xFFD1ECFF), // Your custom background
          appBar: AppBar(
            title: const Text(
              'Monthly Statistics',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent, // Blends with body
            elevation: 2, // Subtle shadow for AppBar
            foregroundColor: darkMode ? Colors.white : Colors.black, // Title color
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: darkMode ? Colors.white70 : Colors.black54),
                onPressed: () => _refreshData(context),
                tooltip: 'Refresh Data',
              ),
            ],
          ),
          body: Builder(
            builder: (context) {
              if (dashboardProvider.isLoading && dashboardProvider.monthlyStats == null) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  ),
                );
              }

              if (dashboardProvider.error != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: Theme.of(context).colorScheme.error),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading data: ${dashboardProvider.error}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: darkMode ? Colors.white70 : Colors.red,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => _refreshData(context),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final stats = dashboardProvider.monthlyStats;
              if (stats == null || stats.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.analytics_outlined, size: 80, color: darkMode ? Colors.white54 : Colors.grey[400]),
                      const SizedBox(height: 20),
                      Text(
                        'No statistics data available for now.',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: darkMode ? Colors.white70 : Colors.black54,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () => _refreshData(context),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return _buildStatsList(context, stats, darkMode);
            },
          ),
        );
      },
    );
  }

  Widget _buildStatsList(BuildContext context, Map<String, Map<String, int>> stats, bool darkMode) {
    return Stack(
      children: [
        // Background decorative blobs
        Positioned(
          top: -50,
          right: -50,
          child: Opacity(
            opacity: 0.2, // Slightly reduced opacity
            child: _buildAssetImage(
              darkMode ? 'assets/images/blob-1.png' : 'assets/images/blob2-1.png',
              200,
              200,
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -100,
          child: Opacity(
            opacity: 0.2, // Slightly reduced opacity
            child: _buildAssetImage(
              darkMode ? 'assets/images/blob-2.png' : 'assets/images/blob2-2.png',
              290,
              290,
            ),
          ),
        ),
        RefreshIndicator(
          onRefresh: () => _refreshData(context),
          color: Theme.of(context).primaryColor, // Refresh indicator color
          backgroundColor: darkMode ? Colors.grey[800] : Colors.white,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: stats.length,
            itemBuilder: (context, index) {
              final monthKey = stats.keys.elementAt(index);
              final monthData = stats[monthKey]!;
              final monthName = _getMonthName(monthKey);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0), // More vertical space
                child: Card(
                  elevation: 6, // Increased elevation
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // More rounded corners
                    side: BorderSide(color: darkMode ? Colors.blueGrey.shade700 : Colors.blue.shade100, width: 1), // Subtle border
                  ),
                  color: darkMode ? const Color(0xFF0F4C75) : const Color(0xFF7996FF), // Your custom card colors
                  child: Padding(
                    padding: const EdgeInsets.all(20.0), // Increased padding inside card
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          monthName,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith( // Larger, more prominent month name
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Divider(color: Colors.white54, height: 24, thickness: 1), // Separator
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal, // Keep horizontal scroll for stats
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatCard(context, 'Lost Items', monthData['lost'] ?? 0, darkMode),
                              const SizedBox(width: 30), // Increased space between stat cards
                              _buildStatCard(context, 'Found Items', monthData['found'] ?? 0, darkMode),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAssetImage(String path, double width, double height) {
    // This is for the background blobs
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        color: Colors.transparent, // Should be transparent for blobs
        shape: BoxShape.circle,
      ),
      child: Image.asset(
        path,
        width: width,
        height: height,
        fit: BoxFit.contain, // Ensure image fits without distortion
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1), // Very subtle fallback color
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.broken_image, color: Colors.grey.withOpacity(0.5)), // Placeholder icon
          );
        },
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, int count, bool darkMode) {
    return Column(
      children: [
        Container(
          width: 80, // Slightly larger circle
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3), // More prominent translucent background
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28, // Larger font size for count
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12), // More space below circle
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 18, // Slightly larger font for title
            fontWeight: FontWeight.w600, // Medium bold
          ),
        ),
      ],
    );
  }

  String _getMonthName(String monthKey) {
    final parts = monthKey.split('-');
    final month = int.parse(parts[0]);
    final year = int.parse(parts[1]);

    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    if (month >= 1 && month <= 12) {
      return '${monthNames[month - 1]} $year';
    }
    return monthKey; // Fallback if monthKey format is unexpected
  }

  Future<void> _refreshData(BuildContext context) async {
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);

    // Only refresh if current user is an Administrator
    if (loginProvider.currentAccountHolder is Administrator) {
      await dashboardProvider.refreshStats();
    } else {
      // Optionally show a message if refresh is attempted by non-admin
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only administrators can refresh dashboard data.')),
      );
    }
  }
}
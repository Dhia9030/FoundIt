import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foundita/providers/theme_provider.dart';
import 'package:foundita/providers/dashboard_provider.dart';

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
      Provider.of<DashboardProvider>(context, listen: false).loadInitialStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final darkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: darkMode ? const Color(0xFF1B262C) : const Color(0xFFD1ECFF),
      appBar: AppBar(
        title: const Text('Statistiques Mensuelles'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshData(context),
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.monthlyStats == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Erreur de chargement',
                    style: TextStyle(
                      color: darkMode ? Colors.white : Colors.red,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _refreshData(context),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final stats = provider.monthlyStats;
          if (stats == null || stats.isEmpty) {
            return Center(
              child: Text(
                'Aucune donnée disponible',
                style: TextStyle(
                  color: darkMode ? Colors.white : Colors.black,
                  fontSize: 18,
                ),
              ),
            );
          }

          return _buildStatsList(context, stats, darkMode);
        },
      ),
    );
  }

  Widget _buildStatsList(BuildContext context, Map<String, Map<String, int>> stats, bool darkMode) {
    return Stack(
      children: [
        // Éléments de fond avec vérification de disponibilité des assets
        Positioned(
          top: -50,
          right: -50,
          child: Opacity(
            opacity: 0.3,
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
            opacity: 0.3,
            child: _buildAssetImage(
              darkMode ? 'assets/images/blob-2.png' : 'assets/images/blob2-2.png',
              290,
              290,
            ),
          ),
        ),

        // Contenu principal avec RefreshIndicator
        RefreshIndicator(
          onRefresh: () => _refreshData(context),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: stats.length,
            itemBuilder: (context, index) {
              final monthKey = stats.keys.elementAt(index);
              final monthData = stats[monthKey]!;
              final monthName = _getMonthName(monthKey);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: darkMode ? const Color(0xFF0F4C75) : const Color(0xFF7996FF),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          monthName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        // Correction pour éviter le débordement
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatCard(context, 'Objets Perdus', monthData['lost'] ?? 0, darkMode),
                              const SizedBox(width: 20), // Pour assurer l'espacement
                              _buildStatCard(context, 'Objets Trouvés', monthData['found'] ?? 0, darkMode),
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

  // Méthode pour gérer plus gracieusement les assets manquants
  Widget _buildAssetImage(String path, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Image.asset(
        path,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          // Fallback quand l'image n'est pas disponible
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, int count, bool darkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(String monthKey) {
    final parts = monthKey.split('-');
    final month = int.parse(parts[0]);
    final year = int.parse(parts[1]);
    
    final monthNames = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    
    return '${monthNames[month - 1]} $year';
  }

  Future<void> _refreshData(BuildContext context) async {
    await Provider.of<DashboardProvider>(context, listen: false).refreshStats();
  }
}
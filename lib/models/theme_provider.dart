import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _darkMode = false;
  
  bool get darkMode => _darkMode;
  
  ThemeProvider() {
    _loadThemePreference();
  }
  
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool('darkMode') ?? false;
    notifyListeners();
  }
  
  Future<void> toggleTheme(bool value) async {
    _darkMode = value;
    
    // Save preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    
    notifyListeners();
  }
  
  ThemeData get themeData => _darkMode 
    ? ThemeData.dark().copyWith(
        primaryColor: Color(0xFF539DF3),
        scaffoldBackgroundColor: Color(0xFF1B262C),
      )
    : ThemeData.light().copyWith(
        primaryColor: Color(0xFF539DF3),
        scaffoldBackgroundColor: Colors.white,
      );
}


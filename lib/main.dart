import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';

// Entry point of the whole app
void main() {
  runApp(const FitnessAppRoot());
}

// Root widget that sets up theme + home screen
class FitnessAppRoot extends StatefulWidget {
  const FitnessAppRoot({super.key});
  @override
  State<FitnessAppRoot> createState() => _FitnessAppRootState();
}

class _FitnessAppRootState extends State<FitnessAppRoot> {
  bool isDark = false; // true = dark mode
  bool loaded = false; // false until we load saved theme from prefs

  @override
  void initState() {
    super.initState();
    _loadTheme(); // read theme from SharedPreferences
  }

  // Get theme preference from SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getBool('darkMode') ?? false;
    setState(() {
      isDark = v;
      loaded = true;
    });
  }

  // Save theme preference and update UI
  Future<void> _setTheme(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', v);
    setState(() {
      isDark = v;
    });
  }

  @override
  Widget build(BuildContext context) {
    // While loading theme, just show a blank MaterialApp so there's no crash
    if (!loaded) {
      // NOTE: minimal placeholder while prefs load
      return MaterialApp(home: Container(color: Colors.black));
    }

    // Main MaterialApp for the app
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fitness Tracker App',
      theme: ThemeData.light(useMaterial3: true), // light theme
      darkTheme: ThemeData.dark(useMaterial3: true), // dark theme
      themeMode: isDark
          ? ThemeMode.dark
          : ThemeMode.light, // pick based on isDark
      home: HomeScreen(
        dark: isDark,
        onThemeChanged: (v) {
          _setTheme(v);
        },
      ),
    );
  }
}

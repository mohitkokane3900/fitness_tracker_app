import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const FitnessAppRoot());
}

class FitnessAppRoot extends StatefulWidget {
  const FitnessAppRoot({super.key});
  @override
  State<FitnessAppRoot> createState() => _FitnessAppRootState();
}

class _FitnessAppRootState extends State<FitnessAppRoot> {
  bool isDark = false;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getBool('darkMode') ?? false;
    setState(() {
      isDark = v;
      loaded = true;
    });
  }

  Future<void> _setTheme(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', v);
    setState(() {
      isDark = v;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return MaterialApp(home: Container(color: Colors.black));
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fitness Tracker App',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(
        dark: isDark,
        onThemeChanged: (v) {
          _setTheme(v);
        },
      ),
    );
  }
}

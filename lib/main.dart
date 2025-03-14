// lib/main.dart
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:sampana/lib/screens/fiangonana_list_screen.dart';
import 'package:sampana/lib/screens/membre_list_screen.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
  //   sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  // }
  runApp(const SampanaApp());
}

class SampanaApp extends StatelessWidget {
  const SampanaApp({super.key});

  static final ThemeData appTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFF5F6FA),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontFamily: 'Poppins', color: Color(0xFF2C3E50)),
      bodyMedium: TextStyle(fontFamily: 'Poppins', color: Color(0xFF757575)),
      headlineSmall: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          color: Color(0xFF2C3E50)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE67E22),
        textStyle: const TextStyle(fontFamily: 'Poppins'),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFE67E22),
      foregroundColor: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2C3E50),
      titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sampana Lehilahy',
      theme: appTheme,
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    MembreListScreen(),
    FiangonanaListScreen(),
  ];
  final List<String> _titles = [
    'Liste des Membres',
    'Liste des Fiangonana',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex],
            style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Color(0xFF2C3E50),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF2C3E50)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sampana Lehilahy',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Menu',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.people, color: Color(0xFFE67E22)),
              title: Text('Membres', style: TextStyle(fontFamily: 'Poppins')),
              selected: _selectedIndex == 0,
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.church, color: Color(0xFFE67E22)),
              title:
                  Text('Fiangonana', style: TextStyle(fontFamily: 'Poppins')),
              selected: _selectedIndex == 1,
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }
}

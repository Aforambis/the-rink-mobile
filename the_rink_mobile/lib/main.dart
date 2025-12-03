import 'package:flutter/material.dart';
import 'screens/main_navigation_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const TheRinkApp());
}

class TheRinkApp extends StatelessWidget {
  const TheRinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Rink',
      debugShowCheckedModeBanner: false,
      theme: WinterTheme.build(),
      home: const MainNavigationScreen(),
    );
  }
}

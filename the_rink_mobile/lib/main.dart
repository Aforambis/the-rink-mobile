import 'package:flutter/material.dart';
import 'screens/main_navigation_screen.dart';
import 'theme/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart'; // Import this
import 'package:provider/provider.dart'; // Import this
import 'screens/main_navigation_screen.dart'; // Ensure this matches your folder structure
import 'theme/app_theme.dart'; // Import your theme if you have one

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      // This is the "Power Station" for your app
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        title: 'The Rink',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.glacialBlue),
        ),
        // Now MainNavigationScreen can find the CookieRequest provider!
        home: const MainNavigationScreen(),
      ),
    );
  }
}

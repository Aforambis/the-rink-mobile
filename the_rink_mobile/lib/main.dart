import 'package:flutter/material.dart';
import 'screens/main_navigation_screen.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:the_rink_mobile/auth/login.dart';
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
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        title: 'The Rink',
        debugShowCheckedModeBanner: false,
        theme: WinterTheme.build(),
        home: const MainNavigationScreen(), // ubah ke login nanti kalo udh jadi
      ),
    );
  }
}
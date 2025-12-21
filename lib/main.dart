import 'package:flutter/material.dart';
import 'screens/main_navigation_screen.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'theme/app_theme.dart';

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
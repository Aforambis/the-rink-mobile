import 'package:flutter/material.dart';
import 'screens/main_navigation_screen.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:the_rink_mobile/auth/login.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const TheRinkApp());
}

class TheRinkApp extends StatelessWidget {
  const TheRinkApp({super.key});

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

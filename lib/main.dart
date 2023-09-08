import 'package:flutter/material.dart';
import 'package:passer/events_page.dart';
import 'package:passer/login_page.dart';
import 'package:passer/pass_page.dart';
import 'package:passer/splash_page.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
      url: 'https://gitqqdlhyjvkcaarhoqk.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdpdHFxZGxoeWp2a2NhYXJob3FrIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTMzODEwOTksImV4cCI6MjAwODk1NzA5OX0.RCJlX83-zxbjPl4XlUf_tSXz83d3FT_4s8DwPYivk_Q');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Passer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/": (context) => const SplashPage(),
        "/login": (context) => const LoginPage(),
        "/passes": (context) => const PassPage(),
        "/events": (context) => const EventsPage()
      },
    );
  }
}

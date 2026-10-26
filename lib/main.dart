import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_session_provider.dart';
import 'screens/login/login_screen.dart';

void main() {
  runApp(
    // 📦 Embrulha a app
    ChangeNotifierProvider(
      create: (_) => UserSessionProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

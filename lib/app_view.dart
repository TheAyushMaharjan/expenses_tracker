import 'package:expenses_tracker/screens/home/views/home_screen.dart';
import 'package:flutter/material.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Expense Tracker",
      theme:ThemeData(
        colorScheme: ColorScheme.light(
          surface: Colors.grey.shade300,
          onSurface: Colors.black,
          primary: const Color(0xFFE0A9E8),
          secondary: const Color(0xFFA9E8E0),
          tertiary: const Color(0xFF4A4A4A),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

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
          background: Colors.grey.shade300,
          onBackground: Colors.black,
          primary: Color(0xFFE0A9E8),
          secondary: Color(0xFFA9E8E0),
          tertiary: Color(0xFF4A4A4A),
        ),
      ),
      home: HomeScreen(),
    );
  }
}

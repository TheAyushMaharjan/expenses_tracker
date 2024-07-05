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
          secondary: Color(0xFF064f7),
          tertiary: Color(0xFFFF8D6C),
        ),
      ),
      home: HomeScreen(),
    );
  }
}

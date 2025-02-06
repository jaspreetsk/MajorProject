import 'package:academiax/constants/pallet.dart';
import 'package:academiax/screens/welcome_page_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AcademiaX',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Pallet.backgroundColor,
      ),
      home: const WelcomePage(),
    );
  }
}

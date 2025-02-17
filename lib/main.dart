import 'package:academiax/constants/pallet.dart';
import 'package:academiax/screens/welcome_page_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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

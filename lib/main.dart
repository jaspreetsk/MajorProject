import 'package:academiax/constants/pallet.dart';
import 'package:academiax/screens/hod_home_screen.dart';
import 'package:academiax/screens/student_home_screen.dart';
import 'package:academiax/screens/welcome_page_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
        home: FutureBuilder(
            future: SharedPreferences.getInstance(), // function to enable state persistence
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (!snapshot.hasError && snapshot.hasData) {
                  SharedPreferences? prefs = snapshot.data!;
                  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
                  String userType = prefs.getString('userType') ?? '';
                  if (isLoggedIn) {
                    if (userType == 'Students') {
                      return StudentHomeScreen();
                    } else if (userType == 'Heads of Departments') {
                      return HodHomeScreen();
                    }
                  }
                  return WelcomePage();
                } else {
                  return WelcomePage();
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }));
  }
}

import 'package:academiax/constants/pallet.dart';
import 'package:academiax/screens/loginpage.dart';
import 'package:academiax/screens/role_screen.dart';
import 'package:flutter/material.dart';

class LoginCreateAccScreen extends StatelessWidget {
  const LoginCreateAccScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffe3ffff),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xffe3ffff),
        title: const Text(
          "AcademiaX",
          style: TextStyle(
            color: Pallet.headingColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/login.gif',
              height: 250, // Adjust height as needed
            ),
            const SizedBox(
              height: 60,
            ),
            // Login Button
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => Loginpage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallet.buttonColor,
                minimumSize: const Size(220, 60),
              ),
              child: Text(
                "Login",
                style: TextStyle(
                  fontSize: 25,
                  color: Color(0xffe3ffff),
                ),
              ),
            ),
            const SizedBox(
              height: 60,
            ),
            // Create Account Button
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => RoleScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallet.buttonColor,
                minimumSize: const Size(200, 60),
              ),
              child: Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 25,
                  color: Color(0xffe3ffff),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

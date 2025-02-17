import 'package:academiax/constants/pallet.dart';
import 'package:academiax/screens/hod_create_account.dart';
import 'package:academiax/screens/student_create_account.dart';
import 'package:flutter/material.dart';

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Pallet.backgroundColor,
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
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Text(
                "Choose your role",
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  wordSpacing: -2,
                  color: Pallet.headingColor,
                ),
              ),
            ),
            const SizedBox(
              height: 194,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => StudentCreateAccount()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallet.buttonColor,
                minimumSize: const Size(200, 60),
              ),
              child: Text(
                "Student",
                style: TextStyle(
                  fontSize: 25,
                  color: Pallet.textColor,
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => HODCreateAccount()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallet.buttonColor,
                minimumSize: const Size(200, 60),
              ),
              child: Text(
                "HOD",
                style: TextStyle(
                  fontSize: 25,
                  color: Pallet.textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

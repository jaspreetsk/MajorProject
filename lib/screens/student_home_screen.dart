import 'package:academiax/constants/pallet.dart';
import 'package:flutter/material.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

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
            const SizedBox(
              height: 50,
            ),
            Text(
              'Hello,<Student name>',
              style: TextStyle(
                fontSize: 30,
                color: Pallet.headingColor,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallet.buttonColor,
                minimumSize: const Size(200, 60),
              ),
              child: Text(
                "Academic Details",
                style: TextStyle(
                  fontSize: 25,
                  color: Pallet.textColor,
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallet.buttonColor,
                minimumSize: const Size(200, 60),
              ),
              child: Text(
                "Research Work",
                style: TextStyle(
                  fontSize: 25,
                  color: Pallet.textColor,
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallet.buttonColor,
                minimumSize: const Size(200, 60),
              ),
              child: Text(
                "Internship",
                style: TextStyle(
                  fontSize: 25,
                  color: Pallet.textColor,
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallet.buttonColor,
                minimumSize: const Size(200, 60),
              ),
              child: Text(
                "Projects",
                style: TextStyle(
                  fontSize: 25,
                  color: Pallet.textColor,
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallet.buttonColor,
                minimumSize: const Size(200, 60),
              ),
              child: Text(
                "Online Course",
                style: TextStyle(
                  fontSize: 25,
                  color: Pallet.textColor,
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallet.buttonColor,
                minimumSize: const Size(200, 60),
              ),
              child: Text(
                "Club Details",
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

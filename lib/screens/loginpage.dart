import 'package:academiax/constants/pallet.dart';
import 'package:academiax/firebase_authentication/firebase_auth.dart';
import 'package:academiax/firebase_authentication/show_snack_bar.dart';
import 'package:academiax/screens/hod_home_screen.dart';
import 'package:academiax/screens/student_home_screen.dart';
import 'package:academiax/screens/welcome_page_screen.dart';
import 'package:academiax/wigets/textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  // controllers for manipulating/holding data for custom TextFieldArea() created in textfield.dart
  final TextEditingController emailIDController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // to dispose off texteditingcontrollers after their work is done.

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailIDController.dispose();
    passwordController.dispose();
  }

  void loginUser() async {
    FirebaseAuthMethods().loginInWithEmailandPassword(
        email: emailIDController.text,
        password: passwordController.text,
        context: context);

    final emailStudent =
        await emailAlreadyExistsStudent(emailIDController.text);

    final emailHOD = await emailAlreadyExistsHOD(emailIDController.text);

    if (emailStudent) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => StudentHomeScreen()));
    } else if (emailHOD) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => HodHomeScreen()));
    } else {
      showSnackBar(context, "Email not found :(");
    }
  }

  Future<bool> emailAlreadyExistsStudent(String email) async {
    final db = FirebaseFirestore.instance;
    final QuerySnapshot = await db
        .collection("Students")
        .where("email ID", isEqualTo: emailIDController.text)
        .limit(1)
        .get();

    return QuerySnapshot.docs.isNotEmpty;
  }

  Future<bool> emailAlreadyExistsHOD(String email) async {
    final db = FirebaseFirestore.instance;
    final QuerySnapshot = await db
        .collection("Heads of Departments")
        .where("email ID", isEqualTo: emailIDController.text)
        .limit(1)
        .get();

    return QuerySnapshot.docs.isNotEmpty;
  }

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
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => WelcomePage()),
              );
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Text(
                "Login",
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  wordSpacing: -2,
                  color: Pallet.headingColor,
                ),
              ),
            ),
            const SizedBox(
              height: 100,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  "Email ID",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Pallet.headingColor,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            TextFieldArea(
              textFieldController: emailIDController,
            ),
            const SizedBox(
              height: 30,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  "Password",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Pallet.headingColor,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            TextFieldArea(
              textFieldController: passwordController,
            ),
            const SizedBox(
              height: 60,
            ),
            ElevatedButton(
              onPressed: loginUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallet.buttonColor,
                minimumSize: const Size(200, 60),
              ),
              child: Text(
                "Login",
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

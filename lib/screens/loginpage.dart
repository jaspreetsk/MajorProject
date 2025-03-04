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
import 'package:shared_preferences/shared_preferences.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  // controllers for manipulating/holding data for custom TextFieldArea() created in textfield.dart
  final TextEditingController emailIDController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // to dispose off texteditingcontrollers after their work is done.

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailIDController.dispose();
    passwordController.dispose();
  }

  void loginUser() async {
    // First, attempt to sign in the user
    User? userCred = await FirebaseAuthMethods().loginInWithEmailandPassword(
        email: emailIDController.text,
        password: passwordController.text,
        context: context);

    if (userCred != null) {
      // Login was successful, now check email verification status
      User? user = _auth.currentUser;
      if (user != null && user.emailVerified) {
        // Email is verified, proceed to home screen
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        final emailStudent =
            await emailAlreadyExistsStudent(emailIDController.text);
        final emailHOD = await emailAlreadyExistsHOD(emailIDController.text);

        if (emailStudent) {
          await prefs.setString('userType', 'Students');
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => StudentHomeScreen()));
        } else if (emailHOD) {
          await prefs.setString('userType', 'Heads of Departments');
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HodHomeScreen()));
        } // No need for "else" here, email existence is already checked
      } else {
        // Email is not verified, show snackbar
        showSnackBar(context, "Please verify your email first");
        // Optionally, resend verification email if needed:
        // FirebaseAuthMethods().sendEmailVerification(context);
      }
    }
    // If userCred is null, login failed, FirebaseAuthMethods should handle error snackbar
  }

  Future<bool> emailAlreadyExistsStudent(String email) async {
    final db = FirebaseFirestore.instance;
    final QuerySnapshot = await db
        .collection("Students")
        .where("email", isEqualTo: emailIDController.text)
        .limit(1)
        .get();

    return QuerySnapshot.docs.isNotEmpty;
  }

  Future<bool> emailAlreadyExistsHOD(String email) async {
    final db = FirebaseFirestore.instance;
    final QuerySnapshot = await db
        .collection("Heads of Departments")
        .where("email", isEqualTo: emailIDController.text)
        .limit(1)
        .get();

    return QuerySnapshot.docs.isNotEmpty;
  }

  Future<void> resetPassword() async {
    String email = emailIDController.text;
    try {
      await _auth.sendPasswordResetEmail(email: email);
      setState(() {
        showSnackBar(context, "Check your email: $email to reset the password");
      });
    } catch (e) {
      setState(() {
        showSnackBar(context, "Failed to send the email please try again");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // 1. Ensure resizeToAvoidBottomInset is true
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
      body: SingleChildScrollView(
        // 2. Wrap body in SingleChildScrollView
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20.0), // Add horizontal padding
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
                Padding(
                  // 3. Add dynamic bottom padding to ElevatedButton
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: ElevatedButton(
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
                ),
                const SizedBox(
                  height: 30,
                ),
                TextButton(
                    onPressed: resetPassword,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Pallet.headingColor,
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

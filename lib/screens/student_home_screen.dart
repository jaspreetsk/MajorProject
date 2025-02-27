import 'package:academiax/constants/pallet.dart';

import 'package:academiax/firebase_authentication/firebase_auth.dart';
import 'package:academiax/screens/loginpage.dart';
import 'package:academiax/screens/student_academic_detalils_page.dart';
import 'package:academiax/screens/student_internship_page.dart';
import 'package:academiax/screens/student_project_page.dart';
import 'package:academiax/screens/student_research_paper.dart';
import 'package:academiax/screens/studnet_online_course_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  String studentName = 'Loading Name...'; // Initial loading state for name
  String enrollmentNumber =
      'Loading Enrollment...'; // Initial loading state for enrollment
  bool isLoading = true; // To indicate loading state

  @override
  void initState() {
    super.initState();
    _loadStudentData(); // Fetch student data when the screen initializes
  }

  Future<void> _loadStudentData() async {
    setState(() {
      isLoading = true; // Set loading to true when starting fetch
    });
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot studentDoc = await FirebaseFirestore.instance
            .collection(
                'Students') // Replace 'students' with your collection name
            .doc(user.uid)
            .get();

        if (studentDoc.exists) {
          setState(() {
            studentName = studentDoc.get('name') ??
                'Name not found'; // Get name field, handle null
            enrollmentNumber = studentDoc.get('enrollment Number') ??
                'Enrollment # not found'; // Get enrollment, handle null
            isLoading = false; // Data loaded, set loading to false
          });
        } else {
          setState(() {
            studentName =
                'Data not found'; // Handle case where document doesn't exist
            enrollmentNumber = 'Data not found';
            isLoading = false;
          });
          print(
              "Student document not found in Firestore"); // Log if document not found
        }
      } else {
        setState(() {
          studentName =
              'User not logged in'; // Handle case where user is not logged in (shouldn't happen if properly routed)
          enrollmentNumber = 'User not logged in';
          isLoading = false;
        });
        print("No user logged in."); // Log if no user logged in
      }
    } catch (e) {
      setState(() {
        studentName = 'Error loading data'; // Handle error during data fetch
        enrollmentNumber = 'Error loading data';
        isLoading = false;
      });
      print("Error loading student data: $e"); // Log error
    }
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
        leading: Builder(
          // Use Builder to get context for Scaffold.of
          builder: (BuildContext appBarContext) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                size: 35,
                color: Pallet.headingColor,
              ), // Hamburger icon
              onPressed: () {
                Scaffold.of(appBarContext).openDrawer(); // Open drawer
              },
              tooltip:
                  MaterialLocalizations.of(appBarContext).openAppDrawerTooltip,
            );
          },
        ),
      ),
      drawer: Drawer(
        // Add the Drawer here
        backgroundColor: Pallet.backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Pallet.headingColor,
              ),
              child: Text(
                'App Menu',
                style: TextStyle(
                  color: Pallet.backgroundColor,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.person_2,
                size: 25,
                color: Pallet.headingColor,
              ),
              title: Text(
                'My Profile',
                style: TextStyle(
                    color: Pallet.headingColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
                size: 25,
                color: Pallet.headingColor,
              ),
              title: Text(
                'Logout!',
                style: TextStyle(
                    color: Pallet.headingColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              ),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', false);
                FirebaseAuthMethods().signout(context);
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => Loginpage()));
              },
            ),
            // Removed Logout ListTile
          ],
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Text(
              '$studentName ($enrollmentNumber)',
              style: TextStyle(
                fontSize: 25,
                color: Pallet.headingColor,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => StudentAcademicDetalilsPage()));
              },
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
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => StudentResearchPaper()));
              },
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
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => StudentInternship()));
              },
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
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => StudentProject()));
              },
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
              onPressed: () {
                 Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => StudnetOnlineCourse()));
              },
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

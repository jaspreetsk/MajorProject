import 'package:academiax/constants/pallet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentAcademicDetalilsPage extends StatefulWidget {
  const StudentAcademicDetalilsPage({super.key});

  @override
  State<StudentAcademicDetalilsPage> createState() =>
      _StudentAcademicDetalilsPageState();
}

class _StudentAcademicDetalilsPageState
    extends State<StudentAcademicDetalilsPage> {
  String studentName = 'Loading Name...'; // Initial loading state for name
  String enrollmentNumber =
      'Loading Enrollment...'; // Initial loading state for enrollment
  bool isLoading = true; // To indicate loading state
  String studentDepartment = 'Loading Department...';
  int studentSemester = -1;

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
            studentDepartment =
                studentDoc.get('department') ?? 'Department not found';
            studentSemester =
                studentDoc.get('semester') ?? 'semester not found';
            isLoading = false; // Data loaded, set loading to false
          });
        } else {
          setState(() {
            studentName =
                'Data not found'; // Handle case where document doesn't exist
            enrollmentNumber = 'Data not found';
            isLoading = false;
            studentDepartment = 'Data not found';
            studentSemester = -1;
          });
          print(
              "Student document not found in Firestore"); // Log if document not found
        }
      } else {
        setState(() {
          studentName =
              'User not logged in'; // Handle case where user is not logged in (shouldn't happen if properly routed)
          enrollmentNumber = 'User not logged in';
          studentDepartment = 'User not logged in';
          studentSemester = -1;
          isLoading = false;
        });
        print("No user logged in."); // Log if no user logged in
      }
    } catch (e) {
      setState(() {
        studentName = 'Error loading data'; // Handle error during data fetch
        enrollmentNumber = 'Error loading data';
        studentDepartment = 'Error loading data';
        studentSemester = -1;
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
        backgroundColor: Pallet.headingColor,
        title: const Text(
          "Academic Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, top: 50),
        child: Column(
          children: [
             Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$studentName ($enrollmentNumber)',
                    style: TextStyle(
                      fontSize: 20,
                      color: Pallet.headingColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(
                height: 20,
              ),
              Text(
                    studentDepartment,
                    style: TextStyle(
                      fontSize: 20,
                      color: Pallet.headingColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(
                height: 20,
              ),
              Text(
                    'Semester: $studentSemester',
                    style: TextStyle(
                      fontSize: 20,
                      color: Pallet.headingColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(
                height: 20,
              ),
              ],
              ),
              
            
          ],
            ),
      ),
    );
  }
}

import 'package:academiax/constants/pallet.dart';
import 'package:academiax/screens/student_home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentClub extends StatefulWidget {
  const StudentClub({super.key});

  @override
  State<StudentClub> createState() => _StudentClubState();
}

class _StudentClubState extends State<StudentClub> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  String clubName = 'Loading Name...';
  bool isLoading = true;

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
      User? user = auth.currentUser;
      if (user != null) {
        DocumentSnapshot studentDoc = await firestore
            .collection(
                'Students') // Replace 'students' with your collection name
            .doc(user.uid)
            .get();

        if (studentDoc.exists) {
          setState(() {
            clubName = studentDoc.get('club') ??
                'Club not found'; // Get name field, handle null

            isLoading = false; // Data loaded, set loading to false
          });
        } else {
          setState(() {
            clubName =
                'Data not found'; // Handle case where document doesn't exist

            isLoading = false;
          });
        }
      } else {
        setState(() {
          clubName =
              'User not logged in'; // Handle case where user is not logged in (shouldn't happen if properly routed)

          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        clubName = 'Error loading data'; // Handle error during data fetch

        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Pallet.headingColor,
        title: const Text(
          "Club",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => StudentHomeScreen()),
            );
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Text(
          clubName,
          style: TextStyle(
            fontSize: 25,
            color: Pallet.headingColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

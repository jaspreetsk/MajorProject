import 'package:academiax/constants/pallet.dart';
import 'package:academiax/screens/student_home_screen.dart';
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
  // Map<String, dynamic>? studentData;
  Map<String, dynamic>? academicData;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
    // Fetch student data when the screen initializes
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
          if (studentSemester != -1) {
            _loadAcademicDetails(studentSemester);
          }
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

  _loadAcademicDetails(int semester) async {
    String docId = 'sem$semester';
    try {
      DocumentSnapshot academicSnapshot = await FirebaseFirestore.instance
          .collection(
              'Academic Details') // Replace 'academic details' with your collection name
          .doc(docId)
          .get();

      if (academicSnapshot.exists) {
        setState(() {
          academicData = academicSnapshot.data() as Map<String, dynamic>?;
        });
      } else {
        // Handle case where academic data is not found for this semester
        print('Academic data not found for semester $semester');
        setState(() {
          academicData = null; // Clear existing data if any
        });
      }
    } catch (e) {
      print('Error loading academic details: $e');
      setState(() {
        academicData = null; // Clear existing data if any
      });
      // Handle error gracefully
    }
  }

  List<DataColumn> _createColumns() {
    if (studentSemester == -1)
      return []; // Return empty if semester is not loaded yet

    if (studentSemester == 1) {
      return [
        DataColumn(
            label: Text(
          'Class',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 23),
        )),
        DataColumn(
            label: Text(
          'Percentage',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 23),
        )),
      ];
    } else if (studentSemester >= 2 && studentSemester <= 8) {
      return [
        DataColumn(
            label: Text(
          'Semester',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 23),
        )),
        DataColumn(
            label: Text(
          'SGPA',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 23),
        )),
        DataColumn(
            label: Text(
          'CGPA',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 23),
        )),
      ];
    }
    return []; // Default case, shouldn't usually reach here
  }

  List<DataRow> _createRows() {
    if (academicData == null)
      return []; // Return empty if academic data is not loaded

    if (studentSemester == 1) {
      return [
        DataRow(cells: [
          DataCell(Text(
            '10th',
            style: TextStyle(
                color: Pallet.extraColor,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          )),
          DataCell(Text(
            academicData?['SSC']?.toString() ?? 'N/A',
            style: TextStyle(
                color: Pallet.headingColor,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          )),
        ]),
        DataRow(cells: [
          DataCell(Text(
            '12th',
            style: TextStyle(
                color: Pallet.extraColor,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          )),
          DataCell(Text(
            academicData?['HSC']?.toString() ?? 'N/A',
            style: TextStyle(
                color: Pallet.headingColor,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          )),
        ]),
      ];
    } else if (studentSemester >= 2 && studentSemester <= 8) {
      List<DataRow> rows = [];
      for (int i = 1; i < studentSemester; i++) {
        // Display data up to previous semester
        String sem = '$i';
        rows.add(DataRow(cells: [
          DataCell(Text(
            'Semester $sem',
            style: TextStyle(
                color: Pallet.extraColor,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          )),
          DataCell(Text(
            academicData?['SGPA$sem']?.toString() ?? 'N/A',
            style: TextStyle(
                color: Pallet.headingColor,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          )),
          DataCell(Text(
            academicData?['CGPA$sem']?.toString() ?? 'N/A',
            style: TextStyle(
                color: Pallet.headingColor,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          )),
        ]));
      }
      

      return rows;
    }
    return []; // Default case
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
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => StudentHomeScreen()));
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
        ),
      ),
      body: studentSemester == -1
          ? Center(
              child:
                  CircularProgressIndicator()) // Loading indicator while student data is loading
          : Padding(
              padding: const EdgeInsets.only(left: 0, top: 50),
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
                  SizedBox(height: 20),
                  Text(
                    'Academic Performance',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Pallet.headingColor),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: SingleChildScrollView(
                      // Make table scrollable horizontally if needed
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: _createColumns(),
                        rows: _createRows(),
                        border: TableBorder.all(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

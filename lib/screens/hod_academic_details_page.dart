// hod_academic_details_page.dart
import 'package:academiax/constants/pallet.dart';
// Import StudentDetailsPage for navigation back
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HodAcademicDetailsPage extends StatefulWidget {
  final DocumentSnapshot studentDetails; // Receive student details as parameter

  const HodAcademicDetailsPage({Key? key, required this.studentDetails}) : super(key: key);

  @override
  State<HodAcademicDetailsPage> createState() => _HodAcademicDetailsPageState();
}

class _HodAcademicDetailsPageState extends State<HodAcademicDetailsPage> {
  String studentName = 'Loading Name...';
  String enrollmentNumber = 'Loading Enrollment...';
  bool isLoading = true;
  String studentDepartment = 'Loading Department...';
  int studentSemester = -1;
  Map<String, dynamic>? academicData;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Access student details from widget.studentDetails
      studentName = widget.studentDetails.get('name') ?? 'Name not found';
      enrollmentNumber = widget.studentDetails.get('enrollment Number') ?? 'Enrollment # not found';
      studentDepartment = widget.studentDetails.get('department') ?? 'Department not found';
      studentSemester = widget.studentDetails.get('semester') ?? -1;

      if (studentSemester != -1) {
        await _loadAcademicDetails(studentSemester); // Load academic details after basic student info
      }

      setState(() {
        isLoading = false;
      });

    } catch (e) {
      setState(() {
        studentName = 'Error loading data';
        enrollmentNumber = 'Error loading data';
        studentDepartment = 'Error loading data';
        studentSemester = -1;
        isLoading = false;
      });
      print("Error loading student data: $e");
    }
  }

  _loadAcademicDetails(int semester) async {
    String docId = 'sem$semester';
    try {
      DocumentSnapshot academicSnapshot = await FirebaseFirestore.instance
          .collection('Academic Details') // Replace 'academic details' with your collection name if different
          .doc(docId)
          .get();

      if (academicSnapshot.exists) {
        setState(() {
          academicData = academicSnapshot.data() as Map<String, dynamic>?;
        });
      } else {
        print('Academic data not found for semester $semester');
        setState(() {
          academicData = null;
        });
      }
    } catch (e) {
      print('Error loading academic details: $e');
      setState(() {
        academicData = null;
      });
    }
  }

  List<DataColumn> _createColumns() {
    if (studentSemester == -1) return [];
    if (studentSemester == 1) {
      return [
        DataColumn(label: Text('Class', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 23))),
        DataColumn(label: Text('Percentage', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 23))),
      ];
    } else if (studentSemester >= 2 && studentSemester <= 8) {
      return [
        DataColumn(label: Text('Semester', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 23))),
        DataColumn(label: Text('SGPA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 23))),
        DataColumn(label: Text('CGPA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 23))),
      ];
    }
    return [];
  }

  List<DataRow> _createRows() {
    if (academicData == null) return [];
    if (studentSemester == 1) {
      return [
        DataRow(cells: [
          DataCell(Text('10th', style: TextStyle(color: Pallet.extraColor, fontSize: 18, fontWeight: FontWeight.bold))),
          DataCell(Text(academicData?['SSC']?.toString() ?? 'N/A', style: TextStyle(color: Pallet.headingColor, fontSize: 18, fontWeight: FontWeight.bold))),
        ]),
        DataRow(cells: [
          DataCell(Text('12th', style: TextStyle(color: Pallet.extraColor, fontSize: 18, fontWeight: FontWeight.bold))),
          DataCell(Text(academicData?['HSC']?.toString() ?? 'N/A', style: TextStyle(color: Pallet.headingColor, fontSize: 18, fontWeight: FontWeight.bold))),
        ]),
      ];
    } else if (studentSemester >= 2 && studentSemester <= 8) {
      List<DataRow> rows = [];
      for (int i = 1; i < studentSemester; i++) {
        String sem = '$i';
        rows.add(DataRow(cells: [
          DataCell(Text('Semester $sem', style: TextStyle(color: Pallet.extraColor, fontSize: 18, fontWeight: FontWeight.bold))),
          DataCell(Text(academicData?['SGPA$sem']?.toString() ?? 'N/A', style: TextStyle(color: Pallet.headingColor, fontSize: 18, fontWeight: FontWeight.bold))),
          DataCell(Text(academicData?['CGPA$sem']?.toString() ?? 'N/A', style: TextStyle(color: Pallet.headingColor, fontSize: 18, fontWeight: FontWeight.bold))),
        ]));
      }
      return rows;
    }
    return [];
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
            Navigator.of(context).pop(); // Go back to StudentDetailsPage
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
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
                      const SizedBox(height: 20),
                      Text(
                        studentDepartment,
                        style: TextStyle(
                          fontSize: 20,
                          color: Pallet.headingColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Semester: $studentSemester',
                        style: TextStyle(
                          fontSize: 20,
                          color: Pallet.headingColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 20),
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
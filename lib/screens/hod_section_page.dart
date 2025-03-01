// // student_list_page.dart
// import 'package:academiax/constants/pallet.dart';
// import 'package:academiax/screens/hod_student_details_page.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class StudentListPage extends StatefulWidget {
//   final String year;
//   final String section;
//   final String departmentName;

//   const StudentListPage({
//     Key? key,
//     required this.year,
//     required this.section,
//     required this.departmentName,
//   }) : super(key: key);

//   @override
//   State<StudentListPage> createState() => _StudentListPageState();
// }

// class _StudentListPageState extends State<StudentListPage> {
//   List<DocumentSnapshot> studentList = [];
//   bool isLoadingStudents = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadStudentList();
//   }

//   Future<void> _loadStudentList() async {
//     setState(() {
//       isLoadingStudents = true;
//       studentList = [];
//     });
//     try {
//       QuerySnapshot studentSnapshot;
//       int semesterStart = 0;
//       int semesterEnd = 0;

//       if (widget.year == "Year I") {
//         semesterStart = 1;
//         semesterEnd = 2;
//       } else if (widget.year == "Year II") {
//         semesterStart = 3;
//         semesterEnd = 4;
//       } else if (widget.year == "Year III") {
//         semesterStart = 5;
//         semesterEnd = 6;
//       } else if (widget.year == "Year IV") {
//         semesterStart = 7;
//         semesterEnd = 8;
//       }

//       print(
//           "Department Name (Query): ${widget.departmentName}"); // ADD THIS LINE
      

//       studentSnapshot = await FirebaseFirestore.instance
//           .collection('Students')
//           .where('department', isEqualTo: widget.departmentName)
//           .where('semester', isGreaterThanOrEqualTo: semesterStart)
//           .where('semester', isLessThanOrEqualTo: semesterEnd)
//           .where('section', isEqualTo: widget.section)
//           .orderBy('name', descending: false)
//           .get();

//       setState(() {
//         studentList = studentSnapshot.docs;
//         isLoadingStudents = false;
//       });
//     } catch (e) {
//       print("Error loading student list: $e");
//       setState(() {
//         isLoadingStudents = false;
//         studentList = []; // Ensure list is empty in case of error
//       });
//     }
//   }

//   Widget _buildStudentTile(DocumentSnapshot studentDoc) {
//     String studentName = studentDoc.get('name') ?? 'No Name';
//     String enrollmentNumber = studentDoc.get('enrollment Number') ?? 'N/A';
//     print("Enrollment Number from Firestore: $enrollmentNumber");
//     String? profileImageUrl = studentDoc.get('profileImageUrl');

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 30,
//             backgroundColor: Pallet.buttonColor,
//             backgroundImage: profileImageUrl != null
//                 ? NetworkImage(profileImageUrl) as ImageProvider<Object>?
//                 : null, // Use null as default if no image URL
//             child: profileImageUrl == null
//                 ? const Icon(Icons.person, color: Pallet.textColor, size: 30)
//                 : null,
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 TextButton(onPressed: (){
//                     Navigator.of(context).push(
//                     MaterialPageRoute(builder: (context) => StudentDetailsPage(studentDetails: )));
//                 }, child: Text(
//                   studentName,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Pallet.headingColor,
//                   ),
//                 ),),
                
//                 const SizedBox(height: 4),
//                 Text(
//                   'Enrollment No: $enrollmentNumber',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     color: Pallet.headingColor,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: Pallet.backgroundColor,
//         title: Text(
//           '${widget.year} - ${widget.section}',
//           style: const TextStyle(
//             color: Pallet.headingColor,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         iconTheme: const IconThemeData(color: Pallet.headingColor),
//       ),
//       body: isLoadingStudents
//           ? const Center(
//               child: CircularProgressIndicator(color: Pallet.headingColor))
//           : studentList.isEmpty
//               ? Center(
//                   child: Text(
//                       "No students in ${widget.year} - ${widget.section}",
//                       style: const TextStyle(
//                           fontSize: 20, color: Pallet.headingColor)))
//               : ListView.builder(
//                   itemCount: studentList.length,
//                   itemBuilder: (context, index) {
//                     return _buildStudentTile(studentList[index]);
//                   },
//                 ),
//     );
//   }
// }

// student_list_page.dart
import 'package:academiax/constants/pallet.dart';
import 'package:academiax/screens/hod_student_details_page.dart';
 // Correct import path for StudentDetailsPage
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentListPage extends StatefulWidget {
  final String year;
  final String section;
  final String departmentName;

  const StudentListPage({
    Key? key,
    required this.year,
    required this.section,
    required this.departmentName,
  }) : super(key: key);

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  List<DocumentSnapshot> studentList = [];
  bool isLoadingStudents = true;

  @override
  void initState() {
    super.initState();
    _loadStudentList();
  }

  Future<void> _loadStudentList() async {
    setState(() {
      isLoadingStudents = true;
      studentList = [];
    });
    try {
      QuerySnapshot studentSnapshot;
      int semesterStart = 0;
      int semesterEnd = 0;

      if (widget.year == "Year I") {
        semesterStart = 1;
        semesterEnd = 2;
      } else if (widget.year == "Year II") {
        semesterStart = 3;
        semesterEnd = 4;
      } else if (widget.year == "Year III") {
        semesterStart = 5;
        semesterEnd = 6;
      } else if (widget.year == "Year IV") {
        semesterStart = 7;
        semesterEnd = 8;
      }

      print("Department Name (Query): ${widget.departmentName}");

      studentSnapshot = await FirebaseFirestore.instance
          .collection('Students')
          .where('department', isEqualTo: widget.departmentName)
          .where('semester', isGreaterThanOrEqualTo: semesterStart)
          .where('semester', isLessThanOrEqualTo: semesterEnd)
          .where('section', isEqualTo: widget.section)
          .orderBy('name', descending: false)
          .get();

      setState(() {
        studentList = studentSnapshot.docs;
        isLoadingStudents = false;
      });
    } catch (e) {
      print("Error loading student list: $e");
      setState(() {
        isLoadingStudents = false;
        studentList = []; // Ensure list is empty in case of error
      });
    }
  }

  Widget _buildStudentTile(DocumentSnapshot studentDoc) {
    String studentName = studentDoc.get('name') ?? 'No Name';
    String enrollmentNumber = studentDoc.get('enrollment Number') ?? 'N/A';
    print("Enrollment Number from Firestore: $enrollmentNumber");
    String? profileImageUrl = studentDoc.get('profileImageUrl');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          GestureDetector( // Added GestureDetector to make the profile picture tappable
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => StudentDetailsPage(studentDetails: studentDoc),
                ),
              );
            },
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Pallet.buttonColor,
              backgroundImage: profileImageUrl != null
                  ? NetworkImage(profileImageUrl) as ImageProvider<Object>?
                  : null,
              child: profileImageUrl == null
                  ? const Icon(Icons.person, color: Pallet.textColor, size: 30)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector( // Added GestureDetector to make the name tappable
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => StudentDetailsPage(studentDetails: studentDoc),
                      ),
                    );
                  },
                  child: Text(
                    studentName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Pallet.headingColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enrollment No: $enrollmentNumber',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Pallet.headingColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Pallet.backgroundColor,
        title: Text(
          '${widget.year} - ${widget.section}',
          style: const TextStyle(
            color: Pallet.headingColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Pallet.headingColor),
      ),
      body: isLoadingStudents
          ? const Center(
              child: CircularProgressIndicator(color: Pallet.headingColor))
          : studentList.isEmpty
              ? Center(
                  child: Text(
                      "No students in ${widget.year} - ${widget.section}",
                      style: const TextStyle(
                          fontSize: 20, color: Pallet.headingColor)))
              : ListView.builder(
                  itemCount: studentList.length,
                  itemBuilder: (context, index) {
                    return _buildStudentTile(studentList[index]);
                  },
                ),
    );
  }
}
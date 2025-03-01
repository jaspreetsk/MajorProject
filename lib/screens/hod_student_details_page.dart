// student_details_page.dart
import 'package:academiax/constants/pallet.dart';
import 'package:academiax/screens/hod_academic_details_page.dart';
import 'package:academiax/screens/hod_internship_details_page.dart';
import 'package:academiax/screens/hod_research_work_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentDetailsPage extends StatelessWidget {
  final DocumentSnapshot studentDetails;

  const StudentDetailsPage({Key? key, required this.studentDetails})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String studentName = studentDetails.get('name') ?? 'No Name';
    String enrollmentNumber = studentDetails.get('enrollment Number') ?? 'N/A';
    String email = studentDetails.get('email') ?? 'N/A';
    String phoneNumber = studentDetails.get('phone number') ?? 'N/A';
    String department = studentDetails.get('department') ?? 'N/A';
    int semester = studentDetails.get('semester') ?? 0;
    String section = studentDetails.get('section') ?? 'N/A';
    String? profileImageUrl = studentDetails.get('profileImageUrl');
    String studentID = studentDetails.get('uid');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Pallet.backgroundColor,
        title: const Text(
          'Student Details',
          style: TextStyle(
            color: Pallet.headingColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Pallet.headingColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundColor: Pallet.buttonColor,
              backgroundImage: profileImageUrl != null
                  ? NetworkImage(profileImageUrl) as ImageProvider<Object>?
                  : null,
              child: profileImageUrl == null
                  ? const Icon(Icons.person, color: Pallet.textColor, size: 80)
                  : null,
            ),
            const SizedBox(height: 20),
            Text(
              studentName,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Pallet.headingColor,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              '($enrollmentNumber)',
              style: const TextStyle(
                fontSize: 18,
                color: Pallet.extraColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Department', department),
            _buildDetailRow('Semester', semester.toString()),
            _buildDetailRow('Section', section),
            _buildDetailRow('Email', email),
            _buildDetailRow('Phone Number', phoneNumber),

            const SizedBox(height: 40), // Spacing before buttons
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => HodAcademicDetailsPage(
                        studentDetails: studentDetails)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallet.buttonColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text('Academic Details',
                  style: TextStyle(fontSize: 20, color: Pallet.textColor)),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => HodViewStudentResearchWorkPage(
                        studentId: studentID, studentName: studentName)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallet.buttonColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text('Research Work',
                  style: TextStyle(fontSize: 20, color: Pallet.textColor)),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => HodViewStudentInternshipWorkPage(studentId: studentID, studentName: studentName)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallet.buttonColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text('Internship',
                  style: TextStyle(fontSize: 20, color: Pallet.textColor)),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to Projects Page
                print("Projects Button Pressed");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallet.buttonColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text('Projects',
                  style: TextStyle(fontSize: 20, color: Pallet.textColor)),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to Online Courses Page
                print("Online Course Button Pressed");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallet.buttonColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text('Online Course',
                  style: TextStyle(fontSize: 20, color: Pallet.textColor)),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to Club Details Page
                print("Club Details Button Pressed");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallet.buttonColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text('Club Details',
                  style: TextStyle(fontSize: 20, color: Pallet.textColor)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.start, // Align label to start and value to end
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Pallet.headingColor,
            ),
          ),
          Text(
            " $value",
            style: const TextStyle(
              fontSize: 18,
              color: Pallet.headingColor,
            ),
          ),
        ],
      ),
    );
  }
}

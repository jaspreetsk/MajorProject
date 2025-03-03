import 'package:academiax/constants/pallet.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HodViewStudentClubPage extends StatefulWidget {
  final String studentId;
  final String studentName;

  const HodViewStudentClubPage(
      {super.key, required this.studentId, required this.studentName});

  @override
  _HodViewStudentClubPageState createState() =>
      _HodViewStudentClubPageState();
}

class _HodViewStudentClubPageState extends State<HodViewStudentClubPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  late Future<DocumentSnapshot> _studentDocument;

  @override
  void initState() {
    super.initState();
    _studentDocument = _fetchStudentDocument();
  }

  Future<DocumentSnapshot> _fetchStudentDocument() async {
    return firestore.collection('Students').doc(widget.studentId).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text('${widget.studentName}\'s Club',
                style: TextStyle(color: Colors.white))),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Pallet.headingColor,
      ),
      body: Center(
        child: FutureBuilder<DocumentSnapshot>(
          future: _studentDocument,
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text("Something went wrong: ${snapshot.error}");
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            if (snapshot.data == null || !snapshot.data!.exists) {
              return Text("Document does not exist");
            }

            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            String clubName = data['club'] ?? 'No Club Assigned';

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                clubName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Pallet.headingColor,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
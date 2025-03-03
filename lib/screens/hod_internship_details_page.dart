import 'package:academiax/constants/pallet.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HodViewStudentInternshipWorkPage extends StatefulWidget {
  final String studentId;
  final String studentName;

  const HodViewStudentInternshipWorkPage(
      {super.key, required this.studentId, required this.studentName});

  @override
  _HodViewStudentInternshipWorkPageState createState() =>
      _HodViewStudentInternshipWorkPageState();
}

class _HodViewStudentInternshipWorkPageState
    extends State<HodViewStudentInternshipWorkPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  late Stream<QuerySnapshot> _currentInternshipStream;
  late Stream<QuerySnapshot> _pastInternshipStream;

  @override
  void initState() {
    super.initState();
    _currentInternshipStream = _getInternshipStream('current');
    _pastInternshipStream = _getInternshipStream('past');
  }

  Stream<QuerySnapshot> _getInternshipStream(String internshipType) {
    return firestore
        .collection('internship') // Changed collection name to 'internship'
        .doc(widget
            .studentId) // Assuming studentId is the document ID in 'internship'
        .collection(internshipType) // Access 'current' or 'past' subcollection
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text('${widget.studentName}\'s Internship Work',
                style: TextStyle(color: Colors.white))),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Pallet.headingColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Current Internships",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Pallet.headingColor,
                ),
              ),
              _buildInternshipList(
                  internshipStream: _currentInternshipStream,
                  internshipType: 'current'),
              SizedBox(height: 20),
              Text(
                "Past Internships",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Pallet.headingColor,
                ),
              ),
              _buildInternshipList(
                  internshipStream: _pastInternshipStream,
                  internshipType: 'past'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInternshipList(
      {required Stream<QuerySnapshot> internshipStream,
      required String internshipType}) {
    return StreamBuilder<QuerySnapshot>(
      stream: internshipStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          print("Stream Error ($internshipType): ${snapshot.error}");
          return Text('Something went wrong: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          print("Stream Waiting ($internshipType)");
          return CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print("No data or empty docs for $internshipType");
          return Text("No $internshipType internships uploaded yet.");
        }

        print(
            "Data received for $internshipType, document count: ${snapshot.data!.docs.length}");

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot document = snapshot.data!.docs[index];
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;

            print(
                "Document data for $internshipType index $index: $data"); // Print document data

            String companyName =
                data['companyName'] ?? data['CompanyName'] ?? 'No Company Name';
            String fieldTechnology = data['field'] ??
                data['Field'] ??
                data['technology'] ??
                data['Technology'] ??
                'No Field Specified'; // Added field and technology
            String duration =
                data['duration'] ?? data['Duration'] ?? 'No Duration';
            String stipend = data['stipend'] ?? data['Stipend'] ?? 'No Stipend';
            dynamic certificateUrlData = data['certificateUrl'] ??
                data['certificateURL'] ??
                data['CertificateUrl'] ??
                data['CertificateURL'] ??
                ''; // Get certificate URL

            List<dynamic> certificates = [];
            if (certificateUrlData is String && certificateUrlData.isNotEmpty) {
              // Check if certificate URL is a String and not empty
              certificates = [
                certificateUrlData
              ]; // Treat single URL as a list for consistent UI code
            } else if (certificateUrlData is List) {
              // Handle case where it might still be a List (from previous data structure)
              certificates = certificateUrlData.cast<
                  dynamic>(); // Cast to dynamic to be safe, or ideally to <String> if you expect URLs
              print(
                  "Warning: certificateUrlData was a List. Handling as list, but should be String URL."); // Add a warning log
            }

            return Card(
              color: const Color.fromARGB(255, 249, 225, 172),
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyName,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Pallet.headingColor),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Field/Technology: $fieldTechnology', // Display Field/Technology
                      style:
                          TextStyle(fontSize: 14, color: Pallet.headingColor),
                    ),
                    Text(
                      'Duration: $duration', // Display Duration
                      style:
                          TextStyle(fontSize: 14, color: Pallet.headingColor),
                    ),
                    Text(
                      'Stipend: $stipend', // Display Stipend
                      style:
                          TextStyle(fontSize: 14, color: Pallet.headingColor),
                    ),
                    if (certificates.isNotEmpty) ...[
                      SizedBox(height: 10),
                      Text("Certificate URL:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Pallet
                                  .headingColor)), // Changed to Certificate URL
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: certificates
                            .map((certificateLink) => Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: InkWell(
                                    onTap: () async {
                                      var url = Uri.parse(certificateLink);
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Could not launch $certificateLink')),
                                        );
                                      }
                                    },
                                    child: Text(
                                      'View Certificate', // Changed to 'View Certificate'
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

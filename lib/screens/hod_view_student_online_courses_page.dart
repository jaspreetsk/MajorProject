import 'package:academiax/constants/pallet.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HodViewStudentOnlineCoursesPage extends StatefulWidget {
  final String studentId;
  final String studentName;

  const HodViewStudentOnlineCoursesPage(
      {super.key, required this.studentId, required this.studentName});

  @override
  _HodViewStudentOnlineCoursesPageState createState() =>
      _HodViewStudentOnlineCoursesPageState();
}

class _HodViewStudentOnlineCoursesPageState
    extends State<HodViewStudentOnlineCoursesPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  late Stream<QuerySnapshot> _currentCoursesStream;
  late Stream<QuerySnapshot> _pastCoursesStream;

  @override
  void initState() {
    super.initState();
    _currentCoursesStream = _getCoursesStream('current');
    _pastCoursesStream = _getCoursesStream('past');
  }

  Stream<QuerySnapshot> _getCoursesStream(String courseType) {
    return firestore
        .collection('online_courses')
        .doc(widget.studentId)
        .collection(courseType)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text('${widget.studentName}\'s Online Courses',
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
                "Current Online Courses",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Pallet.headingColor,
                ),
              ),
              _buildCoursesList(
                  coursesStream: _currentCoursesStream, courseType: 'current'),
              SizedBox(height: 20),
              Text(
                "Past Online Courses",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Pallet.headingColor,
                ),
              ),
              _buildCoursesList(
                  coursesStream: _pastCoursesStream, courseType: 'past'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoursesList(
      {required Stream<QuerySnapshot> coursesStream,
      required String courseType}) {
    return StreamBuilder<QuerySnapshot>(
      stream: coursesStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text("No $courseType online courses uploaded yet.");
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot document = snapshot.data!.docs[index];
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;

            String courseName = data['courseName'] ?? 'No Course Name';
            String duration = data['duration'] ?? 'No Duration';
            String platformName = data['platformName'] ?? 'No Platform Name';
            String skillsAcquired =
                data['skillsAcquired'] ?? 'No Skills Acquired';
            String uploadDate = data['timestamp'] != null
                ? data['timestamp'].toDate().toString()
                : 'No Upload Date';

            // Modified part to handle both 'proofDocumentUrl' and 'certificateUrl'
            dynamic certificateUrlsData =
                data['proofDocumentUrl'] ?? data['certificateUrl'] ?? [];
            List<dynamic> certificateUrls = [];
            if (certificateUrlsData is String &&
                certificateUrlsData.isNotEmpty) {
              certificateUrls = [certificateUrlsData];
            } else if (certificateUrlsData is List) {
              certificateUrls = certificateUrlsData.cast<String>();
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
                    // ... (rest of the course details display code is the same) ...
                    Text(
                      courseName,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Pallet.headingColor),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Platform: $platformName',
                      style:
                          TextStyle(fontSize: 14, color: Pallet.headingColor),
                    ),
                    Text(
                      'Duration: $duration',
                      style:
                          TextStyle(fontSize: 14, color: Pallet.headingColor),
                    ),
                    Text(
                      'Skills Acquired: $skillsAcquired',
                      style:
                          TextStyle(fontSize: 14, color: Pallet.headingColor),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Upload Date: $uploadDate',
                      style:
                          TextStyle(fontSize: 14, color: Pallet.headingColor),
                    ),

                    SizedBox(height: 10),

                    if (certificateUrls.isNotEmpty) ...[
                      Text("Certificate URLs:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Pallet.headingColor)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: certificateUrls
                            .map((documentLink) => Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: InkWell(
                                    onTap: () async {
                                      var url = Uri.parse(documentLink);
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Could not launch $documentLink')),
                                        );
                                      }
                                    },
                                    child: Text(
                                      'View Certificate',
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

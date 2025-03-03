import 'package:academiax/constants/pallet.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HodViewStudentProjectsPage extends StatefulWidget {
  final String studentId;
  final String studentName;

  const HodViewStudentProjectsPage(
      {super.key, required this.studentId, required this.studentName});

  @override
  _HodViewStudentProjectsPageState createState() =>
      _HodViewStudentProjectsPageState();
}

class _HodViewStudentProjectsPageState
    extends State<HodViewStudentProjectsPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  late Stream<QuerySnapshot> _currentProjectsStream;
  late Stream<QuerySnapshot> _pastProjectsStream;

  @override
  void initState() {
    super.initState();
    _currentProjectsStream = _getProjectsStream('current');
    _pastProjectsStream = _getProjectsStream('past');
  }

  Stream<QuerySnapshot> _getProjectsStream(String projectType) {
    return firestore
        .collection('projects')
        .doc(widget.studentId)
        .collection(projectType)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text('${widget.studentName}\'s Projects',
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
                "Current Projects",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Pallet.headingColor,
                ),
              ),
              _buildProjectsList(
                  projectStream: _currentProjectsStream,
                  projectType: 'current'),
              SizedBox(height: 20),
              Text(
                "Past Projects",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Pallet.headingColor,
                ),
              ),
              _buildProjectsList(
                  projectStream: _pastProjectsStream, projectType: 'past'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectsList(
      {required Stream<QuerySnapshot> projectStream,
      required String projectType}) {
    return StreamBuilder<QuerySnapshot>(
      stream: projectStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          print("Stream Error ($projectType): ${snapshot.error}");
          return Text('Something went wrong: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          print("Stream Waiting ($projectType)");
          return CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print("No data or empty docs for $projectType");
          return Text("No $projectType projects uploaded yet.");
        }

        print(
            "Data received for $projectType, document count: ${snapshot.data!.docs.length}");

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot document = snapshot.data!.docs[index];
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;

            print(
                "Document data for $projectType index $index: $data"); // Print document data

            String projectTitle = data['projectTitle'] ?? 'No Project Title';
            String projectDescription =
                data['projectDescription'] ?? 'No Description';
            List<dynamic> documentUrls =
                (data['documentUrl'] ?? []).cast<String>();
            List<dynamic> photoUrls = (data['photoUrl'] ?? []).cast<String>();
            List<dynamic> videoUrls = (data['videoUrl'] ?? []).cast<String>();
            String uploadDate = data['uploadDate'] != null
                ? data['uploadDate'].toDate().toString()
                : 'No Upload Date';

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
                      projectTitle,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Pallet.headingColor),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Description: $projectDescription',
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
                    if (photoUrls.isNotEmpty) ...[
                      Text("Photo URLs:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Pallet.headingColor)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: photoUrls
                            .map((photoLink) => Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: InkWell(
                                    onTap: () async {
                                      var url = Uri.parse(photoLink);
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Could not launch $photoLink')),
                                        );
                                      }
                                    },
                                    child: Text(
                                      'View Photo',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      SizedBox(height: 10),
                    ],
                    if (videoUrls.isNotEmpty) ...[
                      Text("Video URLs:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Pallet.headingColor)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: videoUrls
                            .map((videoLink) => Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: InkWell(
                                    onTap: () async {
                                      var url = Uri.parse(videoLink);
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Could not launch $videoLink')),
                                        );
                                      }
                                    },
                                    child: Text(
                                      'View Video',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      SizedBox(height: 10),
                    ],
                    if (documentUrls.isNotEmpty) ...[
                      Text("Document URLs:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Pallet.headingColor)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: documentUrls
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
                                      'View Document',
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

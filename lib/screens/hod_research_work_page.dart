// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'package:academiax/constants/pallet.dart';

// class HodViewStudentResearchWorkPage extends StatefulWidget {
//   final String studentId;
//   final String studentName;

//   HodViewStudentResearchWorkPage({required this.studentId, required this.studentName});

//   @override
//   _HodViewStudentResearchWorkPageState createState() => _HodViewStudentResearchWorkPageState();
// }

// class _HodViewStudentResearchWorkPageState extends State<HodViewStudentResearchWorkPage> {
//   FirebaseFirestore firestore = FirebaseFirestore.instance;
//   FirebaseAuth auth = FirebaseAuth.instance;

//   late Stream<QuerySnapshot> _currentResearchStream;
//   late Stream<QuerySnapshot> _pastResearchStream;

//   @override
//   void initState() {
//     super.initState();
//     _currentResearchStream = _getResearchPaperStream('current');
//     _pastResearchStream = _getResearchPaperStream('past');
//   }

//   Stream<QuerySnapshot> _getResearchPaperStream(String researchType) {
//     return firestore
//         .collection('research paper')
//         .doc(widget.studentId) // Assuming studentId is the document ID in 'research paper'
//         .collection(researchType) // Access 'current' or 'past' subcollection
//         .snapshots();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Center(child: Text('${widget.studentName}\'s Research Work', style: TextStyle(color: Colors.white))),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         backgroundColor: Pallet.headingColor,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Current Research Work",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Pallet.headingColor,
//                 ),
//               ),
//               _buildResearchList(researchStream: _currentResearchStream, researchType: 'current'),
//               SizedBox(height: 20),
//               Text(
//                 "Past Research Papers",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Pallet.headingColor,
//                 ),
//               ),
//               _buildResearchList(researchStream: _pastResearchStream, researchType: 'past'),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildResearchList({required Stream<QuerySnapshot> researchStream, required String researchType}) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: researchStream,
//       builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (snapshot.hasError) {
//           print("Stream Error ($researchType): ${snapshot.error}");
//           return Text('Something went wrong: ${snapshot.error}');
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           print("Stream Waiting ($researchType)");
//           return CircularProgressIndicator();
//         }

//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           print("No data or empty docs for $researchType");
//           return Text("No $researchType research papers uploaded yet.");
//         }

//         print("Data received for $researchType, document count: ${snapshot.data!.docs.length}");

//         return ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: snapshot.data!.docs.length,
//           itemBuilder: (context, index) {
//             DocumentSnapshot document = snapshot.data!.docs[index];
//             Map<String, dynamic> data = document.data() as Map<String, dynamic>;

//             print("Document data for $researchType index $index: $data"); // Print document data

//             String heading = data['heading'] ?? data['Heading'] ?? 'No Heading';
//             String description = data['description'] ?? data['Description'] ?? 'No Description';
//             String publishedLink = data['publishedLink'] ?? data['link'] ?? '';

//             // Debugging Prints for document URLs
//             print("$researchType - supportingDocuments raw data: ${data['supportingDocuments']}");
//             print("$researchType - researchPaperDocuments raw data: ${data['researchPaperDocuments']}");

//             List<dynamic> supportingDocuments = []; // Initialize as empty list
//             if (data['supportingDocuments'] is List) {
//               supportingDocuments = data['supportingDocuments'].cast<dynamic>(); // Safe cast if it's a List
//             } else if (data['supportingDocuments'] is String) {
//               print("Warning: supportingDocuments is a String for $researchType - needs fixing in Firestore");
//               // If it's a String, you might want to split it or handle it differently if it's a comma-separated list
//               // For now, using empty list to avoid error if it's a String
//             }

//             List<dynamic> researchPaperDocuments = []; // Initialize as empty list
//             if (data['researchPaperDocuments'] is List) {
//               researchPaperDocuments = data['researchPaperDocuments'].cast<dynamic>(); // Safe cast if it's a List
//             } else if (data['researchPaperDocuments'] is String) {
//               print("Warning: researchPaperDocuments is a String for $researchType - needs fixing in Firestore");
//               // Handle String case - similar to supportingDocuments
//             }

//             return Card(
//               color: Colors.white, // Changed Card color to white
//               elevation: 2,
//               margin: EdgeInsets.symmetric(vertical: 8),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             heading,
//                             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Pallet.headingColor),
//                           ),
//                           SizedBox(height: 8),
//                           if (researchType == 'current')
//                             Text(
//                               description,
//                               style: TextStyle(fontSize: 14, color: Pallet.textColor),
//                             )
//                           else if (researchType == 'past' && publishedLink.isNotEmpty)
//                             InkWell(
//                               onTap: () async {
//                                 var url = Uri.parse(publishedLink);
//                                 if (await canLaunchUrl(url)) {
//                                   await launchUrl(url);
//                                 } else {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(content: Text('Could not launch $publishedLink')),
//                                   );
//                                 }
//                               },
//                               child: Text(
//                                 'Published Link: $publishedLink',
//                                 style: TextStyle(fontSize: 14, color: Colors.blue, decoration: TextDecoration.underline),
//                               ),
//                             ),
//                           SizedBox(height: 10),

//                           if (supportingDocuments.isNotEmpty) ...[
//                             Text("Supporting Documents:", style: TextStyle(fontWeight: FontWeight.bold, color: Pallet.headingColor)),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: supportingDocuments.map((link) => Padding(
//                                 padding: const EdgeInsets.only(top: 4.0),
//                                 child: InkWell(
//                                   onTap: () async {
//                                     var url = Uri.parse(link);
//                                     if (await canLaunchUrl(url)) {
//                                       await launchUrl(url);
//                                     } else {
//                                       ScaffoldMessenger.of(context).showSnackBar(
//                                         SnackBar(content: Text('Could not launch $link')),
//                                       );
//                                     }
//                                   },
//                                   child: Text(
//                                     'Supporting Document Link',
//                                     style: TextStyle(fontSize: 14, color: Colors.blue, decoration: TextDecoration.underline),
//                                   ),
//                                 ),
//                               )).toList(),
//                             ),
//                             SizedBox(height: 10),
//                           ],

//                           if (researchPaperDocuments.isNotEmpty) ...[
//                             Text("Research Paper Document:", style: TextStyle(fontWeight: FontWeight.bold, color: Pallet.headingColor)),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: researchPaperDocuments.map((link) => Padding(
//                                 padding: const EdgeInsets.only(top: 4.0),
//                                 child: InkWell(
//                                   onTap: () async {
//                                     var url = Uri.parse(link);
//                                     if (await canLaunchUrl(url)) {
//                                       await launchUrl(url);
//                                     } else {
//                                       ScaffoldMessenger.of(context).showSnackBar(
//                                         SnackBar(content: Text('Could not launch $link')),
//                                       );
//                                     }
//                                   },
//                                   child: Text(
//                                     'Research Paper Link',
//                                     style: TextStyle(fontSize: 14, color: Colors.blue, decoration: TextDecoration.underline),
//                                   ),
//                                 ),
//                               )).toList(),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

import 'package:academiax/constants/pallet.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HodViewStudentResearchWorkPage extends StatefulWidget {
  final String studentId;
  final String studentName;

  HodViewStudentResearchWorkPage(
      {required this.studentId, required this.studentName});

  @override
  _HodViewStudentResearchWorkPageState createState() =>
      _HodViewStudentResearchWorkPageState();
}

class _HodViewStudentResearchWorkPageState
    extends State<HodViewStudentResearchWorkPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  late Stream<QuerySnapshot> _currentResearchStream;
  late Stream<QuerySnapshot> _pastResearchStream;

  @override
  void initState() {
    super.initState();
    _currentResearchStream = _getResearchPaperStream('current');
    _pastResearchStream = _getResearchPaperStream('past');
  }

  Stream<QuerySnapshot> _getResearchPaperStream(String researchType) {
    return firestore
        .collection('research paper')
        .doc(widget
            .studentId) // Assuming studentId is the document ID in 'research paper'
        .collection(researchType) // Access 'current' or 'past' subcollection
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text('${widget.studentName}\'s Research Work',
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
                "Current Research Work",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Pallet.headingColor,
                ),
              ),
              _buildResearchList(
                  researchStream: _currentResearchStream,
                  researchType: 'current'),
              SizedBox(height: 20),
              Text(
                "Past Research Papers",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Pallet.headingColor,
                ),
              ),
              _buildResearchList(
                  researchStream: _pastResearchStream, researchType: 'past'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResearchList(
      {required Stream<QuerySnapshot> researchStream,
      required String researchType}) {
    return StreamBuilder<QuerySnapshot>(
      stream: researchStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          print("Stream Error ($researchType): ${snapshot.error}");
          return Text('Something went wrong: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          print("Stream Waiting ($researchType)");
          return CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print("No data or empty docs for $researchType");
          return Text("No $researchType research papers uploaded yet.");
        }

        print(
            "Data received for $researchType, document count: ${snapshot.data!.docs.length}");

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot document = snapshot.data!.docs[index];
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;

            print(
                "Document data for $researchType index $index: $data"); // Print document data

            String heading = data['heading'] ?? data['Heading'] ?? 'No Heading';
            String description =
                data['description'] ?? data['Description'] ?? 'No Description';
            String publishedLink = data['publishedLink'] ?? data['link'] ?? '';

            List<dynamic> supportingDocuments = [];
            List<dynamic> researchPaperDocuments = [];

            if (researchType == 'current') {
              // For current papers, URLs are in 'documentUrl'
              if (data['documentUrl'] is List) {
                List<dynamic> docUrls = data['documentUrl'].cast<dynamic>();
                // Clean up potential empty string at the beginning of 'documentUrl' list
                researchPaperDocuments = docUrls
                    .where((url) => url != null && url.toString().isNotEmpty)
                    .toList();
                supportingDocuments =
                    researchPaperDocuments; // Assuming documentUrl contains both types for current
              }
            } else if (researchType == 'past') {
              // For past papers, research paper URLs are in 'researchPaperUrl'
              if (data['researchPaperUrl'] is List) {
                researchPaperDocuments =
                    data['researchPaperUrl'].cast<dynamic>();
              } else if (data['researchPaperUrl'] is String) {
                researchPaperDocuments = [
                  data['researchPaperUrl']
                ]; // Handle case if it's a single string URL
              }
              // Supporting documents are not present in the example past paper data
            }

            return Card(
              color: const Color.fromARGB(255, 249, 225, 172),
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            heading,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Pallet.headingColor),
                          ),
                          SizedBox(height: 8),
                          if (researchType == 'current')
                            Text(
                              description,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.blueGrey),
                            )
                          else if (researchType == 'past' &&
                              publishedLink.isNotEmpty)
                            InkWell(
                              onTap: () async {
                                var url = Uri.parse(publishedLink);
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Could not launch $publishedLink')),
                                  );
                                }
                              },
                              child: Text(
                                'Published Link: $publishedLink',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          SizedBox(height: 10),
                          if (supportingDocuments.isNotEmpty &&
                              researchType == 'current') ...[
                            // Only show for current for now
                            Text("Supporting Documents:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Pallet.headingColor)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: supportingDocuments
                                  .map((link) => Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: InkWell(
                                          onTap: () async {
                                            var url = Uri.parse(link);
                                            // **Enhanced Error Handling for canLaunchUrl and launchUrl:**
                                            if (await canLaunchUrl(
                                                Uri.parse(link))) {
                                              // Parse again for canLaunchUrl
                                              try {
                                                await launchUrl(Uri.parse(
                                                    link)); // Parse again for launchUrl
                                                print(
                                                    "Launched URL: $link"); // Success log
                                              } catch (e) {
                                                print(
                                                    "Error launching URL: $link, Error: $e"); // Launch error log
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          'Could not launch $link. Error: $e')),
                                                );
                                              }
                                            } else {
                                              print(
                                                  "Cannot launch URL: $link"); // canLaunchUrl failure log
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Could not launch $link')),
                                              );
                                            }
                                          },
                                          child: Text(
                                            'Supporting Document Link',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.blue,
                                                decoration:
                                                    TextDecoration.underline),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                            SizedBox(height: 10),
                          ],
                          if (researchPaperDocuments.isNotEmpty &&
                              researchType != 'current') ...[
                            Text("Research Paper Document:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Pallet.headingColor)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: researchPaperDocuments
                                  .map((link) => Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: InkWell(
                                          onTap: () async {
                                            var url = Uri.parse(link);
                                            // **Enhanced Error Handling for canLaunchUrl and launchUrl:**
                                            if (await canLaunchUrl(
                                                Uri.parse(link))) {
                                              // Parse again for canLaunchUrl
                                              try {
                                                await launchUrl(Uri.parse(
                                                    link)); // Parse again for launchUrl
                                                print(
                                                    "Launched URL: $link"); // Success log
                                              } catch (e) {
                                                print(
                                                    "Error launching URL: $link, Error: $e"); // Launch error log
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          'Could not launch $link. Error: $e')),
                                                );
                                              }
                                            } else {
                                              print(
                                                  "Cannot launch URL: $link"); // canLaunchUrl failure log
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Could not launch $link')),
                                              );
                                            }
                                          },
                                          child: Text(
                                            'Research Paper Link',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.blue,
                                                decoration:
                                                    TextDecoration.underline),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
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

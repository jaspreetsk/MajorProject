// import 'dart:io';

// import 'package:academiax/constants/pallet.dart';
// import 'package:academiax/firebase_authentication/show_snack_bar.dart';
// import 'package:academiax/screens/student_home_screen.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

// class StudentResearchPaper extends StatefulWidget {
//   const StudentResearchPaper({super.key});

//   @override
//   State<StudentResearchPaper> createState() => _StudentResearchPaperState();
// }

// class _StudentResearchPaperState extends State<StudentResearchPaper> {
//   String? _selectedOption;
//   TextEditingController _headingController = TextEditingController();
//   TextEditingController _descriptionController = TextEditingController();
//   TextEditingController _linkController = TextEditingController();
//   FirebaseFirestore firestore = FirebaseFirestore.instance;
//   FirebaseAuth auth = FirebaseAuth.instance;
//   FirebaseStorage storage = FirebaseStorage.instance;
//   File? _supportingDocumentFile;
//   File? _researchPaperFile;
//   String? _hoveredHeadingCurrent;
//   String? _hoveredHeadingPast;

//   Stream<QuerySnapshot<Map<String, dynamic>>>? _currentResearchStream;
//   Stream<QuerySnapshot<Map<String, dynamic>>>? _pastResearchStream;

//   @override
//   void initState() {
//     super.initState();
//     _loadResearchPapers();
//   }

//   void _loadResearchPapers() {
//     User? user = auth.currentUser;
//     String? studentDocumentId = user?.uid;
//     if (studentDocumentId != null) {
//       _currentResearchStream =
//           _getResearchPaperStream(studentDocumentId, 'current');
//       _pastResearchStream = _getResearchPaperStream(studentDocumentId, 'past');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: Pallet.headingColor,
//         title: const Text(
//           "Research Work",
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leading: IconButton(
//           onPressed: () {
//             Navigator.of(context).pushReplacement(
//               MaterialPageRoute(builder: (context) => StudentHomeScreen()),
//             );
//           },
//           icon: const Icon(
//             Icons.arrow_back,
//             color: Colors.white,
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Pallet.headingColor,
//         onPressed: () {
//           _showUploadDialog(context);
//         },
//         child: const Icon(
//           Icons.upload_file,
//           color: Colors.white,
//           size: 35,
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Current Research Work',
//                 style: TextStyle(
//                   fontSize: 25,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               _buildResearchList(
//                   researchStream: _currentResearchStream,
//                   researchType: 'current'),
//               const SizedBox(height: 20),
//               const Text(
//                 'Past Research Papers',
//                 style: TextStyle(
//                   fontSize: 25,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               _buildResearchList(
//                   researchStream: _pastResearchStream, researchType: 'past'),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildResearchList(
//       {required Stream<QuerySnapshot<Map<String, dynamic>>>? researchStream,
//       required String researchType}) {
//     return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//       stream: researchStream,
//       builder: (BuildContext context,
//           AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
//         if (snapshot.hasError) {
//           return Text('Error: ${snapshot.error}');
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const CircularProgressIndicator();
//         }

//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return Text('No $researchType research papers uploaded yet.');
//         }

//         return ListView.builder(
//           shrinkWrap: true,
//           physics:
//               const NeverScrollableScrollPhysics(), // to disable ListView's own scrolling
//           itemCount: snapshot.data!.docs.length,
//           itemBuilder: (context, index) {
//             DocumentSnapshot<Map<String, dynamic>> document =
//                 snapshot.data!.docs[index];
//             Map<String, dynamic> data = document.data()!;
//             String heading = data['heading'] ?? 'No Heading';
//             String description = data['description'] ?? 'No Description';
//             String link = data['link'] ?? ''; // Link is only for past papers
//             String documentUrl =
//                 data['documentUrl'] ?? ''; // Document URL for current papers
//             String researchPaperUrl = data['researchPaperUrl'] ??
//                 ''; // Research paper URL for past papers

//             return Card(
//               color: const Color.fromARGB(255, 249, 225, 172),
//               elevation: 4,
//               margin: const EdgeInsets.symmetric(vertical: 8),
//               child: Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       heading,
//                       style: const TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF468F92),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     if (description.isNotEmpty)
//                       Text(
//                         description,
//                         style: const TextStyle(
//                             fontSize: 18, color: Color(0xFF6C7F93)),
//                       ),
//                     if (link.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8.0),
//                         child: InkWell(
//                           onTap: () async {
//                             // Make onTap async
//                             final Uri uri = Uri.parse(link);
//                             bool canLaunch = await canLaunchUrl(
//                                 uri); // Capture canLaunchUrl result
//                             print(
//                                 'Can launch URL (Published Link - $heading): $canLaunch, URL: $link'); // Print to debug console
//                             if (canLaunch) {
//                               launchUrl(uri);
//                             } else {
//                               showSnackBar(
//                                   context, 'Could not launch URL: $link');
//                             }
//                           },
//                           child: Text(
//                             'Published Link: $link',
//                             style: const TextStyle(
//                                 color: Color(0XFF90AE85),
//                                 decoration: TextDecoration.underline,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ),
//                     if (documentUrl.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8.0),
//                         child: InkWell(
//                           onTap: () async {
//                             // Make onTap async
//                             final Uri uri = Uri.parse(documentUrl);
//                             bool canLaunch = await canLaunchUrl(
//                                 uri); // Capture canLaunchUrl result
//                             print(
//                                 'Can launch URL (Supporting Document - $heading): $canLaunch, URL: $documentUrl'); // Print to debug console
//                             if (canLaunch) {
//                               launchUrl(uri);
//                             } else {
//                               showSnackBar(context,
//                                   'Could not launch URL: $documentUrl');
//                             }
//                           },
//                           child: Text(
//                             'Supporting Document: View Document',
//                             style: const TextStyle(
//                                 color: Color(0XFF799ACC),
//                                 fontWeight: FontWeight.bold,
//                                 decoration: TextDecoration.underline),
//                           ),
//                         ),
//                       ),
//                     if (researchPaperUrl.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8.0),
//                         child: InkWell(
//                           onTap: () async {
//                             // Make onTap async
//                             final Uri uri = Uri.parse(researchPaperUrl);
//                             bool canLaunch = await canLaunchUrl(
//                                 uri); // Capture canLaunchUrl result
//                             print(
//                                 'Can launch URL (Research Paper Document - $heading): $canLaunch, URL: $researchPaperUrl'); // Print to debug console
//                             if (canLaunch) {
//                               launchUrl(uri);
//                             } else {
//                               showSnackBar(context,
//                                   'Could not launch URL: $researchPaperUrl');
//                             }
//                           },
//                           child: Text(
//                             'Research Paper Document: View Document',
//                             style: const TextStyle(
//                                 color: Color(0XFF799ACC),
//                                 fontWeight: FontWeight.bold,
//                                 decoration: TextDecoration.underline),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   void _showUploadDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setState) {
//             return AlertDialog(
//               title: const Text('Upload Research Paper'),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: <Widget>[
//                     DropdownButtonFormField<String>(
//                       decoration:
//                           const InputDecoration(labelText: 'Select Option'),
//                       value: _selectedOption,
//                       items: const [
//                         DropdownMenuItem(
//                           value: "current",
//                           child: Text("Add current working research work"),
//                         ),
//                         DropdownMenuItem(
//                           value: "past",
//                           child: Text("Add past published research papers"),
//                         ),
//                       ],
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           _selectedOption = newValue;
//                         });
//                       },
//                     ),
//                     if (_selectedOption == "current")
//                       Column(
//                         children: [
//                           const SizedBox(
//                             height: 15,
//                           ),
//                           TextFormField(
//                             controller: _headingController,
//                             decoration: const InputDecoration(
//                               labelText: 'Heading',
//                             ),
//                           ),
//                           const SizedBox(
//                             height: 5,
//                           ),
//                           TextFormField(
//                             controller: _descriptionController,
//                             decoration:
//                                 const InputDecoration(labelText: 'Description'),
//                             maxLines: 3,
//                           ),
//                           const SizedBox(
//                             height: 10,
//                           ),
//                           ElevatedButton(
//                             onPressed: () async {
//                               FilePickerResult? result =
//                                   await FilePicker.platform.pickFiles(
//                                 type: FileType.custom,
//                                 allowedExtensions: [
//                                   'jpg',
//                                   'png',
//                                   'pdf',
//                                   'docx',
//                                   'odt',
//                                 ],
//                               );

//                               if (result != null && result.files.isNotEmpty) {
//                                 setState(() {
//                                   _supportingDocumentFile =
//                                       File(result.files.first.path!);
//                                 });
//                                 print(
//                                     'Selected supporting document: ${_supportingDocumentFile!.path}'); // Debugging
//                               } else {
//                                 // User canceled the picker
//                               }
//                             },
//                             child: const Text(
//                               'Upload Supporting Documents',
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               minimumSize: const Size(50, 40),
//                             ),
//                           ),
//                           if (_supportingDocumentFile != null)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8.0),
//                               child: Text(
//                                   'Selected file: ${_supportingDocumentFile!.path.split('/').last}',
//                                   style: const TextStyle(
//                                       fontSize: 12, color: Colors.grey)),
//                             ),
//                         ],
//                       ),
//                     if (_selectedOption == "past")
//                       Column(
//                         children: [
//                           const SizedBox(
//                             height: 10,
//                           ),
//                           TextFormField(
//                             controller: _headingController,
//                             decoration:
//                                 const InputDecoration(labelText: 'Heading'),
//                           ),
//                           const SizedBox(
//                             height: 10,
//                           ),
//                           TextFormField(
//                             controller: _linkController,
//                             decoration: const InputDecoration(
//                                 labelText: 'Link of Published Research Paper'),
//                           ),
//                           const SizedBox(
//                             height: 10,
//                           ),
//                           ElevatedButton(
//                             onPressed: () async {
//                               FilePickerResult? result =
//                                   await FilePicker.platform.pickFiles(
//                                 type: FileType.custom,
//                                 allowedExtensions: [
//                                   'pdf',
//                                   'docx',
//                                   'odt',
//                                 ], // Past papers are usually PDFs
//                               );

//                               if (result != null && result.files.isNotEmpty) {
//                                 setState(() {
//                                   _researchPaperFile =
//                                       File(result.files.first.path!);
//                                 });
//                                 print(
//                                     'Selected research paper: ${_researchPaperFile!.path}'); // Debugging
//                               } else {
//                                 // User canceled the picker
//                               }
//                             },
//                             child: const Text('Upload Research Paper'),
//                           ),
//                           if (_researchPaperFile != null)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8.0),
//                               child: Text(
//                                   'Selected file: ${_researchPaperFile!.path.split('/').last}',
//                                   style: const TextStyle(
//                                       fontSize: 12, color: Colors.grey)),
//                             ),
//                         ],
//                       ),
//                   ],
//                 ),
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   child: const Text('Cancel'),
//                   onPressed: () {
//                     Navigator.of(dialogContext).pop();
//                     _selectedOption =
//                         null; // Reset selected option when dialog is closed
//                     _headingController.clear();
//                     _descriptionController.clear();
//                     _linkController.clear();
//                     _supportingDocumentFile = null;
//                     _researchPaperFile = null;
//                   },
//                 ),
//                 TextButton(
//                   child: const Text('Submit'),
//                   onPressed: () async {
//                     User? user = auth.currentUser;

//                     String? studentDocumentId = user?.uid;

//                     if (studentDocumentId != null) {
//                       String? supportingDocumentUrl;
//                       String? researchPaperUrl;

//                       if (_selectedOption == "current" &&
//                           _supportingDocumentFile != null) {
//                         supportingDocumentUrl = await _uploadFileToStorage(
//                             studentId: studentDocumentId,
//                             file: _supportingDocumentFile!,
//                             fileType: 'supporting_documents');
//                       } else if (_selectedOption == "past" &&
//                           _researchPaperFile != null) {
//                         researchPaperUrl = await _uploadFileToStorage(
//                             studentId: studentDocumentId,
//                             file: _researchPaperFile!,
//                             fileType: 'research_papers');
//                       }
//                       if (_selectedOption == "current") {
//                         String heading = _headingController.text;
//                         String description = _descriptionController.text;
//                         _uploadResearchData(
//                           studentId: studentDocumentId,
//                           type: "current",
//                           heading: heading,
//                           description: description,
//                           documentUrl: supportingDocumentUrl,
//                         );
//                       } else if (_selectedOption == "past") {
//                         String heading = _headingController.text;
//                         String link = _linkController.text;
//                         _uploadResearchData(
//                           studentId: studentDocumentId,
//                           type: "past",
//                           heading: heading,
//                           link: link,
//                           researchPaperUrl: researchPaperUrl,
//                         );
//                       }
//                       Navigator.of(dialogContext).pop();
//                       _selectedOption =
//                           null; // Reset selected option after submission
//                       _headingController.clear();
//                       _descriptionController.clear();
//                       _linkController.clear();
//                       _supportingDocumentFile = null;
//                       _researchPaperFile = null;
//                       _loadResearchPapers(); // Reload research papers after upload
//                     } else {
//                       showSnackBar(context, "Error: User not authenticated.");
//                     }
//                   },
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   Future<String?> _uploadFileToStorage({
//     required String studentId,
//     required File file,
//     required String fileType,
//   }) async {
//     try {
//       String fileName = file.path.split('/').last;
//       Reference storageReference = storage.ref().child(
//           'research_papers/$studentId/$fileType/$fileName'); // Storage path

//       UploadTask uploadTask = storageReference.putFile(file);
//       TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
//       String downloadUrl = await taskSnapshot.ref.getDownloadURL();
//       print('File uploaded to Firebase Storage. Download URL: $downloadUrl');
//       return downloadUrl;
//     } catch (e) {
//       print('Error uploading file to Firebase Storage: $e');
//       // Handle error, maybe return null or throw exception
//       return null;
//     }
//   }

//   // Function to upload research data to Firestore
//   Future<void> _uploadResearchData({
//     required String? studentId,
//     required String type,
//     String? heading,
//     String? description,
//     String? link,
//     String? documentUrl,
//     String? researchPaperUrl,
//   }) async {
//     print("--- _uploadResearchData ---");
//     print("Student ID: $studentId, Type: $type, Heading: $heading");
//     print(
//         "Description: $description, Link: $link, Document URL: $documentUrl, Research Paper URL: $researchPaperUrl");

//     try {
//       CollectionReference researchPapers = firestore
//           .collection('research paper'); // Use singular 'research paper'

//       // Document ID will be the same as student's document ID
//       DocumentReference studentDoc = researchPapers.doc(studentId);

//       CollectionReference typeCollection =
//           studentDoc.collection(type); // 'current' or 'past' subcollection
//       DocumentReference paperDoc = typeCollection
//           .doc(heading); // Use heading as document ID within subcollection

//       Map<String, dynamic> researchData = {};
//       researchData['type'] =
//           type; // Still include type for clarity, though redundant in subcollection
//       researchData['heading'] = heading;
//       if (description != null) {
//         researchData['description'] = description;
//       }
//       if (link != null) {
//         researchData['link'] = link;
//       }
//       if (documentUrl != null) {
//         researchData['documentUrl'] = documentUrl;
//       }
//       if (researchPaperUrl != null) {
//         researchData['researchPaperUrl'] = researchPaperUrl;
//       }

//       print("Firestore document path: ${paperDoc.path}");
//       print("Data to be written to Firestore: $researchData");

//       await paperDoc
//           .set(researchData) // Use set() to create or overwrite the document
//           .then((_) {
//         showSnackBar(context,
//             'Research data uploaded to Firestore for student ID: $studentId in $type collection');
//       }).catchError((error) {
//         showSnackBar(
//             context, 'Error uploading research data to Firestore: $error');
//       });

//       // Optionally show a success message to the user
//     } catch (e) {
//       showSnackBar(context, 'Error uploading research data to Firestore: $e');
//       // Optionally show an error message to the user
//     }
//   }

//   // Modified _getResearchPaperStream to fetch from subcollections
//   Stream<QuerySnapshot<Map<String, dynamic>>> _getResearchPaperStream(
//       String studentId, String type) {
//     return firestore
//         .collection('research paper')
//         .doc(studentId)
//         .collection(type) // Access the 'current' or 'past' subcollection
//         .snapshots() as Stream<QuerySnapshot<Map<String, dynamic>>>;
//   }
// }

// ADDING THE EDIT AND DELETE BUTTONS.

import 'dart:io';

import 'package:academiax/constants/pallet.dart';
import 'package:academiax/firebase_authentication/show_snack_bar.dart';
import 'package:academiax/screens/student_home_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

class StudentResearchPaper extends StatefulWidget {
  const StudentResearchPaper({super.key});

  @override
  State<StudentResearchPaper> createState() => _StudentResearchPaperState();
}

class _StudentResearchPaperState extends State<StudentResearchPaper> {
  String? _selectedOption;
  TextEditingController _headingController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _linkController = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  File? _supportingDocumentFile;
  File? _researchPaperFile;
  String? _hoveredHeadingCurrent;
  String? _hoveredHeadingPast;

  Stream<QuerySnapshot<Map<String, dynamic>>>? _currentResearchStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _pastResearchStream;

  @override
  void initState() {
    super.initState();
    _loadResearchPapers();
  }

  void _loadResearchPapers() {
    User? user = auth.currentUser;
    String? studentDocumentId = user?.uid;
    if (studentDocumentId != null) {
      _currentResearchStream =
          _getResearchPaperStream(studentDocumentId, 'current');
      _pastResearchStream = _getResearchPaperStream(studentDocumentId, 'past');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Pallet.headingColor,
        title: const Text(
          "Research Work",
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Pallet.headingColor,
        onPressed: () {
          _showUploadDialog(context);
        },
        child: const Icon(
          Icons.upload_file,
          color: Colors.white,
          size: 35,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Research Work',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildResearchList(
                  researchStream: _currentResearchStream,
                  researchType: 'current'),
              const SizedBox(height: 20),
              const Text(
                'Past Research Papers',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildResearchList(
                  researchStream: _pastResearchStream, researchType: 'past'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResearchList(
      {required Stream<QuerySnapshot<Map<String, dynamic>>>? researchStream,
      required String researchType}) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: researchStream,
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No $researchType research papers uploaded yet.');
        }

        return ListView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(), // to disable ListView's own scrolling
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot<Map<String, dynamic>> document =
                snapshot.data!.docs[index];
            Map<String, dynamic> data = document.data()!;
            String heading = data['heading'] ?? 'No Heading';
            String description = data['description'] ?? 'No Description';
            String link = data['link'] ?? ''; // Link is only for past papers
            String documentUrl =
                data['documentUrl'] ?? ''; // Document URL for current papers
            String researchPaperUrl = data['researchPaperUrl'] ??
                ''; // Research paper URL for past papers

            return Card(
              color: const Color.fromARGB(255, 249, 225, 172),
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  // Wrap with Row
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        // Use Expanded to take available space
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          heading,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF468F92),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (description.isNotEmpty)
                          Text(
                            description,
                            style: const TextStyle(
                                fontSize: 18, color: Color(0xFF6C7F93)),
                          ),
                        if (link.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: InkWell(
                              onTap: () async {
                                // Make onTap async
                                final Uri uri = Uri.parse(link);
                                bool canLaunch = await canLaunchUrl(
                                    uri); // Capture canLaunchUrl result
                                print(
                                    'Can launch URL (Published Link - $heading): $canLaunch, URL: $link'); // Print to debug console
                                if (canLaunch) {
                                  launchUrl(uri);
                                } else {
                                  showSnackBar(
                                      context, 'Could not launch URL: $link');
                                }
                              },
                              child: Text(
                                'Published Link: $link',
                                style: const TextStyle(
                                    color: Color(0XFF90AE85),
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        if (documentUrl.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: InkWell(
                              onTap: () async {
                                // Make onTap async
                                final Uri uri = Uri.parse(documentUrl);
                                bool canLaunch = await canLaunchUrl(
                                    uri); // Capture canLaunchUrl result
                                print(
                                    'Can launch URL (Supporting Document - $heading): $canLaunch, URL: $documentUrl'); // Print to debug console
                                if (canLaunch) {
                                  launchUrl(uri);
                                } else {
                                  showSnackBar(context,
                                      'Could not launch URL: $documentUrl');
                                }
                              },
                              child: Text(
                                'Supporting Document: View Document',
                                style: const TextStyle(
                                    color: Color(0XFF799ACC),
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          ),
                        if (researchPaperUrl.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: InkWell(
                              onTap: () async {
                                // Make onTap async
                                final Uri uri = Uri.parse(researchPaperUrl);
                                bool canLaunch = await canLaunchUrl(
                                    uri); // Capture canLaunchUrl result
                                print(
                                    'Can launch URL (Research Paper Document - $heading): $canLaunch, URL: $researchPaperUrl'); // Print to debug console
                                if (canLaunch) {
                                  launchUrl(uri);
                                } else {
                                  showSnackBar(context,
                                      'Could not launch URL: $researchPaperUrl');
                                }
                              },
                              child: Text(
                                'Research Paper Document: View Document',
                                style: const TextStyle(
                                    color: Color(0XFF799ACC),
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          ),
                      ],
                    )),
                    PopupMenuButton<String>(
                      color: const Color.fromARGB(255, 255, 217, 134),
                      icon: const Icon(Icons.more_vert),
                      onSelected: (String value) {
                        if (value == 'edit') {
                          _showEditDialog(context, document, researchType);
                          print('Edit option selected for: $heading');
                          // TODO: Implement edit functionality
                        } else if (value == 'delete') {
                          // Show confirmation dialog before deletion
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm Deletion'),
                                content: const Text(
                                    'Are you sure you want to delete this research paper?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Cancel deletion
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context)
                                          .pop(); // Dismiss the dialog
                                      String? studentId = auth.currentUser?.uid;
                                      if (studentId != null) {
                                        // Determine which file URL to delete based on research type
                                        String? fileUrl;
                                        if (researchType == "current") {
                                          fileUrl = documentUrl;
                                        } else if (researchType == "past") {
                                          fileUrl = researchPaperUrl;
                                        }
                                        await _deleteResearchPaper(
                                          studentId: studentId,
                                          researchType: researchType,
                                          heading: heading,
                                          fileUrl: fileUrl,
                                        );
                                      } else {
                                        showSnackBar(context,
                                            "Error: User not authenticated.");
                                      }
                                    },
                                    child: const Text('Yes, Delete'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Edit'),
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete),
                            title: Text('Delete'),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // New function: _showEditDialog
  // void _showEditDialog(BuildContext context,
  //     DocumentSnapshot<Map<String, dynamic>> document, String researchType) {
  //   // Get current field values
  //   String currentHeading = document.data()?['heading'] ?? '';
  //   String currentDescription = document.data()?['description'] ?? '';
  //   String currentLink = document.data()?['link'] ?? '';
  //   String currentFileUrl = researchType == 'current'
  //       ? (document.data()?['documentUrl'] ?? '')
  //       : (document.data()?['researchPaperUrl'] ?? '');

  //   // Controllers pre-populated with current values
  //   TextEditingController editHeadingController =
  //       TextEditingController(text: currentHeading);
  //   TextEditingController editDescriptionController =
  //       TextEditingController(text: currentDescription);
  //   TextEditingController editLinkController =
  //       TextEditingController(text: currentLink);

  //   File? _newFile;
  //   bool _deleteExistingFile = false;

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext dialogContext) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return AlertDialog(
  //             title: const Text('Edit Research Paper'),
  //             content: SingleChildScrollView(
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   // Editable heading
  //                   TextField(
  //                     controller: editHeadingController,
  //                     decoration: const InputDecoration(labelText: 'Heading'),
  //                   ),
  //                   const SizedBox(height: 10),
  //                   // For 'current' type show description field; for 'past' show link field
  //                   researchType == 'current'
  //                       ? TextField(
  //                           controller: editDescriptionController,
  //                           decoration:
  //                               const InputDecoration(labelText: 'Description'),
  //                           maxLines: 3,
  //                         )
  //                       : TextField(
  //                           controller: editLinkController,
  //                           decoration: const InputDecoration(
  //                               labelText: 'Published Link'),
  //                         ),
  //                   const SizedBox(height: 20),
  //                   // Display current file (if exists and not marked for deletion)
  //                   if (!_deleteExistingFile && currentFileUrl.isNotEmpty)
  //                     Row(
  //                       children: [
  //                         Expanded(
  //                           child: Text(
  //                             'Current file: ${currentFileUrl.split('/').last}',
  //                             style: const TextStyle(fontSize: 14),
  //                           ),
  //                         ),
  //                         IconButton(
  //                           icon: const Icon(Icons.delete, color: Colors.red),
  //                           onPressed: () {
  //                             setState(() {
  //                               _deleteExistingFile = true;
  //                             });
  //                           },
  //                         ),
  //                       ],
  //                     ),
  //                   if (_deleteExistingFile)
  //                     const Text(
  //                       'File will be deleted.',
  //                       style: TextStyle(color: Colors.red),
  //                     ),
  //                   const SizedBox(height: 10),
  //                   // Button to replace the file (which resets any deletion flag)
  //                   ElevatedButton(
  //                     onPressed: () async {
  //                       FilePickerResult? result =
  //                           await FilePicker.platform.pickFiles(
  //                         type: FileType.custom,
  //                         allowedExtensions: researchType == 'current'
  //                             ? ['jpg', 'png', 'pdf', 'docx', 'odt']
  //                             : ['pdf', 'docx', 'odt'],
  //                       );
  //                       if (result != null && result.files.isNotEmpty) {
  //                         setState(() {
  //                           _newFile = File(result.files.first.path!);
  //                           _deleteExistingFile = false;
  //                         });
  //                         print('Selected new file: ${_newFile!.path}');
  //                       }
  //                     },
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: Pallet.headingColor,
  //                     ),
  //                     child: const Text(
  //                       'Replace File',
  //                       style: TextStyle(color: Colors.white),
  //                     ),
  //                   ),
  //                   if (_newFile != null)
  //                     Padding(
  //                       padding: const EdgeInsets.only(top: 8.0),
  //                       child: Text(
  //                         'New file: ${_newFile!.path.split('/').last}',
  //                         style:
  //                             const TextStyle(fontSize: 12, color: Colors.grey),
  //                       ),
  //                     ),
  //                 ],
  //               ),
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.of(dialogContext).pop();
  //                 },
  //                 child: const Text('Cancel'),
  //               ),
  //               TextButton(
  //                 onPressed: () async {
  //                   // Get updated values
  //                   String updatedHeading = editHeadingController.text.trim();
  //                   String updatedDescription =
  //                       editDescriptionController.text.trim();
  //                   String updatedLink = editLinkController.text.trim();

  //                   String? newFileUrl;
  //                   // If a new file was selected, upload it
  //                   if (_newFile != null) {
  //                     newFileUrl = await _uploadFileToStorage(
  //                       studentId: auth.currentUser!.uid,
  //                       file: _newFile!,
  //                       fileType: researchType == 'current'
  //                           ? 'supporting_documents'
  //                           : 'research_papers',
  //                     );
  //                   } else if (_deleteExistingFile &&
  //                       currentFileUrl.isNotEmpty) {
  //                     // Delete the existing file from storage if deletion is requested
  //                     try {
  //                       Reference fileRef = storage.refFromURL(currentFileUrl);
  //                       await fileRef.delete();
  //                       print('Deleted file: $currentFileUrl');
  //                     } catch (e) {
  //                       print('Error deleting file: $e');
  //                     }
  //                   }

  //                   // Build the update data map
  //                   Map<String, dynamic> updateData = {};
  //                   updateData['heading'] = updatedHeading;
  //                   if (researchType == 'current') {
  //                     updateData['description'] = updatedDescription;
  //                     if (_newFile != null) {
  //                       updateData['documentUrl'] = newFileUrl;
  //                     } else if (_deleteExistingFile) {
  //                       updateData['documentUrl'] = '';
  //                     }
  //                   } else {
  //                     updateData['link'] = updatedLink;
  //                     if (_newFile != null) {
  //                       updateData['researchPaperUrl'] = newFileUrl;
  //                     } else if (_deleteExistingFile) {
  //                       updateData['researchPaperUrl'] = '';
  //                     }
  //                   }

  //                   String studentId = auth.currentUser!.uid;
  //                   // Since you are using the heading as document ID, if it has changed you can choose to:
  //                   // Option A: update the document in place (document id remains unchanged) or
  //                   // Option B: create a new document with the updated heading and delete the old one.
  //                   // Below is an approach for Option B.
  //                   String oldDocId = currentHeading; // original document ID
  //                   if (updatedHeading != currentHeading) {
  //                     // Create new document with updated heading
  //                     await firestore
  //                         .collection('research paper')
  //                         .doc(studentId)
  //                         .collection(researchType)
  //                         .doc(updatedHeading)
  //                         .set(updateData);
  //                     // Delete the old document
  //                     await firestore
  //                         .collection('research paper')
  //                         .doc(studentId)
  //                         .collection(researchType)
  //                         .doc(oldDocId)
  //                         .delete();
  //                   } else {
  //                     // If the heading remains the same, update in place
  //                     await firestore
  //                         .collection('research paper')
  //                         .doc(studentId)
  //                         .collection(researchType)
  //                         .doc(oldDocId)
  //                         .update(updateData);
  //                   }

  //                   Navigator.of(dialogContext).pop();
  //                   _loadResearchPapers(); // Refresh list after update
  //                 },
  //                 child: const Text('Update'),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
  void _showEditDialog(BuildContext context,
      DocumentSnapshot<Map<String, dynamic>> document, String researchType) {
    // Get current field values
    String currentHeading = document.data()?['heading'] ?? '';
    String currentDescription = document.data()?['description'] ?? '';
    String currentLink = document.data()?['link'] ?? '';
    String currentFileUrl = researchType == 'current'
        ? (document.data()?['documentUrl'] ?? '')
        : (document.data()?['researchPaperUrl'] ?? '');

    // Controllers pre-populated with current values
    TextEditingController editHeadingController =
        TextEditingController(text: currentHeading);
    TextEditingController editDescriptionController =
        TextEditingController(text: currentDescription);
    TextEditingController editLinkController =
        TextEditingController(text: currentLink);

    File? _newFile;
    bool _deleteExistingFile = false;
    List<File> _additionalFiles = []; // List to store additional files

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Research Paper'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Editable heading
                    TextField(
                      controller: editHeadingController,
                      decoration: const InputDecoration(labelText: 'Heading'),
                    ),
                    const SizedBox(height: 10),
                    // For 'current' type show description field; for 'past' show link field
                    researchType == 'current'
                        ? TextField(
                            controller: editDescriptionController,
                            decoration:
                                const InputDecoration(labelText: 'Description'),
                            maxLines: 3,
                          )
                        : TextField(
                            controller: editLinkController,
                            decoration: const InputDecoration(
                                labelText: 'Published Link'),
                          ),
                    const SizedBox(height: 20),
                    // Display current file (if exists and not marked for deletion)
                    if (!_deleteExistingFile && currentFileUrl.isNotEmpty)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Current file: ${currentFileUrl.split('/').last}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _deleteExistingFile = true;
                              });
                            },
                          ),
                        ],
                      ),
                    if (_deleteExistingFile)
                      const Text(
                        'File will be deleted.',
                        style: TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      // Row to contain Replace and Add Document buttons
                      children: [
                        Expanded(
                          // Use Expanded to make buttons share space
                          child: ElevatedButton(
                            onPressed: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: researchType == 'current'
                                    ? ['jpg', 'png', 'pdf', 'docx', 'odt']
                                    : ['pdf', 'docx', 'odt'],
                              );
                              if (result != null && result.files.isNotEmpty) {
                                setState(() {
                                  _newFile = File(result.files.first.path!);
                                  _deleteExistingFile = false;
                                });
                                print('Selected new file: ${_newFile!.path}');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Pallet.headingColor),
                            child: const Text(
                              'Replace File',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8), // Space between buttons
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowMultiple:
                                    true, // Allow multiple files selection
                                allowedExtensions: researchType == 'current'
                                    ? ['jpg', 'png', 'pdf', 'docx', 'odt']
                                    : ['pdf', 'docx', 'odt'],
                              );
                              if (result != null && result.files.isNotEmpty) {
                                setState(() {
                                  for (var file in result.files) {
                                    if (file.path != null) {
                                      _additionalFiles.add(File(file.path!));
                                    }
                                  }
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Pallet.headingColor),
                            child: const Text(
                              'Add Document',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (_newFile != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'New file: ${_newFile!.path.split('/').last}',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    if (_additionalFiles.isNotEmpty) // Display added files
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Added documents:',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            ..._additionalFiles.map((file) => Text(
                                  '• ${file.path.split('/').last}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                )),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    // Get updated values
                    String updatedHeading = editHeadingController.text.trim();
                    String updatedDescription =
                        editDescriptionController.text.trim();
                    String updatedLink = editLinkController.text.trim();

                    String? newFileUrl;
                    // If a new file was selected (replace file button)
                    if (_newFile != null) {
                      newFileUrl = await _uploadFileToStorage(
                        studentId: auth.currentUser!.uid,
                        file: _newFile!,
                        fileType: researchType == 'current'
                            ? 'supporting_documents'
                            : 'research_papers',
                      );
                    } else if (_deleteExistingFile &&
                        currentFileUrl.isNotEmpty) {
                      // Delete the existing file from storage if deletion is requested
                      try {
                        Reference fileRef = storage.refFromURL(currentFileUrl);
                        await fileRef.delete();
                        print('Deleted file: $currentFileUrl');
                      } catch (e) {
                        print('Error deleting file: $e');
                      }
                    }

                    // Upload additional files and get their URLs
                    List<String> newAdditionalUrls = [];
                    for (var file in _additionalFiles) {
                      String? url = await _uploadFileToStorage(
                        studentId: auth.currentUser!.uid,
                        file: file,
                        fileType: researchType == 'current'
                            ? 'supporting_documents'
                            : 'research_papers',
                      );
                      if (url != null) {
                        newAdditionalUrls.add(url);
                      }
                    }

                    // Build the update data map
                    Map<String, dynamic> updateData = {};
                    updateData['heading'] = updatedHeading;
                    if (researchType == 'current') {
                      updateData['description'] = updatedDescription;
                      if (_newFile != null) {
                        updateData['documentUrl'] = newFileUrl;
                      } else if (_deleteExistingFile) {
                        updateData['documentUrl'] = '';
                      }
                      // Add new additional document URLs if any
                      if (newAdditionalUrls.isNotEmpty) {
                        List<String> existingUrls =
                            document.data()?['documentUrls'] != null
                                ? List<String>.from(
                                    document.data()?['documentUrls'])
                                : currentFileUrl.isNotEmpty
                                    ? [currentFileUrl]
                                    : [];
                        updateData['documentUrls'] = [
                          ...existingUrls,
                          ...newAdditionalUrls
                        ];
                      }
                    } else {
                      updateData['link'] = updatedLink;
                      if (_newFile != null) {
                        updateData['researchPaperUrl'] = newFileUrl;
                      } else if (_deleteExistingFile) {
                        updateData['researchPaperUrl'] = '';
                      }
                      // Add new additional research paper URLs if any
                      if (newAdditionalUrls.isNotEmpty) {
                        List<String> existingUrls =
                            document.data()?['researchPaperUrls'] != null
                                ? List<String>.from(
                                    document.data()?['researchPaperUrls'])
                                : currentFileUrl.isNotEmpty
                                    ? [currentFileUrl]
                                    : [];
                        updateData['researchPaperUrls'] = [
                          ...existingUrls,
                          ...newAdditionalUrls
                        ];
                      }
                    }

                    String studentId = auth.currentUser!.uid;
                    // Option B: Create a new document if the heading (document ID) has changed.
                    String oldDocId = currentHeading; // original document ID
                    if (updatedHeading != currentHeading) {
                      // Create new document with updated heading
                      await firestore
                          .collection('research paper')
                          .doc(studentId)
                          .collection(researchType)
                          .doc(updatedHeading)
                          .set(updateData);
                      // Delete the old document
                      await firestore
                          .collection('research paper')
                          .doc(studentId)
                          .collection(researchType)
                          .doc(oldDocId)
                          .delete();
                    } else {
                      // If the heading remains the same, update in place
                      await firestore
                          .collection('research paper')
                          .doc(studentId)
                          .collection(researchType)
                          .doc(oldDocId)
                          .update(updateData);
                    }

                    Navigator.of(dialogContext).pop();
                    _loadResearchPapers(); // Refresh list after update
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Upload Research Paper'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'Select Option'),
                      value: _selectedOption,
                      items: const [
                        DropdownMenuItem(
                          value: "current",
                          child: Text("Add current working research work"),
                        ),
                        DropdownMenuItem(
                          value: "past",
                          child: Text("Add past published research papers"),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedOption = newValue;
                        });
                      },
                    ),
                    if (_selectedOption == "current")
                      Column(
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            controller: _headingController,
                            decoration: const InputDecoration(
                              labelText: 'Heading',
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            controller: _descriptionController,
                            decoration:
                                const InputDecoration(labelText: 'Description'),
                            maxLines: 3,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: [
                                  'jpg',
                                  'png',
                                  'pdf',
                                  'docx',
                                  'odt',
                                ],
                              );

                              if (result != null && result.files.isNotEmpty) {
                                setState(() {
                                  _supportingDocumentFile =
                                      File(result.files.first.path!);
                                });
                                print(
                                    'Selected supporting document: ${_supportingDocumentFile!.path}'); // Debugging
                              } else {
                                // User canceled the picker
                              }
                            },
                            child: const Text(
                              'Upload Supporting Documents',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Pallet.headingColor,
                              minimumSize: const Size(50, 40),
                            ),
                          ),
                          if (_supportingDocumentFile != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                  'Selected file: ${_supportingDocumentFile!.path.split('/').last}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ),
                        ],
                      ),
                    if (_selectedOption == "past")
                      Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: _headingController,
                            decoration:
                                const InputDecoration(labelText: 'Heading'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: _linkController,
                            decoration: const InputDecoration(
                                labelText: 'Link of Published Research Paper'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: [
                                  'pdf',
                                  'docx',
                                  'odt',
                                ], // Past papers are usually PDFs
                              );

                              if (result != null && result.files.isNotEmpty) {
                                setState(() {
                                  _researchPaperFile =
                                      File(result.files.first.path!);
                                });
                                print(
                                    'Selected research paper: ${_researchPaperFile!.path}'); // Debugging
                              } else {
                                // User canceled the picker
                              }
                            },
                            child: const Text(
                              'Upload Research Paper',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Pallet.headingColor,
                            ),
                          ),
                          if (_researchPaperFile != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                  'Selected file: ${_researchPaperFile!.path.split('/').last}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _selectedOption =
                        null; // Reset selected option when dialog is closed
                    _headingController.clear();
                    _descriptionController.clear();
                    _linkController.clear();
                    _supportingDocumentFile = null;
                    _researchPaperFile = null;
                  },
                ),
                TextButton(
                  child: const Text('Submit'),
                  onPressed: () async {
                    User? user = auth.currentUser;

                    String? studentDocumentId = user?.uid;

                    if (studentDocumentId != null) {
                      String? supportingDocumentUrl;
                      String? researchPaperUrl;

                      if (_selectedOption == "current" &&
                          _supportingDocumentFile != null) {
                        supportingDocumentUrl = await _uploadFileToStorage(
                            studentId: studentDocumentId,
                            file: _supportingDocumentFile!,
                            fileType: 'supporting_documents');
                      } else if (_selectedOption == "past" &&
                          _researchPaperFile != null) {
                        researchPaperUrl = await _uploadFileToStorage(
                            studentId: studentDocumentId,
                            file: _researchPaperFile!,
                            fileType: 'research_papers');
                      }
                      if (_selectedOption == "current") {
                        String heading = _headingController.text;
                        String description = _descriptionController.text;
                        _uploadResearchData(
                          studentId: studentDocumentId,
                          type: "current",
                          heading: heading,
                          description: description,
                          documentUrl: supportingDocumentUrl,
                        );
                      } else if (_selectedOption == "past") {
                        String heading = _headingController.text;
                        String link = _linkController.text;
                        _uploadResearchData(
                          studentId: studentDocumentId,
                          type: "past",
                          heading: heading,
                          link: link,
                          researchPaperUrl: researchPaperUrl,
                        );
                      }
                      Navigator.of(dialogContext).pop();
                      _selectedOption =
                          null; // Reset selected option after submission
                      _headingController.clear();
                      _descriptionController.clear();
                      _linkController.clear();
                      _supportingDocumentFile = null;
                      _researchPaperFile = null;
                      _loadResearchPapers(); // Reload research papers after upload
                    } else {
                      showSnackBar(context, "Error: User not authenticated.");
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<String?> _uploadFileToStorage({
    required String studentId,
    required File file,
    required String fileType,
  }) async {
    try {
      String fileName = file.path.split('/').last;
      Reference storageReference = storage.ref().child(
          'research_papers/$studentId/$fileType/$fileName'); // Storage path

      UploadTask uploadTask = storageReference.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      print('File uploaded to Firebase Storage. Download URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading file to Firebase Storage: $e');
      // Handle error, maybe return null or throw exception
      return null;
    }
  }

  Future<void> _deleteResearchPaper({
    required String studentId,
    required String researchType,
    required String heading,
    String? fileUrl,
  }) async {
    try {
      // Delete file from Firebase Storage if it exists
      if (fileUrl != null && fileUrl.isNotEmpty) {
        Reference fileRef = storage.refFromURL(fileUrl);
        await fileRef.delete();
        print('File deleted from Firebase Storage: $fileUrl');
      }
      // Delete Firestore document from the respective subcollection
      await firestore
          .collection('research paper')
          .doc(studentId)
          .collection(researchType)
          .doc(heading)
          .delete();
      showSnackBar(context, 'Research paper deleted successfully.');
    } catch (e) {
      print('Error deleting research paper: $e');
      showSnackBar(context, 'Error deleting research paper: $e');
    }
  }

  // Function to upload research data to Firestore
  Future<void> _uploadResearchData({
    required String? studentId,
    required String type,
    String? heading,
    String? description,
    String? link,
    String? documentUrl,
    String? researchPaperUrl,
  }) async {
    print("--- _uploadResearchData ---");
    print("Student ID: $studentId, Type: $type, Heading: $heading");
    print(
        "Description: $description, Link: $link, Document URL: $documentUrl, Research Paper URL: $researchPaperUrl");

    try {
      CollectionReference researchPapers = firestore
          .collection('research paper'); // Use singular 'research paper'

      // Document ID will be the same as student's document ID
      DocumentReference studentDoc = researchPapers.doc(studentId);

      CollectionReference typeCollection =
          studentDoc.collection(type); // 'current' or 'past' subcollection
      DocumentReference paperDoc = typeCollection
          .doc(heading); // Use heading as document ID within subcollection

      Map<String, dynamic> researchData = {};
      researchData['type'] =
          type; // Still include type for clarity, though redundant in subcollection
      researchData['heading'] = heading;
      if (description != null) {
        researchData['description'] = description;
      }
      if (link != null) {
        researchData['link'] = link;
      }
      if (documentUrl != null) {
        researchData['documentUrl'] = documentUrl;
      }
      if (researchPaperUrl != null) {
        researchData['researchPaperUrl'] = researchPaperUrl;
      }

      print("Firestore document path: ${paperDoc.path}");
      print("Data to be written to Firestore: $researchData");

      await paperDoc
          .set(researchData) // Use set() to create or overwrite the document
          .then((_) {
        showSnackBar(context,
            'Research data uploaded to Firestore for student ID: $studentId in $type collection');
      }).catchError((error) {
        showSnackBar(
            context, 'Error uploading research data to Firestore: $error');
      });

      // Optionally show a success message to the user
    } catch (e) {
      showSnackBar(context, 'Error uploading research data to Firestore: $e');
      // Optionally show an error message to the user
    }
  }

  // Modified _getResearchPaperStream to fetch from subcollections
  Stream<QuerySnapshot<Map<String, dynamic>>> _getResearchPaperStream(
      String studentId, String type) {
    return firestore
        .collection('research paper')
        .doc(studentId)
        .collection(type) // Access the 'current' or 'past' subcollection
        .snapshots() as Stream<QuerySnapshot<Map<String, dynamic>>>;
  }
}

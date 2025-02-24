import 'dart:io';

import 'package:academiax/constants/pallet.dart';
import 'package:academiax/firebase_authentication/show_snack_bar.dart';
import 'package:academiax/screens/student_home_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                            ),
                            style: ElevatedButton.styleFrom(
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
                            child: const Text('Upload Research Paper'),
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
                      }
                      if (_selectedOption == "current") {
                        String heading = _headingController.text;
                        String description = _descriptionController.text;
                        _uploadResearchData(
                          studentId: studentDocumentId,
                          type: "current",
                          heading: heading,
                          description: description,
                        );
                      } else if (_selectedOption == "past") {
                        String heading = _headingController.text;
                        String link = _linkController.text;
                        _uploadResearchData(
                          studentId: studentDocumentId,
                          type: "past",
                          heading: heading,
                          link: link,
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
                    }),
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

  // Function to upload research data to Firestore
  Future<void> _uploadResearchData({
    required String? studentId,
    required String type,
    String? heading,
    String? description,
    String? link,
  }) async {
    try {
      CollectionReference researchPapers = firestore
          .collection('Research Paper'); // Create 'research paper' collection

      // Document ID will be the same as student's document ID
      DocumentReference studentDoc = researchPapers.doc(studentId);

      Map<String, dynamic> researchData = {};
      researchData['type'] = type;
      researchData['heading'] = heading;

      if (type == 'current') {
        researchData['description'] = description;
        // TODO: Add logic to store document URL after successful upload to Firebase Storage if needed
        // researchData['documentUrl'] = 'YOUR_DOCUMENT_URL';
      } else if (type == 'past') {
        researchData['link'] = link;
        // TODO: Add logic to store research paper URL after successful upload to Firebase Storage if needed
        // researchData['researchPaperUrl'] = 'YOUR_PAPER_URL';
      }

      await studentDoc
          .set(researchData); // Use set() to create or overwrite document
      showSnackBar(context,
          'Research data uploaded to Firestore for student ID: $studentId');
      // Optionally show a success message to the user
    } catch (e) {
      showSnackBar(context, 'Error uploading research data to Firestore: $e');
      // Optionally show an error message to the user
    }
  }
}

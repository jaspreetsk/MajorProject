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
  final TextEditingController _headingController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  File? _supportingDocumentFile;
  File? _researchPaperFile;
  // _deleteExistingFile is kept but not used in this version.
  final bool _deleteExistingFile = false;

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
                  researchStream: _currentResearchStream, researchType: 'current'),
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
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot<Map<String, dynamic>> document =
                snapshot.data!.docs[index];
            Map<String, dynamic> data = document.data()!;
            String heading = data['heading'] ?? 'No Heading';
            String description = data['description'] ?? 'No Description';
            String link = data['link'] ?? '';
            List<dynamic> documentUrls = data['documentUrl'] is List
                ? data['documentUrl']
                : (data['documentUrl'] != null ? [data['documentUrl']] : []);
            List<dynamic> researchPaperUrls = data['researchPaperUrl'] is List
                ? data['researchPaperUrl']
                : (data['researchPaperUrl'] != null
                    ? [data['researchPaperUrl']]
                    : []);

            return Card(
              color: const Color.fromARGB(255, 249, 225, 172),
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
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
                                  final Uri uri = Uri.parse(link);
                                  bool canLaunchURL = await canLaunchUrl(uri);
                                  if (canLaunchURL) {
                                    launchUrl(uri);
                                  } else {
                                    showSnackBar(context, 'Could not launch URL: $link');
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
                          if (documentUrls.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (var docUrl in documentUrls)
                                    if (docUrl != null &&
                                        docUrl.toString().isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 4.0),
                                        child: InkWell(
                                          onTap: () async {
                                            final Uri uri = Uri.parse(docUrl.toString());
                                            bool canLaunchURL = await canLaunchUrl(uri);
                                            if (canLaunchURL) {
                                              launchUrl(uri);
                                            } else {
                                              showSnackBar(context, 'Could not launch URL: $docUrl');
                                            }
                                          },
                                          child: Text(
                                            'Supporting Document ${documentUrls.indexOf(docUrl) + 1}: View Document',
                                            style: const TextStyle(
                                                color: Color(0XFF799ACC),
                                                fontWeight: FontWeight.bold,
                                                decoration: TextDecoration.underline),
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                            ),
                          if (researchPaperUrls.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (var paperUrl in researchPaperUrls)
                                    if (paperUrl != null &&
                                        paperUrl.toString().isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 4.0),
                                        child: InkWell(
                                          onTap: () async {
                                            final Uri uri = Uri.parse(paperUrl.toString());
                                            bool canLaunchURL = await canLaunchUrl(uri);
                                            if (canLaunchURL) {
                                              launchUrl(uri);
                                            } else {
                                              showSnackBar(context, 'Could not launch URL: $paperUrl');
                                            }
                                          },
                                          child: Text(
                                            'Research Paper Document ${researchPaperUrls.indexOf(paperUrl) + 1}: View Document',
                                            style: const TextStyle(
                                                color: Color(0XFF799ACC),
                                                fontWeight: FontWeight.bold,
                                                decoration: TextDecoration.underline),
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      color: const Color.fromARGB(255, 255, 217, 134),
                      icon: const Icon(Icons.more_vert),
                      onSelected: (String value) {
                        if (value == 'edit') {
                          _showEditDialog(context, document, researchType);
                        } else if (value == 'delete') {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm Deletion'),
                                content: const Text('Are you sure you want to delete this research paper?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Cancel deletion
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop(); // Dismiss the dialog
                                      String? studentId = auth.currentUser?.uid;
                                      if (studentId != null) {
                                        List<String>? fileUrls;
                                        List<String>? researchPaperFileUrls;
                                        if (researchType == "current") {
                                          fileUrls = documentUrls.map((url) => url.toString()).toList();
                                          researchPaperFileUrls = []; // No research paper URLs for current
                                        } else if (researchType == "past") {
                                          researchPaperFileUrls = researchPaperUrls.map((url) => url.toString()).toList();
                                          fileUrls = []; // No supporting document URLs for past
                                        }
                                        await _deleteResearchPaper(
                                          studentId: studentId,
                                          researchType: researchType,
                                          heading: heading,
                                          documentUrlsToDelete: fileUrls ?? [],
                                          researchPaperUrlsToDelete: researchPaperFileUrls ?? [],
                                        );
                                      } else {
                                        showSnackBar(context, "Error: User not authenticated.");
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
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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

  void _showEditDialog(BuildContext context, DocumentSnapshot<Map<String, dynamic>> document, String researchType) {
    // Get current field values
    String currentHeading = document.data()?['heading'] ?? '';
    String currentDescription = document.data()?['description'] ?? '';
    String currentLink = document.data()?['link'] ?? '';

    // Fetch lists of URLs, handling null and non-list cases
    List<dynamic> currentDocumentUrlsDynamic = document.data()?['documentUrl'] ?? [];
    List<dynamic> currentResearchPaperUrlsDynamic = document.data()?['researchPaperUrl'] ?? [];

    // Ensure they are lists of strings
    List<String> currentDocumentUrls = currentDocumentUrlsDynamic.cast<String>().toList();
    List<String> currentResearchPaperUrls = currentResearchPaperUrlsDynamic.cast<String>().toList();

    // Controllers pre-populated with current values
    TextEditingController editHeadingController = TextEditingController(text: currentHeading);
    TextEditingController editDescriptionController = TextEditingController(text: currentDescription);
    TextEditingController editLinkController = TextEditingController(text: currentLink);

    // Lists to store additional files and their controllers
    List<File> additionalDocumentFiles = [];
    List<File> additionalResearchPaperFiles = [];

    // Controllers for existing URLs
    List<TextEditingController> documentUrlControllers = currentDocumentUrls.map((url) => TextEditingController(text: url)).toList();
    List<TextEditingController> researchPaperUrlControllers = currentResearchPaperUrls.map((url) => TextEditingController(text: url)).toList();

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
                    TextField(
                      controller: editHeadingController,
                      decoration: const InputDecoration(labelText: 'Heading'),
                    ),
                    const SizedBox(height: 10),
                    researchType == 'current'
                        ? TextField(
                            controller: editDescriptionController,
                            decoration: const InputDecoration(labelText: 'Description'),
                            maxLines: 3,
                          )
                        : TextField(
                            controller: editLinkController,
                            decoration: const InputDecoration(labelText: 'Published Link'),
                          ),
                    const SizedBox(height: 20),
                    const Text("Supporting Documents:"),
                    ...List.generate(
                        documentUrlControllers.length,
                        (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: documentUrlControllers[index],
                                      decoration: InputDecoration(labelText: 'Document URL ${index + 1}'),
                                    ),
                                  ),
                                  if (documentUrlControllers.length > 1)
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          documentUrlControllers.removeAt(index);
                                        });
                                      },
                                    ),
                                ],
                              ),
                            )),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          documentUrlControllers.add(TextEditingController());
                        });
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Pallet.headingColor),
                      child: const Text('Add Supporting Document URL', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 10),
                    const Text("Research Paper Documents:"),
                    ...List.generate(
                        researchPaperUrlControllers.length,
                        (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: researchPaperUrlControllers[index],
                                      decoration: InputDecoration(labelText: 'Research Paper URL ${index + 1}'),
                                    ),
                                  ),
                                  if (researchPaperUrlControllers.length > 1)
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          researchPaperUrlControllers.removeAt(index);
                                        });
                                      },
                                    ),
                                ],
                              ),
                            )),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          researchPaperUrlControllers.add(TextEditingController());
                        });
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Pallet.headingColor),
                      child: const Text('Add Research Paper Document URL', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 20),
                    // Optionally, add buttons to replace main files as needed.
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                TextButton(
                  child: const Text('Update'),
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    User? user = auth.currentUser;
                    if (user != null) {
                      String studentId = user.uid;
                      List<String> updatedDocumentUrls = documentUrlControllers.map((controller) => controller.text).toList();
                      List<String> updatedResearchPaperUrls = researchPaperUrlControllers.map((controller) => controller.text).toList();

                      await _updateResearchPaper(
                        studentId: studentId,
                        researchType: researchType,
                        documentId: document.id,
                        heading: editHeadingController.text,
                        description: editDescriptionController.text,
                        link: editLinkController.text,
                        newSupportingDocumentFile: _supportingDocumentFile,
                        newResearchPaperFile: _researchPaperFile,
                        deleteExistingFile: _deleteExistingFile,
                        existingDocumentUrls: currentDocumentUrls,
                        existingResearchPaperUrls: currentResearchPaperUrls,
                        additionalDocumentFiles: additionalDocumentFiles,
                        updatedDocumentUrls: updatedDocumentUrls,
                        updatedResearchPaperUrls: updatedResearchPaperUrls,
                      );
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

  Future<void> _updateResearchPaper({
    required String studentId,
    required String researchType,
    required String documentId,
    required String heading,
    String? description,
    String? link,
    File? newSupportingDocumentFile,
    File? newResearchPaperFile,
    required bool deleteExistingFile,
    required List<String> existingDocumentUrls,
    required List<String> existingResearchPaperUrls,
    required List<File> additionalDocumentFiles,
    required List<String> updatedDocumentUrls,
    required List<String> updatedResearchPaperUrls,
  }) async {
    try {
      // Use the new Firestore path for research paper
      CollectionReference researchCollection = firestore
          .collection('research paper')
          .doc(studentId)
          .collection(researchType);

      Map<String, dynamic> updateData = {
        'heading': heading,
      };
      if (researchType == 'current') {
        updateData['description'] = description;
      } else {
        updateData['link'] = link;
      }

      List<String> finalDocumentUrls = List.from(updatedDocumentUrls);
      List<String> finalResearchPaperUrls = List.from(updatedResearchPaperUrls);

      // Handle new supporting document file upload for 'current' type
      if (researchType == 'current' && newSupportingDocumentFile != null) {
        String fileName = 'supporting_doc_${DateTime.now().millisecondsSinceEpoch}.pdf';
        Reference storageReference = storage.ref().child(
            'students/$studentId/research_papers/$researchType/$fileName');
        await storageReference.putFile(newSupportingDocumentFile);
        String downloadURL = await storageReference.getDownloadURL();
        finalDocumentUrls.clear(); // Replace existing main document
        finalDocumentUrls.add(downloadURL);
      }
      // Upload additional supporting documents
      List<String> addedDocumentUrls = [];
      for (File docFile in additionalDocumentFiles) {
        String fileName =
            'supporting_doc_${DateTime.now().millisecondsSinceEpoch}_${additionalDocumentFiles.indexOf(docFile) + 1}.pdf';
        Reference storageReference = storage.ref().child(
            'students/$studentId/research_papers/$researchType/$fileName');
        await storageReference.putFile(docFile);
        addedDocumentUrls.add(await storageReference.getDownloadURL());
      }
      finalDocumentUrls.addAll(addedDocumentUrls);

      // Handle new research paper file upload for 'past' type
      if (researchType == 'past' && newResearchPaperFile != null) {
        String fileName = 'research_paper_${DateTime.now().millisecondsSinceEpoch}.pdf';
        Reference storageReference = storage.ref().child(
            'students/$studentId/research_papers/$researchType/$fileName');
        await storageReference.putFile(newResearchPaperFile);
        String downloadURL = await storageReference.getDownloadURL();
        finalResearchPaperUrls.clear(); // Replace existing research paper
        finalResearchPaperUrls.add(downloadURL);
      }

      updateData['documentUrl'] = finalDocumentUrls;
      updateData['researchPaperUrl'] = finalResearchPaperUrls;

      await researchCollection.doc(documentId).update(updateData);
      showSnackBar(context, 'Research paper updated successfully!');
      _loadResearchPapers();
    } catch (e) {
      showSnackBar(context, 'Error updating research paper: $e');
    }
  }

  Future<void> _deleteResearchPaper({
    required String studentId,
    required String researchType,
    required String heading,
    required List<String> documentUrlsToDelete,
    required List<String> researchPaperUrlsToDelete,
  }) async {
    try {
      // Use the new Firestore path for deletion
      CollectionReference researchCollection = firestore
          .collection('research paper')
          .doc(studentId)
          .collection(researchType);

      QuerySnapshot querySnapshot =
          await researchCollection.where('heading', isEqualTo: heading).get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
        String documentId = documentSnapshot.id;

        // Delete files from Firebase Storage
        for (String docUrl in documentUrlsToDelete) {
          if (docUrl.isNotEmpty) {
            Reference storageReference = storage.refFromURL(docUrl);
            await storageReference.delete();
          }
        }
        for (String paperUrl in researchPaperUrlsToDelete) {
          if (paperUrl.isNotEmpty) {
            Reference storageReference = storage.refFromURL(paperUrl);
            await storageReference.delete();
          }
        }

        // Delete document from Firestore
        await researchCollection.doc(documentId).delete();
        showSnackBar(context, 'Research paper deleted successfully!');
        _loadResearchPapers();
      } else {
        showSnackBar(context, 'Research paper not found.');
      }
    } catch (e) {
      showSnackBar(context, 'Error deleting research paper: $e');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getResearchPaperStream(
      String studentId, String type) {
    return firestore
        .collection('research paper')
        .doc(studentId)
        .collection(type)
        .snapshots();
  }

  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text("Upload Research Paper"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: "Research Type"),
                      value: _selectedOption,
                      items: const [
                        DropdownMenuItem(
                          value: "current",
                          child: Text("Current Research"),
                        ),
                        DropdownMenuItem(
                          value: "past",
                          child: Text("Past Research Paper"),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedOption = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select research type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _headingController,
                      decoration: const InputDecoration(labelText: 'Heading'),
                    ),
                    const SizedBox(height: 20),
                    if (_selectedOption == "current")
                      TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                      ),
                    if (_selectedOption == "past")
                      TextField(
                        controller: _linkController,
                        decoration: const InputDecoration(labelText: 'Published Link (if any)'),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: _selectedOption == 'current'
                              ? ['jpg', 'png', 'pdf', 'docx', 'odt']
                              : ['pdf', 'docx', 'odt'],
                        );
                        if (result != null && result.files.isNotEmpty) {
                          setState(() {
                            if (_selectedOption == 'current') {
                              _supportingDocumentFile = File(result.files.single.path!);
                            } else {
                              _researchPaperFile = File(result.files.single.path!);
                            }
                          });
                        } else {
                          showSnackBar(context, 'No file selected.');
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Pallet.headingColor),
                      child: Text(
                        _selectedOption == 'current'
                            ? 'Upload Supporting Document'
                            : 'Upload Research Paper',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    if (_selectedOption == 'current' && _supportingDocumentFile != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('Selected Document: ${_supportingDocumentFile!.path.split('/').last}'),
                      ),
                    if (_selectedOption == 'past' && _researchPaperFile != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('Selected Research Paper: ${_researchPaperFile!.path.split('/').last}'),
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Pallet.headingColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (_selectedOption == null) {
                      showSnackBar(context, "Please select the research type.");
                      return;
                    }
                    if (_headingController.text.isEmpty) {
                      showSnackBar(context, "Heading cannot be empty.");
                      return;
                    }

                    if (_selectedOption == 'current' && _supportingDocumentFile == null) {
                      showSnackBar(context, "Please upload supporting document.");
                      return;
                    }
                    if (_selectedOption == 'past' && _researchPaperFile == null) {
                      showSnackBar(context, "Please upload research paper document.");
                      return;
                    }

                    Navigator.of(context).pop();
                    User? user = auth.currentUser;
                    if (user != null) {
                      String studentId = user.uid;
                      String fileName = _selectedOption == 'current'
                          ? 'supporting_doc_${DateTime.now().millisecondsSinceEpoch}.pdf'
                          : 'research_paper_${DateTime.now().millisecondsSinceEpoch}.pdf';
                      File? fileToUpload = _selectedOption == 'current'
                          ? _supportingDocumentFile
                          : _researchPaperFile;

                      if (fileToUpload != null) {
                        Reference storageReference = storage.ref().child(
                            'students/$studentId/research_papers/$_selectedOption/$fileName');
                        try {
                          await storageReference.putFile(fileToUpload);
                          String downloadURL = await storageReference.getDownloadURL();

                          // Use the new Firestore path for research paper
                          CollectionReference researchCollection = firestore
                              .collection('research paper')
                              .doc(studentId)
                              .collection(_selectedOption!);

                          Map<String, dynamic> researchData = {
                            'type': _selectedOption,
                            'heading': _headingController.text,
                            'documentUrl': _selectedOption == 'current' ? [downloadURL] : [],
                            'researchPaperUrl': _selectedOption == 'past' ? [downloadURL] : [],
                          };
                          if (_selectedOption == 'current') {
                            researchData['description'] = _descriptionController.text;
                          }
                          if (_selectedOption == 'past') {
                            researchData['link'] = _linkController.text;
                          }

                          await researchCollection.add(researchData);
                          showSnackBar(context, 'Research paper uploaded successfully!');
                          _loadResearchPapers();

                          // Clear controllers and selected files
                          _headingController.clear();
                          _descriptionController.clear();
                          _linkController.clear();
                          setState(() {
                            _supportingDocumentFile = null;
                            _researchPaperFile = null;
                            _selectedOption = null;
                          });
                        } catch (error) {
                          showSnackBar(context, 'Error uploading research paper: $error');
                        }
                      }
                    } else {
                      showSnackBar(context, "User not authenticated. Please sign in.");
                    }
                  },
                  child: const Text("Upload"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

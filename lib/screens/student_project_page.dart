import 'package:academiax/constants/pallet.dart';
import 'dart:io';
import 'package:academiax/constants/pallet.dart';
import 'package:academiax/firebase_authentication/show_snack_bar.dart';
import 'package:academiax/screens/student_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentProject extends StatefulWidget {
  const StudentProject({super.key});

  @override
  State<StudentProject> createState() => _StudentProjectState();
}

class _StudentProjectState extends State<StudentProject> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>>? _currentProjectStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _pastProjectStream;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Pallet.headingColor,
        title: const Text(
          "Projects",
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
          _showUploadProjectDialog(context);
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
                'Current Projects', // Changed text
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildProjectList(
                  // Replaced _buildResearchList with _buildInternshipList
                  projectStream:
                      _currentProjectStream, // Assuming you will create _currentInternshipStream
                  projectType: 'current'),
              const SizedBox(height: 20),
              const Text(
                'Past Projects', // Changed text
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildProjectList(
                  // Replaced _buildResearchList with _buildInternshipList
                  projectStream:
                      _pastProjectStream, // Assuming you will create _pastInternshipStream
                  projectType: 'past'),
            ],
          ),
        ),
      ),
    );
  }

// 3rd block of code to upload data to firebase storage

  Future<String?> _uploadFileToStorage({
    required String studentId,
    required File file,
    required String fileType,
  }) async {
    try {
      final Reference storageReference = storage.ref().child(
          'projects/$studentId/$fileType/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}');

      final UploadTask uploadTask = storageReference.putFile(file);
      await uploadTask.whenComplete(() => null);

      final String downloadURL = await storageReference.getDownloadURL();
      return downloadURL;
    } catch (e) {
      debugPrint("Error uploading file to storage: $e");
      return null;
    }
  }

// 2nd block of code to upload the data to firebase db

  void _uploadProjectData({
    required String studentId,
    required String type,
    required String projectTitle,
    required String projectDescription,
    List<String>? videoUrls,
    List<String>? documentUrls,
    List<String>? photoUrls,
  }) async {
    try {
      CollectionReference projectCollection = firestore
          .collection('projects') // Changed collection name to 'projects'
          .doc(studentId)
          .collection(type);

      Map<String, dynamic> projectData = {
        'projectTitle': projectTitle, // Changed field name
        'projectDescription': projectDescription, // Changed field name
        'videoUrl': videoUrls ?? [],
        'documentUrl': documentUrls ?? [],
        'photoUrl': photoUrls ?? [],
        'uploadDate': FieldValue.serverTimestamp(),
        // Add other relevant fields here if needed
      };

      await projectCollection
          .doc(projectTitle)
          .set(projectData); // Using projectTitle as document ID
      debugPrint('Project data uploaded successfully for: $projectTitle');
    } catch (e) {
      debugPrint('Error uploading project data: $e');
      // Handle error appropriately, maybe show a snackbar
    }
  }

// 1st block of code to show the dialog box to upload the relevant
// project's details

  void _showUploadProjectDialog(BuildContext context) {
    String? _selectedOption;
    final TextEditingController _projectTitleController =
        TextEditingController();
    final TextEditingController _projectDescriptionController =
        TextEditingController();
    List<File> _videoFiles = [];
    List<File> _documentFiles = [];
    List<File> _photoFiles = [];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Upload Project Details'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'Select Option'),
                      value: _selectedOption,
                      items: const [
                        DropdownMenuItem(
                          value: "current",
                          child: Text("Add current project"),
                        ),
                        DropdownMenuItem(
                          value: "past",
                          child: Text("Add past project"),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedOption = newValue;
                        });
                      },
                    ),
                    if (_selectedOption !=
                        null) // Show fields only after option is selected
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _projectTitleController,
                            decoration: const InputDecoration(
                              labelText: 'Project Title',
                            ),
                          ),
                          const SizedBox(height: 5),
                          TextFormField(
                            controller: _projectDescriptionController,
                            decoration: const InputDecoration(
                                labelText: 'Project Description'),
                            maxLines: 3, // Allows for longer descriptions
                          ),
                          const SizedBox(height: 20),

                          // --- Video Upload ---
                          ElevatedButton(
                            onPressed: () async {
                              FilePickerResult? videoResult =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.video,
                                allowMultiple: true,
                              );
                              if (videoResult != null &&
                                  videoResult.files.isNotEmpty) {
                                setState(() {
                                  _videoFiles = videoResult.files
                                      .map((e) => File(e.path!))
                                      .toList();
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Pallet.headingColor),
                            child: const Text('Upload Video(s)',
                                style: TextStyle(color: Colors.white)),
                          ),
                          if (_videoFiles.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Selected videos:',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                  ..._videoFiles.map((file) => Text(
                                      '• ${file.path.split('/').last}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey))),
                                ],
                              ),
                            ),
                          const SizedBox(height: 10),

                          // --- Document Upload ---
                          ElevatedButton(
                            onPressed: () async {
                              FilePickerResult? documentResult =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: [
                                  'pdf',
                                  'doc',
                                  'docx',
                                  'txt'
                                ], // Example document types
                                allowMultiple: true,
                              );
                              if (documentResult != null &&
                                  documentResult.files.isNotEmpty) {
                                setState(() {
                                  _documentFiles = documentResult.files
                                      .map((e) => File(e.path!))
                                      .toList();
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Pallet.headingColor),
                            child: const Text('Upload Document(s)',
                                style: TextStyle(color: Colors.white)),
                          ),
                          if (_documentFiles.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Selected documents:',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                  ..._documentFiles.map((file) => Text(
                                      '• ${file.path.split('/').last}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey))),
                                ],
                              ),
                            ),
                          const SizedBox(height: 10),

                          // --- Photo Upload ---
                          ElevatedButton(
                            onPressed: () async {
                              FilePickerResult? photoResult =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.image,
                                allowMultiple: true,
                              );
                              if (photoResult != null &&
                                  photoResult.files.isNotEmpty) {
                                setState(() {
                                  _photoFiles = photoResult.files
                                      .map((e) => File(e.path!))
                                      .toList();
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Pallet.headingColor),
                            child: const Text('Upload Photo(s)',
                                style: TextStyle(color: Colors.white)),
                          ),
                          if (_photoFiles.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Selected photos:',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                  ..._photoFiles.map((file) => Text(
                                      '• ${file.path.split('/').last}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey))),
                                ],
                              ),
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
                    _selectedOption = null;
                    _projectTitleController.clear();
                    _projectDescriptionController.clear();
                    _videoFiles.clear();
                    _documentFiles.clear();
                    _photoFiles.clear();
                  },
                ),
                TextButton(
                  child: const Text('Submit'),
                  onPressed: () async {
                    User? user = auth.currentUser;
                    String? studentDocumentId = user?.uid;

                    if (studentDocumentId != null && _selectedOption != null) {
                      List<String> videoUrls = [];
                      List<String> documentUrls = [];
                      List<String> photoUrls = [];

                      // Upload videos
                      for (File file in _videoFiles) {
                        String? url = await _uploadFileToStorage(
                            studentId: studentDocumentId,
                            file: file,
                            fileType: 'project_videos'); // File type for videos
                        if (url != null) {
                          videoUrls.add(url);
                        }
                      }
                      // Upload documents
                      for (File file in _documentFiles) {
                        String? url = await _uploadFileToStorage(
                            studentId: studentDocumentId,
                            file: file,
                            fileType:
                                'project_documents'); // File type for documents
                        if (url != null) {
                          documentUrls.add(url);
                        }
                      }
                      // Upload photos
                      for (File file in _photoFiles) {
                        String? url = await _uploadFileToStorage(
                            studentId: studentDocumentId,
                            file: file,
                            fileType: 'project_photos'); // File type for photos
                        if (url != null) {
                          photoUrls.add(url);
                        }
                      }

                      String projectTitle = _projectTitleController.text.trim();
                      String projectDescription =
                          _projectDescriptionController.text.trim();

                      _uploadProjectData(
                        studentId: studentDocumentId,
                        type: _selectedOption!,
                        projectTitle: projectTitle,
                        projectDescription: projectDescription,
                        videoUrls: videoUrls,
                        documentUrls: documentUrls,
                        photoUrls: photoUrls,
                      );

                      Navigator.of(dialogContext).pop();
                      _selectedOption = null;
                      _projectTitleController.clear();
                      _projectDescriptionController.clear();
                      _videoFiles.clear();
                      _documentFiles.clear();
                      _photoFiles.clear();
                      // _loadProjects(); // Function to load projects - create this next
                      showSnackBar(
                          context, 'Project details uploaded successfully!');
                    } else {
                      showSnackBar(context,
                          "Error: Select project type and ensure user is authenticated.");
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

// 4th block of code to build the list of projects to be shown on the
// page.

  Widget _buildProjectList(
      {required Stream<QuerySnapshot<Map<String, dynamic>>>? projectStream,
      required String projectType}) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: projectStream,
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No $projectType projects uploaded yet.');
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot<Map<String, dynamic>> document =
                snapshot.data!.docs[index];
            Map<String, dynamic> data = document.data()!;
            String projectTitle = data['projectTitle'] ?? 'No Project Title';
            String projectDescription =
                data['projectDescription'] ?? 'No Description Provided';
            List<dynamic> videoUrls = data['videoUrl'] ?? [];
            List<dynamic> documentUrls = data['documentUrl'] ?? [];
            List<dynamic> photoUrls = data['photoUrl'] ?? [];
            List<String> allMediaUrls = [
              ...videoUrls.map((url) => url.toString()),
              ...documentUrls.map((url) => url.toString()),
              ...photoUrls.map((url) => url.toString()),
            ];

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
                            projectTitle,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF468F92),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (projectDescription.isNotEmpty)
                            Text(
                              projectDescription,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 16, color: Color(0xFF6C7F93)),
                            ),
                          const SizedBox(height: 8),
                          if (videoUrls.isNotEmpty ||
                              documentUrls.isNotEmpty ||
                              photoUrls.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Project Media:',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.grey)),
                                  if (videoUrls.isNotEmpty)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Videos:',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey)),
                                        ...videoUrls
                                            .map((videoUrl) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 4.0,
                                                          left: 8.0),
                                                  child: InkWell(
                                                    onTap: () async {
                                                      if (videoUrl != null &&
                                                          videoUrl
                                                              .toString()
                                                              .isNotEmpty) {
                                                        final Uri uri =
                                                            Uri.parse(videoUrl
                                                                .toString());
                                                        if (await canLaunchUrl(
                                                            uri)) {
                                                          launchUrl(uri);
                                                        } else {
                                                          showSnackBar(context,
                                                              'Could not launch URL: $videoUrl');
                                                        }
                                                      }
                                                    },
                                                    child: Text(
                                                      'Video ${videoUrls.indexOf(videoUrl) + 1}: View Video',
                                                      style: const TextStyle(
                                                          color:
                                                              Color(0XFF799ACC),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline),
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                      ],
                                    ),
                                  if (documentUrls.isNotEmpty)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Documents:',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey)),
                                        ...documentUrls
                                            .map((docUrl) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 4.0,
                                                          left: 8.0),
                                                  child: InkWell(
                                                    onTap: () async {
                                                      if (docUrl != null &&
                                                          docUrl
                                                              .toString()
                                                              .isNotEmpty) {
                                                        final Uri uri =
                                                            Uri.parse(docUrl
                                                                .toString());
                                                        if (await canLaunchUrl(
                                                            uri)) {
                                                          launchUrl(uri);
                                                        } else {
                                                          showSnackBar(context,
                                                              'Could not launch URL: $docUrl');
                                                        }
                                                      }
                                                    },
                                                    child: Text(
                                                      'Document ${documentUrls.indexOf(docUrl) + 1}: View Document',
                                                      style: const TextStyle(
                                                          color:
                                                              Color(0XFF799ACC),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline),
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                      ],
                                    ),
                                  if (photoUrls.isNotEmpty)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Photos:',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey)),
                                        ...photoUrls
                                            .map((photoUrl) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 4.0,
                                                          left: 8.0),
                                                  child: InkWell(
                                                    onTap: () async {
                                                      if (photoUrl != null &&
                                                          photoUrl
                                                              .toString()
                                                              .isNotEmpty) {
                                                        final Uri uri =
                                                            Uri.parse(photoUrl
                                                                .toString());
                                                        if (await canLaunchUrl(
                                                            uri)) {
                                                          launchUrl(uri);
                                                        } else {
                                                          showSnackBar(context,
                                                              'Could not launch URL: $photoUrl');
                                                        }
                                                      }
                                                    },
                                                    child: Text(
                                                      'Photo ${photoUrls.indexOf(photoUrl) + 1}: View Photo',
                                                      style: const TextStyle(
                                                          color:
                                                              Color(0XFF799ACC),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline),
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                      ],
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
                          _showEditProjectDialog(
                              context, document, projectType); // To be created
                          showSnackBar(context,
                              'Edit Project feature to be implemented');
                        } else if (value == 'delete') {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm Deletion'),
                                content: const Text(
                                    'Are you sure you want to delete this project detail?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      String? studentId = auth.currentUser?.uid;
                                      if (studentId != null) {
                                        await _deleteProject(
                                          // To be created
                                          studentId: studentId,
                                          projectType: projectType,
                                          projectTitle: projectTitle,
                                          mediaUrls: allMediaUrls,
                                        );
                                        _loadProjects();
                                        showSnackBar(context,
                                            'Project deleted successfully!');
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

// 5th block of code to load data of projects and supply it to 6th block

  @override
  void initState() {
    super.initState();
    _loadProjects(); // Changed function call to _loadInternships
  }

  void _loadProjects() {
    // Renamed function to _loadInternships
    User? user = auth.currentUser;
    String? studentId = user?.uid; // More descriptive variable name
    if (studentId != null) {
      _currentProjectStream = // Use _currentInternshipStream
          _getInternshipStream(
              studentId, 'current'); // Call _getInternshipStream
      _pastProjectStream = // Use _pastInternshipStream
          _getInternshipStream(studentId, 'past'); // Call _getInternshipStream
    }
  }

// 6th block of code to get stream of data from projects directory
// from firebase database

  Stream<QuerySnapshot<Map<String, dynamic>>> _getInternshipStream(
      String studentId, String type) {
    return firestore
        .collection('projects') // Changed collection to 'internship'
        .doc(studentId)
        .collection(type) // Access the 'current' or 'past' subcollection
        .snapshots() as Stream<QuerySnapshot<Map<String, dynamic>>>;
  }

  // 7th block of code to delete data from card(s)

  Future<void> _deleteProject({
    required String studentId,
    required String projectType,
    required String projectTitle, // Changed to projectTitle
    List<String>?
        mediaUrls, // Generalized parameter for media URLs (videos, docs, photos)
  }) async {
    try {
      // Delete files from Firebase Storage if they exist
      if (mediaUrls != null && mediaUrls.isNotEmpty) {
        for (String mediaUrl in mediaUrls) {
          // Loop through the list of media URLs
          if (mediaUrl.isNotEmpty) {
            // Check if URL is not empty
            try {
              Reference fileRef = storage.refFromURL(mediaUrl);
              await fileRef.delete();
            } catch (storageError) {
              // Log storage deletion error, but continue with Firestore document deletion
              // Consider adding more robust error handling/user feedback if needed.
              print(
                  "Storage deletion error for URL: $mediaUrl - Error: $storageError"); // More specific log
            }
          }
        }
      }

      // Delete Firestore document from the respective subcollection in 'projects'
      await firestore
          .collection('projects') // Changed collection to 'projects'
          .doc(studentId)
          .collection(projectType) // Use projectType
          .doc(projectTitle) // Changed document ID to projectTitle
          .delete();

      showSnackBar(
          context, 'Project details deleted successfully.'); // Updated message
    } catch (e) {
      showSnackBar(
          context, 'Error deleting project details: $e'); // Updated message
    }
  }

// 8th block of code to edit the card

  void _showEditProjectDialog(BuildContext context,
    DocumentSnapshot<Map<String, dynamic>> document, String projectType) {
  // Get current field values - Project specific fields
  String currentProjectTitle = document.data()?['projectTitle'] ?? '';
  String currentProjectDescription = document.data()?['projectDescription'] ?? '';

  // Fetch lists of media URLs
  List<dynamic> currentVideoUrlsDynamic = document.data()?['videoUrl'] ?? [];
  List<dynamic> currentDocumentUrlsDynamic = document.data()?['documentUrl'] ?? [];
  List<dynamic> currentPhotoUrlsDynamic = document.data()?['photoUrl'] ?? [];

  List<String> currentVideoUrls = currentVideoUrlsDynamic.cast<String>().toList();
  List<String> currentDocumentUrls = currentDocumentUrlsDynamic.cast<String>().toList();
  List<String> currentPhotoUrls = currentPhotoUrlsDynamic.cast<String>().toList();

  // Controllers pre-populated with current values - Project specific
  TextEditingController editProjectTitleController =
      TextEditingController(text: currentProjectTitle);
  TextEditingController editProjectDescriptionController =
      TextEditingController(text: currentProjectDescription);

  // Initialize controllers for existing media URLs and lists to track URLs to be deleted
  List<TextEditingController> videoUrlControllers =
      currentVideoUrls.map((url) => TextEditingController(text: url)).toList();
  List<TextEditingController> documentUrlControllers =
      currentDocumentUrls.map((url) => TextEditingController(text: url)).toList();
  List<TextEditingController> photoUrlControllers =
      currentPhotoUrls.map((url) => TextEditingController(text: url)).toList();

  List<String> deletedVideoUrls = []; // List to track video URLs to delete
  List<String> deletedDocumentUrls = []; // List to track document URLs to delete
  List<String> deletedPhotoUrls = []; // List to track photo URLs to delete


  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Project Details'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Editable Project Title
                  TextField(
                    controller: editProjectTitleController,
                    decoration: const InputDecoration(labelText: 'Project Title'),
                  ),
                  const SizedBox(height: 10),

                  // Editable Project Description
                  TextField(
                    controller: editProjectDescriptionController,
                    decoration: const InputDecoration(labelText: 'Project Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  // --- Section for Video URLs ---
                  const Text("Video URLs:", style: TextStyle(fontWeight: FontWeight.bold)),
                  ...List.generate(
                    videoUrlControllers.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: videoUrlControllers[index],
                              decoration: InputDecoration(labelText: 'Video URL ${index + 1}'),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              String urlToDelete = videoUrlControllers[index].text;
                              if (currentVideoUrls.contains(urlToDelete)) {
                                deletedVideoUrls.add(urlToDelete); // Add to deleted URLs list
                              }
                              setState(() {
                                videoUrlControllers.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        videoUrlControllers.add(TextEditingController());
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Pallet.headingColor),
                    child: const Text('Add Video URL', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 10),

                  // --- Section for Document URLs ---
                  const Text("Document URLs:", style: TextStyle(fontWeight: FontWeight.bold)),
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
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              String urlToDelete = documentUrlControllers[index].text;
                              if (currentDocumentUrls.contains(urlToDelete)) {
                                deletedDocumentUrls.add(urlToDelete); // Add to deleted URLs list
                              }
                              setState(() {
                                documentUrlControllers.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        documentUrlControllers.add(TextEditingController());
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Pallet.headingColor),
                    child: const Text('Add Document URL', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 10),

                  // --- Section for Photo URLs ---
                  const Text("Photo URLs:", style: TextStyle(fontWeight: FontWeight.bold)),
                  ...List.generate(
                    photoUrlControllers.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: photoUrlControllers[index],
                              decoration: InputDecoration(labelText: 'Photo URL ${index + 1}'),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              String urlToDelete = photoUrlControllers[index].text;
                              if (currentPhotoUrls.contains(urlToDelete)) {
                                deletedPhotoUrls.add(urlToDelete); // Add to deleted URLs list
                              }
                              setState(() {
                                photoUrlControllers.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        photoUrlControllers.add(TextEditingController());
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Pallet.headingColor),
                    child: const Text('Add Photo URL', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 10),


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
                  // Get updated values - Project specific
                  String updatedProjectTitle = editProjectTitleController.text.trim();
                  String updatedProjectDescription = editProjectDescriptionController.text.trim();
                  List<String> updatedVideoUrls = videoUrlControllers.map((c) => c.text.trim()).where((url) => url.isNotEmpty).toList();
                  List<String> updatedDocumentUrls = documentUrlControllers.map((c) => c.text.trim()).where((url) => url.isNotEmpty).toList();
                  List<String> updatedPhotoUrls = photoUrlControllers.map((c) => c.text.trim()).where((url) => url.isNotEmpty).toList();


                  // --- Build the update data map --- - Project specific fields
                  Map<String, dynamic> updateData = {};
                  updateData['projectTitle'] = updatedProjectTitle;
                  updateData['projectDescription'] = updatedProjectDescription;
                  updateData['videoUrl'] = updatedVideoUrls;
                  updateData['documentUrl'] = updatedDocumentUrls;
                  updateData['photoUrl'] = updatedPhotoUrls;

                  String studentId = auth.currentUser!.uid;
                  String oldDocId = currentProjectTitle; // Use projectTitle as doc ID

                  // Option B: Create a new document if the projectTitle (document ID) has changed.
                  if (updatedProjectTitle != currentProjectTitle) {
                    // Create new document with updated projectTitle
                    await firestore
                        .collection('projects')
                        .doc(studentId)
                        .collection(projectType)
                        .doc(updatedProjectTitle)
                        .set(updateData);
                    // Delete the old document
                    await firestore
                        .collection('projects')
                        .doc(studentId)
                        .collection(projectType)
                        .doc(oldDocId)
                        .delete();
                  } else {
                    // If the projectTitle remains the same, update in place
                    await firestore
                        .collection('projects')
                        .doc(studentId)
                        .collection(projectType)
                        .doc(oldDocId)
                        .update(updateData);
                  }

                  // Delete removed media files from storage
                  await _deleteMediaFilesFromStorage(deletedVideoUrls);
                  await _deleteMediaFilesFromStorage(deletedDocumentUrls);
                  await _deleteMediaFilesFromStorage(deletedPhotoUrls);


                  Navigator.of(dialogContext).pop();
                  _loadProjects(); // Refresh project list
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

Future<void> _deleteMediaFilesFromStorage(List<String> urls) async {
  for (String url in urls) {
    if (url.isNotEmpty) {
      try {
        Reference fileRef = FirebaseStorage.instance.refFromURL(url);
        await fileRef.delete();
        print('Successfully deleted file from storage: $url');
      } catch (e) {
        print('Error deleting file from storage: $url - $e');
        // Consider adding more robust error handling, like showing a SnackBar
        // if media deletion fails, or retry mechanism.
      }
    }
  }
}
}

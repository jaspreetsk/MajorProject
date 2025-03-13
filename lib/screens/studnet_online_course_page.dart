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

class StudnetOnlineCourse extends StatefulWidget {
  const StudnetOnlineCourse({super.key});

  @override
  State<StudnetOnlineCourse> createState() => _StudnetOnlineCourseState();
}

class _StudnetOnlineCourseState extends State<StudnetOnlineCourse> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>>? _currentOnlineCourseStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _pastOnlineCourseStream;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Pallet.headingColor,
        title: const Text(
          "Online Courses",
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
          _showUploadOnlineCourseDialog(context);
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
                'Current Course', // Changed text
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildOnlineCourseList(
                  // Replaced _buildResearchList with _buildInternshipList
                  onlineCourseStream:
                      _currentOnlineCourseStream, // Assuming you will create _currentInternshipStream
                  onlineCourseType: 'current'),
              const SizedBox(height: 20),
              const Text(
                'Past Course(s)', // Changed text
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildOnlineCourseList(
                  // Replaced _buildResearchList with _buildInternshipList
                  onlineCourseStream:
                      _pastOnlineCourseStream, // Assuming you will create _pastInternshipStream
                  onlineCourseType: 'past'),
            ],
          ),
        ),
      ),
    );
  }

  void _showUploadOnlineCourseDialog(BuildContext context) {
    String? selectedOption;
    final TextEditingController courseNameController = TextEditingController();
    final TextEditingController platformNameController =
        TextEditingController();
    final TextEditingController durationController = TextEditingController();
    final TextEditingController skillsAcquiredController =
        TextEditingController();
    List<File> proofDocumentFiles =
        []; // Changed to List for multiple proof documents
    List<File> certificateFiles =
        []; // Changed to List for multiple certificates

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Upload Online Course Details'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'Select Option'),
                      value: selectedOption,
                      items: const [
                        DropdownMenuItem(
                          value: "current",
                          child: Text("Add current course"),
                        ),
                        DropdownMenuItem(
                          value: "past",
                          child: Text("Add past course"),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedOption = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: courseNameController,
                      decoration: const InputDecoration(
                        labelText: 'Name of Course',
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: platformNameController,
                      decoration:
                          const InputDecoration(labelText: 'Platform Name'),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: durationController,
                      decoration: const InputDecoration(
                          labelText: 'Duration (e.g., Weeks, Hours)'),
                    ),
                    if (selectedOption == "current")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowMultiple: true, // Allow multiple selection
                                allowedExtensions: [
                                  'pdf',
                                  'jpg',
                                  'png',
                                  'doc',
                                  'docx'
                                ],
                              );
                              if (result != null && result.files.isNotEmpty) {
                                setState(() {
                                  proofDocumentFiles = result.files
                                      .map((e) => File(e.path!))
                                      .toList(); // Store multiple files
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Pallet.headingColor,
                            ),
                            child: const Text('Upload Proof Documents',
                                style: TextStyle(
                                    color: Colors.white)), // Changed to plural
                          ),
                          if (proofDocumentFiles.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                      'Selected proof documents:', // Changed to plural
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                  ...proofDocumentFiles.map((file) => Text(
                                      // Display list of files
                                      '• ${file.path.split('/').last}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey))),
                                ],
                              ),
                            ),
                        ],
                      ),
                    if (selectedOption == "past")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 5),
                          TextFormField(
                            controller: skillsAcquiredController,
                            decoration: const InputDecoration(
                                labelText: 'Skills Acquired (Optional)'),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowMultiple: true, // Allow multiple selection
                                allowedExtensions: [
                                  'pdf',
                                  'jpg',
                                  'png',
                                  'jpeg'
                                ],
                              );
                              if (result != null && result.files.isNotEmpty) {
                                setState(() {
                                  certificateFiles = result.files
                                      .map((e) => File(e.path!))
                                      .toList(); // Store multiple files
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Pallet.headingColor,
                            ),
                            child: const Text('Upload Certificates',
                                style: TextStyle(
                                    color: Colors.white)), // Keep plural
                          ),
                          if (certificateFiles.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Selected certificates:',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                  ...certificateFiles.map((file) => Text(
                                      // Display list of files
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
                  },
                ),
                TextButton(
                  child: const Text('Submit'),
                  onPressed: () async {
                    User? user = auth.currentUser;
                    String? studentDocumentId = user?.uid;

                    if (studentDocumentId != null && selectedOption != null) {
                      List<String> proofDocumentUrls = []; // Changed to List
                      List<String> certificateUrls = []; // Changed to List

                      if (selectedOption == "current" &&
                          proofDocumentFiles.isNotEmpty) {
                        // Check if list is not empty
                        for (File file in proofDocumentFiles) {
                          // Loop through multiple files
                          String? url = await _uploadFileToStorage(
                            studentId: studentDocumentId,
                            file: file,
                            fileType: 'online_course_proofs',
                          );
                          if (url != null) {
                            proofDocumentUrls.add(url); // Add URL to list
                          }
                        }
                      }

                      if (selectedOption == "past" &&
                          certificateFiles.isNotEmpty) {
                        // Check if list is not empty
                        for (File file in certificateFiles) {
                          // Loop through multiple files
                          String? url = await _uploadFileToStorage(
                            studentId: studentDocumentId,
                            file: file,
                            fileType: 'online_course_certificates',
                          );
                          if (url != null) {
                            certificateUrls.add(url); // Add URL to list
                          }
                        }
                      }

                      String courseName = courseNameController.text.trim();
                      String platformName = platformNameController.text.trim();
                      String duration = durationController.text.trim();
                      String skillsAcquired =
                          skillsAcquiredController.text.trim();

                      _uploadOnlineCourseData(
                        studentId: studentDocumentId,
                        type: selectedOption!,
                        courseName: courseName,
                        platformName: platformName,
                        duration: duration,
                        proofDocumentUrls: proofDocumentUrls, // Pass URL list
                        certificateUrls: certificateUrls, // Pass URL list
                        skillsAcquired: skillsAcquired,
                      );

                      Navigator.of(dialogContext).pop();
                      selectedOption = null;
                      courseNameController.clear();
                      platformNameController.clear();
                      durationController.clear();
                      skillsAcquiredController.clear();
                      proofDocumentFiles = []; // Clear file lists
                      certificateFiles = []; // Clear file lists
                      _loadOnlineCourse(); // Call function to refresh online course list
                    } else {
                      showSnackBar(context,
                          "Error: User not authenticated or Option not selected.");
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

  Future<void> _uploadOnlineCourseData({
    required String studentId,
    required String type,
    required String courseName,
    required String platformName,
    required String duration,
    List<String>? proofDocumentUrls, // Changed to List<String>
    List<String>? certificateUrls, // Changed to List<String>
    String? skillsAcquired,
  }) async {
    try {
      CollectionReference courseCollection = firestore
          .collection('online_courses') // Change collection name
          .doc(studentId)
          .collection(type); // Use type (current/past) as subcollection

      String docId = courseName
          .trim(); // Use course name as document ID - or generate unique ID if needed.

      Map<String, dynamic> courseData = {
        'courseName': courseName,
        'platformName': platformName,
        'duration': duration,
        'timestamp': FieldValue.serverTimestamp(), // Add timestamp for ordering
      };

      if (proofDocumentUrls != null && proofDocumentUrls.isNotEmpty) {
        // Check if list is not null and not empty
        courseData['proofDocumentUrl'] = proofDocumentUrls; // Store the list
      }
      if (certificateUrls != null && certificateUrls.isNotEmpty) {
        // Check if list is not null and not empty
        courseData['certificateUrl'] = certificateUrls; // Store the list
      }
      if (skillsAcquired != null) {
        courseData['skillsAcquired'] = skillsAcquired;
      }

      await courseCollection
          .doc(docId)
          .set(courseData); // Use course name as doc ID

      showSnackBar(context, 'Online course details uploaded successfully!');
    } catch (e) {
      showSnackBar(context, 'Failed to upload online course details: $e');
    }
  }

  Future<String?> _uploadFileToStorage({
    required String studentId,
    required File file,
    required String fileType,
  }) async {
    try {
      String fileName = file.path.split('/').last;
      Reference storageReference = storage.ref().child(
          'online_courses/$studentId/$fileType/$fileName'); // Storage path

      UploadTask uploadTask = storageReference.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      // Handle error, maybe return null or throw exception
      return null;
    }
  }

  Widget _buildOnlineCourseList(
      {required Stream<QuerySnapshot<Map<String, dynamic>>>? onlineCourseStream,
      required String onlineCourseType}) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: onlineCourseStream,
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No $onlineCourseType online courses uploaded yet.');
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot<Map<String, dynamic>> document =
                snapshot.data!.docs[index];
            Map<String, dynamic> data = document.data()!;
            String courseName = data['courseName'] ?? 'No Course Name';
            String platformName =
                data['platformName'] ?? 'No Platform Specified';
            String duration = data['duration'] ?? 'N/A';
            List<dynamic> certificateUrlsDynamic = data['certificateUrl'] ?? [];
            List<String> certificateUrls =
                certificateUrlsDynamic.cast<String>().toList();
            List<dynamic> proofDocumentUrlsDynamic =
                data['proofDocumentUrl'] ?? [];
            List<String> proofDocumentUrls =
                proofDocumentUrlsDynamic.cast<String>().toList();
            String skillsAcquired = data['skillsAcquired'] ?? '';

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
                            courseName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF468F92),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (platformName.isNotEmpty)
                            Text(
                              'Platform: $platformName',
                              style: const TextStyle(
                                  fontSize: 16, color: Color(0xFF6C7F93)),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            'Duration: $duration',
                            style: const TextStyle(
                                fontSize: 16, color: Color(0xFF6C7F93)),
                          ),
                          const SizedBox(height: 4),
                          if (skillsAcquired.isNotEmpty &&
                              onlineCourseType ==
                                  'past') // Show skills for past courses only
                            Text(
                              'Skills Acquired: $skillsAcquired',
                              style: const TextStyle(
                                  fontSize: 16, color: Color(0xFF6C7F93)),
                            ),
                          if (certificateUrls.isNotEmpty &&
                              onlineCourseType == 'past')
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Certificates:',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.grey)),
                                  for (var certUrl in certificateUrls)
                                    if (certUrl.toString().isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 4.0),
                                        child: InkWell(
                                          onTap: () async {
                                            final Uri uri =
                                                Uri.parse(certUrl.toString());
                                            bool canLaunch =
                                                await canLaunchUrl(uri);
                                            if (canLaunch) {
                                              launchUrl(uri);
                                            } else {
                                              showSnackBar(context,
                                                  'Could not launch URL: $certUrl');
                                            }
                                          },
                                          child: Text(
                                            'Certificate ${certificateUrls.indexOf(certUrl) + 1}: View Certificate',
                                            style: const TextStyle(
                                                color: Color(0XFF799ACC),
                                                fontWeight: FontWeight.bold,
                                                decoration:
                                                    TextDecoration.underline),
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                            ),
                          if (proofDocumentUrls.isNotEmpty &&
                              onlineCourseType == 'current')
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Proof Documents:',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.grey)),
                                  for (var proofUrl in proofDocumentUrls)
                                    if (proofUrl.toString().isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 4.0),
                                        child: InkWell(
                                          onTap: () async {
                                            final Uri uri =
                                                Uri.parse(proofUrl.toString());
                                            bool canLaunch =
                                                await canLaunchUrl(uri);
                                            if (canLaunch) {
                                              launchUrl(uri);
                                            } else {
                                              showSnackBar(context,
                                                  'Could not launch URL: $proofUrl');
                                            }
                                          },
                                          child: Text(
                                            'Proof Document ${proofDocumentUrls.indexOf(proofUrl) + 1}: View Proof',
                                            style: const TextStyle(
                                                color: Color(0XFF799ACC),
                                                fontWeight: FontWeight.bold,
                                                decoration:
                                                    TextDecoration.underline),
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
                          _showEditOnlineCourseDialog(context, document,
                              onlineCourseType); // Will create this next
                        } else if (value == 'delete') {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm Deletion'),
                                content: const Text(
                                    'Are you sure you want to delete this online course detail?'),
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
                                        List<String> allMediaUrls = [
                                          ...certificateUrls
                                              .map((url) => url.toString()),
                                          ...proofDocumentUrls
                                              .map((url) => url.toString()),
                                        ];
                                        await _deleteOnlineCourse(
                                          // Create this function next
                                          studentId: studentId,
                                          onlineCourseType: onlineCourseType,
                                          courseName: courseName,
                                          mediaUrls: allMediaUrls,
                                        );
                                        _loadOnlineCourse(); // Refresh course list
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

  Stream<QuerySnapshot<Map<String, dynamic>>> _getOnlineCourseStream(
      String studentId, String type) {
    return firestore
        .collection('online_courses') // Changed collection to 'internship'
        .doc(studentId)
        .collection(type) // Access the 'current' or 'past' subcollection
        .snapshots();
  }

  @override
  void initState() {
    super.initState();
    _loadOnlineCourse(); // Changed function call to _loadInternships
  }

  void _loadOnlineCourse() {
    // Renamed function to _loadInternships
    User? user = auth.currentUser;
    String? studentId = user?.uid; // More descriptive variable name
    if (studentId != null) {
      _currentOnlineCourseStream = // Use _currentInternshipStream
          _getOnlineCourseStream(
              studentId, 'current'); // Call _getInternshipStream
      _pastOnlineCourseStream = // Use _pastInternshipStream
          _getOnlineCourseStream(
              studentId, 'past'); // Call _getInternshipStream
    }
  }

  Future<void> _deleteOnlineCourse({
    required String studentId,
    required String onlineCourseType,
    required String courseName, // Changed from heading to courseName
    List<String>?
        mediaUrls, // Changed from fileUrls to mediaUrls to handle both proofs and certificates
  }) async {
    try {
      // Delete media files from Firebase Storage if they exist
      if (mediaUrls != null && mediaUrls.isNotEmpty) {
        for (String mediaUrl in mediaUrls) {
          // Loop through the list of media URLs (proof documents and certificate URLs)
          if (mediaUrl.isNotEmpty) {
            // Check if URL is not empty
            try {
              Reference fileRef = storage.refFromURL(mediaUrl);
              await fileRef.delete();
            } catch (storageError) {
              // Log storage deletion error, but continue with Firestore document deletion
              // Consider adding more robust error handling/user feedback if needed.
            }
          }
        }
      }
      // Delete Firestore document from the respective subcollection in 'online_courses'
      await firestore
          .collection(
              'online_courses') // Changed collection to 'online_courses'
          .doc(studentId)
          .collection(onlineCourseType) // Use onlineCourseType (current/past)
          .doc(courseName) // Use courseName as document ID
          .delete();

      showSnackBar(context,
          'Online course details deleted successfully.'); // Updated message
    } catch (e) {
      showSnackBar(context,
          'Error deleting online course details: $e'); // Updated message
    }
  }

  void _showEditOnlineCourseDialog(
      BuildContext context,
      DocumentSnapshot<Map<String, dynamic>> document,
      String onlineCourseType) {
    // Get current field values - Online Course specific fields
    String currentCourseName = document.data()?['courseName'] ?? '';
    String currentPlatformName = document.data()?['platformName'] ?? '';
    String currentDuration = document.data()?['duration'] ?? '';
    String currentSkillsAcquired = document.data()?['skillsAcquired'] ?? '';

    // Fetch lists of media URLs
    List<dynamic> currentCertificateUrlsDynamic =
        document.data()?['certificateUrl'] ?? [];
    List<dynamic> currentProofDocumentUrlsDynamic =
        document.data()?['proofDocumentUrl'] ?? [];

    List<String> currentCertificateUrls =
        currentCertificateUrlsDynamic.cast<String>().toList();
    List<String> currentProofDocumentUrls =
        currentProofDocumentUrlsDynamic.cast<String>().toList();

    // Controllers pre-populated with current values - Online Course specific
    TextEditingController editCourseNameController =
        TextEditingController(text: currentCourseName);
    TextEditingController editPlatformNameController =
        TextEditingController(text: currentPlatformName);
    TextEditingController editDurationController =
        TextEditingController(text: currentDuration);
    TextEditingController editSkillsAcquiredController =
        TextEditingController(text: currentSkillsAcquired);

    // Lists to hold currently displayed certificate and proof document URLs/names
    List<String> certificateFileNames = [
      ...currentCertificateUrls
    ]; // Initially URLs, will be replaced by filenames after upload
    List<String> proofDocumentFileNames = [
      ...currentProofDocumentUrls
    ]; // Initially URLs, will be replaced by filenames after upload

    List<File> newCertificateFiles =
        []; // To hold newly selected certificate files
    List<File> newProofDocumentFiles =
        []; // To hold newly selected proof document files

    List<String> deletedCertificateUrls =
        []; // List to track certificate URLs to delete
    List<String> deletedProofDocumentUrls =
        []; // List to track proof document URLs to delete

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Online Course Details'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Editable Course Name
                    TextField(
                      controller: editCourseNameController,
                      decoration:
                          const InputDecoration(labelText: 'Course Name'),
                    ),
                    const SizedBox(height: 10),
                    // Editable Platform Name
                    TextField(
                      controller: editPlatformNameController,
                      decoration:
                          const InputDecoration(labelText: 'Platform Name'),
                    ),
                    const SizedBox(height: 10),
                    // Editable Duration
                    TextField(
                      controller: editDurationController,
                      decoration: const InputDecoration(labelText: 'Duration'),
                    ),
                    const SizedBox(height: 10),

                    if (onlineCourseType ==
                        'past') // Skills acquired only for past courses
                      TextField(
                        controller: editSkillsAcquiredController,
                        decoration: const InputDecoration(
                            labelText: 'Skills Acquired (Optional)'),
                        maxLines: 2,
                      ),
                    if (onlineCourseType == 'past') const SizedBox(height: 10),

                    // --- Section for Certificate Documents (Past Courses) ---
                    if (onlineCourseType == 'past')
                      const Text("Certificates:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    if (onlineCourseType == 'past')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display current certificate files (or URLs initially)
                          ...List<Widget>.generate(certificateFileNames.length,
                              (index) {
                            String fileName = certificateFileNames[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                          fileName)), // Display file name or URL for existing
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      String urlToDelete = currentCertificateUrls[
                                          index]; // Use current URL for deletion
                                      deletedCertificateUrls.add(urlToDelete);
                                      setState(() {
                                        certificateFileNames.removeAt(index);
                                        currentCertificateUrls.removeAt(
                                            index); // Keep current URLs list updated
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                          // Button to add more certificate documents
                          ElevatedButton(
                            onPressed: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: [
                                  'pdf',
                                  'jpg',
                                  'png',
                                  'jpeg'
                                ], // Example extensions
                                allowMultiple: true,
                              );
                              if (result != null) {
                                setState(() {
                                  newCertificateFiles.addAll(
                                      result.files.map((e) => File(e.path!)));
                                  certificateFileNames.addAll(result.files.map(
                                      (e) => e.name)); // Display file names
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Pallet.headingColor),
                            child: const Text('Add Certificates',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    if (onlineCourseType == 'past') const SizedBox(height: 10),

                    // --- Section for Proof Documents (Current Courses) ---
                    if (onlineCourseType == 'current')
                      const Text("Proof Documents:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    if (onlineCourseType == 'current')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display current proof document files (or URLs initially)
                          ...List<Widget>.generate(
                              proofDocumentFileNames.length, (index) {
                            String fileName = proofDocumentFileNames[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                          fileName)), // Display file name or URL for existing
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      String urlToDelete = currentProofDocumentUrls[
                                          index]; // Use current URL for deletion
                                      deletedProofDocumentUrls.add(urlToDelete);
                                      setState(() {
                                        proofDocumentFileNames.removeAt(index);
                                        currentProofDocumentUrls.removeAt(
                                            index); // Keep current URLs list updated
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                          // Button to add more proof documents
                          ElevatedButton(
                            onPressed: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: [
                                  'pdf',
                                  'jpg',
                                  'png',
                                  'jpeg'
                                ], // Example extensions
                                allowMultiple: true,
                              );
                              if (result != null) {
                                setState(() {
                                  newProofDocumentFiles.addAll(
                                      result.files.map((e) => File(e.path!)));
                                  proofDocumentFileNames.addAll(result.files
                                      .map(
                                          (e) => e.name)); // Display file names
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Pallet.headingColor),
                            child: const Text('Add Documents',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    if (onlineCourseType == 'current')
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
                    // Get updated values - Online Course specific
                    String updatedCourseName =
                        editCourseNameController.text.trim();
                    String updatedPlatformName =
                        editPlatformNameController.text.trim();
                    String updatedDuration = editDurationController.text.trim();
                    String updatedSkillsAcquired =
                        editSkillsAcquiredController.text.trim();

                    List<String> uploadedCertificateUrls = [];
                    List<String> uploadedProofDocumentUrls = [];

                    // Upload new certificate files and get URLs
                    if (newCertificateFiles.isNotEmpty) {
                      uploadedCertificateUrls =
                          await _uploadMediaFilesToStorage(
                        studentId: auth.currentUser!.uid,
                        files: newCertificateFiles,
                        folderPath: 'online_courses/certificates',
                        context: context,
                      );
                    }
                    // Upload new proof document files and get URLs
                    if (newProofDocumentFiles.isNotEmpty) {
                      uploadedProofDocumentUrls =
                          await _uploadMediaFilesToStorage(
                        studentId: auth.currentUser!.uid,
                        files: newProofDocumentFiles,
                        folderPath: 'online_courses/proof_documents',
                        context: context,
                      );
                    }

                    // --- Build the update data map --- - Online Course specific fields
                    Map<String, dynamic> updateData = {};
                    updateData['courseName'] = updatedCourseName;
                    updateData['platformName'] = updatedPlatformName;
                    updateData['duration'] = updatedDuration;
                    if (onlineCourseType == 'past') {
                      updateData['skillsAcquired'] = updatedSkillsAcquired;
                      updateData['certificateUrl'] = [
                        ...currentCertificateUrls,
                        ...uploadedCertificateUrls
                      ]; // Combine old and new URLs
                    } else if (onlineCourseType == 'current') {
                      updateData['proofDocumentUrl'] = [
                        ...currentProofDocumentUrls,
                        ...uploadedProofDocumentUrls
                      ]; // Combine old and new URLs
                    }

                    String studentId = auth.currentUser!.uid;
                    String oldDocId =
                        currentCourseName; // Use courseName as doc ID

                    // Option B: Create a new document if the courseName (document ID) has changed.
                    if (updatedCourseName != currentCourseName) {
                      // Create new document with updated courseName
                      await firestore
                          .collection('online_courses')
                          .doc(studentId)
                          .collection(onlineCourseType)
                          .doc(updatedCourseName)
                          .set(updateData);
                      // Delete the old document
                      await firestore
                          .collection('online_courses')
                          .doc(studentId)
                          .collection(onlineCourseType)
                          .doc(oldDocId)
                          .delete();
                    } else {
                      // If the courseName remains the same, update in place
                      await firestore
                          .collection('online_courses')
                          .doc(studentId)
                          .collection(onlineCourseType)
                          .doc(oldDocId)
                          .update(updateData);
                    }

                    // Delete removed media files from storage
                    await _deleteMediaFilesFromStorage(deletedCertificateUrls);
                    await _deleteMediaFilesFromStorage(
                        deletedProofDocumentUrls);

                    Navigator.of(dialogContext).pop();
                    _loadOnlineCourse(); // Refresh online course list
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

  Future<List<String>> _uploadMediaFilesToStorage({
    required String studentId,
    required List<File> files,
    required String folderPath,
    required BuildContext context,
  }) async {
    List<String> downloadUrls = [];
    for (File file in files) {
      String fileName = file.path.split('/').last;
      Reference storageReference =
          storage.ref().child('$folderPath/$studentId/$fileName');
      try {
        await storageReference.putFile(file);
        String downloadUrl = await storageReference.getDownloadURL();
        downloadUrls.add(downloadUrl);
      } catch (e) {
        showSnackBar(context, 'Error uploading file: $fileName - $e');

        // Consider more robust error handling, maybe stop the whole upload process
        // or provide a way to retry individual uploads.
      }
    }
    return downloadUrls;
  }

  Future<void> _deleteMediaFilesFromStorage(List<String> urls) async {
    for (String url in urls) {
      if (url.isNotEmpty) {
        try {
          Reference fileRef = FirebaseStorage.instance.refFromURL(url);
          await fileRef.delete();
        } catch (e) {
          // Consider adding more robust error handling, like showing a SnackBar
          // if media deletion fails, or retry mechanism.
        }
      }
    }
  }
}

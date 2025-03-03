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

class StudentInternship extends StatefulWidget {
  const StudentInternship({super.key});

  @override
  State<StudentInternship> createState() => _StudentInternshipState();
}

class _StudentInternshipState extends State<StudentInternship> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>>? _currentInternshipStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _pastInternshipStream;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Pallet.headingColor,
        title: const Text(
          "Internship",
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
          _showUploadInternshipDialog(context);
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
                'Current Internships', // Changed text
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildInternshipList(
                  // Replaced _buildResearchList with _buildInternshipList
                  internshipStream:
                      _currentInternshipStream, // Assuming you will create _currentInternshipStream
                  internshipType: 'current'),
              const SizedBox(height: 20),
              const Text(
                'Past Internships', // Changed text
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildInternshipList(
                  // Replaced _buildResearchList with _buildInternshipList
                  internshipStream:
                      _pastInternshipStream, // Assuming you will create _pastInternshipStream
                  internshipType: 'past'),
            ],
          ),
        ),
      ),
    );
  }

  // 1st block of code for [+] bottom-right upload button

  void _showUploadInternshipDialog(BuildContext context) {
    String? selectedOption;
    final TextEditingController companyNameController =
        TextEditingController();
    final TextEditingController fieldController = TextEditingController();
    final TextEditingController durationController = TextEditingController();
    final TextEditingController stipendController = TextEditingController();
    List<File> certificateFiles =
        []; // List to store multiple certificate files

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Upload Internship Details'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'Select Option'),
                      value: selectedOption,
                      items: const [
                        DropdownMenuItem(
                          value: "current",
                          child: Text("Add current internship"),
                        ),
                        DropdownMenuItem(
                          value: "past",
                          child: Text("Add past internship"),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedOption = newValue;
                        });
                      },
                    ),
                    if (selectedOption == "current")
                      Column(
                        children: [
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: companyNameController,
                            decoration: const InputDecoration(
                              labelText: 'Company Name',
                            ),
                          ),
                          const SizedBox(height: 5),
                          TextFormField(
                            controller: fieldController,
                            decoration: const InputDecoration(
                                labelText: 'Field/Technology'),
                          ),
                          const SizedBox(height: 5),
                          TextFormField(
                            controller: durationController,
                            decoration: const InputDecoration(
                                labelText: 'Duration (Days)'),
                            keyboardType:
                                TextInputType.number, // Input type for duration
                          ),
                          const SizedBox(height: 5),
                          TextFormField(
                            controller: stipendController,
                            decoration: const InputDecoration(
                                labelText: 'Stipend (or N/A)'),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowMultiple: true, // Allow multiple selection
                                allowedExtensions: [
                                  'jpg',
                                  'png',
                                  'pdf',
                                  'docx',
                                  'odt',
                                ], // Common certificate formats
                              );

                              if (result != null && result.files.isNotEmpty) {
                                setState(() {
                                  certificateFiles = result.files
                                      .map((e) => File(e.path!))
                                      .toList();
                                });
                                print(
                                    'Selected certificate files: ${certificateFiles.map((file) => file.path).toList()}'); // Debugging
                              } else {
                                // User canceled the picker
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Pallet.headingColor,
                              minimumSize: const Size(50, 40),
                            ),
                            child: const Text(
                              'Upload Certificates',
                              style: TextStyle(color: Colors.white),
                            ),
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
                        children: [
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: companyNameController,
                            decoration: const InputDecoration(
                              labelText: 'Company Name',
                            ),
                          ),
                          const SizedBox(height: 5),
                          TextFormField(
                            controller: fieldController,
                            decoration: const InputDecoration(
                                labelText: 'Field/Technology'),
                          ),
                          const SizedBox(height: 5),
                          TextFormField(
                            controller: durationController,
                            decoration: const InputDecoration(
                                labelText: 'Duration (Days)'),
                            keyboardType:
                                TextInputType.number, // Input type for duration
                          ),
                          const SizedBox(height: 5),
                          TextFormField(
                            controller: stipendController,
                            decoration: const InputDecoration(
                                labelText: 'Stipend (or N/A)'),
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
                                  'docx',
                                  'odt',
                                ], // Common certificate formats
                              );

                              if (result != null && result.files.isNotEmpty) {
                                setState(() {
                                  certificateFiles = result.files
                                      .map((e) => File(e.path!))
                                      .toList();
                                });
                                print(
                                    'Selected certificate files: ${certificateFiles.map((file) => file.path).toList()}'); // Debugging
                              } else {
                                // User canceled the picker
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Pallet.headingColor,
                              minimumSize: const Size(50, 40),
                            ),
                            child: const Text(
                              'Upload Certificates',
                              style: TextStyle(color: Colors.white),
                            ),
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
                    selectedOption = null;
                    companyNameController.clear();
                    fieldController.clear();
                    durationController.clear();
                    stipendController.clear();
                    certificateFiles.clear();
                  },
                ),
                TextButton(
                  child: const Text('Submit'),
                  onPressed: () async {
                    User? user = auth.currentUser;
                    String? studentDocumentId = user?.uid;

                    if (studentDocumentId != null) {
                      List<String> certificateUrls =
                          []; // List to store certificate URLs

                      // Upload multiple certificate files
                      for (File file in certificateFiles) {
                        String? url = await _uploadFileToStorage(
                            studentId: studentDocumentId,
                            file: file,
                            fileType:
                                'internship_certificates'); // Changed fileType
                        if (url != null) {
                          certificateUrls.add(url);
                        }
                      }

                      String companyName = companyNameController.text;
                      String field = fieldController.text;
                      String duration = durationController.text;
                      String stipend = stipendController.text;

                      _uploadInternshipData(
                        // Call new function for Internship data
                        studentId: studentDocumentId,
                        type:
                            selectedOption!, // _selectedOption is guaranteed to be not null here
                        companyName: companyName,
                        field: field,
                        duration: duration,
                        stipend: stipend,
                        certificateUrls:
                            certificateUrls, // Pass certificate URL list
                      );

                      Navigator.of(dialogContext).pop();
                      selectedOption = null;
                      companyNameController.clear();
                      fieldController.clear();
                      durationController.clear();
                      stipendController.clear();
                      certificateFiles.clear();
                      _loadInternships(); // Create this function next to reload internships after upload - similar to _loadResearchPapers
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

// 2nd block of code to upload certificates to Firebase Storage

  Future<String?> _uploadFileToStorage({
    required String studentId,
    required File file,
    required String fileType,
  }) async {
    try {
      String fileName = file.path.split('/').last;
      Reference storageReference = storage.ref().child(
          'internship_certificates/$studentId/$fileType/$fileName'); // Storage path

      UploadTask uploadTask = storageReference.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      // Handle error, maybe return null or throw exception
      return null;
    }
  }

  // 3rd block of code to upload the internship field details to
  // firebase database

  Future<void> _uploadInternshipData({
    required String? studentId,
    required String type,
    String? companyName,
    String? field,
    String? duration,
    String? stipend,
    List<String>? certificateUrls, // List to store certificate URLs
  }) async {
    print("--- _uploadInternshipData ---");
    print("Student ID: $studentId, Type: $type, Company Name: $companyName");
    print(
        "Field: $field, Duration: $duration, Stipend: $stipend, Certificate URLs: $certificateUrls");

    try {
      CollectionReference internshipsCollection = firestore
          .collection('internship'); // Changed collection to 'internship'

      // Document ID will be the same as student's document ID
      DocumentReference studentDoc = internshipsCollection.doc(studentId);

      CollectionReference typeCollection =
          studentDoc.collection(type); // 'current' or 'past' subcollection
      DocumentReference internshipDoc = typeCollection.doc(
          companyName); // Use companyName as document ID within subcollection (can be changed if needed)

      Map<String, dynamic> internshipData = {};
      internshipData['type'] = type; // Still include type for clarity
      internshipData['companyName'] = companyName;
      if (field != null) {
        internshipData['field'] = field;
      }
      if (duration != null) {
        internshipData['duration'] = duration;
      }
      if (stipend != null) {
        internshipData['stipend'] = stipend;
      }
      if (certificateUrls != null) {
        // Store the list of certificate URLs
        internshipData['certificateUrl'] = certificateUrls;
      } else {
        internshipData['certificateUrl'] =
            []; // Store empty list if no certificates, consistent data type
      }

      await internshipDoc
          .set(internshipData) // Use set() to create or overwrite
          .then((_) {
        showSnackBar(context,
            'Internship data uploaded to Firestore for student ID: $studentId in $type collection');
      }).catchError((error) {
        showSnackBar(
            context, 'Error uploading internship data to Firestore: $error');
      });

      // Optionally show a success message to the user
    } catch (e) {
      showSnackBar(context, 'Error uploading internship data to Firestore: $e');
      // Optionally show an error message to the user
    }
  }

// 4th block of code to display data on the page in the form of cards

  Widget _buildInternshipList(
      {required Stream<QuerySnapshot<Map<String, dynamic>>>? internshipStream,
      required String internshipType}) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: internshipStream,
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No $internshipType internships uploaded yet.');
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot<Map<String, dynamic>> document =
                snapshot.data!.docs[index];
            Map<String, dynamic> data = document.data()!;
            String companyName = data['companyName'] ?? 'No Company Name';
            String field = data['field'] ?? 'No Field Specified';
            String duration = data['duration'] ?? 'N/A';
            String stipend = data['stipend'] ?? 'N/A';
            List<dynamic> certificateUrls = data['certificateUrl'] is List
                ? data['certificateUrl']
                : (data['certificateUrl'] != null
                    ? [data['certificateUrl']]
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
                            companyName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF468F92),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (field.isNotEmpty)
                            Text(
                              'Field/Technology: $field',
                              style: const TextStyle(
                                  fontSize: 16, color: Color(0xFF6C7F93)),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            'Duration: $duration Days',
                            style: const TextStyle(
                                fontSize: 16, color: Color(0xFF6C7F93)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Stipend: $stipend',
                            style: const TextStyle(
                                fontSize: 16, color: Color(0xFF6C7F93)),
                          ),
                          if (certificateUrls.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Certificates:',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.grey)),
                                  for (var certUrl in certificateUrls)
                                    if (certUrl != null &&
                                        certUrl.toString().isNotEmpty)
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
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      color: const Color.fromARGB(255, 255, 217, 134),
                      icon: const Icon(Icons.more_vert),
                      onSelected: (String value) {
                        if (value == 'edit') {
                          _showEditInternshipDialog(context, document,
                              internshipType); // Create this function next
                        } else if (value == 'delete') {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm Deletion'),
                                content: const Text(
                                    'Are you sure you want to delete this internship detail?'),
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
                                        List<String>? fileUrls =
                                            certificateUrls.cast<
                                                String>(); // Cast to List<String> for delete function

                                        await _deleteInternship(
                                          //Create this function next
                                          studentId: studentId,
                                          internshipType: internshipType,
                                          companyName: companyName,
                                          fileUrls: fileUrls,
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

// 5th block to fetch the data in the form of stream from firebase
// database

  Stream<QuerySnapshot<Map<String, dynamic>>> _getInternshipStream(
      String studentId, String type) {
    return firestore
        .collection('internship') // Changed collection to 'internship'
        .doc(studentId)
        .collection(type) // Access the 'current' or 'past' subcollection
        .snapshots();
  }

// 6th block of code to load the data onto page that comes in the form of
// stream from 5th block

  @override
  void initState() {
    super.initState();
    _loadInternships(); // Changed function call to _loadInternships
  }

  void _loadInternships() {
    // Renamed function to _loadInternships
    User? user = auth.currentUser;
    String? studentId = user?.uid; // More descriptive variable name
    if (studentId != null) {
      _currentInternshipStream = // Use _currentInternshipStream
          _getInternshipStream(
              studentId, 'current'); // Call _getInternshipStream
      _pastInternshipStream = // Use _pastInternshipStream
          _getInternshipStream(studentId, 'past'); // Call _getInternshipStream
    }
  }

// 7th block of code to delete the card.

  Future<void> _deleteInternship({
    required String studentId,
    required String internshipType,
    required String companyName, // Changed from heading to companyName
    List<String>? fileUrls, // Keep fileUrls for certificate URLs
  }) async {
    try {
      // Delete files from Firebase Storage if they exist
      if (fileUrls != null && fileUrls.isNotEmpty) {
        for (String fileUrl in fileUrls) {
          // Loop through the list of file URLs (certificate URLs in this case)
          if (fileUrl.isNotEmpty) {
            // Check if URL is not empty
            try {
              Reference fileRef = storage.refFromURL(fileUrl);
              await fileRef.delete();
            } catch (storageError) {
              // Log storage deletion error, but continue with Firestore document deletion
              // Consider adding more robust error handling/user feedback if needed.
            }
          }
        }
      }
      // Delete Firestore document from the respective subcollection in 'internship'
      await firestore
          .collection('internship') // Changed collection to 'internship'
          .doc(studentId)
          .collection(internshipType) // Use internshipType
          .doc(companyName) // Changed document ID to companyName
          .delete();

      showSnackBar(context,
          'Internship details deleted successfully.'); // Updated message
    } catch (e) {
      showSnackBar(
          context, 'Error deleting internship details: $e'); // Updated message
    }
  }

// 8th block of code to edit the card(s)

  void _showEditInternshipDialog(BuildContext context,
      DocumentSnapshot<Map<String, dynamic>> document, String internshipType) {
    // Get current field values - Internship specific fields
    String currentCompanyName = document.data()?['companyName'] ?? '';
    String currentRole = document.data()?['role'] ?? '';
    String currentDuration =
        document.data()?['duration'] ?? ''; // Assuming duration is relevant
    String currentStipend =
        document.data()?['stipend'] ?? ''; // Get current stipend
    String currentTechField = document.data()?['technologyField'] ??
        ''; // Get current technology/field

    // Fetch lists of certificate URLs, handling null and non-list cases
    List<dynamic> currentCertificateUrlsDynamic =
        document.data()?['certificateUrl'] ?? [];

    // Ensure they are lists of strings, or empty lists if not.
    List<String> currentCertificateUrls =
        currentCertificateUrlsDynamic.cast<String>().toList();

    // Controllers pre-populated with current values - Internship specific
    TextEditingController editCompanyNameController =
        TextEditingController(text: currentCompanyName);
    TextEditingController editRoleController =
        TextEditingController(text: currentRole);
    TextEditingController editDurationController =
        TextEditingController(text: currentDuration); // Controller for duration
    TextEditingController editStipendController = // Controller for stipend
        TextEditingController(text: currentStipend);
    TextEditingController
        editTechFieldController = // Controller for technology/field
        TextEditingController(text: currentTechField);

    File? newCertificateFile; // For replacing certificate file
    bool deleteExistingCertificateFile = false;
    List<File> additionalCertificateFiles =
        []; // For adding multiple certificate files

    // Initialize controllers for existing certificate URLs
    List<TextEditingController> certificateUrlControllers =
        currentCertificateUrls
            .map((url) => TextEditingController(text: url))
            .toList();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Internship Details'), // Updated title
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Editable Company Name
                    TextField(
                      controller: editCompanyNameController,
                      decoration: const InputDecoration(
                          labelText: 'Company Name'), // Updated label
                    ),
                    const SizedBox(height: 10),
                    // For 'current' type show Role field; for 'past' show Duration field
                    internshipType == 'current'
                        ? TextField(
                            controller: editRoleController,
                            decoration: const InputDecoration(
                                labelText: 'Role'), // Updated label
                            maxLines: 3,
                          )
                        : TextField(
                            controller: editDurationController,
                            decoration: const InputDecoration(
                                labelText: 'Duration'), // Updated label
                          ),
                    const SizedBox(height: 10),

                    // Stipend Field - Added
                    TextField(
                      controller: editStipendController,
                      decoration: const InputDecoration(
                          labelText: 'Stipend (Optional)'), // Added label
                      keyboardType:
                          TextInputType.number, // Suggest numeric keyboard
                    ),
                    const SizedBox(height: 10),

                    // Technology/Field Used Field - Added
                    TextField(
                      controller: editTechFieldController,
                      decoration: const InputDecoration(
                          labelText:
                              'Technology/Field Used (Optional)'), // Added label
                      maxLines:
                          2, // Allow multiple lines for technologies/fields
                    ),
                    const SizedBox(height: 20),

                    // --- Display and Edit Certificate URLs ---
                    const Text(
                        "Certificate Documents:"), // Updated section title
                    ...List.generate(
                        certificateUrlControllers.length,
                        (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller:
                                          certificateUrlControllers[index],
                                      decoration: InputDecoration(
                                          labelText:
                                              'Certificate URL ${index + 1}'), // Updated label
                                    ),
                                  ),
                                  if (certificateUrlControllers.length > 1)
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          certificateUrlControllers
                                              .removeAt(index);
                                        });
                                      },
                                    ),
                                ],
                              ),
                            )),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          certificateUrlControllers
                              .add(TextEditingController());
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Pallet.headingColor),
                      child: const Text(
                          'Add Certificate URL', // Updated button text
                          style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 10),

                    // --- Replace Main Certificate File (if needed) ---
                    if (!deleteExistingCertificateFile &&
                        currentCertificateUrls.isNotEmpty)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Current main certificate: ${currentCertificateUrls.isNotEmpty ? currentCertificateUrls.first.split('/').last : 'No main certificate'}', // Updated text
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                deleteExistingCertificateFile = true;
                              });
                            },
                          ),
                        ],
                      ),
                    if (deleteExistingCertificateFile)
                      const Text(
                        'Certificate file will be deleted.', // Updated text
                        style: TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                      type: FileType.custom,
                                      allowedExtensions: [
                                    'jpg',
                                    'png',
                                    'pdf'
                                  ]); // Common certificate formats
                              if (result != null && result.files.isNotEmpty) {
                                setState(() {
                                  newCertificateFile =
                                      File(result.files.first.path!);
                                  deleteExistingCertificateFile = false;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Pallet.headingColor),
                            child: const Text(
                              'Replace Certificate File', // Updated button text
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                      type: FileType.custom,
                                      allowMultiple: true,
                                      allowedExtensions: [
                                    'jpg',
                                    'png',
                                    'pdf'
                                  ]); // Common certificate formats
                              if (result != null && result.files.isNotEmpty) {
                                setState(() {
                                  for (var file in result.files) {
                                    if (file.path != null) {
                                      additionalCertificateFiles
                                          .add(File(file.path!));
                                    }
                                  }
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Pallet.headingColor),
                            child: const Text(
                              'Add Certificate Files', // Updated button text
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (newCertificateFile != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'New file: ${newCertificateFile!.path.split('/').last}', // Updated text
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    if (additionalCertificateFiles.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                                'Added certificate documents:', // Updated text
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            ...additionalCertificateFiles.map((file) => Text(
                                  '• ${file.path.split('/').last}', // Updated text
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
                    // Get updated values - Internship specific
                    String updatedCompanyName =
                        editCompanyNameController.text.trim();
                    String updatedRole = editRoleController.text.trim();
                    String updatedDuration = editDurationController.text.trim();
                    String updatedStipend = editStipendController.text
                        .trim(); // Get updated stipend
                    String updatedTechField = editTechFieldController.text
                        .trim(); // Get updated technology/field

                    String?
                        newMainCertificateUrl; // URL for replaced main certificate
                    List<String> newAdditionalCertificateUrls =
                        []; // URLs for added certificates

                    // If a new certificate file was selected (replace file button)
                    if (newCertificateFile != null) {
                      newMainCertificateUrl = await _uploadFileToStorage(
                        studentId: auth.currentUser!.uid,
                        file: newCertificateFile!,
                        fileType:
                            'certificate_documents', // Updated fileType for certificates
                      );
                    } else if (deleteExistingCertificateFile) {
                      newMainCertificateUrl =
                          ''; // Set to empty string if main file deleted
                    }

                    // Upload additional certificate files and get their URLs
                    for (var file in additionalCertificateFiles) {
                      String? url = await _uploadFileToStorage(
                        studentId: auth.currentUser!.uid,
                        file: file,
                        fileType:
                            'certificate_documents', // Updated fileType for certificates
                      );
                      if (url != null) {
                        newAdditionalCertificateUrls.add(url);
                      }
                    }

                    // --- Build the update data map --- - Internship specific fields
                    Map<String, dynamic> updateData = {};
                    updateData['companyName'] = updatedCompanyName;
                    if (internshipType == 'current') {
                      updateData['role'] = updatedRole;
                    } else {
                      updateData['duration'] = updatedDuration;
                    }
                    updateData['stipend'] =
                        updatedStipend; // Add stipend to update data
                    updateData['technologyField'] =
                        updatedTechField; // Add technology/field to update data

                    // Handle main certificate URL update
                    if (newMainCertificateUrl != null) {
                      updateData['certificateUrl'] = [
                        newMainCertificateUrl
                      ]; // Replace main URL
                    } else if (deleteExistingCertificateFile) {
                      updateData['certificateUrl'] =
                          []; // Set to empty if deleted
                    } else {
                      updateData['certificateUrl'] = certificateUrlControllers
                          .map((controller) => controller.text)
                          .toList(); // Keep existing URLs
                    }

                    // Add new additional certificate URLs
                    if (newAdditionalCertificateUrls.isNotEmpty) {
                      List<String> existingUrls = certificateUrlControllers
                          .map((controller) => controller.text)
                          .toList();
                      updateData['certificateUrl'] = [
                        ...existingUrls,
                        ...newAdditionalCertificateUrls
                      ];
                    } else {
                      updateData['certificateUrl'] = certificateUrlControllers
                          .map((controller) => controller.text)
                          .toList();
                    }

                    String studentId = auth.currentUser!.uid;
                    String oldDocId =
                        currentCompanyName; // Use companyName as doc ID

                    // Option B: Create a new document if the companyName (document ID) has changed.
                    if (updatedCompanyName != currentCompanyName) {
                      // Create new document with updated companyName
                      await firestore
                          .collection('internship') // Updated collection
                          .doc(studentId)
                          .collection(internshipType)
                          .doc(
                              updatedCompanyName) // Use updatedCompanyName as doc ID
                          .set(updateData);
                      // Delete the old document
                      await firestore
                          .collection('internship') // Updated collection
                          .doc(studentId)
                          .collection(internshipType)
                          .doc(
                              oldDocId) // Use oldDocId (currentCompanyName before edit)
                          .delete();
                    } else {
                      // If the companyName remains the same, update in place
                      await firestore
                          .collection('internship') // Updated collection
                          .doc(studentId)
                          .collection(internshipType)
                          .doc(oldDocId) // Use oldDocId (currentCompanyName)
                          .update(updateData);
                    }

                    Navigator.of(dialogContext).pop();
                    _loadInternships(); // Refresh internship list
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
}

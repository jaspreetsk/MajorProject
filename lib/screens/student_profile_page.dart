// // import 'package:academiax/constants/pallet.dart';
// // import 'package:academiax/screens/student_home_screen.dart';
// // import 'package:flutter/material.dart';

// // class StudentProfile extends StatefulWidget {
// //   const StudentProfile({super.key});

// //   @override
// //   State<StudentProfile> createState() => _StudentProfileState();
// // }

// // class _StudentProfileState extends State<StudentProfile> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         centerTitle: true,
// //         backgroundColor: Pallet.headingColor,
// //         title: const Text(
// //           "My Profile",
// //           style: TextStyle(
// //             color: Colors.white,
// //             fontWeight: FontWeight.bold,
// //           ),
// //         ),
// //         leading: IconButton(
// //           onPressed: () {
// //             Navigator.of(context).pushReplacement(
// //               MaterialPageRoute(builder: (context) => StudentHomeScreen()),
// //             );
// //           },
// //           icon: const Icon(
// //             Icons.arrow_back,
// //             color: Colors.white,
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'dart:io';

// import 'package:academiax/constants/pallet.dart';
// import 'package:academiax/firebase_authentication/firebase_auth.dart';
// import 'package:academiax/firebase_authentication/show_snack_bar.dart';
// import 'package:academiax/screens/student_home_screen.dart';
// import 'package:academiax/wigets/textfield.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class StudentProfile extends StatefulWidget {
//   const StudentProfile({super.key});

//   @override
//   State<StudentProfile> createState() => _StudentProfileState();
// }

// class _StudentProfileState extends State<StudentProfile> {
//   FirebaseAuth _auth = FirebaseAuth.instance;
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController enrollmentNoController = TextEditingController();
//   String? selectedValueDepartment;
//   int? selectedValueYear;
//   String? selectedValueClub;
//   File? _profileImage;
//   String? profileImageUrl;
//   bool _isLoading = false;

//   // function to upload image to firebase storage

//   Future<void> _uploadProfileImage() async {
//     User? user = _auth.currentUser;
//     String? studentDocumentId = user?.uid;
//     setState(() {
//       _isLoading = true;
//     });
//     if (_profileImage != null) {
//       try {
//         final Reference storageRef = FirebaseStorage.instance
//             .ref()
//             .child('student_profile_images')
//             .child('$studentDocumentId.jpg');

//         await storageRef.putFile(_profileImage!);
//         profileImageUrl = await storageRef.getDownloadURL();
//         showSnackBar(context, "Profile picture updated successfully!");
//       } catch (e) {
//         showSnackBar(context, "Error uploading image: $e");
//       }
//     }
//     setState(() {
//       _isLoading = false;
//     });
//   }

//   // function to pick image from gallery or camera

//   Future<void> _pickProfileImage(ImageSource source) async {
//     final pickedFile = await ImagePicker().pickImage(source: source);

//     if (pickedFile != null) {
//       setState(() {
//         _profileImage = File(pickedFile.path);
//       });
//       await _uploadProfileImage();
//       _updateProfileData(); // Update Firestore with the new image URL
//     }
//   }

//   // function to fetch student data from firestore

//   Future<Map<String, dynamic>?> _fetchStudentData() async {
//     User? user = _auth.currentUser;
//     String? studentDocumentId = user?.uid;
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       final studentDoc = await FirebaseFirestore.instance
//           .collection('Students')
//           .doc(studentDocumentId)
//           .get();
//       if (studentDoc.exists) {
//         final studentData = studentDoc.data() as Map<String, dynamic>;
//         nameController.text = studentData['name'] ?? '';
//         enrollmentNoController.text = studentData['enrollment Number'] ?? '';
//         selectedValueDepartment = studentData['department'];
//         selectedValueYear = studentData['semester'];
//         selectedValueClub = studentData['club'];
//         profileImageUrl = studentData['profileImageUrl']; // Fetch profile image URL
//         return studentData;
//       } else {
//         showSnackBar(context, "Student data not found");
//         return null;
//       }
//     } catch (e) {
//       showSnackBar(context, "Error fetching data: $e");
//       return null;
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // function to update profile data on firebase firestore

//   Future<void> _updateProfileData() async {
//     User? user = _auth.currentUser;
//     String? studentDocumentId = user?.uid;
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       await FirebaseFirestore.instance
//           .collection('Students')
//           .doc(studentDocumentId)
//           .update({
//         'name': nameController.text,
//         'enrollmentNumber': enrollmentNoController.text,
//         'department': selectedValueDepartment,
//         'semester': selectedValueYear,
//         'club': selectedValueClub,
//         'profileImageUrl': profileImageUrl, // Save profile image URL
//       });
//       showSnackBar(context, "Profile updated successfully!");
//     } catch (e) {
//       showSnackBar(context, "Error updating profile: $e");
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _fetchStudentData();
//   }

//   @override
//   void dispose() {
//     nameController.dispose();
//     enrollmentNoController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: Pallet.headingColor,
//         title: const Text(
//           "My Profile",
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
//       body: _isLoading
//           ? const Center(
//               child: CircularProgressIndicator(
//                 color: Pallet.buttonColor,
//               ),
//             )
//           : SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         showModalBottomSheet(
//                           context: context,
//                           builder: (BuildContext context) {
//                             return SafeArea(
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: <Widget>[
//                                   ListTile(
//                                     leading: const Icon(Icons.camera_alt),
//                                     title: const Text('Take a picture'),
//                                     onTap: () {
//                                       Navigator.pop(context);
//                                       _pickProfileImage(ImageSource.camera);
//                                     },
//                                   ),
//                                   ListTile(
//                                     leading: const Icon(Icons.image),
//                                     title: const Text('Choose from gallery'),
//                                     onTap: () {
//                                       Navigator.pop(context);
//                                       _pickProfileImage(ImageSource.gallery);
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         );
//                       },
//                       child: CircleAvatar(
//                         radius: 80,
//                         backgroundColor: Pallet.headingColor,
//                         backgroundImage: profileImageUrl != null
//                             ? NetworkImage(profileImageUrl!) as ImageProvider<
//                                 ImageProvider<dynamic>> // Explicit cast here
//                             : _profileImage != null
//                                 ? FileImage(_profileImage!) as ImageProvider
//                                 : null,
//                         child: profileImageUrl == null && _profileImage == null
//                             ? const Icon(
//                                 Icons.person,
//                                 size: 80,
//                                 color: Colors.white,
//                               )
//                             : null,
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         "Name",
//                         textAlign: TextAlign.left,
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Pallet.headingColor,
//                         ),
//                       ),
//                     ),
//                     TextFieldArea(
//                       textFieldController: nameController,
//                     ),
//                     const SizedBox(height: 20),
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         "Enrollment Number",
//                         textAlign: TextAlign.left,
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Pallet.headingColor,
//                         ),
//                       ),
//                     ),
//                     TextFieldArea(
//                       textFieldController: enrollmentNoController,
//                     ),
//                     const SizedBox(height: 20),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 0.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           Text(
//                             "Department:",
//                             textAlign: TextAlign.left,
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: Pallet.headingColor,
//                             ),
//                           ),
//                           const SizedBox(
//                             width: 20.0,
//                           ),
//                           Expanded(
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 border: Border.all(
//                                   color: Pallet.headingColor,
//                                   width: 2,
//                                 ),
//                                 borderRadius:
//                                     const BorderRadius.all(Radius.circular(7)),
//                               ),
//                               child: DropdownButton<String>(
//                                 dropdownColor: const Color.fromARGB(
//                                     255, 211, 195, 132),
//                                 isExpanded: true,
//                                 hint: const Text(
//                                   "Select department",
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 value: selectedValueDepartment,
//                                 items: <String>[
//                                   'Computer Science & Engineering',
//                                   'Information Technology',
//                                   'Civil Engineering',
//                                   'Mechanical Engineering',
//                                   'Electrical Engineering',
//                                   'Electrical and Electronics Engineering',
//                                   'Artificial Intelligence & Data Science'
//                                 ].map<DropdownMenuItem<String>>((String value) {
//                                   return DropdownMenuItem<String>(
//                                       value: value, child: Text(value));
//                                 }).toList(),
//                                 onChanged: (String? newValue) {
//                                   setState(() {
//                                     selectedValueDepartment = newValue;
//                                   });
//                                 },
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 0.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           Text(
//                             "Semester:",
//                             textAlign: TextAlign.left,
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: Pallet.headingColor,
//                             ),
//                           ),
//                           const SizedBox(
//                             width: 20.0,
//                           ),
//                           Expanded(
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 border: Border.all(
//                                   color: Pallet.headingColor,
//                                   width: 2,
//                                 ),
//                                 borderRadius:
//                                     const BorderRadius.all(Radius.circular(7)),
//                               ),
//                               child: DropdownButton<int>(
//                                 dropdownColor: const Color.fromARGB(
//                                     255, 211, 195, 132),
//                                 isExpanded: true,
//                                 hint: const Text(
//                                   "Select Semester",
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 value: selectedValueYear,
//                                 items: <int>[1, 2, 3, 4, 5, 6, 7, 8]
//                                     .map<DropdownMenuItem<int>>((int value) {
//                                   return DropdownMenuItem<int>(
//                                       value: value,
//                                       child: Text(value.toString()));
//                                 }).toList(),
//                                 onChanged: (int? newValue) {
//                                   setState(() {
//                                     selectedValueYear = newValue;
//                                   });
//                                 },
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 0.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           Text(
//                             "Club:",
//                             textAlign: TextAlign.left,
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: Pallet.headingColor,
//                             ),
//                           ),
//                           const SizedBox(
//                             width: 20.0,
//                           ),
//                           Expanded(
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 border: Border.all(
//                                   color: Pallet.headingColor,
//                                   width: 2,
//                                 ),
//                                 borderRadius:
//                                     const BorderRadius.all(Radius.circular(7)),
//                               ),
//                               child: DropdownButton<String>(
//                                 dropdownColor: const Color.fromARGB(
//                                     255, 211, 195, 132),
//                                 isExpanded: true,
//                                 hint: const Text(
//                                   "Select club",
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 value: selectedValueClub,
//                                 items: <String>[
//                                   "None",
//                                   "Azure",
//                                   "AWS cloud foundation",
//                                   "Arduino",
//                                 ].map<DropdownMenuItem<String>>((String value) {
//                                   return DropdownMenuItem<String>(
//                                       value: value, child: Text(value));
//                                 }).toList(),
//                                 onChanged: (String? newValue) {
//                                   setState(() {
//                                     selectedValueClub = newValue;
//                                   });
//                                 },
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         ElevatedButton(
//                           onPressed: () {
//                             _updateProfileData();
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Pallet.buttonColor,
//                             minimumSize: const Size(150, 50),
//                           ),
//                           child: const Text(
//                             "Update",
//                             style: TextStyle(
//                               fontSize: 20,
//                               color: Pallet.textColor,
//                             ),
//                           ),
//                         ),
//                         ElevatedButton(
//                           onPressed: () {
//                             Navigator.of(context).pushReplacement(
//                               MaterialPageRoute(
//                                   builder: (context) => StudentHomeScreen()),
//                             );
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.grey,
//                             minimumSize: const Size(150, 50),
//                           ),
//                           child: const Text(
//                             "Cancel",
//                             style: TextStyle(
//                               fontSize: 20,
//                               color: Pallet.textColor,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 30),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }

import 'dart:io';

import 'package:academiax/constants/pallet.dart';
import 'package:academiax/firebase_authentication/show_snack_bar.dart';
import 'package:academiax/screens/student_home_screen.dart';
import 'package:academiax/wigets/textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class StudentProfile extends StatefulWidget {
  const StudentProfile({super.key});

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController enrollmentNoController = TextEditingController();
  final TextEditingController sectionController =
      TextEditingController(); // Added sectionController
  String? selectedValueDepartment;
  int? selectedValueYear;
  String? selectedValueClub;
  File? _profileImage;
  String? profileImageUrl;
  bool _isLoading = false;

  // function to upload image to firebase storage

  Future<void> _uploadProfileImage() async {
    User? user = _auth.currentUser;
    String? studentDocumentId = user?.uid;
    setState(() {
      _isLoading = true;
    });
    if (_profileImage != null) {
      try {
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('student_profile_images')
            .child('$studentDocumentId.jpg');

        await storageRef.putFile(_profileImage!);
        profileImageUrl = await storageRef.getDownloadURL();
        showSnackBar(context, "Profile picture updated successfully!");
      } catch (e) {
        showSnackBar(context, "Error uploading image: $e");
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  // function to pick image from gallery or camera

  Future<void> _pickProfileImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      await _uploadProfileImage();
      _updateProfileData(); // Update Firestore with the new image URL
    }
  }

  // function to fetch student data from firestore

  Future<Map<String, dynamic>?> _fetchStudentData() async {
    User? user = _auth.currentUser;
    String? studentDocumentId = user?.uid;
    setState(() {
      _isLoading = true;
    });
    try {
      final studentDoc = await FirebaseFirestore.instance
          .collection('Students')
          .doc(studentDocumentId)
          .get();
      if (studentDoc.exists) {
        final studentData = studentDoc.data() as Map<String, dynamic>;
        nameController.text = studentData['name'] ?? '';
        enrollmentNoController.text = studentData['enrollment Number'] ?? '';
        selectedValueDepartment = studentData['department'];
        selectedValueYear = studentData['semester'];
        selectedValueClub = studentData['club'];
        profileImageUrl =
            studentData['profileImageUrl']; // Fetch profile image URL
        sectionController.text = studentData['section'] ?? ''; // Fetch section
        return studentData;
      } else {
        showSnackBar(context, "Student data not found");
        return null;
      }
    } catch (e) {
      showSnackBar(context, "Error fetching data: $e");
      return null;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // function to update profile data on firebase firestore

  Future<void> _updateProfileData() async {
    User? user = _auth.currentUser;
    String? studentDocumentId = user?.uid;
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection('Students')
          .doc(studentDocumentId)
          .update({
        'name': nameController.text,
        'enrollment Number': enrollmentNoController.text,
        'department': selectedValueDepartment,
        'semester': selectedValueYear,
        'club': selectedValueClub,
        'profileImageUrl': profileImageUrl, // Save profile image URL
        'section': sectionController.text, // save section
      });
      showSnackBar(context, "Profile updated successfully!");
    } catch (e) {
      showSnackBar(context, "Error updating profile: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  @override
  void dispose() {
    nameController.dispose();
    enrollmentNoController.dispose();
    sectionController.dispose(); // Dispose sectionController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Pallet.headingColor,
        title: const Text(
          "My Profile",
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Pallet.buttonColor,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    leading: const Icon(Icons.camera_alt),
                                    title: const Text('Take a picture'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _pickProfileImage(ImageSource.camera);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.image),
                                    title: const Text('Choose from gallery'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _pickProfileImage(ImageSource.gallery);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: CircleAvatar(
                        radius: 80,
                        backgroundColor: Pallet.headingColor,
                        backgroundImage: profileImageUrl != null
                            ? NetworkImage(profileImageUrl!) as ImageProvider<
                                ImageProvider<dynamic>> // Explicit cast here
                            : _profileImage != null
                                ? FileImage(_profileImage!) as ImageProvider
                                : null,
                        child: profileImageUrl == null && _profileImage == null
                            ? const Icon(
                                Icons.person,
                                size: 80,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Name",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Pallet.headingColor,
                        ),
                      ),
                    ),
                    TextFieldArea(
                      textFieldController: nameController,
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Enrollment Number",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Pallet.headingColor,
                        ),
                      ),
                    ),
                    TextFieldArea(
                      textFieldController: enrollmentNoController,
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Section",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Pallet.headingColor,
                        ),
                      ),
                    ),
                    TextFieldArea(
                      textFieldController: sectionController,
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Department:",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Pallet.headingColor,
                            ),
                          ),
                          const SizedBox(
                            width: 20.0,
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Pallet.headingColor,
                                  width: 2,
                                ),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(7)),
                              ),
                              child: DropdownButton<String>(
                                dropdownColor:
                                    const Color.fromARGB(255, 211, 195, 132),
                                isExpanded: true,
                                hint: const Text(
                                  "Select department",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                value: selectedValueDepartment,
                                items: <String>[
                                  'Computer Science & Engineering',
                                  'Information Technology',
                                  'Civil Engineering',
                                  'Mechanical Engineering',
                                  'Electrical Engineering',
                                  'Electrical and Electronics Engineering',
                                  'Artificial Intelligence & Data Science'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                      value: value, child: Text(value));
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedValueDepartment = newValue;
                                  });
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Semester:",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Pallet.headingColor,
                            ),
                          ),
                          SizedBox(
                            width: 20.0,
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Pallet.headingColor,
                                  width: 2,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(7)),
                              ),
                              child: DropdownButton<int>(
                                  dropdownColor:
                                      const Color.fromARGB(255, 211, 195, 132),
                                  isExpanded: true,
                                  hint: const Text(
                                    "Select semester",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  value: selectedValueYear,
                                  items: <int>[1, 2, 3, 4, 5, 6, 7, 8]
                                      .map<DropdownMenuItem<int>>((int value) {
                                    return DropdownMenuItem<int>(
                                        value: value,
                                        child: Text(value.toString()));
                                  }).toList(),
                                  onChanged: (int? newValue) {
                                    setState(() {
                                      selectedValueYear = newValue;
                                    });
                                  }),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Club:",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Pallet.headingColor,
                            ),
                          ),
                          SizedBox(
                            width: 20.0,
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Pallet.headingColor,
                                  width: 2,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(7)),
                              ),
                              child: DropdownButton<String>(
                                  dropdownColor:
                                      const Color.fromARGB(255, 211, 195, 132),
                                  isExpanded: true,
                                  hint: const Text(
                                    "Select club",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  value: selectedValueClub,
                                  items: <String>[
                                    "None",
                                    "Azure",
                                    "AWS cloud foundation",
                                    "Arduino",
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                        value: value, child: Text(value));
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedValueClub = newValue;
                                    });
                                  }),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _updateProfileData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Pallet.buttonColor,
                        minimumSize: const Size(200, 50),
                      ),
                      child: Text(
                        "Update Profile",
                        style: TextStyle(
                          fontSize: 20,
                          color: Pallet.textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

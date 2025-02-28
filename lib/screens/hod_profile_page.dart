// import 'package:academiax/constants/pallet.dart';
// import 'package:academiax/firebase_authentication/show_snack_bar.dart';
// import 'package:academiax/wigets/textfield.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class HODProfilePage extends StatefulWidget {
//   const HODProfilePage({super.key});

//   @override
//   State<HODProfilePage> createState() => _HODProfilePageState();
// }

// class _HODProfilePageState extends State<HODProfilePage> {
//   String hodName = 'Loading Name...';
//   String facultyID = 'Loading Faculty ID...';
//   String department = 'Loading Department...';
//   String phoneNumber = 'Loading Phone...';
//   String? profileImageUrl;
//   bool isLoading = true;

//   // Controllers for text fields
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController facultyIDController = TextEditingController();
//   final TextEditingController phoneNumberController = TextEditingController();
//   String? selectedValueDepartment;

//   @override
//   void initState() {
//     super.initState();
//     _loadHODData();
//   }

//   Future<void> _loadHODData() async {
//     setState(() {
//       isLoading = true;
//     });
//     try {
//       User? user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         DocumentSnapshot hodDoc = await FirebaseFirestore.instance
//             .collection('Heads of Departments')
//             .doc(user.uid)
//             .get();

//         if (hodDoc.exists) {
//           setState(() {
//             hodName = hodDoc.get('name') ?? 'Name not found';
//             facultyID = hodDoc.get('faculty ID') ?? 'Faculty ID not found';
//             department = hodDoc.get('department') ?? 'Department not found';
//             phoneNumber = hodDoc.get('phone number') ?? 'Phone not found';
//             profileImageUrl = hodDoc.get('profileImageUrl');

//             // Initialize text field controllers with existing data
//             nameController.text = hodName;
//             facultyIDController.text = facultyID;
//             phoneNumberController.text = phoneNumber;
//             selectedValueDepartment = department;

//             isLoading = false;
//           });
//         } else {
//           setState(() {
//             hodName = 'Data not found';
//             facultyID = 'Data not found';
//             department = 'Data not found';
//             phoneNumber = 'Data not found';
//             isLoading = false;
//           });
//           print("HOD document not found in Firestore");
//         }
//       } else {
//         setState(() {
//           hodName = 'User not logged in';
//           facultyID = 'User not logged in';
//           department = 'User not logged in';
//           phoneNumber = 'User not logged in';
//           isLoading = false;
//         });
//         print("No user logged in.");
//       }
//     } catch (e) {
//       setState(() {
//         hodName = 'Error loading data';
//         facultyID = 'Error loading data';
//         department = 'Error loading data';
//         phoneNumber = 'Error loading data';
//         isLoading = false;
//       });
//       print("Error loading HOD data: $e");
//     }
//   }

//   Future<void> _updateProfile() async {
//     setState(() {
//       isLoading = true;
//     });
//     try {
//       User? user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         await FirebaseFirestore.instance
//             .collection('Heads of Departments')
//             .doc(user.uid)
//             .update({
//           'name': nameController.text,
//           'faculty ID': facultyIDController.text,
//           'department': selectedValueDepartment,
//           'phone number': phoneNumberController.text,
//         });
//         showSnackBar(context, "Profile updated successfully!");
//         _loadHODData(); // Refresh data to reflect updates
//       }
//     } catch (e) {
//       showSnackBar(context, "Failed to update profile: $e");
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     nameController.dispose();
//     facultyIDController.dispose();
//     phoneNumberController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: Pallet.backgroundColor,
//         title: const Text(
//           "HOD Profile",
//           style: TextStyle(
//             color: Pallet.headingColor,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 children: [
//                   CircleAvatar(
//                     radius: 70,
//                     backgroundColor: Pallet.headingColor,
//                     backgroundImage:
//                         profileImageUrl != null ? NetworkImage(profileImageUrl!) : null,
//                     child: profileImageUrl == null
//                         ? const Icon(
//                             Icons.person,
//                             size: 80,
//                             color: Pallet.backgroundColor,
//                           )
//                         : null,
//                   ),
//                   const SizedBox(height: 30),
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       "Name",
//                       textAlign: TextAlign.left,
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Pallet.headingColor,
//                       ),
//                     ),
//                   ),
//                   TextFieldArea(
//                     textFieldController: nameController,
//                   ),
//                   const SizedBox(height: 20),
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       "Faculty ID",
//                       textAlign: TextAlign.left,
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Pallet.headingColor,
//                       ),
//                     ),
//                   ),
//                   TextFieldArea(
//                     textFieldController: facultyIDController,
//                   ),
//                   const SizedBox(height: 20),
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       "Phone Number",
//                       textAlign: TextAlign.left,
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Pallet.headingColor,
//                       ),
//                     ),
//                   ),
//                   TextFieldArea(
//                     textFieldController: phoneNumberController,
//                   ),
//                   const SizedBox(height: 20),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 0.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Text(
//                           "Department:",
//                           textAlign: TextAlign.left,
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Pallet.headingColor,
//                           ),
//                         ),
//                         const SizedBox(
//                           width: 20.0,
//                         ),
//                         Expanded(
//                           child: Container(
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                 color: Pallet.headingColor,
//                                 width: 2,
//                               ),
//                               borderRadius:
//                                   const BorderRadius.all(Radius.circular(7)),
//                             ),
//                             child: DropdownButton<String>(
//                               dropdownColor:
//                                   const Color.fromARGB(255, 211, 195, 132),
//                               isExpanded: true,
//                               hint: Text(
//                                 "Select your department",
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               value: selectedValueDepartment,
//                               items: <String>[
//                                 'Computer Science & Engineering',
//                                 'Information Technology',
//                                 'Civil Engineering',
//                                 'Mechanical Engineering',
//                                 'Electrical Engineering',
//                                 'Electrical and Electronics Engineering',
//                                 'Artificial Intelligence & Data Science'
//                               ].map<DropdownMenuItem<String>>((String value) {
//                                 return DropdownMenuItem<String>(
//                                     value: value, child: Text(value));
//                               }).toList(),
//                               onChanged: (String? newValue) {
//                                 setState(() {
//                                   selectedValueDepartment = newValue;
//                                 });
//                               },
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   ElevatedButton(
//                     onPressed: _updateProfile,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Pallet.buttonColor,
//                       minimumSize: const Size(200, 50),
//                     ),
//                     child: const Text(
//                       "Update Profile",
//                       style: TextStyle(
//                         fontSize: 20,
//                         color: Pallet.textColor,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }

import 'dart:io';

import 'package:academiax/constants/pallet.dart';
import 'package:academiax/firebase_authentication/firebase_auth.dart';
import 'package:academiax/firebase_authentication/show_snack_bar.dart';
import 'package:academiax/screens/hod_home_screen.dart'; // Assuming you have a HOD home screen
import 'package:academiax/wigets/textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HODProfile extends StatefulWidget {
  const HODProfile({super.key});

  @override
  State<HODProfile> createState() => _HODProfileState();
}

class _HODProfileState extends State<HODProfile> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController facultyIDController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  String? selectedValueDepartment;
  File? _profileImage;
  String? profileImageUrl;
  bool _isLoading = false;

  // function to upload image to firebase storage

  Future<void> _uploadProfileImage() async {
    User? user = _auth.currentUser;
    String? hodDocumentId = user?.uid;
    setState(() {
      _isLoading = true;
    });
    if (_profileImage != null) {
      try {
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('hod_profile_images')
            .child('$hodDocumentId.jpg');

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

  // function to fetch hod data from firestore

  Future<Map<String, dynamic>?> _fetchHODData() async {
    User? user = _auth.currentUser;
    String? hodDocumentId = user?.uid;
    setState(() {
      _isLoading = true;
    });
    try {
      final hodDoc = await FirebaseFirestore.instance
          .collection('Heads of Departments')
          .doc(hodDocumentId)
          .get();
      if (hodDoc.exists) {
        final hodData = hodDoc.data() as Map<String, dynamic>;
        nameController.text = hodData['name'] ?? '';
        facultyIDController.text = hodData['faculty ID'] ?? '';
        selectedValueDepartment = hodData['department'];
        phoneNumberController.text = hodData['phone number'] ?? '';
        profileImageUrl = hodData['profileImageUrl']; // Fetch profile image URL
        return hodData;
      } else {
        showSnackBar(context, "HOD data not found");
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
    String? hodDocumentId = user?.uid;
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection('Heads of Departments')
          .doc(hodDocumentId)
          .update({
        'name': nameController.text,
        'faculty ID': facultyIDController.text,
        'department': selectedValueDepartment,
        'phone number': phoneNumberController.text,
        'profileImageUrl': profileImageUrl, // Save profile image URL
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
    _fetchHODData();
  }

  @override
  void dispose() {
    nameController.dispose();
    facultyIDController.dispose();
    phoneNumberController.dispose();
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
              MaterialPageRoute(builder: (context) => HodHomeScreen()), // Navigate to HOD home screen
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
                        "Faculty ID",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Pallet.headingColor,
                        ),
                      ),
                    ),
                    TextFieldArea(
                      textFieldController: facultyIDController,
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Phone Number",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Pallet.headingColor,
                        ),
                      ),
                    ),
                    TextFieldArea(
                      textFieldController: phoneNumberController,
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
                                dropdownColor: const Color.fromARGB(
                                    255, 211, 195, 132),
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
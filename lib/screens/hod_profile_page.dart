import 'dart:io';

import 'package:academiax/constants/pallet.dart';
import 'package:academiax/firebase_authentication/show_snack_bar.dart';
import 'package:academiax/screens/hod_home_screen.dart';
import 'package:academiax/wigets/textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

class HODProfile extends StatefulWidget {
  const HODProfile({super.key});

  @override
  State<HODProfile> createState() => _HODProfileState();
}

class _HODProfileState extends State<HODProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController facultyIDController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  String? selectedValueDepartment;
  File? _profileImage;
  String? profileImageUrl;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>(); // Global key for form validation

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
    if (_formKey.currentState!.validate()) {
      // Validate form here
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
              MaterialPageRoute(
                  builder: (context) =>
                      HodHomeScreen()), // Navigate to HOD home screen
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
                child: Form(
                  // Wrap Column with Form
                  key: _formKey, // Assign the form key
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
                              ? NetworkImage(profileImageUrl!)
                              : _profileImage != null
                                  ? FileImage(_profileImage!) as ImageProvider
                                  : null,
                          child:
                              profileImageUrl == null && _profileImage == null
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          if (value.length < 3) {
                            return 'Name should be at least 3 characters';
                          }
                          if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                            return 'Name should not contain numerals or special characters';
                          }
                          return null;
                        },
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Faculty ID';
                          }
                          if (!RegExp(r'^[A-Z0-9]+$').hasMatch(value)) {
                            return 'Faculty ID should contain only capital letters and digits';
                          }
                          return null;
                        },
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (value.length != 10) {
                            return 'Enter a 10-digit phone number';
                          }
                          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return 'Enter digits only';
                          }
                          return null;
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
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
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(7)),
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
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
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
            ),
    );
  }
}

import 'package:academiax/constants/pallet.dart';
import 'package:academiax/firebase_authentication/firebase_auth.dart';
import 'package:academiax/firebase_authentication/show_snack_bar.dart';
import 'package:academiax/screens/loginpage.dart';
import 'package:academiax/wigets/textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for TextInputFormatters
import 'package:intl/intl.dart';

class StudentCreateAccount extends StatefulWidget {
  const StudentCreateAccount({super.key});

  @override
  State<StudentCreateAccount> createState() => _StudentCreateAccountState();
}

class _StudentCreateAccountState extends State<StudentCreateAccount> {
  // for instantiating our FirebaseAuthMethods() created in firebase_auth.dart
  final _auth = FirebaseAuthMethods();
  final _formKey = GlobalKey<FormState>(); // Form key for validation

  // variables holding values of our dropdown menus of department and club section.
  String? selectedValueDepartment;
  String? selectedValueClub;
  int? selectedValueYear;
  DateTime? _selectedDate;

  // controllers for manipulating/holding data for custom TextFieldArea() created in textfield.dart
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailIDController = TextEditingController();
  final TextEditingController phonenumberController = TextEditingController();
  final TextEditingController enrollmentNoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController sectionController = TextEditingController();
  bool _obscureText = true; // For password visibility

  // firestore collection
  CollectionReference students =
      FirebaseFirestore.instance.collection('Students');

  // function to check if email already exists on the database
  Future<bool> emailAlreadyExists(String email) async {
    final db = FirebaseFirestore.instance;
    final QuerySnapshot = await db
        .collection("Students")
        .where("email ID", isEqualTo: emailIDController.text)
        .limit(1)
        .get();

    return QuerySnapshot.docs.isNotEmpty;
  }

  // function created to store student's create account data in firestore database
  void userFireStoredb() async {
    if (_formKey.currentState!.validate()) {
      if (await emailAlreadyExists(emailIDController.text) == false) {
        try {
          await _auth.signupWithEmailandPasswordStudent(
            email: emailIDController.text,
            password: passwordController.text,
            context: context,
            club: selectedValueClub,
            semester: selectedValueYear,
            department: selectedValueDepartment,
            dob: _selectedDate,
            enrollmentNumber: enrollmentNoController.text,
            name: nameController.text,
            phoneNumber: phonenumberController.text,
            section: sectionController.text,
          );
          showSnackBar(context,
              " Student Registration successful! Email verification sent.");
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => Loginpage()));
        } on FirebaseException catch (e) {
          showSnackBar(context, e.message!);
        } catch (error) {
          showSnackBar(context, "Failed to create an account: $error");
        }
      } else {
        showSnackBar(context, "Email already exists :(");
      }
    }
  }

  // to dispose off texteditingcontrollers after their work is done.
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
    emailIDController.dispose();
    phonenumberController.dispose();
    enrollmentNoController.dispose();
    passwordController.dispose();
    sectionController.dispose();
  }

  // the following function will be called when clicked on
  // the 'Create Account' button.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Pallet.backgroundColor,
        title: const Text(
          "AcademiaX",
          style: TextStyle(
            color: Pallet.headingColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  "Enter your details",
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    wordSpacing: -2,
                    color: Pallet.headingColor,
                  ),
                ),
                // details blocks such as email, name, password, etc.

                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      "Name",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Pallet.headingColor,
                      ),
                    ),
                  ),
                ),
                TextFieldArea(
                  textFieldController: nameController,
                  hintText: "Enter your name",
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
                const SizedBox(
                  height: 20,
                ),
                // enrollment no

                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      "Enrollment Number",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Pallet.headingColor,
                      ),
                    ),
                  ),
                ),
                TextFieldArea(
                  textFieldController: enrollmentNoController,
                  hintText: "Enter your Enrollment Number",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your enrollment number';
                    }
                    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(value)) {
                      return 'Enrollment Number should contain only capital letters and digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                // email id

                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      "Email ID",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Pallet.headingColor,
                      ),
                    ),
                  ),
                ),
                TextFieldArea(
                  textFieldController: emailIDController,
                  hintText: "Enter your Email ID",
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                // phone no

                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      "Phone Number",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Pallet.headingColor,
                      ),
                    ),
                  ),
                ),
                TextFieldArea(
                  textFieldController: phonenumberController,
                  hintText: "Enter your Phone Number",
                  keyboardType: TextInputType.phone,
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
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(
                  height: 20,
                ),
                // Department

                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "Department:",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 25,
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
                            borderRadius: BorderRadius.all(Radius.circular(7)),
                          ),
                          child: DropdownButtonFormField<String>(
                            dropdownColor:
                                const Color.fromARGB(255, 211, 195, 132),
                            isExpanded: true,
                            hint: Text(
                              "Select your department",
                              style: TextStyle(
                                fontSize: 20,
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your department';
                              }
                              return null;
                            },
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
                const SizedBox(
                  height: 20,
                ),

                // Date of birth

                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      "Date of Birth:",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Pallet.headingColor,
                      ),
                    ),
                  ),
                ),
                Text(
                  _selectedDate == null
                      ? 'No date selected'
                      : 'Selected Date: ${DateFormat('dd-MM-yyyy').format(_selectedDate!)}', // Format the date
                  style: const TextStyle(fontSize: 20),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Pallet.buttonColor,
                    minimumSize: const Size(120, 40),
                  ),
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ??
                          DateTime
                              .now(), // Start with current date or selected date
                      firstDate: DateTime(1937), // Earliest allowable date
                      lastDate: DateTime(2101), // Latest allowable date
                    );
                    if (picked != null && picked != _selectedDate) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  child: const Text(
                    'Select Date',
                    style: TextStyle(
                      fontSize: 18,
                      color: Pallet.textColor,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                // current year

                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "Semester:",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 25,
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
                            borderRadius: BorderRadius.all(Radius.circular(7)),
                          ),
                          child: DropdownButtonFormField<int>(
                            dropdownColor:
                                const Color.fromARGB(255, 211, 195, 132),
                            isExpanded: true,
                            hint: const Text(
                              "Select your semester",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            value: selectedValueYear,
                            items: <int>[1, 2, 3, 4, 5, 6, 7, 8]
                                .map<DropdownMenuItem<int>>((int value) {
                              return DropdownMenuItem<int>(
                                  value: value, child: Text(value.toString()));
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Please select your semester';
                              }
                              return null;
                            },
                            onChanged: (int? newValue) {
                              setState(() {
                                selectedValueYear = newValue;
                              });
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      "Section",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Pallet.headingColor,
                      ),
                    ),
                  ),
                ),
                TextFieldArea(
                  hintText: "Use capital letter",
                  textFieldController: sectionController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your section';
                    }
                    if (value.length != 1) {
                      return 'Section should be a single capital letter';
                    }
                    if (!RegExp(r'^[A-Z]+$').hasMatch(value)) {
                      return 'Section should be a capital letter';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                // club

                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "Club:",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 25,
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
                            borderRadius: BorderRadius.all(Radius.circular(7)),
                          ),
                          child: DropdownButtonFormField<String>(
                            dropdownColor:
                                const Color.fromARGB(255, 211, 195, 132),
                            isExpanded: true,
                            hint: const Text(
                              "Select your club",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            value: selectedValueClub,
                            items: <String>[
                              "None",
                              "Azure",
                              "AWS cloud foundation",
                              "Arduino",
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                  value: value, child: Text(value));
                            }).toList(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your club';
                              }
                              return null;
                            },
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedValueClub = newValue;
                              });
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                // Password
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      "Password",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Pallet.headingColor,
                      ),
                    ),
                  ),
                ),
                TextFieldArea(
                  textFieldController: passwordController,
                  hintText: "Enter your Password",
                  obscureText: _obscureText, // Use obscureText and toggle
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscureText =
                              !_obscureText; // Toggle password visibility
                        });
                      },
                      child: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Pallet.headingColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: userFireStoredb,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Pallet.buttonColor,
                    minimumSize: const Size(200, 60),
                  ),
                  child: const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 25,
                      color: Pallet.textColor,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

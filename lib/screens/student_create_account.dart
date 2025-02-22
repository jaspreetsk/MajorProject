import 'package:academiax/constants/pallet.dart';
import 'package:academiax/firebase_authentication/firebase_auth.dart';
import 'package:academiax/firebase_authentication/show_snack_bar.dart';
import 'package:academiax/screens/loginpage.dart';
import 'package:academiax/wigets/textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentCreateAccount extends StatefulWidget {
  const StudentCreateAccount({super.key});

  @override
  State<StudentCreateAccount> createState() => _StudentCreateAccountState();
}

class _StudentCreateAccountState extends State<StudentCreateAccount> {
// for instantiating our FirebaseAuthMethods() created in firebase_auth.dart

  final _auth = FirebaseAuthMethods();

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
        );
        showSnackBar(context,
            " Student Registration successful! Email verification sent.");
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Loginpage()));
      } on FirebaseException catch (e) {
        showSnackBar(context, e.message!);
      } catch (error) {
        showSnackBar(context, "Failed to create an account: $error");
        print("Error during account creation: $error");
      }
    } else {
      showSnackBar(context, "Email already exists :(");
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
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                        ),
                        child: DropdownButton(
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
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedValueDepartment = newValue;
                              });
                            }),
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
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                        ),
                        child: DropdownButton(
                            dropdownColor:
                                const Color.fromARGB(255, 211, 195, 132),
                            isExpanded: true,
                            hint: Text(
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
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                        ),
                        child: DropdownButton(
                            dropdownColor:
                                const Color.fromARGB(255, 211, 195, 132),
                            isExpanded: true,
                            hint: Text(
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
                child: Text(
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
    );
  }
}

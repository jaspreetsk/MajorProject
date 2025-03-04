// import 'package:academiax/constants/pallet.dart';
// import 'package:academiax/firebase_authentication/firebase_auth.dart';
// import 'package:academiax/firebase_authentication/show_snack_bar.dart';
// import 'package:academiax/screens/loginpage.dart';
// import 'package:academiax/wigets/textfield.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:flutter/material.dart';

// class HODCreateAccount extends StatefulWidget {
//   const HODCreateAccount({super.key});

//   @override
//   State<HODCreateAccount> createState() => _HODCreateAccountState();
// }

// class _HODCreateAccountState extends State<HODCreateAccount> {
//   // for instantiating our FirebaseAuthMethods() created in firebase_auth.dart

//   final _auth = FirebaseAuthMethods();

// // variables holding values of our dropdown menus of department

//   String? selectedValueDepartment;

//   // firestore collection

//   CollectionReference hods =
//       FirebaseFirestore.instance.collection('Heads of Departments');

// // function to check if email already exists on the database

//   Future<bool> emailAlreadyExists(String email) async {
//     final db = FirebaseFirestore.instance;
//     final QuerySnapshot = await db
//         .collection("Heads of Departments")
//         .where("email ID", isEqualTo: emailIDController.text)
//         .limit(1)
//         .get();

//     return QuerySnapshot.docs.isNotEmpty;
//   }

//   // function created to store hod's create account data in firestore database

//   void userFireStoredb() async {
//     if (await emailAlreadyExists(emailIDController.text) == false) {
//       try {
//         await _auth.signupWithEmailandPasswordHod(
//           email: emailIDController.text,
//           password: passwordController.text,
//           context: context,
//           department: selectedValueDepartment,
//           facultyID: facultyIDController.text,
//           name: nameController.text,
//           phoneNumber: phonenumberController.text,
//         );
//         showSnackBar(
//             context, " HOD Registration successful! Email verification sent.");
//         Navigator.of(context).pushReplacement(
//             MaterialPageRoute(builder: (context) => Loginpage()));
//       } on FirebaseException catch (e) {
//         showSnackBar(context, e.message!);
//       } catch (error) {
//         showSnackBar(context, "Failed to create an account: $error");
//         print("Error during account creation: $error");
//       }
//     } else {
//       showSnackBar(context, "Email already exists :(");
//     }
//   }

// // controllers for manipulating/holding data for custom TextFieldArea() created in textfield.dart

//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailIDController = TextEditingController();
//   final TextEditingController phonenumberController = TextEditingController();
//   final TextEditingController facultyIDController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

// // to dispose off texteditingcontrollers after their work is done.

//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//     nameController.dispose();
//     emailIDController.dispose();
//     phonenumberController.dispose();
//     facultyIDController.dispose();
//     passwordController.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: Pallet.backgroundColor,
//         title: const Text(
//           "AcademiaX",
//           style: TextStyle(
//             color: Pallet.headingColor,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Text(
//                 "Enter your details",
//                 style: TextStyle(
//                   fontSize: 50,
//                   fontWeight: FontWeight.bold,
//                   wordSpacing: -2,
//                   color: Pallet.headingColor,
//                 ),
//               ),
//               // details blocks such as email, name, password, etc.

//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Padding(
//                   padding: const EdgeInsets.only(left: 20.0),
//                   child: Text(
//                     "Name",
//                     textAlign: TextAlign.left,
//                     style: TextStyle(
//                       fontSize: 25,
//                       fontWeight: FontWeight.bold,
//                       color: Pallet.headingColor,
//                     ),
//                   ),
//                 ),
//               ),
//               TextFieldArea(
//                 textFieldController: nameController,
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               // enrollment no

//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Padding(
//                   padding: const EdgeInsets.only(left: 20.0),
//                   child: Text(
//                     "Faculty ID",
//                     textAlign: TextAlign.left,
//                     style: TextStyle(
//                       fontSize: 25,
//                       fontWeight: FontWeight.bold,
//                       color: Pallet.headingColor,
//                     ),
//                   ),
//                 ),
//               ),
//               TextFieldArea(
//                 textFieldController: facultyIDController,
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               // email id

//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Padding(
//                   padding: const EdgeInsets.only(left: 20.0),
//                   child: Text(
//                     "Email ID",
//                     textAlign: TextAlign.left,
//                     style: TextStyle(
//                       fontSize: 25,
//                       fontWeight: FontWeight.bold,
//                       color: Pallet.headingColor,
//                     ),
//                   ),
//                 ),
//               ),
//               TextFieldArea(
//                 textFieldController: emailIDController,
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               // phone no

//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Padding(
//                   padding: const EdgeInsets.only(left: 20.0),
//                   child: Text(
//                     "Phone Number",
//                     textAlign: TextAlign.left,
//                     style: TextStyle(
//                       fontSize: 25,
//                       fontWeight: FontWeight.bold,
//                       color: Pallet.headingColor,
//                     ),
//                   ),
//                 ),
//               ),
//               TextFieldArea(
//                 textFieldController: phonenumberController,
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               // Department

//               Padding(
//                 padding: const EdgeInsets.only(left: 20.0, right: 20.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     Text(
//                       "Department:",
//                       textAlign: TextAlign.left,
//                       style: TextStyle(
//                         fontSize: 25,
//                         fontWeight: FontWeight.bold,
//                         color: Pallet.headingColor,
//                       ),
//                     ),
//                     SizedBox(
//                       width: 20.0,
//                     ),
//                     Expanded(
//                       child: Container(
//                         decoration: BoxDecoration(
//                           border: Border.all(
//                             color: Pallet.headingColor,
//                             width: 2,
//                           ),
//                           borderRadius: BorderRadius.all(Radius.circular(7)),
//                         ),
//                         child: DropdownButton(
//                             dropdownColor:
//                                 const Color.fromARGB(255, 211, 195, 132),
//                             isExpanded: true,
//                             hint: Text(
//                               "Select your department",
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             value: selectedValueDepartment,
//                             items: <String>[
//                               'Computer Science & Engineering',
//                               'Information Technology',
//                               'Civil Engineering',
//                               'Mechanical Engineering',
//                               'Electrical Engineering',
//                               'Electrical and Electronics Engineering',
//                               'Artificial Intelligence & Data Science'
//                             ].map<DropdownMenuItem<String>>((String value) {
//                               return DropdownMenuItem<String>(
//                                   value: value, child: Text(value));
//                             }).toList(),
//                             onChanged: (String? newValue) {
//                               setState(() {
//                                 selectedValueDepartment = newValue;
//                               });
//                             }),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               // Password
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Padding(
//                   padding: const EdgeInsets.only(left: 20.0),
//                   child: Text(
//                     "Password",
//                     textAlign: TextAlign.left,
//                     style: TextStyle(
//                       fontSize: 25,
//                       fontWeight: FontWeight.bold,
//                       color: Pallet.headingColor,
//                     ),
//                   ),
//                 ),
//               ),
//               TextFieldArea(
//                 textFieldController: passwordController,
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               ElevatedButton(
//                 onPressed: userFireStoredb,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Pallet.buttonColor,
//                   minimumSize: const Size(200, 60),
//                 ),
//                 child: Text(
//                   "Create Account",
//                   style: TextStyle(
//                     fontSize: 25,
//                     color: Pallet.textColor,
//                   ),
//                 ),
//               ),
//               const SizedBox(
//                 height: 50,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:academiax/constants/pallet.dart';
import 'package:academiax/firebase_authentication/firebase_auth.dart';
import 'package:academiax/firebase_authentication/show_snack_bar.dart';
import 'package:academiax/screens/loginpage.dart';
import 'package:academiax/wigets/textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for TextInputFormatters

class HODCreateAccount extends StatefulWidget {
  const HODCreateAccount({super.key});

  @override
  State<HODCreateAccount> createState() => _HODCreateAccountState();
}

class _HODCreateAccountState extends State<HODCreateAccount> {
  final _auth = FirebaseAuthMethods();
  String? selectedValueDepartment;
  CollectionReference hods =
      FirebaseFirestore.instance.collection('Heads of Departments');

  final _formKey = GlobalKey<FormState>(); // Form key for validation

  Future<bool> emailAlreadyExists(String email) async {
    final db = FirebaseFirestore.instance;
    final QuerySnapshot = await db
        .collection("Heads of Departments")
        .where("email ID", isEqualTo: emailIDController.text)
        .limit(1)
        .get();

    return QuerySnapshot.docs.isNotEmpty;
  }

  void userFireStoredb() async {
    if (_formKey.currentState!.validate()) {
      if (await emailAlreadyExists(emailIDController.text) == false) {
        try {
          await _auth.signupWithEmailandPasswordHod(
            email: emailIDController.text,
            password: passwordController.text,
            context: context,
            department: selectedValueDepartment,
            facultyID: facultyIDController.text,
            name: nameController.text,
            phoneNumber: phonenumberController.text,
          );
          showSnackBar(
              context, " HOD Registration successful! Email verification sent.");
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
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailIDController = TextEditingController();
  final TextEditingController phonenumberController = TextEditingController();
  final TextEditingController facultyIDController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscureText = true; // For password visibility

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailIDController.dispose();
    phonenumberController.dispose();
    facultyIDController.dispose();
    passwordController.dispose();
  }

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
                // Name Field
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
                const SizedBox(height: 20),

                // Faculty ID Field
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      "Faculty ID",
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
                  textFieldController: facultyIDController,
                  hintText: "Enter your Faculty ID",
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

                // Email ID Field
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
                    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Phone Number Field
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
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Allow only digits
                ),
                const SizedBox(height: 20),

                // Department Dropdown
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
                      const SizedBox(width: 20.0),
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
                              "Select department",
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
                const SizedBox(height: 20),

                // Password Field
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
                          _obscureText = !_obscureText; // Toggle password visibility
                        });
                      },
                      child: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Pallet.headingColor,
                      ),
                    ),
                  ),
                ),


                const SizedBox(height: 15),
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
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
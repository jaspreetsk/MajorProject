import 'package:academiax/constants/pallet.dart';
import 'package:academiax/screens/loginpage.dart';
import 'package:academiax/wigets/textfield.dart';
import 'package:flutter/material.dart';

class HODCreateAccount extends StatefulWidget {
  const HODCreateAccount({super.key});

  @override
  State<HODCreateAccount> createState() => _HODCreateAccountState();
}

class _HODCreateAccountState extends State<HODCreateAccount> {
  String? selectedValueDepartment;
  String? selectedValueClub;
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
              TextFieldArea(),
              const SizedBox(
                height: 20,
              ),
              // enrollment no

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
              TextFieldArea(),
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
              TextFieldArea(),
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
              TextFieldArea(),
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
              TextFieldArea(),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Loginpage()));
                },
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

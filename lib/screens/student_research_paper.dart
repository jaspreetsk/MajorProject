import 'package:academiax/constants/pallet.dart';
import 'package:academiax/screens/student_home_screen.dart';
import 'package:flutter/material.dart';

class StudentResearchPaper extends StatefulWidget {
  const StudentResearchPaper({super.key});

  @override
  State<StudentResearchPaper> createState() => _StudentResearchPaperState();
}

class _StudentResearchPaperState extends State<StudentResearchPaper> {
  String? _selectedOption;
  TextEditingController _headingController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _linkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Pallet.headingColor,
        title: const Text(
          "Research Work",
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
          _showUploadDialog(context);
        },
        child: const Icon(
          Icons.upload_file,
          color: Colors.white,
          size: 35,
        ),
      ),
    );
  }

  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Upload Research Paper'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'Select Option'),
                      value: _selectedOption,
                      items: const [
                        DropdownMenuItem(
                          value: "current",
                          child: Text("Add current working research work"),
                        ),
                        DropdownMenuItem(
                          value: "past",
                          child: Text("Add past published research papers"),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedOption = newValue;
                        });
                      },
                    ),
                    if (_selectedOption == "current")
                      Column(
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            controller: _headingController,
                            decoration: const InputDecoration(
                              labelText: 'Heading',
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            controller: _descriptionController,
                            decoration:
                                const InputDecoration(labelText: 'Description'),
                            maxLines: 3,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // TODO: Implement document upload for current work
                            },
                            child: const Text(
                              'Upload Supporting Documents',
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(50, 40),
                            ),
                          ),
                        ],
                      ),
                    if (_selectedOption == "past")
                      Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: _headingController,
                            decoration:
                                const InputDecoration(labelText: 'Heading'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: _linkController,
                            decoration: const InputDecoration(
                                labelText: 'Link of Published Research Paper'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // TODO: Implement research paper upload for past work
                            },
                            child: const Text('Upload Research Paper'),
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
                    _selectedOption =
                        null; // Reset selected option when dialog is closed
                    _headingController.clear();
                    _descriptionController.clear();
                    _linkController.clear();
                  },
                ),
                TextButton(
                  child: const Text('Submit'),
                  onPressed: () {
                    // TODO: Implement submit logic based on selected option and fields
                    if (_selectedOption == "current") {
                      String heading = _headingController.text;
                      String description = _descriptionController.text;
                      // Handle current research work submission
                      print("Current Research Work Submitted:");
                      print("Heading: $heading");
                      print("Description: $description");
                    } else if (_selectedOption == "past") {
                      String heading = _headingController.text;
                      String link = _linkController.text;
                      // Handle past research paper submission
                      print("Past Research Paper Submitted:");
                      print("Heading: $heading");
                      print("Link: $link");
                    }
                    Navigator.of(dialogContext).pop();
                    _selectedOption =
                        null; // Reset selected option after submission
                    _headingController.clear();
                    _descriptionController.clear();
                    _linkController.clear();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

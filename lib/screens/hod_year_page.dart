// hod_year_page.dart
import 'package:academiax/constants/pallet.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HodYearPage extends StatefulWidget {
  final String year;

  const HodYearPage({Key? key, required this.year}) : super(key: key);

  @override
  State<HodYearPage> createState() => _HodYearPageState();
}

class _HodYearPageState extends State<HodYearPage> {
  List<String> sectionNames = [];
  bool isLoadingSections = true;

  @override
  void initState() {
    super.initState();
    _loadSectionData();
  }

  Future<void> _loadSectionData() async {
    setState(() {
      isLoadingSections = true;
      sectionNames = [];
    });
    try {
      QuerySnapshot studentSnapshot;
      if (widget.year == "Year I") {
        studentSnapshot = await FirebaseFirestore.instance
            .collection('Students')
            .where('semester', whereIn: [1, 2]).get();
      } else if (widget.year == "Year II") {
        studentSnapshot = await FirebaseFirestore.instance
            .collection('Students')
            .where('semester', whereIn: [3, 4]).get();
      } else if (widget.year == "Year III") {
        studentSnapshot = await FirebaseFirestore.instance
            .collection('Students')
            .where('semester', whereIn: [5, 6]).get();
      } else if (widget.year == "Year IV") {
        studentSnapshot = await FirebaseFirestore.instance
            .collection('Students')
            .where('semester', whereIn: [7, 8]).get();
      } else {
        studentSnapshot = await FirebaseFirestore
            .instance // Just perform an empty query to get a valid QuerySnapshot
            .collection('Students')
            .limit(
                0) // Limit to 0 to get no documents, but still a valid snapshot
            .get();
      }

      Set<String> sections = {};
      if (studentSnapshot.docs.isNotEmpty) {
        // Check if there are any documents
        for (var doc in studentSnapshot.docs) {
          String? section = doc.get('section');
          if (section != null && section.isNotEmpty) {
            sections.add(section);
          } else {
            sections.add('Section A'); // Default section if not provided
          }
        }
      }

      setState(() {
        sectionNames = sections.toList();
        isLoadingSections = false;
      });
    } catch (e) {
      print("Error loading section data: $e");
      setState(() {
        isLoadingSections = false;
        sectionNames = ['Section A', 'Section B']; // Default sections on error
      });
    }
  }

  Widget _buildSectionButton(String sectionName) {
    return Container(
      width: 120,
      height: 120,
      margin: const EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () {
          // TODO: Navigate to the respective section's screen (if needed)
          print("Navigating to $sectionName screen for ${widget.year}");
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Pallet.buttonColor,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(15),
        ),
        child: Text(
          sectionName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            color: Pallet.textColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Pallet.backgroundColor,
        title: Text(
          widget.year,
          style: const TextStyle(
            color: Pallet.headingColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Pallet.headingColor),
      ),
      body: Center(
        child: isLoadingSections
            ? const CircularProgressIndicator(color: Pallet.headingColor)
            : sectionNames.isEmpty
                ? Text("No Sections available for ${widget.year}",
                    style: const TextStyle(
                        fontSize: 20, color: Pallet.headingColor))
                : Column(
                    children: [
                      const SizedBox(height: 50),
                      Text(
                        'Sections for ${widget.year}',
                        style: const TextStyle(
                          fontSize: 30,
                          color: Pallet.headingColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 50),
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: sectionNames
                            .map((section) => _buildSectionButton(section))
                            .toList(),
                      ),
                    ],
                  ),
      ),
    );
  }
}

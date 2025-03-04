import 'package:academiax/constants/pallet.dart';
import 'package:academiax/firebase_authentication/firebase_auth.dart';
import 'package:academiax/screens/hod_profile_page.dart';
import 'package:academiax/screens/hod_year_page.dart';
import 'package:academiax/screens/loginpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HodHomeScreen extends StatefulWidget {
  const HodHomeScreen({super.key});

  @override
  State<HodHomeScreen> createState() => _HodHomeScreenState();
}

class _HodHomeScreenState extends State<HodHomeScreen> {
  String hODName = 'Loading Name...';
  String departmentName = 'Loading Department...';
  String? profileImageUrl;
  bool isLoading = true;
  bool hasYear1Students = false;
  bool hasYear2Students = false;
  bool hasYear3Students = false;
  bool hasYear4Students = false;

  @override
  void initState() {
    super.initState();
    _loadHODData();
  }

  Future<void> _loadHODData() async {
    setState(() {
      isLoading = true;
    });
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot hodDoc = await FirebaseFirestore.instance
            .collection('Heads of Departments')
            .doc(user.uid)
            .get();

        if (hodDoc.exists) {
          setState(() {
            hODName = hodDoc.get('name') ?? 'Name not found';
            departmentName = hodDoc.get('department') ?? 'department not found';
            profileImageUrl = hodDoc.get('profileImageUrl');
            isLoading = false;
          });
        } else {
          setState(() {
            hODName = 'Data not found';
            departmentName = 'Data not found';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          hODName = 'User not logged in';
          departmentName = 'User not logged in';
          isLoading = false;
        });
      }
      await _checkStudentYears(); // Check for students in each year after loading HOD data
    } catch (e) {
      setState(() {
        hODName = 'Error loading data';
        departmentName = 'Error loading data';
        isLoading = false;
      });
    }
  }

  Future<void> _checkStudentYears() async {
    try {
      // Department name is already loaded into departmentName variable
      String hodDepartment = departmentName;

      // Check for Year I students (Semesters 1 & 2) in the HOD's department
      QuerySnapshot year1Snapshot = await FirebaseFirestore.instance
          .collection('Students')
          .where('department', isEqualTo: hodDepartment) // Filter by department
          .where('semester', whereIn: [1, 2]).get();
      // ADD THIS LINE
      setState(() {
        hasYear1Students = year1Snapshot.docs.isNotEmpty;
      });

      // Check for Year II students (Semesters 3 & 4) in the HOD's department
      QuerySnapshot year2Snapshot = await FirebaseFirestore.instance
          .collection('Students')
          .where('department', isEqualTo: hodDepartment) // Filter by department
          .where('semester', whereIn: [3, 4]).get();
      // ADD THIS LINE
      setState(() {
        hasYear2Students = year2Snapshot.docs.isNotEmpty;
      });

      // Check for Year III students (Semesters 5 & 6) in the HOD's department
      QuerySnapshot year3Snapshot = await FirebaseFirestore.instance
          .collection('Students')
          .where('department', isEqualTo: hodDepartment) // Filter by department
          .where('semester', whereIn: [5, 6]).get();
      // ADD THIS LINE
      setState(() {
        hasYear3Students = year3Snapshot.docs.isNotEmpty;
      });

      // Check for Year IV students (Semesters 7 & 8) in the HOD's department
      QuerySnapshot year4Snapshot = await FirebaseFirestore.instance
          .collection('Students')
          .where('department', isEqualTo: hodDepartment) // Filter by department
          .where('semester', whereIn: [7, 8]).get();
      // ADD THIS LINE
      setState(() {
        hasYear4Students = year4Snapshot.docs.isNotEmpty;
      });
    } catch (e) {
      // Handle error appropriately
    }
  }

  Widget _buildYearButton(String year, bool isVisible, String departmentName) {
    return Visibility(
      visible: isVisible,
      child: SizedBox(
        width: 150,
        height: 150,
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => HodYearPage(
                      year: year,
                      departmentName: departmentName,
                    )));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Pallet.buttonColor,
            shape: CircleBorder(),
            padding: EdgeInsets.all(20),
          ),
          child: Text(
            year,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              color: Pallet.textColor,
            ),
          ),
        ),
      ),
    );
  }

  // Function to refresh the data
  Future<void> _refreshData() async {
    await _loadHODData();
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
        leading: Builder(
          builder: (BuildContext appBarContext) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                size: 35,
                color: Pallet.headingColor,
              ),
              onPressed: () {
                Scaffold.of(appBarContext).openDrawer();
              },
              tooltip:
                  MaterialLocalizations.of(appBarContext).openAppDrawerTooltip,
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Pallet.headingColor,
              size: 35,
            ),
            onPressed: _refreshData,
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Pallet.backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 200,
              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Pallet.headingColor,
                  image: profileImageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(profileImageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                accountName: null,
                accountEmail: null,
                currentAccountPicture: null,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.person_2,
                size: 25,
                color: Pallet.headingColor,
              ),
              title: Text(
                'My Profile',
                style: TextStyle(
                    color: Pallet.headingColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              ),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => HODProfile()));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
                size: 25,
                color: Pallet.headingColor,
              ),
              title: Text(
                'Logout!',
                style: TextStyle(
                    color: Pallet.headingColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              ),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', false);
                FirebaseAuthMethods().signout(context);
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => Loginpage()));
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        // Removed Center Widget and kept SingleChildScrollView for scrollability
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          // Added Padding around the Column to control horizontal spacing from screen edges
          padding: const EdgeInsets.symmetric(
              horizontal: 20.0), // Adjust horizontal padding as needed
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.center, // Align content to the start (left)
            children: [
              const SizedBox(
                height: 30, // Reduced spacing at the top
              ),
              Text(
                hODName,
                textAlign: TextAlign.center, // Align text to start
                style: TextStyle(
                  fontSize: 30,
                  color: Pallet.headingColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 10, bottom: 30), // Adjusted padding for department
                child: Text(
                  departmentName,
                  textAlign: TextAlign.center, // Align text to start
                  style: TextStyle(
                    fontSize: 24,
                    color: Pallet.extraColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(
                height: 100, // Reduced spacing at the top
              ),

              // Year buttons section - now below the name and department
              if (hasYear1Students || hasYear2Students)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildYearButton(
                          "Year I", hasYear1Students, departmentName),
                      _buildYearButton(
                          "Year II", hasYear2Students, departmentName),
                    ],
                  ),
                ),
              if (hasYear3Students || hasYear4Students)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildYearButton(
                        "Year III", hasYear3Students, departmentName),
                    _buildYearButton(
                        "Year IV", hasYear4Students, departmentName),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getYearTextForButton(int buttonCount) {
    // ADD THIS LINE
    if (buttonCount == 1) {
      if (hasYear1Students) return "Year I";
      if (hasYear2Students) return "Year II";
      if (hasYear3Students) return "Year III";
      if (hasYear4Students) return "Year IV";
    }
    return ""; // Should not reach here ideally
  }
}

import 'package:academiax/constants/pallet.dart';
import 'package:academiax/firebase_authentication/firebase_auth.dart';
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
  String hODName = 'Loading Name...'; // Initial loading state for name
  String departmentName =
      'Loading Department...'; // Initial loading state for enrollment
  bool isLoading = true; // To indicate loading state

  @override
  void initState() {
    super.initState();
    _loadStudentData(); // Fetch student data when the screen initializes
  }

  Future<void> _loadStudentData() async {
    setState(() {
      isLoading = true; // Set loading to true when starting fetch
    });
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot studentDoc = await FirebaseFirestore.instance
            .collection(
                'Heads of Departments') // Replace 'students' with your collection name
            .doc(user.uid)
            .get();

        if (studentDoc.exists) {
          setState(() {
            hODName = studentDoc.get('name') ??
                'Name not found'; // Get name field, handle null
            departmentName = studentDoc.get('department') ??
                'department not found'; // Get enrollment, handle null
            isLoading = false; // Data loaded, set loading to false
          });
        } else {
          setState(() {
            hODName =
                'Data not found'; // Handle case where document doesn't exist
            departmentName = 'Data not found';
            isLoading = false;
          });
          print(
              "HOD document not found in Firestore"); // Log if document not found
        }
      } else {
        setState(() {
          hODName =
              'User not logged in'; // Handle case where user is not logged in (shouldn't happen if properly routed)
          departmentName = 'User not logged in';
          isLoading = false;
        });
        print("No user logged in."); // Log if no user logged in
      }
    } catch (e) {
      setState(() {
        hODName = 'Error loading data'; // Handle error during data fetch
        departmentName = 'Error loading data';
        isLoading = false;
      });
      print("Error loading hod data: $e"); // Log error
    }
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
          // Use Builder to get context for Scaffold.of
          builder: (BuildContext appBarContext) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                size: 35,
                color: Pallet.headingColor,
              ), // Hamburger icon
              onPressed: () {
                Scaffold.of(appBarContext).openDrawer(); // Open drawer
              },
              tooltip:
                  MaterialLocalizations.of(appBarContext).openAppDrawerTooltip,
            );
          },
        ),
      ),
      drawer: Drawer(
        // Add the Drawer here
        backgroundColor: Pallet.backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Pallet.headingColor,
              ),
              child: Text(
                'App Menu',
                style: TextStyle(
                  color: Pallet.backgroundColor,
                  fontSize: 24,
                ),
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
              onTap: () {},
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
            // Removed Logout ListTile
          ],
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Text(
              hODName,
              style: TextStyle(
                fontSize: 30,
                color: Pallet.headingColor,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 80),
              child: Text(
                departmentName,
                style: TextStyle(
                  fontSize: 30,
                  color: Pallet.extraColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(
              height: 100,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Year I
                ElevatedButton(
                  onPressed: () {
                    // Navigator.of(context).push(
                    //     MaterialPageRoute(builder: (context) => Loginpage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Pallet.buttonColor,
                    minimumSize: const Size(150, 150),
                  ),
                  child: Text(
                    "Year I",
                    style: TextStyle(
                      fontSize: 25,
                      color: Pallet.textColor,
                    ),
                  ),
                ),
                // Year II

                ElevatedButton(
                  onPressed: () {
                    // Navigator.of(context).push(
                    //     MaterialPageRoute(builder: (context) => Loginpage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Pallet.buttonColor,
                    minimumSize: const Size(150, 150),
                  ),
                  child: Text(
                    "Year II",
                    style: TextStyle(
                      fontSize: 25,
                      color: Pallet.textColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            // 2nd row

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Year III
                ElevatedButton(
                  onPressed: () {
                    // Navigator.of(context).push(
                    //     MaterialPageRoute(builder: (context) => Loginpage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Pallet.buttonColor,
                    minimumSize: const Size(150, 150),
                  ),
                  child: Text(
                    "Year III",
                    style: TextStyle(
                      fontSize: 25,
                      color: Pallet.textColor,
                    ),
                  ),
                ),
                // Year IV

                ElevatedButton(
                  onPressed: () {
                    // Navigator.of(context).push(
                    //     MaterialPageRoute(builder: (context) => Loginpage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Pallet.buttonColor,
                    minimumSize: const Size(150, 150),
                  ),
                  child: Text(
                    "Year IV",
                    style: TextStyle(
                      fontSize: 25,
                      color: Pallet.textColor,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

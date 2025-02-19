import 'package:academiax/constants/pallet.dart';
import 'package:academiax/firebase_authentication/firebase_auth.dart';
import 'package:academiax/screens/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HodHomeScreen extends StatelessWidget {
  const HodHomeScreen({super.key});

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
              'Greetings,<HOD name>',
              style: TextStyle(
                fontSize: 30,
                color: Pallet.headingColor,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Text(
              '<Department Name>',
              style: TextStyle(
                fontSize: 30,
                color: Pallet.extraColor,
                fontWeight: FontWeight.w900,
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

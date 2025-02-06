import 'package:academiax/constants/pallet.dart';
import 'package:flutter/material.dart';

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

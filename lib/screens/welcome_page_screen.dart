// import 'package:academiax/constants/constants.dart';
// import 'package:academiax/constants/pallet.dart';
// import 'package:academiax/screens/login_create_acc_screen.dart';
// import 'package:flutter/material.dart';

// class WelcomePage extends StatelessWidget {
//   const WelcomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           children: [
//             const SizedBox(
//               height: 150,
//             ),
//             Text(
//               'AcademiaX',
//               style: TextStyle(
//                 fontSize: 60,
//                 color: Pallet.headingColor,
//                 fontWeight: FontWeight.w900,
//               ),
//             ),
//             const SizedBox(
//               height: 50,
//             ),
//             Image.asset(
//               Constants.backgroundImage,
//               fit: BoxFit.fitWidth,
//               height: 500,
//             ),
//             const SizedBox(
//               height: 30,
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).push(MaterialPageRoute(
//                     builder: (context) => LoginCreateAccScreen()));
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Pallet.buttonColor,
//                 minimumSize: const Size(200, 60),
//               ),
//               child: Text(
//                 "Let's Start!",
//                 style: TextStyle(
//                   fontSize: 25,
//                   color: Pallet.textColor,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:academiax/constants/constants.dart';
import 'package:academiax/constants/pallet.dart';
import 'package:academiax/screens/login_create_acc_screen.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        backgroundColor: Pallet.backgroundColor,
      ) ,
      body: SingleChildScrollView(
        // 1. Wrap Column in SingleChildScrollView
        child: Center(
          child: Padding(
            // 2. Add Padding around the Column
            padding: const EdgeInsets.symmetric(
                horizontal: 20.0), // Add horizontal padding
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center content vertically
              children: [
                const SizedBox(height: 20), // Reduced SizedBox height

                Text(
                  'AcademiaX',
                  textAlign: TextAlign.center, // Ensure text is centered
                  style: TextStyle(
                    fontSize: 50, // Slightly reduced font size
                    color: Pallet.headingColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 30), // Reduced SizedBox height

                Image.asset(
                  Constants.backgroundImage,
                  fit: BoxFit
                      .contain, // Use BoxFit.contain to scale image proportionally
                  height: MediaQuery.of(context).size.height *
                      0.4, // Responsive image height (40% of screen height)
                ),
                const SizedBox(height: 40), // Reduced SizedBox height

                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => LoginCreateAccScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Pallet.buttonColor,
                    padding: EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15), // Adjust button padding
                    // Removed fixed minimumSize
                  ),
                  child: Text(
                    "Let's Start!",
                    style: TextStyle(
                      fontSize: 22, // Slightly reduced font size
                      color: Pallet.textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Reduced SizedBox height
              ],
            ),
          ),
        ),
      ),
    );
  }
}

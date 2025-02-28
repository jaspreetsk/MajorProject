import 'package:academiax/constants/pallet.dart';
import 'package:flutter/material.dart';

class TextFieldArea extends StatelessWidget {
  final TextEditingController textFieldController;
  final String? hintText; // Added optional hintText parameter
  const TextFieldArea(
      {super.key,
      required this.textFieldController,
      this.hintText}); // Updated constructor

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: TextField(
        controller: textFieldController,
        style: const TextStyle(
          color: Pallet.headingColor,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hintText, // Use hintText here
          hintStyle: const TextStyle(
            fontSize: 19,
            // Optional: Style the hint text
            color: Color(0xFF625d4c),
            fontWeight: FontWeight.bold,
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Pallet.headingColor, width: 2.0),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Pallet.headingColor, width: 2.0),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Pallet.headingColor, width: 2.0),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Pallet.headingColor, width: 2.0),
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Pallet.headingColor,
            ),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
        ),
      ),
    );
  }
}

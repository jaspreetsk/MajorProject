import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for TextInputType

class TextFieldArea extends StatelessWidget {
  final TextEditingController textFieldController;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType; // Add keyboardType
  final String? Function(String?)? validator; // Add validator
  final List<TextInputFormatter>? inputFormatters; // Add inputFormatters

  const TextFieldArea({
    Key? key,
    required this.textFieldController,
    this.hintText,
    this.obscureText = false,
    this.keyboardType, // Initialize keyboardType
    this.validator, // Initialize validator
    this.inputFormatters, // Initialize inputFormatters
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: TextFormField(
        // Use TextFormField here
        controller: textFieldController,
        obscureText: obscureText,
        keyboardType: keyboardType, // Use keyboardType
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 112, 94, 53),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromARGB(255, 112, 94, 53),
              width: 2,
            ),
            borderRadius: BorderRadius.all(Radius.circular(7)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromARGB(255, 112, 94, 53),
              width: 3,
            ),
            borderRadius: BorderRadius.all(Radius.circular(7)),
          ),
          fillColor: const Color.fromARGB(255, 211, 195, 132),
          filled: true,
          contentPadding: const EdgeInsets.all(20),
        ),
        validator: validator, // Use validator
        inputFormatters: inputFormatters, // Use inputFormatters
      ),
    );
  }
}

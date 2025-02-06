import 'package:academiax/constants/pallet.dart';
import 'package:flutter/material.dart';

class TextFieldArea extends StatelessWidget {
  const TextFieldArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: TextField(
        style: TextStyle(
          color: Pallet.headingColor,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Pallet.headingColor, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Pallet.headingColor, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Pallet.headingColor, width: 2.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Pallet.headingColor, width: 2.0),
          ),
          border: OutlineInputBorder(
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

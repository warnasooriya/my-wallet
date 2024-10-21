import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget BuildTextField(
    TextEditingController controller, String label, TextInputType keyboardType,
    {bool isNumberOnly = false}) {
  return Padding(
    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
      keyboardType: keyboardType,
      inputFormatters: isNumberOnly
          ? [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ] // Restrict to numbers
          : [],
    ),
  );
}

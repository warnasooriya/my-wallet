import 'package:flutter/material.dart';

Widget BuildDropdown(String hint, List<String> items, String? selectedValue,
    ValueChanged<String?> onChanged) {
  return DropdownButtonFormField<String>(
    decoration: InputDecoration(
      labelText: hint,
      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
    ),
    value: selectedValue,
    onChanged: onChanged,
    items: items.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList(),
  );
}

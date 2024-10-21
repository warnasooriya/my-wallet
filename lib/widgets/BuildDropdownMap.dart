import 'package:flutter/material.dart';

Widget BuildDropdownMap(
    String rebuildKey,
    String hint,
    List<Map<String, dynamic>> items,
    String? selectedValue,
    ValueChanged<String?> onChanged,
    String value,
    String label) {
  final List<Map<String, dynamic>> validItems = items ?? [];

  bool isValidValue = selectedValue == null ||
      validItems.any((item) => item[value] == selectedValue);

  return DropdownButtonFormField<String>(
    decoration: InputDecoration(
      labelText: hint,
      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
    ),
    key: ValueKey(rebuildKey),
    value: isValidValue ? selectedValue : null,
    onChanged: validItems.isNotEmpty ? onChanged : null,
    items: validItems.isNotEmpty
        ? validItems.map<DropdownMenuItem<String>>((Map<String, dynamic> item) {
            return DropdownMenuItem<String>(
              value: item[value], // Use the value from the map
              child: Text(item[label] ?? ''), // Display the label from the map
            );
          }).toList()
        : null, // If items is empty or null, no items will be displayed
  );
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget BuildTextButton(label, VoidCallback method) {
  return TextButton(
    child: Text(label),
    onPressed: () {
      method;
    },
  );
}

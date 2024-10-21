import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerWidget extends StatelessWidget {
  final DateTime selectedDate;
  final String label;
  final Function(DateTime) onDateChanged; // Callback to handle date changes

  DatePickerWidget({
    required this.selectedDate,
    required this.onDateChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${label}: ${DateFormat.yMd().format(selectedDate)}'),
      trailing: Icon(Icons.calendar_today),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null && picked != selectedDate) {
          onDateChanged(picked); // Trigger the callback when the date changes
        }
      },
    );
  }
}

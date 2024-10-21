import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

Widget BuildBarChart(barAnimData) {
  return Container(
    padding: const EdgeInsets.all(10),
    child: Chart(
      rebuild: true, // Enable rebuild when data changes
      data: barAnimData, // Pass the transformed data
      variables: {
        'category': Variable(
          accessor: (Map map) =>
              map['category'] as String, // X-axis (category: e.g., month)
        ),
        'value': Variable(
          accessor: (Map map) =>
              map['value'] as num, // Y-axis (value: income/expenses)
          scale: LinearScale(min: 0),
        ),
        'type': Variable(
          accessor: (Map map) =>
              map['type'] as String, // Grouping by type (Income/Expenses)
        ),
      },
      marks: [
        IntervalMark(
          label: LabelEncode(
            encoder: (tuple) => Label(
              tuple['type'].toString().toString().substring(0, 1),
              LabelStyle(
                align: Alignment.topLeft,
                textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 7, 7, 7),
                ),
              ),
            ),
          ),
          // Use dodge to align the two bars (Income/Expenses) together in each category
          position: Varset('category') * Varset('value') / Varset('type'),
          color: ColorEncode(
            variable: 'type',
            values: [
              const Color.fromARGB(255, 226, 71, 60), // Red for Expenses
              const Color.fromARGB(255, 19, 103, 228), // Blue for Income
            ],
          ),
          // Use a smaller dodge ratio to reduce the gap between bars of the same category
          modifiers: [
            DodgeModifier(ratio: 0.09)
          ], // Smaller ratio reduces the gap between Income and Expenses
          size: SizeEncode(
            value:
                10, // Increase the bar width to reduce the gap between different groups (months)
          ),
        ),
      ],
      axes: [
        Defaults.horizontalAxis,
        Defaults.verticalAxis,
      ],
    ),
  );
}

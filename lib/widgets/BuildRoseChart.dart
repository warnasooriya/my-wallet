import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

Widget BuildRoseChart(List<Map<String, dynamic>> data) {
  final colorPalette = _generateDynamicColors();

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end, // Align legend to the right
      children: [
        Container(
          height: 200,
          child: Chart(
            rebuild: true,
            data: data,
            variables: {
              'name': Variable(
                accessor: (Map map) => map['name'] as String,
              ),
              'value': Variable(
                accessor: (Map map) => map['value'] as num,
                scale: LinearScale(min: 0, marginMax: 0.1),
              ),
            },
            marks: [
              IntervalMark(
                shape: ShapeEncode(
                  value: RectShape(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                  ),
                ),
                color: ColorEncode(
                  variable: 'name',
                  values: colorPalette,
                ),
                elevation: ElevationEncode(
                  value: 6,
                ),
                transition: Transition(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                ),
                entrance: {MarkEntrance.y},
              ),
            ],
            coord: PolarCoord(
              startRadius: 0.8,
            ),
            selections: {
              'tooltipMouse': PointSelection(
                on: {
                  GestureType.scaleUpdate,
                  GestureType.tapDown,
                  GestureType.longPressMoveUpdate,
                  GestureType.hover,
                },
                devices: {PointerDeviceKind.mouse},
                variable: 'name',
              ),
            },
            tooltip: TooltipGuide(
              followPointer: [true, true],
              align: Alignment.topLeft,
              offset: const Offset(10, 10),
              selections: {'tooltipMouse'},
              textStyle: const TextStyle(fontSize: 12, color: Colors.white),
              backgroundColor: Colors.black,
              padding: const EdgeInsets.all(8),
            ),
            crosshair: CrosshairGuide(
              selections: {'tooltipMouse'},
              followPointer: [false, true],
            ),
          ),
        ),
        // Add the legend widget here
        _buildLegend(data, colorPalette),
      ],
    ),
  );
}

Widget _buildLegend(List<Map<String, dynamic>> data, List<Color> colors) {
  return Container(
    margin: const EdgeInsets.only(top: 10, right: 20),
    alignment: Alignment.bottomRight,
    child: Wrap(
      spacing: 10,
      runSpacing: 5,
      children: List.generate(data.length, (index) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                shape: BoxShape.rectangle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              data[index]['name'] as String,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }),
    ),
  );
}

List<Color> _generateDynamicColors() {
  return [
    const Color.fromARGB(255, 236, 146, 11),
    const Color.fromARGB(255, 248, 77, 9),
    Colors.blue,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    const Color.fromARGB(255, 112, 20, 165),
    Colors.pink,
    Colors.indigo,
    Colors.cyan,
  ];
}

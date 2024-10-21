import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

Widget BuildRoseChart(List<Map<String, dynamic>> data) {
  return Container(
    height: 300,
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
          label: LabelEncode(
            encoder: (tuple) => Label(
              tuple['name'].toString(),
              LabelStyle(
                align: Alignment.center,
                textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 7, 7, 7),
                ),
              ),
            ),
          ),
          shape: ShapeEncode(
            value: RectShape(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
          ),
          color: ColorEncode(
            variable: 'name',
            values: _generateDynamicColors(),
          ),
          elevation: ElevationEncode(
            value: 4,
          ),
          transition: Transition(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          ),
          entrance: {MarkEntrance.y},
        ),
      ],
      coord: PolarCoord(
        startRadius: 0.1,
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
        // Ensure that the selection points trigger the tooltip
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
  );
}

List<Color> _generateDynamicColors() {
  return [
    const Color.fromARGB(255, 255, 0, 234),
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

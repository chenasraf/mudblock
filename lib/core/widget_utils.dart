import 'package:flutter/material.dart';

class WidgetUtils {
  static join(List<Widget> widgets, Widget separator) => widgets.length == 1
      ? widgets
      : widgets.expand((widget) => [separator, widget]).toList()
    ..removeAt(0);

  static gap(List<Widget> widgets, double gap) =>
      join(widgets, SizedBox(width: gap, height: gap));
}


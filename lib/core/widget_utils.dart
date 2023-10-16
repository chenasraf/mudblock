import 'package:flutter/material.dart';

class WidgetUtils {
  static join(List<Widget> widgets, Widget separator) =>
      widgets.expand((widget) => [separator, widget]).toList()..removeAt(0);
}


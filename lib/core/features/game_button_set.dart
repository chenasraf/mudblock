import 'dart:math';

import 'package:flutter/material.dart';

import '../string_utils.dart';
import 'action.dart';
import 'game_button.dart';

class GameButtonSet extends StatelessWidget {
  const GameButtonSet({
    super.key,
    required this.data,
  });

  final GameButtonSetData data;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: data.alignment,
      child: IconTheme(
        data: IconTheme.of(context).copyWith(size: 32),
        child: Builder(builder: _buildButtonContainer),
      ),
    );
  }

  Widget _buildButtonContainer(BuildContext context) {
    return buildContainer(
      context: context,
      type: data.type,
      crossAxisCount: data.crossAxisCount,
      spacing: data.spacing,
      count: data.buttons.length,
      alignment: data.alignment,
      builder: (context, index) => data.buttons[index] != null
          ? GameButton(data: data.buttons[index]!)
          : const SizedBox(
              width: GameButtonData.defaultSize,
              height: GameButtonData.defaultSize,
            ),
    );
  }

  static Widget buildContainer({
    required BuildContext context,
    required GameButtonSetType type,
    required Widget Function(BuildContext context, int index) builder,
    required int count,
    required int? crossAxisCount,
    required Alignment alignment,
    required double spacing,
  }) {
    final buttonWidgets = List.generate(
      count,
      (index) => Padding(
        padding: EdgeInsets.all(spacing / 2),
        child: builder(context, index),
      ),
    );
    switch (type) {
      case GameButtonSetType.row:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: buttonWidgets,
        );
      case GameButtonSetType.column:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: buttonWidgets,
        );
      case GameButtonSetType.grid:
        final rows = <List<Widget>>[];
        final rowCount = (count / crossAxisCount!).ceil();
        for (var i = 0; i < rowCount; i++) {
          final row = <Widget>[];
          for (var j = 0; j < crossAxisCount; j++) {
            final index = i * crossAxisCount + j;
            if (index < count) {
              row.add(buttonWidgets[index]);
            } else {
              row.add(Container());
            }
          }
          rows.add(row);
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: rows
              .map((row) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: row,
                  ))
              .toList(),
        );
    }
  }
}

class GameButtonSetData {
  final String id;
  String label;
  bool enabled;
  String name;
  GameButtonSetType type;
  List<GameButtonData?> buttons;
  int? crossAxisCount;
  Alignment alignment;
  double spacing;
  String group;

  GameButtonSetData({
    required this.id,
    required this.type,
    required this.name,
    required this.buttons,
    this.label = '',
    this.crossAxisCount,
    this.alignment = Alignment.center,
    this.spacing = 8,
    this.group = '',
    this.enabled = true,
  });

  static const IconData iconData = Icons.gamepad;

  factory GameButtonSetData.empty() => GameButtonSetData(
        id: uuid(),
        name: '',
        label: '',
        type: GameButtonSetType.row,
        buttons: [],
      );

  List<GameButtonData> get nonEmptyButtons =>
      buttons.whereType<GameButtonData>().toList();

  factory GameButtonSetData.fromJson(Map<String, dynamic> json) =>
      GameButtonSetData(
        id: json['id'] as String,
        label: json['label'] as String? ?? '',
        enabled: json['enabled'] as bool? ?? true,
        name: json['name'] as String,
        type: GameButtonSetType.values.firstWhere(
          (type) => type.name == json['type'],
        ),
        buttons: (json['buttons'] as List<dynamic>)
            .map<GameButtonData?>(
              (button) => button == null
                  ? null
                  : GameButtonData.fromJson(button as Map<String, dynamic>),
            )
            .toList(),
        crossAxisCount: json['crossAxisCount'] as int?,
        alignment: Alignment(
          json['alignment']['x'] as double,
          json['alignment']['y'] as double,
        ),
        spacing: json['spacing'] as double,
        group: json['group'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'label': label,
        'enabled': enabled,
        'name': name,
        'type': type.name,
        'buttons': buttons.map((button) => button?.toJson()).toList(),
        'crossAxisCount': crossAxisCount,
        'alignment': <String, double>{
          'x': alignment.x,
          'y': alignment.y,
        },
        'spacing': spacing,
        'group': group,
      };

  GameButtonSetData copyWith({
    String? id,
    bool? enabled,
    String? name,
    GameButtonSetType? type,
    List<GameButtonData?>? buttons,
    int? crossAxisCount,
    Alignment? alignment,
    double? spacing,
    String? group,
  }) =>
      GameButtonSetData(
        id: id ?? this.id,
        enabled: enabled ?? this.enabled,
        name: name ?? this.name,
        type: type ?? this.type,
        buttons: buttons ?? [...this.buttons],
        crossAxisCount: crossAxisCount ?? this.crossAxisCount,
        alignment: alignment ?? this.alignment,
        spacing: spacing ?? this.spacing,
        group: group ?? this.group,
      );

  // double calculateWidth() {
  //   switch (type) {
  //     case GameButtonSetType.row:
  //       return sumSize(buttons) + buttons.length * spacing;
  //     case GameButtonSetType.column:
  //       return maxSize(buttons) + spacing;
  //     case GameButtonSetType.grid:
  //       final colWidths = List.generate(
  //         colCount,
  //         (index) => maxSize(getColumnButtons(index)),
  //       );
  //
  //       return colWidths.fold<double>(
  //           0, (sum, width) => sum + width + (spacing / 2));
  //   }
  // }
  //
  // double calculateHeight() {
  //   switch (type) {
  //     case GameButtonSetType.row:
  //       return maxSize(buttons) + spacing;
  //     case GameButtonSetType.column:
  //       return sumSize(buttons) + buttons.length * spacing;
  //     case GameButtonSetType.grid:
  //       final rowHeights = List.generate(
  //         rowCount,
  //         (index) => maxSize(getRowButtons(index)),
  //       );
  //       return rowHeights.fold<double>(
  //           0, (sum, height) => sum + height + (spacing / 2));
  //   }
  // }
  //
  // double maxSize(List<GameButtonData?> buttons) {
  //   return buttons.fold<double>(
  //     0,
  //     (sum, button) => max(sum, button?.size ?? GameButtonData.defaultSize),
  //   );
  // }
  //
  // double sumSize(List<GameButtonData?> buttons) {
  //   return buttons.fold<double>(
  //     0,
  //     (sum, button) => sum + (button?.size ?? GameButtonData.defaultSize),
  //   );
  // }

  List<GameButtonData?> getRowButtons(int row) =>
      getRowIndices(row).map((index) => buttons[index]).toList(growable: false);

  List<GameButtonData?> getColumnButtons(int col) => getColumnIndices(col)
      .map((index) => buttons[index])
      .toList(growable: false);

  int get rowCount {
    switch (type) {
      case GameButtonSetType.row:
        return 1;
      case GameButtonSetType.column:
        return buttons.length;
      case GameButtonSetType.grid:
        return buttons.length ~/ crossAxisCount!;
    }
  }

  int get colCount {
    switch (type) {
      case GameButtonSetType.row:
        return buttons.length;
      case GameButtonSetType.column:
        return 1;
      case GameButtonSetType.grid:
        return crossAxisCount!;
    }
  }

  List<int> getRowIndices(int row) =>
      List<int>.generate(colCount, (index) => row * colCount + index);

  List<int> getColumnIndices(int col) =>
      List<int>.generate(rowCount, (index) => index * colCount + col);

  int getColumnFromIndex(int index) => index % colCount;

  int getRowFromIndex(int index) => index ~/ colCount;
}

enum GameButtonSetType {
  row,
  column,
  grid,
}

final movementPreset = GameButtonSetData(
  id: uuid(),
  name: 'Movement',
  type: GameButtonSetType.grid,
  crossAxisCount: 3,
  alignment: Alignment.bottomRight,
  buttons: [
    null,
    GameButtonData(
      id: uuid(),
      label: GameButtonLabelData(icon: Icons.keyboard_arrow_up),
      pressAction: MUDAction('north'),
    ),
    GameButtonData(
      id: uuid(),
      label: GameButtonLabelData(icon: Icons.keyboard_double_arrow_up),
      pressAction: MUDAction('up'),
    ),
    GameButtonData(
      id: uuid(),
      label: GameButtonLabelData(icon: Icons.keyboard_arrow_left),
      pressAction: MUDAction('west'),
    ),
    GameButtonData(
      id: uuid(),
      label: GameButtonLabelData(icon: Icons.visibility_outlined),
      labelUp: GameButtonLabelData(icon: Icons.exit_to_app),
      labelDown: GameButtonLabelData(icon: Icons.exit_to_app),
      pressAction: MUDAction('look'),
      dragUpAction: MUDAction('exits'),
      dragDownAction: MUDAction('exits'),
    ),
    GameButtonData(
      id: uuid(),
      label: GameButtonLabelData(icon: Icons.keyboard_arrow_right),
      pressAction: MUDAction('east'),
    ),
    null,
    GameButtonData(
      id: uuid(),
      label: GameButtonLabelData(icon: Icons.keyboard_arrow_down),
      pressAction: MUDAction('south'),
    ),
    GameButtonData(
      id: uuid(),
      label: GameButtonLabelData(icon: Icons.keyboard_double_arrow_down),
      pressAction: MUDAction('down'),
    ),
  ],
);


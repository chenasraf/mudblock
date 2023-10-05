import 'dart:math';

import 'package:flutter/material.dart';

import '../string_utils.dart';
import 'action.dart';
import 'game_button.dart';

class GameButtonSet extends StatelessWidget {
  const GameButtonSet({
    super.key,
    required this.buttonSet,
  });

  final GameButtonSetData buttonSet;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: buttonSet.alignment,
      child: IconTheme(
        data: IconTheme.of(context).copyWith(size: 32),
        child: Builder(
          builder: (context) {
            final containerSize = buttonSet.size;
            return SizedBox(
              width: containerSize.width,
              height: containerSize.height,
              child: _buildButtonContainer(context),
            );
          },
        ),
      ),
    );
  }

  Widget _buildButtonContainer(BuildContext context) {
    final type = buttonSet.type;
    final crossAxisCount = buttonSet.crossAxisCount;
    final buttonWidgets = buttonSet.buttons
        .map(
          (button) => Padding(
            padding: EdgeInsets.all(buttonSet.spacing / 2),
            child: button != null ? GameButton(data: button) : Container(),
          ),
        )
        .toList();
    switch (type) {
      case GameButtonSetType.row:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: buttonWidgets,
        );
      case GameButtonSetType.column:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: buttonWidgets,
        );
      case GameButtonSetType.grid:
        return GridView.count(
          crossAxisCount: crossAxisCount ?? 3,
          children: buttonWidgets,
        );
    }
  }
}

class GameButtonSetData {
  final String id;
  final String name;
  final GameButtonSetType type;
  final List<GameButtonData?> buttons;
  final int? crossAxisCount;
  final Alignment alignment;
  final double spacing;
  final String group;

  const GameButtonSetData({
    required this.id,
    required this.type,
    required this.name,
    required this.buttons,
    this.crossAxisCount,
    this.alignment = Alignment.center,
    this.spacing = 8,
    this.group = '',
  });

  Size get size => Size(calculateWidth(), calculateHeight());

  factory GameButtonSetData.fromJson(Map<String, dynamic> json) => GameButtonSetData(
        id: json['id'] as String,
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

  double calculateWidth() {
    switch (type) {
      case GameButtonSetType.row:
        return buttons.fold<double>(
                0,
                (sum, button) =>
                    sum + (button?.size ?? GameButtonData.defaultSize)) +
            (buttons.length - 1) * spacing;
      case GameButtonSetType.column:
        return buttons.fold<double>(
                0,
                (sum, button) =>
                    max(sum, button?.size ?? GameButtonData.defaultSize)) +
            (buttons.length - 1) * spacing;
      case GameButtonSetType.grid:
        final rowCount = buttons.length ~/ (crossAxisCount ?? 3);
        final rowWidths = List<double>.generate(
          rowCount,
          (row) => buttons
              .sublist(
                row * (crossAxisCount ?? 3),
                (row + 1) * (crossAxisCount ?? 3),
              )
              .fold(
                0,
                (sum, button) =>
                    sum + (button?.size ?? GameButtonData.defaultSize),
              ),
        );
        return rowWidths.fold<double>(0, (sum, width) => max(sum, width)) +
            (rowCount - 1) * spacing;
    }
  }

  double calculateHeight() {
    switch (type) {
      case GameButtonSetType.row:
        return buttons.fold<double>(
                0,
                (sum, button) =>
                    max(sum, button?.size ?? GameButtonData.defaultSize)) +
            (buttons.length - 1) * spacing;
      case GameButtonSetType.column:
        return buttons.fold<double>(
                0,
                (sum, button) =>
                    sum + (button?.size ?? GameButtonData.defaultSize)) +
            (buttons.length - 1) * spacing;
      case GameButtonSetType.grid:
        final rowCount = buttons.length ~/ (crossAxisCount ?? 3);
        final rowHeights = List<double>.generate(
          rowCount,
          (row) => buttons
              .sublist(
                row * (crossAxisCount ?? 3),
                (row + 1) * (crossAxisCount ?? 3),
              )
              .fold(
                0,
                (sum, button) =>
                    sum + (button?.size ?? GameButtonData.defaultSize),
              ),
        );
        return rowHeights.fold<double>(0, (sum, height) => max(sum, height)) +
            (rowCount - 1) * spacing;
    }
  }
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
    null,
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
      swipeUpAction: MUDAction('exits'),
      swipeDownAction: MUDAction('exits'),
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
    null,
  ],
);


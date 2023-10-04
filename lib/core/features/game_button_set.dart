import 'dart:math';

import 'package:flutter/material.dart';

import 'action.dart';
import 'game_button.dart';

class GameButtonsView extends StatelessWidget {
  const GameButtonsView({
    super.key,
    required this.gameButtonSet,
  });

  final GameButtonSet gameButtonSet;

  @override
  Widget build(BuildContext context) {
    final buttons = gameButtonSet.buttons
        .map(
          (button) => Padding(
            padding: EdgeInsets.all(gameButtonSet.spacing ?? 8) / 2,
            child: button ?? Container(),
          ),
        )
        .toList();
    final type = gameButtonSet.type;
    final crossAxisCount = gameButtonSet.crossAxisCount;

    switch (type) {
      case GameButtonSetType.row:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: buttons,
        );
      case GameButtonSetType.column:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: buttons,
        );
      case GameButtonSetType.grid:
        return GridView.count(
          crossAxisCount: crossAxisCount ?? 3,
          children: buttons,
        );
    }
  }
}

class GameButtonSet {
  final GameButtonSetType type;
  final List<GameButton?> buttons;
  final int? crossAxisCount;
  final Alignment alignment;
  final double? spacing;

  const GameButtonSet({
    required this.type,
    required this.buttons,
    this.crossAxisCount,
    this.alignment = Alignment.center,
    this.spacing = 8,
  });

  Size get size => Size(calculateWidth(), calculateHeight());

  double calculateWidth() {
    switch (type) {
      case GameButtonSetType.row:
        return buttons.fold<double>(
                0,
                (sum, button) =>
                    sum + (button?.size ?? GameButton.defaultSize)) +
            (buttons.length - 1) * (spacing ?? 8);
      case GameButtonSetType.column:
        return buttons.fold<double>(
                0,
                (sum, button) =>
                    max(sum, button?.size ?? GameButton.defaultSize)) +
            (buttons.length - 1) * (spacing ?? 8);
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
                (sum, button) => sum + (button?.size ?? GameButton.defaultSize),
              ),
        );
        return rowWidths.fold<double>(0, (sum, width) => max(sum, width)) +
            (rowCount - 1) * (spacing ?? 8);
    }
  }

  double calculateHeight() {
    switch (type) {
      case GameButtonSetType.row:
        return buttons.fold<double>(
                0,
                (sum, button) =>
                    max(sum, button?.size ?? GameButton.defaultSize)) +
            (buttons.length - 1) * (spacing ?? 8);
      case GameButtonSetType.column:
        return buttons.fold<double>(
                0,
                (sum, button) =>
                    sum + (button?.size ?? GameButton.defaultSize)) +
            (buttons.length - 1) * (spacing ?? 8);
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
                (sum, button) => sum + (button?.size ?? GameButton.defaultSize),
              ),
        );
        return rowHeights.fold<double>(0, (sum, height) => max(sum, height)) +
            (rowCount - 1) * (spacing ?? 8);
    }
  }
}

enum GameButtonSetType {
  row,
  column,
  grid,
}

final movementPreset = GameButtonSet(
  type: GameButtonSetType.grid,
  crossAxisCount: 3,
  buttons: [
    null,
    GameButton(
      icon: GameButtonIcon(Icons.keyboard_arrow_up),
      pressAction: MUDAction('north'),
    ),
    null,
    GameButton(
      icon: GameButtonIcon(Icons.keyboard_arrow_left),
      pressAction: MUDAction('west'),
    ),
    GameButton(
      icon: GameButtonIcon(Icons.visibility_outlined),
      iconUp: GameButtonIcon(Icons.exit_to_app),
      iconDown: GameButtonIcon(Icons.exit_to_app),
      pressAction: MUDAction('look'),
      swipeUpAction: MUDAction('exits'),
      swipeDownAction: MUDAction('exits'),
    ),
    GameButton(
      icon: GameButtonIcon(Icons.keyboard_arrow_right),
      pressAction: MUDAction('east'),
    ),
    null,
    GameButton(
      icon: GameButtonIcon(Icons.keyboard_arrow_down),
      pressAction: MUDAction('south'),
    ),
    null,
  ],
);


import 'package:flutter/material.dart';

ThemeData createTheme({
  Brightness? brightness,
  required Color seedColor,
}) {
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );

  final theme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    listTileTheme: base.listTileTheme.copyWith(
      selectedTileColor: base.colorScheme.surfaceVariant,
    ),
  );

  return theme;
}


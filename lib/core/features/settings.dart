import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Settings {
  Setting<String> commandSeparator;
  Setting<bool> echoCommands;
  Setting<bool> showTimestamps;

  List<Setting> get all => [commandSeparator, echoCommands, showTimestamps];

  Settings({
    required this.commandSeparator,
    required this.echoCommands,
    required this.showTimestamps,
  });

  factory Settings.empty() => Settings(
        commandSeparator: commandSeparatorSetting.fromValue(';'),
        echoCommands: echoCommandsSetting.fromValue(true),
        showTimestamps: showTimestampsSetting.fromValue(false),
      );

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
        commandSeparator: commandSeparatorSetting.fromValue(json['commandSeparator']),
        echoCommands: echoCommandsSetting.fromValue(json['echoCommands']),
        showTimestamps: showTimestampsSetting.fromValue(json['showTimestamps']),
      );

  Map<String, dynamic> toJson() => {
        'commandSeparator': commandSeparator.value,
        'echoCommands': echoCommands.value,
        'showTimestamps': showTimestamps.value,
      };

  Settings copyWith({
    Setting<String>? commandSeparator,
    Setting<bool>? echoCommands,
  }) {
    return Settings(
      commandSeparator: commandSeparator ?? this.commandSeparator,
      echoCommands: echoCommands ?? this.echoCommands,
      showTimestamps: showTimestamps,
    );
  }
}

class GlobalSettings {
  Setting<bool> keepAwake;
  Setting<double> gameTextScale;
  Setting<double> uiTextScale;

  List<Setting> get all => [keepAwake, gameTextScale, uiTextScale];

  GlobalSettings({
    required this.keepAwake,
    required this.gameTextScale,
    required this.uiTextScale,
  });

  factory GlobalSettings.empty() => GlobalSettings(
        keepAwake: keepAwakeSetting.fromValue(true),
        gameTextScale: gameTextScaleSetting.fromValue(1.0),
        uiTextScale: uiTextScaleSetting.fromValue(1.0),
      );

  factory GlobalSettings.fromJson(Map<String, dynamic> json) => GlobalSettings(
        keepAwake: keepAwakeSetting.fromValue(json['keepAwake']),
        gameTextScale: gameTextScaleSetting.fromValue(json['gameTextScale']),
        uiTextScale: uiTextScaleSetting.fromValue(json['uiTextScale']),
      );

  Map<String, dynamic> toJson() => {
        'keepAwake': keepAwake.value,
        'gameTextScale': gameTextScale.value,
        'uiTextScale': uiTextScale.value,
      };

  GlobalSettings copyWith({
    Setting<bool>? keepAwake,
    Setting<double>? gameTextScale,
    Setting<double>? uiTextScale,
  }) {
    return GlobalSettings(
      keepAwake: keepAwake ?? this.keepAwake,
      gameTextScale: gameTextScale ?? this.gameTextScale,
      uiTextScale: uiTextScale ?? this.uiTextScale,
    );
  }
}

// Global
final keepAwakeSetting = SettingFactory<bool>('keepAwake', 'Keep Awake', true);
final gameTextScaleSetting =
    SettingFactory<double>('gameTextScale', 'Game Text Scale', 1.0);
final uiTextScaleSetting =
    SettingFactory<double>('uiTextScale', 'UI Text Scale', 1.0);

// Profile
final echoCommandsSetting =
    SettingFactory<bool>('echoCommands', 'Echo Commands', true);
final showTimestampsSetting =
    SettingFactory<bool>('showTimestamps', 'Show Timestamps', false);
final commandSeparatorSetting =
    SettingFactory<String>('commandSeparator', 'Command Separator', ';');

class SettingFactory<T> {
  final String key;
  final String description;
  final T defaultValue;
  SettingFactory(this.key, this.description, this.defaultValue);
  Setting<T> create() => Setting<T>(key, description, defaultValue);
  Setting<T> fromValue(T? value) =>
      Setting<T>(key, description, value ?? defaultValue);
}

class Setting<T> {
  final String key;
  final String description;
  final ValueNotifier<T> _value;
  bool _modified = false;

  Setting(this.key, this.description, T value)
      : _value = ValueNotifier<T>(value);

  T get value => _value.value;

  bool get modified => _modified;

  set value(T value) {
    _value.value = value;
    _modified = true;
  }
}


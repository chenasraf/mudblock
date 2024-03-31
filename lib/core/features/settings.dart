class Settings {
  String commandSeparator;
  bool echoCommands;
  bool showTimestamps;

  Settings({
    required this.commandSeparator,
    required this.echoCommands,
    required this.showTimestamps,
  });

  factory Settings.empty() => Settings(
        commandSeparator: ';',
        echoCommands: true,
        showTimestamps: false,
      );

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
        commandSeparator: json['commandSeparator'] as String,
        echoCommands: json['echoCommands'] as bool? ?? true,
        showTimestamps: json['showTimestamps'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'commandSeparator': commandSeparator,
        'echoCommands': echoCommands,
        'showTimestamps': showTimestamps,
      };

  Settings copyWith({
    String? commandSeparator,
    bool? echoCommands,
  }) {
    return Settings(
      commandSeparator: commandSeparator ?? this.commandSeparator,
      echoCommands: echoCommands ?? this.echoCommands,
      showTimestamps: showTimestamps,
    );
  }
}

class GlobalSettings {
  bool keepAwake;
  double gameTextScale;

  GlobalSettings({
    required this.keepAwake,
    required this.gameTextScale,
  });

  factory GlobalSettings.empty() => GlobalSettings(
        keepAwake: true,
        gameTextScale: 1.0,
      );

  factory GlobalSettings.fromJson(Map<String, dynamic> json) => GlobalSettings(
        keepAwake: json['keepAwake'] as bool? ?? true,
        gameTextScale: json['gameTextScale'] as double? ?? 1.0,
      );

  Map<String, dynamic> toJson() => {
        'keepAwake': keepAwake,
        'gameTextScale': gameTextScale,
      };

  GlobalSettings copyWith({
    bool? keepAwake,
    double? gameTextScale,
  }) {
    return GlobalSettings(
      keepAwake: keepAwake ?? this.keepAwake,
      gameTextScale: gameTextScale ?? this.gameTextScale,
    );
  }
}


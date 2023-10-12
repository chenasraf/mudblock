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


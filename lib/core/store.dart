import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:ctelnet/ctelnet.dart';
import 'package:flutter/material.dart';
import 'package:mudblock/core/features/settings.dart';
import 'package:mudblock/core/profile_presets.dart';
import 'package:mudblock/core/storage.dart';
import 'package:mudblock/pages/select_profile_page.dart';
import 'package:provider/provider.dart';

import 'color_utils.dart';
import 'consts.dart';
import 'features/action.dart';
import 'features/alias.dart';
import 'features/keyboard_shortcuts.dart';
import 'features/profile.dart';

const maxLines = 2000;

class GameStore extends ChangeNotifier {
  final List<String> _lines = [];
  CTelnetClient get _client => _clientRef!;
  CTelnetClient? _clientRef;
  final ScrollController scrollController = ScrollController();
  final TextEditingController input = TextEditingController();
  final FocusNode inputFocus = FocusNode();
  bool isCompressed = false;
  final ZLibDecoder decoder = ZLibDecoder();
  final incomingMsgSplitPattern = RegExp("($cr$lf)|($lf$cr)|$cr|$lf");
  final ZLibCodec _decoder = ZLibCodec();
  final StreamController<List<int>> _rawStreamController = StreamController();
  late Stream<List<int>> _decodedStream;
  late StreamSubscription<List<int>> _decodedSub;
  late final List<MUDProfile> profiles = [];
  MUDProfile? _currentProfile;
  bool _clientReady = false;
  final storage = ProfileStorage('');

  String get commandSeparator => currentProfile.settings.commandSeparator;

  /// accepts csp but NOT double csp
  RegExp get outgoingMsgSplitPattern =>
      RegExp("(?<!$commandSeparator)$commandSeparator(?!$commandSeparator)");

  MUDProfile get currentProfile => _currentProfile!;

  get connected => _clientReady && _client.connected;

  Future<GameStore> init() async {
    debugPrint('GameStore.init');
    await storage.init();
    debugPrint('storage.init $storage');
    fillStockProfiles();
    return this;
  }

  void showConnectionDialog(BuildContext context) async {
    final profile = await showDialog<MUDProfile?>(
      context: context,
      builder: (context) => const SelectProfilePage(),
    );
    if (profile == null) {
      return;
    }
    _currentProfile?.removeListener(onProfileUpdate);
    _currentProfile = profile;
    currentProfile.addListener(onProfileUpdate);

    await _clientRef?.disconnect();

    _clientRef = CTelnetClient(
      host: currentProfile.host,
      port: currentProfile.port,
      onConnect: _onConnect,
      onDisconnect: onDisconnect,
      onData: onData,
      onError: onError,
    );
    await currentProfile.load();
    echoSystem('Connecting...');
    _client.connect();
    notifyListeners();
  }

  bool processTriggers(String line) {
    bool showLine = true;
    final str = ColorUtils.stripColor(line);
    for (final trigger in currentProfile.triggers) {
      if (!trigger.isAvailable) {
        continue;
      }
      if (trigger.matches(str)) {
        trigger.invokeEffect(this, str);
        if (trigger.isRemovedFromBuffer) {
          showLine = false;
        }
        if (trigger.autoDisable) {
          trigger.tempDisabled = true;
        }
      }
    }
    return showLine;
  }

  bool processAliases(String line) {
    bool sendLine = true;
    final str = line;
    for (final alias in [...builtInAliases, ...currentProfile.aliases]) {
      if (!alias.isAvailable) {
        continue;
      }
      if (alias.matches(str)) {
        alias.invokeEffect(this, str);
        sendLine = false;
      }
      if (alias.autoDisable) {
        alias.tempDisabled = true;
      }
    }
    return sendLine;
  }

  Future<void> _onConnect() async {
    _clientReady = true;
    echoSystem('Connected');
    if (currentProfile.authMethod != AuthMethod.none &&
        currentProfile.username.isNotEmpty &&
        currentProfile.password.isNotEmpty) {
      debugPrint('Sending username and password');
      if (currentProfile.authMethod == AuthMethod.diku) {
        await Future.delayed(const Duration(milliseconds: 100));
        send(currentProfile.username);
        await Future.delayed(const Duration(milliseconds: 100));
        send(currentProfile.password);
      }
    }
  }

  void requestMCCP() {
    debugPrint('requestMCCP');
    _client.doo(86);
    sendBytes([Symbols.iac, Symbols.doo, 86]);
  }

  Future<void> disconnect() {
    return _client.disconnect();
  }

  void onDisconnect() {
    echoSystem('Disconnected');
  }

  void onRawData(List<int> bytes) {
    try {
      final data = Message(bytes);
      handleMCCPHandshake(data);
      for (final line in data.text.split(incomingMsgSplitPattern)) {
        onLine(line);
      }
    } catch (e, stack) {
      debugPrint('error: $e$newline$stack');
      echoError('Error: $e');
      echoError('The original line was:');
      echoError(String.fromCharCodes(bytes));
    }
  }

  void onData(Message data) {
    try {
      if (currentProfile.mccpEnabled && isCompressed) {
        _rawStreamController.add(data.bytes);
        return;
      }
      if (currentProfile.mccpEnabled) {
        handleMCCPHandshake(data);
      }

      for (final line in data.text.split(incomingMsgSplitPattern)) {
        onLine(line);
      }
    } catch (e, stack) {
      debugPrint('error: $e$newline$stack');
      echo(data.text);
      echo('Error: $e');
    }
  }

  void handleMCCPHandshake(Message data) {
    if (isCompressed) {
      if (data.se()) {
        disableMCCP();
      }
    } else {
      if (data.sb(86)) {
        enableMCCP();
      }
      if (data.will(86)) {
        requestMCCP();
        echo('Compression requested');
      }
    }
  }

  void disableMCCP() {
    echo('Compression disabled');
    isCompressed = false;
    _decodedSub.cancel();
  }

  void enableMCCP() {
    isCompressed = true;
    _decodedStream = _decoder.decoder.bind(_rawStreamController.stream);
    _decodedSub = _decodedStream.listen(onRawData);
    echo('Compression enabled');
  }

  void onError(Object error) {
    echo('Error: $error');
  }

  void onLine(String line) {
    final showLine = processTriggers(line);
    if (showLine) {
      echo(line);
    }
  }

  List<String> get lines =>
      _lines.sublist(max(0, _lines.length - maxLines), _lines.length);

  /// echo - echo to screen, DOES NOT split by msgSplitPattern, is not send to server
  void echo(String line) {
    if (currentProfile.settings.showTimestamps) {
      line = '[${DateTime.now().toIso8601String()}] $line';
    }
    _lines.add(line);
    notifyListeners();
    scrollToEnd();
  }

  /// echoOwn - same as echo, but with predefined color
  void echoOwn(String line) {
    echo('$esc[93m$line');
  }

  /// echoSystem - same as echo, but with predefined color
  void echoSystem(String line) {
    echo('$esc[96m$line');
  }

  /// echoError - same as echo, but with predefined color
  void echoError(String line) {
    echo('$esc[31;1m$line');
  }

  /// sendBytes - raw send bytes - DOES NOT split by outgoingMsgSplitPattern, no processing
  void sendBytes(List<int> bytes) {
    var output = bytes;
    _client.sendBytes(output);
  }

  /// sendString - send string - DOES NOT split by outgoingMsgSplitPattern, no processing
  void sendString(String line) {
    debugPrint('sending string: $line');
    _client.send(line + newline);
  }

  /// send - raw send string - no processing, DOES split by outgoingMsgSplitPattern
  void send(String text) {
    for (var line in _splitCsp(text)) {
      if (isCompressed) {
        debugPrint(
            'sending bytes${isCompressed ? ' (compressed)' : ''}: $line');
        sendBytes(line.codeUnits + newline.codeUnits);
      } else {
        debugPrint('sending string: $line');
        sendString(line);
      }
    }
  }

  /// execute - process aliases and triggers, then send, also split by outgoingMsgSplitPattern
  void execute(String text) {
    for (var line in _splitCsp(text)) {
      line = MUDAction.doVariableReplacements(this, line);
      debugPrint('processing aliases for: $line');
      var sendLine = processAliases(line);
      if (sendLine) {
        sendString(line);
      }
    }
  }

  List<String> _splitCsp(String line) {
    return line
        .split(outgoingMsgSplitPattern)
        .map((l) => l.replaceAll(
            '$commandSeparator$commandSeparator', commandSeparator))
        .toList();
  }

  /// submitInput - echo input, process aliases and triggers, then send, scroll to end, select input
  void submitInput(String text) {
    if (!_clientReady || !_client.connected) {
      return;
    }
    if (currentProfile.settings.echoCommands) {
      echoOwn(text);
    }
    execute(text);
    scrollToEnd();
    selectInput();
  }

  void scrollToEnd() {
    Future.delayed(const Duration(milliseconds: 50), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 50),
        curve: Curves.easeIn,
      );
    });
  }

  void unselectInput() {
    input.selection = const TextSelection.collapsed(offset: -1);
  }

  void selectInput() {
    // if (inputFocus.hasFocus || inputFocus.hasPrimaryFocus) {
    //   return;
    // }
    input.selection = TextSelection(
      baseOffset: 0,
      extentOffset: input.text.length,
    );
    inputFocus.previousFocus();
    inputFocus.requestFocus();
  }

  void setInput(String content) {
    input.text = content;
    selectInput();
  }

  void setInputSelection(int start, int end) {
    if (start < 0) {
      start = input.text.length + start + 1;
    }
    if (end < 0) {
      end = input.text.length + end + 1;
    }
    input.selection = TextSelection(
      baseOffset: start,
      extentOffset: end,
    );
  }

  static consumer({
    Widget? child,
    required Widget Function(
            BuildContext context, GameStore value, Widget? child)
        builder,
  }) {
    return Consumer<GameStore>(
      builder: builder,
      child: child,
    );
  }

  static provider({
    Widget? child,
    Widget Function(BuildContext context, Widget? child)? builder,
  }) {
    return ChangeNotifierProvider<GameStore>.value(
      value: gameStore,
      builder: builder,
      child: child,
    );
  }

  void loadProfiles() async {
    final list = await storage.readDirectory('.');
    profiles.clear();
    debugPrint('loading profiles: $list');
    for (final name in list) {
      final profile = await storage.readFile(name);
      profiles.add(MUDProfile.fromJson(profile!));
    }
    if (_currentProfile != null) {
      _currentProfile = profiles.firstWhere((e) => e.id == currentProfile.id);
    }
    notifyListeners();
  }

  void fillStockProfiles() async {
    final list = await storage.readDirectory('.');
    debugPrint('existing profiles: $list');
    if (list.isEmpty) {
      debugPrint('filling stock profiles');
      for (final profile in profilePresets) {
        await profile.save();
        profiles.add(profile);
      }
    } else {
      debugPrint('loading profiles: $list');
      for (final name in list) {
        final profile = await storage.readFile('$name/$name');
        if (profile == null) {
          continue;
        }
        debugPrint('profile: $profile');
        profiles.add(MUDProfile.fromJson(profile));
      }
    }
    debugPrint('profiles: ${profiles.map((e) => [e.name, e.password])}');
    notifyListeners();
  }

  void onShortcut(NumpadKey key, BuildContext context) {
    final action = currentProfile.keyboardShortcuts.get(key);
    if (action.isNotEmpty) {
      submitInput(action);
      selectInput();
    }
  }

  void echoSettingsChanged(Settings old, Settings updated) {
    echoSystem('Settings updated:');
    var updateCount = 0;
    if (updated.showTimestamps != old.showTimestamps) {
      updateCount++;
      echoSystem(
          'Timestamps are now ${updated.showTimestamps ? 'enabled' : 'disabled'}');
    }
    if (updated.echoCommands != old.echoCommands) {
      updateCount++;
      echoSystem(
          'Echoing own commands is now ${updated.echoCommands ? 'enabled' : 'disabled'}');
    }
    if (updated.commandSeparator != old.commandSeparator) {
      updateCount++;
      echoSystem(
        'Command separator is now "${updated.commandSeparator}". '
        'To escape when sending, use it twice like so: '
        '"${updated.commandSeparator}${updated.commandSeparator}"',
      );
    }
    if (updateCount == 0) {
      echoSystem('<no changes>');
    }
    echoSystem('');
  }

  void onProfileUpdate() {
    notifyListeners();
  }
}

mixin GameStoreMixin {
  GameStore storeOf(BuildContext context) =>
      Provider.of<GameStore>(context, listen: false);
}

mixin GameStoreStateMixin<T extends StatefulWidget> on State<T> {
  GameStore get store => Provider.of<GameStore>(context, listen: false);
}

final gameStore = GameStore();


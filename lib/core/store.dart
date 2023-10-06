import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:ctelnet/ctelnet.dart';
import 'package:flutter/material.dart';
import 'package:mudblock/core/profile_presets.dart';
import 'package:mudblock/core/storage.dart';
import 'package:mudblock/pages/select_profile_page.dart';
import 'package:provider/provider.dart';

import 'color_utils.dart';
import 'consts.dart';
import 'features/alias.dart';
import 'features/game_button_set.dart';
import 'features/profile.dart';
import 'features/trigger.dart';
import 'features/variable.dart';

const maxLines = 2000;

class GameStore extends ChangeNotifier {
  final List<String> _lines = [];
  late CTelnetClient _client;
  final ScrollController scrollController = ScrollController();
  final TextEditingController input = TextEditingController();
  final FocusNode inputFocus = FocusNode();
  bool isCompressed = false;
  final ZLibDecoder decoder = ZLibDecoder();
  final msgSplitPattern = RegExp("($cr$lf)|($lf$cr)|$cr|$lf");
  // accepts csp but NOT double csp
  final outgoingMsgSplitPattern = RegExp("(?<!$csp)$csp(?!$csp)");
  final ZLibCodec _decoder = ZLibCodec();
  final StreamController<List<int>> _rawStreamController = StreamController();
  late Stream<List<int>> _decodedStream;
  late StreamSubscription<List<int>> _decodedSub;
  late final List<MUDProfile> profiles = [];
  MUDProfile? _currentProfile;
  bool _clientReady = false;

  // TODO move to settings
  /// command separator
  static const csp = ";";

  // features
  // TODO - move to MUDProfile and make that reactive
  final List<Trigger> triggers = [];
  final List<Alias> aliases = [];
  final Map<String, Variable> variables = {};
  final List<GameButtonSetData> buttonSets = [];

  MUDProfile get currentProfile => _currentProfile!;

  get connected => _clientReady && _client.connected;

  Future<GameStore> init() async {
    debugPrint('GameStore.init');
    fillStockProfiles();
    return this;
  }

  void connect(BuildContext context) async {
    final profile = await showDialog<MUDProfile?>(
        context: context,
        builder: (context) {
          return const SelectProfilePage();
        });
    if (profile == null) {
      return;
    }
    _currentProfile = profile;
    echo('Connecting...');
    _client = CTelnetClient(
      host: currentProfile.host,
      port: currentProfile.port,
      onConnect: _onConnect,
      onDisconnect: onDisconnect,
      onData: onData,
      onError: onError,
    );
    await Future.wait([
      loadTriggers(),
      loadAliases(),
      loadVariables(),
      loadButtonSets(),
    ]);
    _client.connect();
  }

  Future<void> loadTriggers() async {
    debugPrint('loadTriggers');
    final list = await currentProfile.loadTriggers();
    triggers.clear();
    triggers.addAll(list);
    notifyListeners();
    debugPrint('Triggers: ${triggers.length}');
  }

  Future<void> loadAliases() async {
    final list = await currentProfile.loadAliases();
    aliases.clear();
    aliases.addAll(list);
    aliases.addAll(builtInAliases);
    notifyListeners();
    debugPrint('Aliases: ${aliases.length}');
  }

  Future<void> loadVariables() async {
    final list = await currentProfile.loadVariables();
    variables.clear();
    variables.addAll(Map.fromEntries(list.map((e) => MapEntry(e.name, e))));
    notifyListeners();
    debugPrint('Variables: ${variables.length}');
  }

  Future<void> loadButtonSets() async {
    final list = await currentProfile.loadButtonSets();
    buttonSets.clear();
    buttonSets.addAll(list);
    notifyListeners();
    debugPrint('ButtonSets: ${buttonSets.length}');
  }

  bool processTriggers(String line) {
    bool showLine = true;
    final str = ColorUtils.stripColor(line);
    for (final trigger in triggers) {
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
    for (final alias in aliases) {
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
    echo('Connected');
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
    echo('Disconnected');
  }

  void onRawData(List<int> bytes) {
    try {
      final data = Message(bytes);
      handleMCCPHandshake(data);
      for (final line in data.text.split(msgSplitPattern)) {
        onLine(line);
      }
    } catch (e, stack) {
      debugPrint('error: $e$newline$stack');
      echo(String.fromCharCodes(bytes));
      echo('Error: $e');
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

      for (final line in data.text.split(msgSplitPattern)) {
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
    _lines.add(line);
    notifyListeners();
    scrollToEnd();
  }

  /// echoOwn - same as echo, but with predefined color
  void echoOwn(String line) {
    _lines.add('$esc[93m$line');
    notifyListeners();
    scrollToEnd();
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
        .map((l) => l.replaceAll('$csp$csp', csp))
        .toList();
  }

  /// submitInput - echo input, process aliases and triggers, then send, scroll to end, select input
  void submitInput(String text) {
    if (!_clientReady || !_client.connected) {
      return;
    }
    echoOwn(text);
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
    final list = await ProfileStorage.listAllProfiles();
    profiles.clear();
    debugPrint('loading profiles: $list');
    for (final name in list) {
      final profile = await ProfileStorage.readProfileFile(name, name);
      profiles.add(MUDProfile.fromJson(profile!));
    }
    if (_currentProfile != null) {
      _currentProfile = profiles.firstWhere((e) => e.id == currentProfile.id);
    }
    notifyListeners();
  }

  void fillStockProfiles() async {
    final list = await ProfileStorage.listAllProfiles();
    debugPrint('existing profiles: $list');
    if (list.isEmpty) {
      debugPrint('filling stock profiles');
      for (final profile in profilePresets) {
        await MUDProfile.save(profile);
        profiles.add(profile);
      }
    } else {
      debugPrint('loading profiles: $list');
      for (final name in list) {
        final profile = await ProfileStorage.readProfileFile(name, name);
        debugPrint('profile: $profile');
        profiles.add(MUDProfile.fromJson(profile!));
      }
    }
    debugPrint('profiles: ${profiles.map((e) => [e.name, e.password])}');
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


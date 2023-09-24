import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:ctelnet/ctelnet.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../pages/home_page.dart';
import 'color_utils.dart';
import 'consts.dart';
import 'features/action.dart';
import 'features/profile.dart';
import 'features/trigger.dart';

const maxLines = 2000;

class GameStore extends ChangeNotifier {
  bool mccpEnabled = false;
  final List<String> _lines = [];
  late final CTelnetClient _client;
  late final ScrollController scrollController;
  final TextEditingController input = TextEditingController();
  final FocusNode inputFocus = FocusNode();
  bool isCompressed = false;
  final ZLibDecoder decoder = ZLibDecoder();
  final List<Trigger> triggers = [];
  final List<Trigger> aliases = [];
  HomePageState get home => homeKey.currentState as HomePageState;

  MUDProfile? _currentProfile;
  MUDProfile get currentProfile => _currentProfile!;

  GameStore init() {
    debugPrint('GameStore.init');
    addLine('Connecting...');
    final profiles = [
      MUDProfile(id: 'local', name: 'Local', host: 'localhost', port: 4000),
      MUDProfile(id: 'smud', name: 'SimpleMUD', host: 'smud.ourmmo.com', port: 3000),
      MUDProfile(id: 'aardwolf', name: 'Aardwolf', host: 'aardmud.org', port: 23),
      MUDProfile(id: 'batmud', name: 'BatMUD', host: 'batmud.bat.org', port: 23),
      MUDProfile(id: 'dune', name: 'Dune', host: 'dune.servint.com', port: 6789),
    ];
    _currentProfile = profiles[1];
    _client = CTelnetClient(
      host: currentProfile.host,
      port: currentProfile.port,
      onConnect: _onConnect,
      onDisconnect: onDisconnect,
      onData: onData,
      onError: onError,
    );
    scrollController = ScrollController();
    loadTriggers();
    loadAliases();
    _client.connect();
    return this;
  }

  void loadTriggers() {
    triggers.clear();
    triggers.addAll(
      [
        Trigger(
          id: 'test',
          pattern: r'^You are in the ([^.]+)\. This is the ([^.]+)\.',
          action: const MUDAction('Hello, %1, the %2!', sendTo: MUDActionTarget.world),
          isRegex: true,
        ),
        Trigger(
          id: 'test2',
          pattern: r'^exits: ([\w\s]+)',
          action: const MUDAction('I see exits: %1', sendTo: MUDActionTarget.world),
          isRegex: true,
        ),
      ],
    );
    debugPrint('triggers: ${triggers.length}');
  }

  void loadAliases() {
    aliases.clear();
    aliases.addAll(
      [
        Trigger(
          id: 'hello',
          pattern: r'^hello|^hi',
          action: const MUDAction('Hello, world!', sendTo: MUDActionTarget.world),
          isRegex: true,
        ),
      ],
    );
    debugPrint('aliases: ${aliases.length}');
  }

  bool processTriggers(BuildContext context, String line) {
    bool showLine = true;
    final str = ColorUtils.stripColor(line);
    debugPrint('Processing triggers for: $str');
    for (final trigger in triggers) {
      if (!trigger.enabled) {
        continue;
      }
      debugPrint('trigger: ${trigger.pattern}');
      if (trigger.matches(str)) {
        debugPrint('trigger matches: ${trigger.pattern}');
        trigger.invokeEffect(context, str);
        if (trigger.isRemovedFromBuffer) {
          debugPrint('line is removed from buffer');
          showLine = false;
        }
      }
    }
    debugPrint('');
    return showLine;
  }

  bool processAliases(BuildContext context, String line) {
    bool sendLine = true;
    final str = line;
    debugPrint('Processing aliases for: $str');
    for (final alias in aliases) {
      if (!alias.enabled) {
        continue;
      }
      debugPrint('alias: ${alias.pattern}');
      if (alias.matches(str)) {
        debugPrint('alias matches: ${alias.pattern}');
        alias.invokeEffect(context, str);
        debugPrint('line is removed from buffer');
        sendLine = false;
      }
    }
    debugPrint('');
    return sendLine;
  }

  void _onConnect() {
    addLine('Connected');
  }

  void requestMCCP() {
    debugPrint('requestMCCP');
    _client.doo(86);
    sendBytes([Symbols.iac, Symbols.doo, 86]);
  }

  void onDisconnect() {
    addLine('Disconnected');
  }

  void onData(Message data) {
    try {
      debugPrint('text: ${data.text}');
      debugPrint('commands: ${data.commands}');

      if (mccpEnabled && isCompressed) {
        data = decompressData(data);
      }
      if (mccpEnabled) {
        handleMCCPHandshake(data);
      }

      final pattern = RegExp("($cr$lf)|($lf$cr)|$cr|$lf");
      for (final line in data.text.trimRight().split(pattern)) {
        onLine(home.context, line);
      }
    } catch (e, stack) {
      debugPrint('error: $e$newline$stack');
      addLine(data.text);
      addLine('Error: $e');
    }
  }

  final Converter<List<int>, List<int>> _decoder = ZLibDecoder();

  Message decompressData(Message data) {
    var bytes = data.bytes;
    // bytes = utf8.decode(bytes).codeUnits;
    bytes = bytes;
    bytes = base64.decode(bytes.toString());
    // String.from
    debugPrint('attempting to decompress');
    debugPrint('data: $bytes');
    debugPrint('string: ${String.fromCharCodes(bytes)}');
    return Message(_decoder.convert(bytes));
  }

  void handleMCCPHandshake(Message data) {
    if (isCompressed) {
      if (data.se()) {
        addLine('Compression disabled');
        isCompressed = false;
      }
    } else {
      if (data.sb(86)) {
        isCompressed = true;
        addLine('Compression enabled');
      }
      if (data.will(86)) {
        requestMCCP();
        addLine('Compression requested');
      }
    }
  }

  void onError(Object error) {
    onError('Error: $error');
  }

  void onLine(BuildContext context, String line) {
    var showLine = processTriggers(context, line);
    if (showLine) {
      addLine(line);
    }
  }

  List<String> get lines => _lines.sublist(max(0, _lines.length - maxLines), _lines.length);

  void addLine(String line) {
    _lines.add(line);
    notifyListeners();
    scrollToEnd();
  }

  void echo(String line) => addLine(line);

  void sendBytes(List<int> bytes) {
    var output = bytes;
    _client.sendBytes(output);
  }

  void sendString(String line) {
    _client.send(line + newline);
  }

  void send(String line) {
    if (isCompressed) {
      debugPrint('sending bytes${isCompressed ? ' (compressed)' : ''}: $line');
      sendBytes(line.codeUnits + newline.codeUnits);
    } else {
      debugPrint('sending string: $line');
      sendString(line);
    }
  }

  void execute(String line) {
    debugPrint('processing aliases for: $line');
    var sendLine = processAliases(home.context, line);
    if (sendLine) {
      sendString(line);
    }
  }

  void submitInput(String text) {
    addLine(text);
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
}

mixin GameStoreMixin<T extends StatefulWidget> on State<T> {
  GameStore get store => Provider.of<GameStore>(context, listen: false);
}


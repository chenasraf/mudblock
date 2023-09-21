import 'dart:math';

import 'package:ctelnet/ctelnet.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'consts.dart';

const maxLines = 2000;

class GameStore extends ChangeNotifier {
  final List<String> _lines = [];
  late final CTelnetClient _client;
  late final ScrollController scrollController;

  GameStore init() {
    addLine('Connecting...');
    _client = CTelnetClient(
      host: 'smud.ourmmo.com',
      port: 3000,
      onConnect: _onConnect,
      onDisconnect: onDisconnect,
      onData: onData,
      onError: onError,
    );
    scrollController = ScrollController();
    _client.connect();
    return this;
  }

  void _onConnect() {
    addLine('Connected');
  }

  void onDisconnect() {
    addLine('Disconnected');
  }

  void onData(String data) {
    debugPrint('onData: $data');
    // final pattern = RegExp("$newline|$ansiEscapePattern");
    // ignore: unnecessary_string_interpolations
    final pattern = RegExp("$newline");
    for (final line in data.split(pattern)) {
      onLine(line);
    }
  }

  void onError(Object error) {
    onData('Error: $error');
  }

  void onLine(String line) {
    addLine(line);
  }

  List<String> get lines => _lines.sublist(max(0, _lines.length - maxLines), _lines.length);

  void addLine(String line) {
    _lines.add(line);
    notifyListeners();
  }

  void send(String line) {
    debugPrint('send: $line');
    _client.send(line + newline);
  }

  void submitInput(String text) {
    addLine(text);
    send(text);
    scrollController.animateTo(
      scrollController.offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

mixin GameStoreMixin<T extends StatefulWidget> on State<T> {
  GameStore get store => Provider.of<GameStore>(context, listen: false);
}


import 'dart:math';

import 'package:ctelnet/ctelnet.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'color_utils.dart';
import 'consts.dart';

const maxLines = 2000;

class GameStore extends ChangeNotifier {
  final List<String> _lines = [];
  late final CTelnetClient _client;
  late final ScrollController scrollController;
  final TextEditingController input = TextEditingController();
  final FocusNode inputFocus = FocusNode();

  GameStore init() {
    addLine('Connecting...');
    _client = CTelnetClient(
      // host: 'aardmud.org',
      // port: 23,
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

  void onData(Message data) {
    debugPrint('onData:   $data');
    debugPrint('stripped: ${ColorUtils.stripColor(data.toString())}');
    // final pattern = RegExp("$newline|$ansiEscapePattern");
    // ignore: unnecessary_string_interpolations
    final pattern = RegExp("($cr$lf)|($lf$cr)|$cr|$lf");
    for (final line in data.text.split(pattern)) {
      onLine(line);
    }
  }

  void onError(Object error) {
    onError('Error: $error');
  }

  void onLine(String line) {
    debugPrint('onLine:   $line');
    addLine(line);
  }

  List<String> get lines => _lines.sublist(max(0, _lines.length - maxLines), _lines.length);

  void addLine(String line) {
    _lines.add(line);
    notifyListeners();
    scrollToEnd();
  }

  void echo(String line) => addLine(line);

  void send(String line) {
    debugPrint('send: $line');
    _client.send(line + newline);
  }

  void submitInput(String text) {
    addLine(text);
    send(text);
    scrollToEnd();
    selectInput();
  }

  void scrollToEnd() {
    Future.delayed(const Duration(milliseconds: 10), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 50),
        curve: Curves.easeIn,
      );
    });
  }

  void selectInput() {
    input.selection = TextSelection(
      baseOffset: 0,
      extentOffset: input.text.length,
    );
    inputFocus.requestFocus();
  }
}

mixin GameStoreMixin<T extends StatefulWidget> on State<T> {
  GameStore get store => Provider.of<GameStore>(context, listen: false);
}


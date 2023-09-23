import 'dart:math';
import 'dart:io';

import 'package:ctelnet/ctelnet.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'consts.dart';

const maxLines = 2000;

class GameStore extends ChangeNotifier {
  final List<String> _lines = [];
  late final CTelnetClient _client;
  late final ScrollController scrollController;
  final TextEditingController input = TextEditingController();
  final FocusNode inputFocus = FocusNode();
  bool awaitingCompression = false;
  bool isCompressed = false;

  GameStore init() {
    addLine('Connecting...');
    _client = CTelnetClient(
      host: 'aardmud.org',
      port: 23,
      // host: 'smud.ourmmo.com',
      // port: 3000,
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
    // TODO this should wait for the IAC DO MCCP response from server before attempting request
    // requestMCCP();
  }

  void requestMCCP() {
    debugPrint('requestMCCP');
    sendBytes([Symbols.iac, Symbols.doo, 86]);
    awaitingCompression = true;
  }

  void onDisconnect() {
    addLine('Disconnected');
  }

  void onData(Message data) {
    debugPrint('text: ${data.text}');
    debugPrint('subnegotiations: ${data.data.subnegotiations}');

    if (isCompressed) {
      data = Message(ZLibDecoder().convert(data.bytes));
    }

    if (awaitingCompression) {
      var subs = data.data.subnegotiations.indexWhere((element) => element.length == 2 && element[0] == Symbols.sb);
      if (subs != -1) {
        awaitingCompression = false;
        isCompressed = true;
        addLine('Compression enabled');
      }
    } else {
      var subs = data.data.subnegotiations
          .indexWhere((element) => element.length == 2 && element[0] == Symbols.will && element[1] == 86);
      if (subs != -1) {
        requestMCCP();
        addLine('Compression requested');
      }
    }

    final pattern = RegExp("($cr$lf)|($lf$cr)|$cr|$lf");
    for (final line in data.text.trimRight().split(pattern)) {
      onLine(line);
    }
  }

  void onError(Object error) {
    onError('Error: $error');
  }

  void onLine(String line) {
    addLine(line);
  }

  List<String> get lines => _lines.sublist(max(0, _lines.length - maxLines), _lines.length);

  void addLine(String line) {
    _lines.add(line);
    notifyListeners();
    scrollToEnd();
  }

  void echo(String line) => addLine(line);

  void sendBytes(List<int> bytes) {
    // var output = isCompressed ? ZLibEncoder().convert([Symbols.iac, Symbols.sb] + bytes) : bytes;
    var output = bytes;
    _client.sendBytes(output);
  }

  void send(String line) {
    if (isCompressed) {
      debugPrint('sending bytes${isCompressed ? ' (compressed)' : ''}: $line');
      sendBytes(line.codeUnits + newline.codeUnits);
    } else {
      debugPrint('sending string: $line');
      _client.send(line + newline);
    }
  }

  void submitInput(String text) {
    addLine(text);
    send(text);
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


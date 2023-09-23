import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'dart:typed_data';

import 'package:ctelnet/ctelnet.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'consts.dart';

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

  void requestMCCP() {
    debugPrint('requestMCCP');
    sendBytes([Symbols.iac, Symbols.doo, 86]);
  }

  void onDisconnect() {
    addLine('Disconnected');
  }

  void onData(Message data) {
    try {
      debugPrint('text: ${data.text}');
      debugPrint('subnegotiations: ${data.data.subnegotiations}');

      if (mccpEnabled && isCompressed) {
        data = decompressData(data);
      }
      if (mccpEnabled) {
        handleMCCPHandshake(data);
      }

      final pattern = RegExp("($cr$lf)|($lf$cr)|$cr|$lf");
      for (final line in data.text.trimRight().split(pattern)) {
        onLine(line);
      }
    } catch (e, stack) {
      debugPrint('error: $e$newline$stack');
      addLine(data.text);
      addLine('Error: $e');
    }
  }

  final Converter<List<int>, List<int>> _decoder = ZLibDecoder();

  Message decompressData(Message data) {
    var bytes = data.data.bytes;
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
      var seMccpIdx =
          data.data.subnegotiations.indexWhere((element) => element.length == 2 && element[0] == Symbols.se);
      if (seMccpIdx != -1) {
        addLine('Compression disabled');
        isCompressed = false;
      }
    } else {
      var sbMccpIdx = data.data.subnegotiations
          .indexWhere((element) => element.length == 2 && element[0] == Symbols.sb && element[1] == 86);
      if (sbMccpIdx != -1) {
        isCompressed = true;
        addLine('Compression enabled');
      }
      var willMccpIdx = data.data.subnegotiations
          .indexWhere((element) => element.length == 2 && element[0] == Symbols.will && element[1] == 86);
      if (willMccpIdx != -1) {
        requestMCCP();
        addLine('Compression requested');
      }
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
    inputFocus.previousFocus();
    inputFocus.requestFocus();
  }
}

mixin GameStoreMixin<T extends StatefulWidget> on State<T> {
  GameStore get store => Provider.of<GameStore>(context, listen: false);
}


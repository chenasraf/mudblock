import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../store.dart';

enum MUDActionTarget {
  world,
  execute,
  script,
  input,
}

class MUDAction {
  final String content;
  final MUDActionTarget sendTo;
  const MUDAction(this.content, {this.sendTo = MUDActionTarget.world});

  void invoke(BuildContext context, List<String> matches) {
    final store = Provider.of<GameStore>(context, listen: false);
    debugPrint('MUDAction.invoke: ${this.content}, $matches');
    var content = this.content;
    for (var i = 0; i < matches.length; i++) {
      content = content.replaceAll('%$i', matches[i]);
    }
    debugPrint('MUDAction.invoking: $content');

    switch (sendTo) {
      case MUDActionTarget.world:
        debugPrint('ActionSendTo.world: $content');
        store.send(content);
        break;
      case MUDActionTarget.execute:
        debugPrint('ActionSendTo.execute: $content');
        break;
      case MUDActionTarget.script:
        debugPrint('ActionSendTo.script: $content');
        break;
      case MUDActionTarget.input:
        debugPrint('ActionSendTo.input: $content');
        store.setInput(content);
        break;
    }
  }
}


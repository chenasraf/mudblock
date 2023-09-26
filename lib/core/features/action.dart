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
  String content;
  MUDActionTarget sendTo;
  MUDAction(this.content, {this.sendTo = MUDActionTarget.world});

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
        store.execute(content);
        break;
      case MUDActionTarget.script:
        debugPrint('ActionSendTo.script: $content');
        // TODO lua support
        break;
      case MUDActionTarget.input:
        debugPrint('ActionSendTo.input: $content');
        store.input.text = content;
        store.setInput(content);
        break;
    }
  }

  factory MUDAction.empty() => MUDAction('');

  factory MUDAction.fromJson(Map<String, dynamic> json) => MUDAction(
        json['content'],
        sendTo: MUDActionTarget.values[json['sendTo']],
      );

  Map<String, dynamic> toJson() => {
        'content': content,
        'sendTo': sendTo.index,
      };
}


import 'package:flutter/widgets.dart';
import 'package:mudblock/core/features/lua.dart';

import '../consts.dart';
import '../store.dart';

enum MUDActionTarget {
  world,
  execute,
  script,
  input,
}

class MUDAction {
  String content;
  MUDActionTarget target;
  MUDAction(this.content, {this.target = MUDActionTarget.world});

  void invoke(GameStore store, List<String> matches) {
    debugPrint('MUDAction.invoke: ${this.content}, $matches');
    var content = this.content;
    for (var i = 0; i < matches.length; i++) {
      content = content.replaceAll('%$i', matches[i]);
    }
    content = _doSpecialReplacements(store, content);
    debugPrint('MUDAction.invoking: $content');

    switch (target) {
      case MUDActionTarget.world:
        debugPrint('ActionSendTo.world: $content');
        store.send(content);
        break;
      case MUDActionTarget.execute:
        debugPrint('ActionSendTo.execute: $content');
        store.execute(content);
        break;
      case MUDActionTarget.script:
        try {
          debugPrint('ActionSendTo.script: $content');
          final lua = LuaInterpreter(store);
          lua.loadString(content);
          lua.execute();
        } catch (e, stack) {
          debugPrint("Error interpreting lua:$e$lf$stack");
          store.onError(e);
        }
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
      // TODO generalize getting enum from string
        target: MUDActionTarget.values.firstWhere(
          (e) => e.name == json['target'],
          orElse: () => MUDActionTarget.world,
        ),
      );

  Map<String, dynamic> toJson() => {
        'content': content,
        'target': target.name,
      };

  String _doSpecialReplacements(GameStore store, String content) {
    debugPrint('MUDAction._doSpecialReplacements: $content');
    content = content
            .replaceAll('%PASSWORD', store.currentProfile.password)
            .replaceAll('%USERNAME', store.currentProfile.username)
        //
        ;
    for (final vari in store.variables) {
      content = content.replaceAll('%${vari.name}', vari.value);
    }
    return content;
  }
}


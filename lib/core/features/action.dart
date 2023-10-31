import 'package:flutter/widgets.dart';
import 'package:mudblock/core/features/lua.dart';

import '../consts.dart';
import '../store.dart';
import 'automation.dart';

enum MUDActionTarget {
  world,
  execute,
  script,
  input,
  output,
  immediate,
  none,
  variable,
}

class MUDAction {
  String content;
  Automation? parent;
  MUDActionTarget target;
  List<String> args;

  MUDAction(
    this.content, {
    this.target = MUDActionTarget.execute,
    this.parent,
    this.args = const [],
  });

  void invoke(GameStore store, List<String> matches) {
    debugPrint('MUDAction.invoke: ${this.content}, $matches');
    var content = this.content;
    for (var i = 0; i < matches.length; i++) {
      // escape %% in the pattern
      final pattern = RegExp('(?<!%)%$i');
      content = content.replaceAll(pattern, matches[i]);
    }
    content = doVariableReplacements(store, content);
    debugPrint('MUDAction.invoking: $content');

    switch (target) {
      case MUDActionTarget.world:
        debugPrint('ActionSendTo.world: $content');
        store.send(content);
        // if (parent == null || !parent!.isRemovedFromBuffer) {
        if (parent != null && !parent!.isRemovedFromBuffer) {
          store.echoOwn(content);
        }
        break;
      case MUDActionTarget.execute:
        debugPrint('ActionSendTo.execute: $content');
        store.execute(content);
        // if (parent == null || !parent!.isRemovedFromBuffer) {
        if (parent != null && !parent!.isRemovedFromBuffer) {
          store.echoOwn(content);
        }
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
      case MUDActionTarget.output:
        debugPrint('ActionSendTo.output: $content');
        store.echoOwn(content);
        break;
      case MUDActionTarget.immediate:
        debugPrint('ActionSendTo.immediate: $content');
        store.send(content);
        break;
      case MUDActionTarget.variable:
        debugPrint('ActionSendTo.variable: $content');
        store.saveVariable(args.single, content);
        break;
      case MUDActionTarget.none:
        debugPrint('ActionSendTo.none: $content');
        break;
    }
    debugPrint('MUDAction.invoke: done');
  }

  factory MUDAction.empty() => MUDAction('');

  factory MUDAction.fromJson(Map<String, dynamic> json) => MUDAction(
        json['content'],
        // TODO generalize getting enum from string
        target: MUDActionTarget.values.firstWhere(
          (e) => e.name == json['target'],
          orElse: () => MUDActionTarget.execute,
        ),
      );

  Map<String, dynamic> toJson() => {
        'content': content,
        'target': target.name,
      };

  static String doVariableReplacements(GameStore store, String content) {
    debugPrint('MUDAction._doSpecialReplacements: $content');
    if (!store.connected) {
      return content;
    }
    content = content
        .replaceAll('%PASSWORD', store.currentProfile.password)
        .replaceAll('%USERNAME', store.currentProfile.username);

    // variables from the store
    // TODO allow disabling this
    for (final vari in store.currentProfile.variables.values) {
      content = content.replaceAll('%${vari.name}', vari.value);
    }
    return content;
  }
}

class NativeMUDAction extends MUDAction {
  NativeMUDAction(this.customInvoke)
      : super('-- native code --', target: MUDActionTarget.script);

  factory NativeMUDAction.echoSystem(String content) =>
      NativeMUDAction((store, matches) {
        store.echoSystem(content);
      });
  factory NativeMUDAction.echo(String content) =>
      NativeMUDAction((store, matches) {
        store.echo(content);
      });
  factory NativeMUDAction.empty() => NativeMUDAction((store, matches) {
        // do nothing
      });

  final void Function(GameStore store, List<String> matches) customInvoke;

  @override
  void invoke(GameStore store, List<String> matches) {
    customInvoke(store, matches);
  }
}


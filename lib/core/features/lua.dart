import 'package:flutter/foundation.dart';
import 'package:lua_dardo/lua.dart';

import '../store.dart';
import 'variable.dart';

class LuaInterpreter {
  LuaState state = LuaState.newState();
  final GameStore store;

  LuaInterpreter(this.store) {
    state.openLibs();
    _loadMUDLibs();
  }

  void _loadMUDLibs() {
    final bindings = LuaBindings(store);
    state.pushDartFunction(bindings.send);
    state.setGlobal("Send");
    state.pushDartFunction(bindings.gsub);
    state.setGlobal("string.gsub");
    state.pushDartFunction(bindings.gsub);
    state.setGlobal("Replace");
    state.pushDartFunction(bindings.getVariable);
    state.setGlobal("GetVariable");
    state.pushDartFunction(bindings.setVariable);
    state.setGlobal("SetVariable");
    state.pushDartFunction(bindings.enableTrigger);
    state.setGlobal("EnableTrigger");
    state.pushDartFunction(bindings.disableTrigger);
    state.setGlobal("DisableTrigger");
    state.pushDartFunction(bindings.enableTriggerGroup);
    state.setGlobal("EnableTriggerGroup");
    state.pushDartFunction(bindings.disableTriggerGroup);
    state.setGlobal("DisableTriggerGroup");
    state.pushDartFunction(bindings.enableAlias);
    state.setGlobal("EnableAlias");
    state.pushDartFunction(bindings.disableAlias);
    state.setGlobal("DisableAlias");
    state.pushDartFunction(bindings.enableAliasGroup);
    state.setGlobal("EnableAliasGroup");
    state.pushDartFunction(bindings.disableAliasGroup);
    state.setGlobal("DisableAliasGroup");
    state.pushDartFunction(bindings.enableButtonSet);
    state.setGlobal("EnableButtonSet");
    state.pushDartFunction(bindings.disableButtonSet);
    state.setGlobal("DisableButtonSet");
    state.pushDartFunction(bindings.enableButtonGroup);
    state.setGlobal("EnableButtonGroup");
    state.pushDartFunction(bindings.disableButtonGroup);
    state.setGlobal("DisableButtonGroup");
  }

  void loadString(String string) {
    state.loadString(string);
  }

  void loadFile(String path) {
    state.doFile(path);
  }

  void execute() {
    state.call(0, 0);
  }
}

class LuaBindings {
  final GameStore store;

  LuaBindings(this.store);

  int send(LuaState ls) {
    final cmd = ls.checkString(1) ?? '';
    ls.pop(1);
    debugPrint("lua.Send $cmd");
    store.send(cmd);
    return 0;
  }

  int gsub(LuaState ls) {
    final source = ls.checkString(1)!;
    // ls.pop(1);
    final find = ls.checkString(2)!;
    // ls.pop(1);
    final replace = ls.checkString(3)!;
    // ls.pop(1);
    debugPrint("lua string.gsub $source, $find, $replace");

    ls.pushString(source.replaceAll(find, replace));
    return 1;
  }

  int getVariable(LuaState ls) {
    final name = ls.checkString(1)!;
    ls.pop(1);
    debugPrint("lua.getVariable $name");
    final vari = store.variables[name];
    if (vari != null) {
      ls.pushString(vari.value);
    } else {
      ls.pushNil();
    }
    return 1;
  }

  int setVariable(LuaState ls) {
    final name = ls.checkString(1)!;
    final value = ls.checkString(2)!;
    ls.pop(2);
    debugPrint("lua.setVariable $name, $value");
    if (store.variables[name] == null) {
      store.variables[name] = Variable(name, value);
    }
    store.variables[name]!.value = value;
    store.currentProfile
        .saveVariable(store.variables.values.toList(), store.variables[name]!);
    return 0;
  }

  int enableTrigger(LuaState ls) {
    final id = ls.checkString(1)!;
    ls.pop(1);
    debugPrint("lua.enableTrigger $id");
    store.triggers.firstWhere((trigger) => trigger.id == id).enabled = true;
    return 0;
  }

  int disableTrigger(LuaState ls) {
    final id = ls.checkString(1)!;
    ls.pop(1);
    debugPrint("lua.disableTrigger $id");
    store.triggers.firstWhere((trigger) => trigger.id == id).enabled = false;
    return 0;
  }

  int enableTriggerGroup(LuaState ls) {
    final id = ls.checkString(1)!;
    ls.pop(1);
    debugPrint("lua.enableTriggerGroup $id");
    store.triggers
        .where((trigger) => trigger.group == id)
        .forEach((trigger) => trigger.enabled = true);
    return 0;
  }

  int disableTriggerGroup(LuaState ls) {
    final id = ls.checkString(1)!;
    ls.pop(1);
    debugPrint("lua.disableTriggerGroup $id");
    store.triggers
        .where((trigger) => trigger.group == id)
        .forEach((trigger) => trigger.enabled = false);
    return 0;
  }

  int enableAlias(LuaState ls) {
    final id = ls.checkString(1)!;
    ls.pop(1);
    debugPrint("lua.enableAlias $id");
    store.aliases.firstWhere((alias) => alias.id == id).enabled = true;
    return 0;
  }

  int disableAlias(LuaState ls) {
    final id = ls.checkString(1)!;
    ls.pop(1);
    debugPrint("lua.disableAlias $id");
    store.aliases.firstWhere((alias) => alias.id == id).enabled = false;
    return 0;
  }

  int enableAliasGroup(LuaState ls) {
    final id = ls.checkString(1)!;
    ls.pop(1);
    debugPrint("lua.enableAliasGroup $id");
    store.aliases
        .where((alias) => alias.group == id)
        .forEach((alias) => alias.enabled = true);
    return 0;
  }

  int disableAliasGroup(LuaState ls) {
    final id = ls.checkString(1)!;
    ls.pop(1);
    debugPrint("lua.disableAliasGroup $id");
    store.aliases
        .where((alias) => alias.group == id)
        .forEach((alias) => alias.enabled = false);
    return 0;
  }

  // int enableTimer(LuaState ls) {
  //   final id = ls.checkString(1)!;
  //   ls.pop(1);
  //   debugPrint("lua.enableTimer $id");
  //   store.timers.firstWhere((timer) => timer.id == id).enabled = true;
  //   return 0;
  // }
  //
  // int disableTimer(LuaState ls) {
  //   final id = ls.checkString(1)!;
  //   ls.pop(1);
  //   debugPrint("lua.disableTimer $id");
  //   store.timers.firstWhere((timer) => timer.id == id).enabled = false;
  //   return 0;
  // }
  //
  // int enableTimerGroup(LuaState ls) {
  //   final id = ls.checkString(1)!;
  //   ls.pop(1);
  //   debugPrint("lua.enableTimerGroup $id");
  //   store.timers
  //       .where((timer) => timer.group == id)
  //       .forEach((timer) => timer.enabled = true);
  //   return 0;
  // }
  //
  // int disableTimerGroup(LuaState ls) {
  //   final id = ls.checkString(1)!;
  //   ls.pop(1);
  //   debugPrint("lua.disableTimerGroup $id");
  //   store.timers
  //       .where((timer) => timer.group == id)
  //       .forEach((timer) => timer.enabled = false);
  //   return 0;
  // }

  int enableButtonSet(LuaState ls) {
    final id = ls.checkString(1)!;
    ls.pop(1);
    debugPrint("lua.enableButtonSet $id");
    store.buttonSets.firstWhere((buttonSet) => buttonSet.id == id).enabled =
        true;
    return 0;
  }

  int disableButtonSet(LuaState ls) {
    final id = ls.checkString(1)!;
    ls.pop(1);
    debugPrint("lua.disableButtonSet $id");
    store.buttonSets.firstWhere((buttonSet) => buttonSet.id == id).enabled =
        false;
    return 0;
  }

  int enableButtonGroup(LuaState ls) {
    final id = ls.checkString(1)!;
    ls.pop(1);
    debugPrint("lua.enableButtonGroup $id");
    store.buttonSets
        .where((buttonSet) => buttonSet.group == id)
        .forEach((buttonSet) => buttonSet.enabled = true);
    return 0;
  }

  int disableButtonGroup(LuaState ls) {
    final id = ls.checkString(1)!;
    ls.pop(1);
    debugPrint("lua.disableButtonGroup $id");
    store.buttonSets
        .where((buttonSet) => buttonSet.group == id)
        .forEach((buttonSet) => buttonSet.enabled = false);
    return 0;
  }
}

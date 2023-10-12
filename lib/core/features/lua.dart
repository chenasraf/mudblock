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
    final trigger = store.triggers.firstWhere((trigger) => trigger.label == id);
    trigger.enabled = true;
    store.currentProfile.saveTrigger(trigger).then((_) => store.loadTriggers());
    return 0;
  }

  int disableTrigger(LuaState ls) {
    final id = ls.checkString(1)!;
    ls.pop(1);
    debugPrint("lua.disableTrigger $id");
    final trigger = store.triggers.firstWhere((trigger) => trigger.label == id);
    trigger.enabled = false;
    store.currentProfile.saveTrigger(trigger).then((_) => store.loadTriggers());
    return 0;
  }

  int enableTriggerGroup(LuaState ls) {
    final id = ls.checkString(1)!;
    ls.pop(1);
    debugPrint("lua.enableTriggerGroup $id");
    final triggers = store.triggers.where((trigger) => trigger.group == id);
    Future.wait(triggers.map((trigger) {
      trigger.enabled = true;
      return store.currentProfile.saveTrigger(trigger);
    })).then((_) => store.loadTriggers());
    return 0;
  }

  int disableTriggerGroup(LuaState ls) {
    final id = ls.checkString(1)!;
    ls.pop(1);
    debugPrint("lua.disableTriggerGroup $id");
    final triggers = store.triggers.where((trigger) => trigger.group == id);
    Future.wait(triggers.map((trigger) {
      trigger.enabled = false;
      return store.currentProfile.saveTrigger(trigger);
    })).then((_) => store.loadTriggers());
    return 0;
  }

  int enableAlias(LuaState ls) {
    final id = ls.checkString(1)!;
    ls.pop(1);
    debugPrint("lua.enableAlias $id");
    final alias = store.aliases.firstWhere((alias) => alias.label == id);
    alias.enabled = true;
    store.currentProfile.saveAlias(alias).then((_) => store.loadAliases());
    return 0;
  }

  int disableAlias(LuaState ls) {
    final id = ls.checkString(1)!;
    ls.pop(1);
    debugPrint("lua.disableAlias $id");
    final alias = store.aliases.firstWhere((alias) => alias.label == id);
    alias.enabled = false;
    store.currentProfile.saveAlias(alias).then((_) => store.loadAliases());
    return 0;
  }

  int enableAliasGroup(LuaState ls) {
    final id = ls.checkString(1)!;
    ls.pop(1);
    debugPrint("lua.enableAliasGroup $id");
    final aliases = store.aliases.where((alias) => alias.group == id);
    Future.wait(aliases.map((alias) {
      alias.enabled = true;
      return store.currentProfile.saveAlias(alias);
    })).then((_) => store.loadAliases());
    return 0;
  }

  int disableAliasGroup(LuaState ls) {
    final id = ls.checkString(1)!;
    ls.pop(1);
    debugPrint("lua.disableAliasGroup $id");
    final aliases = store.aliases.where((alias) => alias.group == id);
    Future.wait(aliases.map((alias) {
      alias.enabled = false;
      return store.currentProfile.saveAlias(alias);
    })).then((_) => store.loadAliases());
    return 0;
  }

  // int enableTimer(LuaState ls) {
  //   final id = ls.checkString(1)!;
  //   ls.pop(1);
  //   debugPrint("lua.enableTimer $id");
  //   final timer = store.timers.firstWhere((timer) => timer.label == id);
  //   timer.enabled = true;
  //   store.currentProfile.saveTimer(timer).then((_) => store.loadTimers());
  //   return 0;
  // }
  //
  // int disableTimer(LuaState ls) {
  //   final id = ls.checkString(1)!;
  //   ls.pop(1);
  //   debugPrint("lua.disableTimer $id");
  //   final timer = store.timers.firstWhere((timer) => timer.label == id);
  //   timer.enabled = false;
  //   store.currentProfile.saveTimer(timer).then((_) => store.loadTimers());
  //   return 0;
  // }
  //
  // int enableTimerGroup(LuaState ls) {
  //   final id = ls.checkString(1)!;
  //   ls.pop(1);
  //   debugPrint("lua.enableTimerGroup $id");
  //   final timers = store.timers.where((timer) => timer.group == id);
  //   Future.wait(timers.map((timer) {
  //     timer.enabled = true;
  //     return store.currentProfile.saveTimer(timer);
  //   })).then((_) => store.loadTimers());
  //   return 0;
  // }
  //
  // int disableTimerGroup(LuaState ls) {
  //   final id = ls.checkString(1)!;
  //   ls.pop(1);
  //   debugPrint("lua.disableTimerGroup $id");
  //   final timers = store.timers.where((timer) => timer.group == id);
  //   Future.wait(timers.map((timer) {
  //     timer.enabled = false;
  //     return store.currentProfile.saveTimer(timer);
  //   })).then((_) => store.loadTimers());
  //   return 0;
  // }

  int enableButtonSet(LuaState ls) {
    final id = ls.checkString(1)!;
    ls.pop(1);
    debugPrint("lua.enableButtonSet $id");
    final buttonSet =
        store.buttonSets.firstWhere((buttonSet) => buttonSet.label == id);
    buttonSet.enabled = true;
    store.currentProfile
        .saveButtonSet(buttonSet)
        .then((_) => store.loadButtonSets());
    return 0;
  }

  int disableButtonSet(LuaState ls) {
    final id = ls.checkString(1)!;
    ls.pop(1);
    debugPrint("lua.disableButtonSet $id");
    final buttonSet =
        store.buttonSets.firstWhere((buttonSet) => buttonSet.label == id);
    buttonSet.enabled = false;
    store.currentProfile
        .saveButtonSet(buttonSet)
        .then((_) => store.loadButtonSets());
    return 0;
  }

  int enableButtonGroup(LuaState ls) {
    final id = ls.checkString(1)!;
    ls.pop(1);
    debugPrint("lua.enableButtonGroup $id");
    final buttonSets =
        store.buttonSets.where((buttonSet) => buttonSet.group == id);
    Future.wait(buttonSets.map((buttonSet) {
      buttonSet.enabled = true;
      return store.currentProfile.saveButtonSet(buttonSet);
    })).then((_) => store.loadButtonSets());
    return 0;
  }

  int disableButtonGroup(LuaState ls) {
    final id = ls.checkString(1)!;
    ls.pop(1);
    debugPrint("lua.disableButtonGroup $id");
    final buttonSets =
        store.buttonSets.where((buttonSet) => buttonSet.group == id);
    Future.wait(buttonSets.map((buttonSet) {
      buttonSet.enabled = false;
      return store.currentProfile.saveButtonSet(buttonSet);
    })).then((_) => store.loadButtonSets());
    return 0;
  }
}


import 'package:flutter/foundation.dart';
import 'package:lua_dardo/lua.dart';

import '../store.dart';
import 'alias.dart';
import 'game_button_set.dart';
import 'trigger.dart';
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
    LuaAliasBindings(store).register(state);
    LuaTriggerBindings(store).register(state);
    LuaButtonSetBindings(store).register(state);
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
    final vari = store.currentProfile.variables[name];
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
    final profile = store.currentProfile;
    if (profile.variables[name] == null) {
      profile.variables[name] = Variable(name, value);
    }
    profile.variables[name]!.value = value;
    profile.saveVariable(
      profile.variables.values.toList(),
      profile.variables[name]!,
    );
    return 0;
  }
}

class LuaAliasBindings extends LuaAutomationBindings<Alias> {
  LuaAliasBindings(this.store);

  final GameStore store;

  @override
  final entityName = 'Alias';

  @override
  List<Alias> getGroup(String group) =>
      store.currentProfile.aliases.where((alias) => alias.group == group).toList();

  @override
  Alias getSingle(String label) =>
      store.currentProfile.aliases.firstWhere((alias) => alias.label == label);

  @override
  Future<void> saveGroup(List<Alias> items, bool state) async {
    await Future.wait(items.map((i) {
      i.enabled = state;
      return store.currentProfile.saveAlias(i);
    }));
    return store.currentProfile.getAliases();
  }

  @override
  Future<void> saveSingle(Alias item, bool state) async {
    item.enabled = state;
    await store.currentProfile.saveAlias(item);
    return store.currentProfile.getAliases();
  }
}

class LuaTriggerBindings extends LuaAutomationBindings<Trigger> {
  LuaTriggerBindings(this.store);

  final GameStore store;

  @override
  final entityName = 'Trigger';

  @override
  List<Trigger> getGroup(String group) =>
      store.currentProfile.triggers.where((alias) => alias.group == group).toList();

  @override
  Trigger getSingle(String label) =>
      store.currentProfile.triggers.firstWhere((alias) => alias.label == label);

  @override
  Future<void> saveGroup(List<Trigger> items, bool state) async {
    await Future.wait(items.map((i) {
      i.enabled = state;
      return store.currentProfile.saveTrigger(i);
    }));
    return store.currentProfile.getTriggers();
  }

  @override
  Future<void> saveSingle(Trigger item, bool state) async {
    item.enabled = state;
    await store.currentProfile.saveTrigger(item);
    return store.currentProfile.getTriggers();
  }
}

class LuaButtonSetBindings extends LuaAutomationBindings<GameButtonSetData> {
  LuaButtonSetBindings(this.store);

  final GameStore store;

  @override
  final entityName = 'ButtonSet';

  @override
  List<GameButtonSetData> getGroup(String group) =>
      store.currentProfile.buttonSets.where((alias) => alias.group == group).toList();

  @override
  GameButtonSetData getSingle(String label) =>
      store.currentProfile.buttonSets.firstWhere((alias) => alias.label == label);

  @override
  Future<void> saveGroup(List<GameButtonSetData> items, bool state) async {
    await Future.wait(items.map((i) {
      i.enabled = state;
      return store.currentProfile.saveButtonSet(i);
    }));
    return store.currentProfile.getTriggers();
  }

  @override
  Future<void> saveSingle(GameButtonSetData item, bool state) async {
    item.enabled = state;
    await store.currentProfile.saveButtonSet(item);
    return store.currentProfile.getTriggers();
  }
}

abstract class LuaAutomationBindings<T> {
  Future<void> saveSingle(T item, bool state);
  Future<void> saveGroup(List<T> items, bool state);

  T getSingle(String label);
  List<T> getGroup(String group);

  String get entityName;

  void register(LuaState ls) {
    ls.pushDartFunction(enableSingle);
    ls.setGlobal('Enable$entityName');
    ls.pushDartFunction(disableSingle);
    ls.setGlobal('Disable$entityName');
    ls.pushDartFunction(enableGroup);
    ls.setGlobal('Enable${entityName}Group');
    ls.pushDartFunction(disableGroup);
    ls.setGlobal('Disable${entityName}Group');
  }

  int enableSingle(LuaState ls) {
    final id = ls.checkString(1)!;
    ls.pop(1);
    bool state = true;
    if (ls.isBoolean(2)) {
      state = ls.toBoolean(2);
      ls.pop(1);
    }
    debugPrint("lua.enableTrigger $id, $state");
    final item = getSingle(id);
    saveSingle(item, state);
    return 0;
  }

  int disableSingle(LuaState ls) {
    final id = ls.checkString(1)!;
    ls.pop(1);
    debugPrint("lua.disableTrigger $id");
    final item = getSingle(id);
    saveSingle(item, false);
    return 0;
  }

  int enableGroup(LuaState ls) {
    final id = ls.checkString(1)!;
    ls.pop(1);
    bool state = true;
    if (ls.isBoolean(2)) {
      state = ls.toBoolean(2);
      ls.pop(1);
    }
    debugPrint("lua.enableTriggerGroup $id, $state");
    final items = getGroup(id);
    saveGroup(items, state);
    return 0;
  }

  int disableGroup(LuaState ls) {
    final id = ls.checkString(1)!;
    ls.pop(1);
    debugPrint("lua.disableTriggerGroup $id");
    final items = getGroup(id);
    saveGroup(items, false);
    return 0;
  }
}


import 'package:flutter/foundation.dart';
import 'package:lua_dardo/lua.dart';

import '../store.dart';
import 'action.dart';
import 'alias.dart';
import 'game_button_set.dart';
import 'trigger.dart';

class LuaInterpreter {
  LuaState state = LuaState.newState();
  final GameStore store;

  LuaInterpreter(this.store) {
    state.openLibs();
    _loadMUDLibs();
  }

  void _loadMUDLibs() {
    LuaBindings(store).register(state);
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

  void register(LuaState state) {
    state.pushDartFunction(send);
    state.setGlobal("Send");
    state.pushDartFunction(gsub);
    state.setGlobal("string.gsub");
    state.pushDartFunction(gsub);
    state.setGlobal("Replace");
    state.pushDartFunction(getVariable);
    state.setGlobal("GetVariable");
    state.pushDartFunction(setVariable);
    state.setGlobal("SetVariable");
    state.pushDartFunction(setInput);
    state.setGlobal("SetInput");
    state.pushDartFunction(setInputSelection);
    state.setGlobal("SetInputSelection");
    state.pushDartFunction(doAfterSpecial);
    state.setGlobal("DoAfterSpecial");
  }

  int send(LuaState ls) {
    final cmd = ls.checkString(1) ?? '';
    ls.pop(1);
    debugPrint("lua.Send $cmd");
    store.send(cmd);
    return 0;
  }

  int gsub(LuaState ls) {
    final source = ls.checkString(1)!;
    final find = ls.checkString(2)!;
    final replace = ls.checkString(3)!;
    ls.pop(3);
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
    profile.saveVariable(name, value);
    return 0;
  }

  int setInput(LuaState ls) {
    final input = ls.checkString(1)!;
    ls.pop(1);
    debugPrint("lua.setInput $input");
    store.setInput(input);
    return 0;
  }

  int setInputSelection(LuaState ls) {
    final start = ls.checkInteger(1)!;
    final end = ls.checkInteger(2)!;
    ls.pop(2);
    debugPrint("lua.setInputSelection $start, $end");
    store.setInputSelection(start, end);
    return 0;
  }

  int doAfterSpecial(LuaState ls) {
    // seconds, sendText, sendTo
    final seconds = ls.checkNumber(1)!;
    final sendText = ls.checkString(2)!;
    final sendTo = ls.checkNumber(3)!;
    ls.pop(3);

    debugPrint("lua.doAfterSpecial $seconds, $sendText, $sendTo");
    final sendToMap = <int, MUDActionTarget>{
      0: MUDActionTarget.world,
      1: MUDActionTarget.input,
      2: MUDActionTarget.output,
      3: MUDActionTarget.none, // TODO status line
      4: MUDActionTarget.none, // TODO notepad
      5: MUDActionTarget.none, // TODO notepad (append)
      6: MUDActionTarget.none, // TODO log file
      7: MUDActionTarget.none, // TODO notepad (replace)
      8: MUDActionTarget.none, // TODO command queue
      9: MUDActionTarget.none, // TODO set variable
      10: MUDActionTarget.execute,
      11: MUDActionTarget.none, // TODO speedwalk
      12: MUDActionTarget.script,
      13: MUDActionTarget.immediate,
      14: MUDActionTarget.script, // TODO script (after lines omitted?)
    };
    final target = sendToMap[sendTo] ?? MUDActionTarget.none;
    final action = MUDAction(sendText, target: target);
    final delay = Duration(milliseconds: (seconds * 1000).toInt());
    Future.delayed(delay, () {
      action.invoke(store, []);
    });
    return 0;
  }
}

class LuaAliasBindings extends LuaAutomationBindings<Alias> {
  LuaAliasBindings(this.store);

  final GameStore store;

  @override
  final entityName = 'Alias';

  @override
  List<Alias> getGroup(String group) => store.currentProfile.aliases
      .where((alias) => alias.group == group)
      .toList();

  @override
  Alias getSingle(String label) =>
      store.currentProfile.aliases.firstWhere((alias) => alias.label == label);

  @override
  Future<void> saveGroup(List<Alias> items, bool state) async {
    await Future.wait(items.map((i) {
      i.enabled = state;
      return store.currentProfile.saveAlias(i);
    }));
  }

  @override
  Future<void> saveSingle(Alias item, bool state) async {
    item.enabled = state;
    await store.currentProfile.saveAlias(item);
  }
}

class LuaTriggerBindings extends LuaAutomationBindings<Trigger> {
  LuaTriggerBindings(this.store);

  final GameStore store;

  @override
  final entityName = 'Trigger';

  @override
  List<Trigger> getGroup(String group) => store.currentProfile.triggers
      .where((alias) => alias.group == group)
      .toList();

  @override
  Trigger getSingle(String label) =>
      store.currentProfile.triggers.firstWhere((alias) => alias.label == label);

  @override
  Future<void> saveGroup(List<Trigger> items, bool state) async {
    await Future.wait(items.map((i) {
      i.enabled = state;
      return store.currentProfile.saveTrigger(i);
    }));
  }

  @override
  Future<void> saveSingle(Trigger item, bool state) async {
    item.enabled = state;
    await store.currentProfile.saveTrigger(item);
  }
}

class LuaButtonSetBindings extends LuaAutomationBindings<GameButtonSetData> {
  LuaButtonSetBindings(this.store);

  final GameStore store;

  @override
  void register(LuaState ls) {
    super.register(ls);
    ls.pushDartFunction(swapButtonSetGroup);
    ls.setGlobal('Swap$groupEntityName');
  }

  @override
  final entityName = 'ButtonSet';

  @override
  final groupEntityName = 'ButtonGroup';

  @override
  List<GameButtonSetData> getGroup(String group) =>
      store.currentProfile.buttonSets
          .where((alias) => alias.group == group)
          .toList();

  @override
  GameButtonSetData getSingle(String label) => store.currentProfile.buttonSets
      .firstWhere((alias) => alias.label == label);

  @override
  Future<void> saveGroup(List<GameButtonSetData> items, bool state) async {
    await Future.wait(items.map((i) {
      i.enabled = state;
      return store.currentProfile.saveButtonSet(i);
    }));
  }

  @override
  Future<void> saveSingle(GameButtonSetData item, bool state) async {
    item.enabled = state;
    await store.currentProfile.saveButtonSet(item);
  }

  int swapButtonSetGroup(LuaState ls) {
    final disable = ls.checkString(1)!;
    final enable = ls.checkString(2)!;
    ls.pop(2);
    debugPrint("lua.SwapButtonGroup $disable, $enable");
    final profile = store.currentProfile;
    final disableGroup = profile.buttonSets
        .where((element) => element.group == disable)
        .toList();
    final enableGroup =
        profile.buttonSets.where((element) => element.group == enable).toList();
    for (final element in disableGroup) {
      element.enabled = false;
      profile.saveButtonSet(element);
    }
    for (final element in enableGroup) {
      element.enabled = true;
      profile.saveButtonSet(element);
    }
    return 0;
  }
}

abstract class LuaAutomationBindings<T> {
  Future<void> saveSingle(T item, bool state);
  Future<void> saveGroup(List<T> items, bool state);

  T getSingle(String label);
  List<T> getGroup(String group);

  String get entityName;
  String get groupEntityName => '${entityName}Group';

  void register(LuaState ls) {
    ls.pushDartFunction(enableSingle);
    ls.setGlobal('Enable$entityName');
    ls.pushDartFunction(disableSingle);
    ls.setGlobal('Disable$entityName');
    ls.pushDartFunction(enableGroup);
    ls.setGlobal('Enable$groupEntityName');
    ls.pushDartFunction(disableGroup);
    ls.setGlobal('Disable$groupEntityName');
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


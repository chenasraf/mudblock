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
}

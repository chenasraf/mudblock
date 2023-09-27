import 'package:flutter/foundation.dart';
import 'package:lua_dardo/lua.dart';

import '../store.dart';

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
}


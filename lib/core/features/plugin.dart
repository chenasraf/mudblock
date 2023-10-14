import 'package:flutter/foundation.dart';

import '../storage.dart';
import 'alias.dart';
import 'game_button_set.dart';
import 'trigger.dart';
import 'variable.dart';

class PluginBase extends ChangeNotifier {
  final IStorage<Map<String, dynamic>> storage = JsonStorage();

  final List<Trigger> triggers = [];
  final List<Alias> aliases = [];
  final Map<String, Variable> variables = {};
  final List<GameButtonSetData> buttonSets = [];

  Future<void> load() async {
    await storage.init();
    await Future.wait([
      getAliases(),
      getTriggers(),
      getVariables(),
      getButtonSets(),
      ...additionalLoaders(),
    ]);

    notifyListeners();
  }

  List<Future<void>> additionalLoaders() => [];

  Future<List<Trigger>> loadTriggers() async {
    debugPrint('$this loadTriggers');
    final triggers = await storage.readDirectory('triggers');
    final triggerFiles = <Map<String, dynamic>>[];
    for (final trigger in triggers) {
      final triggerFile = await storage.readFile(trigger);
      if (triggerFile != null) {
        triggerFiles.add(triggerFile);
      }
    }
    return triggerFiles.map((e) => Trigger.fromJson(e)).toList();
  }

  Future<List<Alias>> loadAliases() async {
    debugPrint('$this loadAliases');
    final aliases = await storage.readDirectory('aliases');
    final aliasFiles = <Map<String, dynamic>>[];
    for (final alias in aliases) {
      final aliasFile = await storage.readFile(alias);
      if (aliasFile != null) {
        aliasFiles.add(aliasFile);
      }
    }
    return aliasFiles.map((e) => Alias.fromJson(e)).toList();
  }

  Future<List<Variable>> loadVariables() async {
    debugPrint('$this loadVariables');
    final vars = await storage.readFile('vars');
    if (vars == null) {
      return [];
    }
    return (vars['vars'] as List<dynamic>)
        .map((e) => Variable.fromJson(e))
        .toList();
  }

  Future<List<GameButtonSetData>> loadButtonSets() async {
    debugPrint('$this loadButtonSets');
    final buttonSets = await storage.readDirectory('button_sets');
    final buttonSetFiles = <Map<String, dynamic>>[];
    for (final buttonSet in buttonSets) {
      final buttonSetFile = await storage.readFile(buttonSet);
      if (buttonSetFile != null) {
        buttonSetFiles.add(buttonSetFile);
      }
    }
    return buttonSetFiles.map((e) => GameButtonSetData.fromJson(e)).toList();
  }

  Future<void> saveAlias(Alias alias) async {
    debugPrint('$this saveAlias: $alias');
    notifyListeners();
    final idx = aliases.indexWhere((a) => a.id == alias.id);
    if (idx >= 0) {
      aliases[idx] = alias;
    } else {
      aliases.add(alias);
    }
    return storage.writeFile('aliases/${alias.id}', alias.toJson());
  }

  Future<void> deleteAlias(Alias alias) async {
    debugPrint('$this deleteAlias: $alias');
    final idx = aliases.indexWhere((a) => a.id == alias.id);
    if (idx >= 0) {
      aliases.removeAt(idx);
    }
    notifyListeners();
    return storage.deleteFile('aliases/${alias.id}');
  }

  Future<void> saveTrigger(Trigger trigger) async {
    debugPrint('$this saveTrigger: $trigger');
    final idx = triggers.indexWhere((a) => a.id == trigger.id);
    if (idx >= 0) {
      triggers[idx] = trigger;
    } else {
      triggers.add(trigger);
    }
    notifyListeners();
    return storage.writeFile('triggers/${trigger.id}', trigger.toJson());
  }

  Future<void> deleteTrigger(Trigger trigger) async {
    debugPrint('$this deleteTrigger: $trigger');
    final idx = triggers.indexWhere((a) => a.id == trigger.id);
    if (idx >= 0) {
      triggers.removeAt(idx);
    }
    notifyListeners();
    return storage.deleteFile('triggers/${trigger.id}');
  }

  Future<void> saveButtonSet(GameButtonSetData buttonSet) async {
    debugPrint('$this saveButtonSet: $buttonSet');
    final idx = buttonSets.indexWhere((a) => a.id == buttonSet.id);
    if (idx >= 0) {
      buttonSets[idx] = buttonSet;
    } else {
      buttonSets.add(buttonSet);
    }
    notifyListeners();
    return storage.writeFile('button_sets/${buttonSet.id}', buttonSet.toJson());
  }

  Future<void> deleteButtonSet(GameButtonSetData buttonSet) async {
    debugPrint('$this deleteButtonSet: $buttonSet');
    final idx = buttonSets.indexWhere((a) => a.id == buttonSet.id);
    if (idx >= 0) {
      buttonSets.removeAt(idx);
    }
    notifyListeners();
    return storage.deleteFile('button_sets/${buttonSet.id}');
  }

  Future<void> saveVariable(List<Variable> current, Variable update) async {
    debugPrint('$this saveVariable: $update');
    final existing = current.indexWhere(
      (v) => v.name == update.name,
    );
    if (existing >= 0) {
      current[existing] = update;
    } else {
      current.add(update);
    }
    notifyListeners();
    return storage.writeFile(
      'vars',
      {'vars': current.map((v) => v.toJson()).toList()},
    );
  }

  Future<void> deleteVariable(List<Variable> current, Variable update) async {
    debugPrint('$this deleteVariable: $update');
    final existing = current.indexWhere(
      (v) => v.name == update.name,
    );
    if (existing >= 0) {
      current.removeAt(existing);
    }
    notifyListeners();
    return storage.writeFile(
      'vars',
      {'vars': current.map((v) => v.toJson()).toList()},
    );
  }

  Future<void> getTriggers() async {
    debugPrint('loadTriggers');
    final list = await loadTriggers();
    triggers.clear();
    triggers.addAll(list);
    notifyListeners();
    debugPrint('Triggers: ${triggers.length}');
  }

  Future<void> getAliases() async {
    final list = await loadAliases();
    aliases.clear();
    aliases.addAll(list);
    notifyListeners();
    debugPrint('Aliases: ${aliases.length}');
  }

  Future<void> getVariables() async {
    final list = await loadVariables();
    variables.clear();
    variables.addAll(Map.fromEntries(list.map((e) => MapEntry(e.name, e))));
    notifyListeners();
    debugPrint('Variables: ${variables.length}');
  }

  Future<void> getButtonSets() async {
    final list = await loadButtonSets();
    buttonSets.clear();
    buttonSets.addAll(list);
    notifyListeners();
    debugPrint('ButtonSets: ${buttonSets.length}');
  }

  @override
  String toString() {
    return 'PluginBase()';
  }
}

class Plugin extends PluginBase {
  final String profileId;
  final String id;

  Plugin(this.profileId, this.id) : _storage = PluginStorage(profileId, id);

  @override
  IStorage<Map<String, dynamic>> get storage => _storage;

  final IStorage<Map<String, dynamic>> _storage;
}


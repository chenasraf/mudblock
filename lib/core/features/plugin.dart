import 'package:flutter/foundation.dart';

import '../storage.dart';
import 'alias.dart';
import 'game_button_set.dart';
import 'trigger.dart';
import 'variable.dart';

class PluginBase extends ChangeNotifier {
  final String id;

  final List<Trigger> triggers = [];
  final List<Alias> aliases = [];
  final Map<String, Variable> variables = {};
  final List<GameButtonSetData> buttonSets = [];

  PluginBase(this.id);

  Future<void> load() async {
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
    debugPrint('MUDProfile.loadTriggers: $id');
    final triggers = await ProfileStorage.listProfileFiles(id, 'triggers');
    final triggerFiles = <Map<String, dynamic>>[];
    for (final trigger in triggers) {
      debugPrint('MUDProfile.loadTriggers: $id/triggers/$trigger');
      final triggerFile =
          await ProfileStorage.readProfileFile(id, 'triggers/$trigger');
      if (triggerFile != null) {
        triggerFiles.add(triggerFile);
      }
    }
    return triggerFiles.map((e) => Trigger.fromJson(e)).toList();
  }

  Future<List<Alias>> loadAliases() async {
    debugPrint('MUDProfile.loadAliases: $id');
    final aliases = await ProfileStorage.listProfileFiles(id, 'aliases');
    final aliasFiles = <Map<String, dynamic>>[];
    for (final alias in aliases) {
      debugPrint('MUDProfile.loadAliases: $id/aliases/$alias');
      final aliasFile =
          await ProfileStorage.readProfileFile(id, 'aliases/$alias');
      if (aliasFile != null) {
        aliasFiles.add(aliasFile);
      }
    }
    return aliasFiles.map((e) => Alias.fromJson(e)).toList();
  }

  Future<List<Variable>> loadVariables() async {
    debugPrint('MUDProfile.loadVariables: $id');
    final vars = await ProfileStorage.readProfileFile(id, 'vars');
    if (vars == null) {
      return [];
    }
    return (vars['vars'] as List<dynamic>)
        .map((e) => Variable.fromJson(e))
        .toList();
  }

  Future<List<GameButtonSetData>> loadButtonSets() async {
    debugPrint('MUDProfile.loadButtonSets: $id');
    final buttonSets = await ProfileStorage.listProfileFiles(id, 'button_sets');
    final buttonSetFiles = <Map<String, dynamic>>[];
    for (final buttonSet in buttonSets) {
      debugPrint('MUDProfile.loadButtonSets: $id/buttonSets/$buttonSet');
      final buttonSetFile =
          await ProfileStorage.readProfileFile(id, 'button_sets/$buttonSet');
      if (buttonSetFile != null) {
        buttonSetFiles.add(buttonSetFile);
      }
    }
    return buttonSetFiles.map((e) => GameButtonSetData.fromJson(e)).toList();
  }

  Future<void> saveAlias(Alias alias) async {
    debugPrint('MUDProfile.saveAlias: $id/aliases/${alias.id}');
    notifyListeners();
    final idx = aliases.indexWhere((a) => a.id == alias.id);
    if (idx >= 0) {
      aliases[idx] = alias;
    } else {
      aliases.add(alias);
    }
    return ProfileStorage.writeProfileFile(
        id, 'aliases/${alias.id}', alias.toJson());
  }

  Future<void> deleteAlias(Alias alias) async {
    debugPrint('MUDProfile.deleteAlias: $id/aliases/${alias.id}');
    final idx = aliases.indexWhere((a) => a.id == alias.id);
    if (idx >= 0) {
      aliases.removeAt(idx);
    }
    notifyListeners();
    return ProfileStorage.deleteProfileFile(id, 'aliases/${alias.id}');
  }

  Future<void> saveTrigger(Trigger trigger) async {
    debugPrint('MUDProfile.saveTrigger: $id/triggers/${trigger.id}');
    final idx = triggers.indexWhere((a) => a.id == trigger.id);
    if (idx >= 0) {
      triggers[idx] = trigger;
    } else {
      triggers.add(trigger);
    }
    notifyListeners();
    return ProfileStorage.writeProfileFile(
        id, 'triggers/${trigger.id}', trigger.toJson());
  }

  Future<void> deleteTrigger(Trigger trigger) async {
    debugPrint('MUDProfile.deleteTrigger: $id/triggers/${trigger.id}');
    final idx = triggers.indexWhere((a) => a.id == trigger.id);
    if (idx >= 0) {
      triggers.removeAt(idx);
    }
    notifyListeners();
    return ProfileStorage.deleteProfileFile(id, 'triggers/${trigger.id}');
  }

  Future<void> saveButtonSet(GameButtonSetData buttonSet) async {
    debugPrint('MUDProfile.saveButtonSet: $id/button_sets/${buttonSet.id}');
    final idx = buttonSets.indexWhere((a) => a.id == buttonSet.id);
    if (idx >= 0) {
      buttonSets[idx] = buttonSet;
    } else {
      buttonSets.add(buttonSet);
    }
    notifyListeners();
    return ProfileStorage.writeProfileFile(
        id, 'button_sets/${buttonSet.id}', buttonSet.toJson());
  }

  Future<void> deleteButtonSet(GameButtonSetData buttonSet) async {
    debugPrint('MUDProfile.deleteButtonSet: $id/button_sets/${buttonSet.id}');
    final idx = buttonSets.indexWhere((a) => a.id == buttonSet.id);
    if (idx >= 0) {
      buttonSets.removeAt(idx);
    }
    notifyListeners();
    return ProfileStorage.deleteProfileFile(id, 'button_sets/${buttonSet.id}');
  }

  Future<void> saveVariable(List<Variable> current, Variable update) async {
    debugPrint('MUDProfile.saveVariable: $id/vars');
    final existing = current.indexWhere(
      (v) => v.name == update.name,
    );
    if (existing >= 0) {
      current[existing] = update;
    } else {
      current.add(update);
    }
    notifyListeners();
    return ProfileStorage.writeProfileFile(
      id,
      'vars',
      {'vars': current.map((v) => v.toJson()).toList()},
    );
  }

  Future<void> deleteVariable(List<Variable> current, Variable update) async {
    debugPrint('MUDProfile.deleteVariable: $id/vars');
    final existing = current.indexWhere(
      (v) => v.name == update.name,
    );
    if (existing >= 0) {
      current.removeAt(existing);
    }
    notifyListeners();
    return ProfileStorage.writeProfileFile(
      id,
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
}

class Plugin extends PluginBase {
  final String profileId;

  @override
  String get id => _id;

  final String _id;

  Plugin(this.profileId, String id)
      : _id = id,
        super('$profileId/$id');
}


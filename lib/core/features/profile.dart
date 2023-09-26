import 'package:flutter/foundation.dart';
import 'package:mudblock/core/storage.dart';

import 'alias.dart';
import 'trigger.dart';

class MUDProfile {
  String id;
  String name;
  String host;
  int port;
  bool mccpEnabled;

  MUDProfile({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    this.mccpEnabled = true,
  });

  Future<List<Trigger>> loadTriggers() async {
    debugPrint('MUDProfile.loadTriggers: $id');
    final triggers = await ProfileStorage.listProfileFiles(id, 'triggers');
    return triggers.values.map((e) => Trigger.fromJson(e)).toList();
  }

  // Stream<List<Alias>> listenAliases({
  //   void Function(List<Alias>) onData,
  //   }) =>

  Future<List<Alias>> loadAliases() async {
    debugPrint('MUDProfile.loadAliases: $id');
    final aliases = await ProfileStorage.listProfileFiles(id, 'aliases');
    return aliases.values.map((e) => Alias.fromJson(e)).toList();
  }

  Future<void> saveAlias(Alias alias) async {
    debugPrint('MUDProfile.saveAlias: $id/aliases/${alias.id}');
    return ProfileStorage.writeProfileFile(id, 'aliases/${alias.id}', alias.toJson());
  }

  Future<void> saveTrigger(Trigger trigger) async {
    debugPrint('MUDProfile.saveTrigger: $id/triggers/${trigger.id}');
    return ProfileStorage.writeProfileFile(id, 'triggers/${trigger.id}', trigger.toJson());
  }
}


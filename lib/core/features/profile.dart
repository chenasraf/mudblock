import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart';

import '../secrets.dart';
import '../storage.dart';
import '../string_utils.dart';
import 'alias.dart';
import 'trigger.dart';

class MUDProfile {
  String id;
  String name;
  String host;
  int port;
  bool mccpEnabled;
  String username;
  String password;

  MUDProfile({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    this.mccpEnabled = true,
    this.username = '',
    this.password = '',
  });

  factory MUDProfile.empty() => MUDProfile(
        id: uuid(),
        name: '',
        host: '',
        port: 23,
      );

  MUDProfile copyWith({
    String? id,
    String? name,
    String? host,
    int? port,
    bool? mccpEnabled,
    String? username,
    String? password,
  }) =>
      MUDProfile(
        id: id ?? this.id,
        name: name ?? this.name,
        host: host ?? this.host,
        port: port ?? this.port,
        mccpEnabled: mccpEnabled ?? this.mccpEnabled,
        username: username ?? this.username,
        password: password ?? this.password,
      );

  factory MUDProfile.fromJson(Map<String, dynamic> json) => MUDProfile(
        id: json['id'],
        name: json['name'],
        host: json['host'],
        port: json['port'],
        mccpEnabled: json['mccpEnabled'],
        username: json['username'],
        password: decrypt(json['password']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'host': host,
        'port': port,
        'mccpEnabled': mccpEnabled,
        'username': username,
        'password': encrypt(password),
      };

  static Future<void> save(MUDProfile profile) async {
    debugPrint('MUDProfile.save: ${profile.id}');
    return ProfileStorage.writeProfileFile(profile.id, profile.id, profile.toJson());
  }

  Future<List<Trigger>> loadTriggers() async {
    debugPrint('MUDProfile.loadTriggers: $id');
    final triggers = await ProfileStorage.listProfileFiles(id, 'triggers');
    return triggers.values.map((e) => Trigger.fromJson(e)).toList();
  }

  Future<List<Alias>> loadAliases() async {
    debugPrint('MUDProfile.loadAliases: $id');
    final aliases = await ProfileStorage.listProfileFiles(id, 'aliases');
    return aliases.values.map((e) => Alias.fromJson(e)).toList();
  }

  Future<void> saveAlias(Alias alias) async {
    debugPrint('MUDProfile.saveAlias: $id/aliases/${alias.id}');
    return ProfileStorage.writeProfileFile(
        id, 'aliases/${alias.id}', alias.toJson());
  }

  Future<void> saveTrigger(Trigger trigger) async {
    debugPrint('MUDProfile.saveTrigger: $id/triggers/${trigger.id}');
    return ProfileStorage.writeProfileFile(
        id, 'triggers/${trigger.id}', trigger.toJson());
  }

  static String encrypt(String password) {
    if (password.isEmpty) {
      return '';
    }
    final key = enc.Key.fromUtf8(pwdKey);
    final encrypter = enc.Encrypter(enc.AES(key));
    final encrypted = encrypter.encrypt(password, iv: enc.IV.fromLength(16));
    return encrypted.base64;
  }

  static String decrypt(String json) {
    final key = enc.Key.fromUtf8(pwdKey);
    final encrypter = enc.Encrypter(enc.AES(key));
    final encrypted = enc.Encrypted.fromBase64(json);
    return encrypter.decrypt(encrypted, iv: enc.IV.fromLength(16));
  }
}


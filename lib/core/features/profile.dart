import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart';

import '../consts.dart';
import '../secrets.dart';
import '../storage.dart';
import '../string_utils.dart';
import 'alias.dart';
import 'trigger.dart';
import 'variable.dart';

class MUDProfile {
  String id;
  String name;
  String host;
  int port;
  bool mccpEnabled;
  String username;
  String password;
  AuthMethod authMethod;

  MUDProfile({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    this.mccpEnabled = true,
    this.username = '',
    this.password = '',
    this.authMethod = AuthMethod.none,
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
    AuthMethod? authMethod,
  }) =>
      MUDProfile(
        id: id ?? this.id,
        name: name ?? this.name,
        host: host ?? this.host,
        port: port ?? this.port,
        mccpEnabled: mccpEnabled ?? this.mccpEnabled,
        username: username ?? this.username,
        password: password ?? this.password,
        authMethod: authMethod ?? this.authMethod,
      );

  factory MUDProfile.fromJson(Map<String, dynamic> json) {
    return MUDProfile(
      id: json['id'],
      name: json['name'],
      host: json['host'],
      port: json['port'],
      mccpEnabled: json['mccpEnabled'],
      username: json['username'],
      password: decrypt(json['password']),
      // TODO generalize getting enum from string
      authMethod: AuthMethod.values.firstWhere(
        (e) => e.name == json['authMethod'],
        orElse: () => AuthMethod.none,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'host': host,
        'port': port,
        'mccpEnabled': mccpEnabled,
        'username': username,
        'password': encrypt(password),
        'authMethod': authMethod.name,
      };

  static Future<void> save(MUDProfile profile) async {
    debugPrint('MUDProfile.save: ${profile.id}');
    return ProfileStorage.writeProfileFile(
        profile.id, profile.id, (profile.toJson()));
  }

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
    return ProfileStorage.writeProfileFile(
      id,
      'vars',
      {'vars': current.map((v) => v.toJson()).toList()},
    );
  }

  static final encKey = enc.Key.fromUtf8(pwdKey);
  static final encrypter = enc.Encrypter(enc.AES(encKey, padding: null));

  static String encrypt(String password) {
    final iv = enc.IV.fromLength(16);
    if (password.isEmpty) {
      return '';
    }
    final encrypted = encrypter.encrypt(password, iv: iv);
    // debugPrint('MUDProfile.encrypt: $password -> ${encrypted.base64}');
    return '${encrypted.base64}:${iv.base64}';
  }

  static String decrypt(String password) {
    if (password.isEmpty) {
      return '';
    }
    try {
      final ivStr = password.substring(password.indexOf(':') + 1);
      final iv = enc.IV.fromBase64(ivStr);
      password = password.substring(0, password.indexOf(':'));
      // debugPrint('MUDProfile.decrypt: $password');
      final encrypted = enc.Encrypted.fromBase64(password);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);
      // debugPrint('MUDProfile.decrypt: $decrypted');
      return decrypted;
    } catch (e, stack) {
      debugPrint('MUDProfile.decrypt: $e$lf$stack');
      return password;
    }
  }
}

enum AuthMethod {
  none,
  diku,
}


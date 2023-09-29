import 'features/profile.dart';

final profilePresets = [
  MUDProfile(
    id: 'local',
    name: 'Local',
    host: 'localhost',
    port: 4000,
  ),
  MUDProfile(
    id: 'smud',
    name: 'SimpleMUD',
    host: 'smud.ourmmo.com',
    port: 3000,
    authMethod: AuthMethod.diku,
    mccpEnabled: false,
  ),
  MUDProfile(
    id: 'aardwolf',
    name: 'Aardwolf',
    host: 'aardmud.org',
    port: 23,
    authMethod: AuthMethod.diku,
  ),
  MUDProfile(
    id: 'batmud',
    name: 'BatMUD',
    host: 'batmud.bat.org',
    port: 23,
  ),
  MUDProfile(
    id: 'dune',
    name: 'Dune',
    host: 'dune.servint.com',
    port: 6789,
  ),
];

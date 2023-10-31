// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:mudblock/core/string_utils.dart';

class BuiltinCommand {
  static const sep =
    '--------------------------------------------------------------------------------';
  static help() {
    final year = DateTime.now().year;
    final years = [2023];
    if (!years.contains(year)) {
      years.add(year);
    }
    return '''
      {_mudblockhelp}
      $sep
      Mudblock - Help
      $sep

      Mudblock is a cross-platform MUD client.
      See more information at https://github.com/chenasraf/mudblock

      $sep
      Developed by Chen Asraf
      Copyright © ${years.join('-')} - All Rights Reserved
      $sep

      To get started, tap the hamburger menu at the top right corner and
      select a profile.

      You can create, delete or update the profiles as you wish.

      Each profile hosts its own settings, aliases, triggers, variables, buttons, and
      other similar features.

      If you've never played an MUD, try one of the sample MUDs to get started!
      $sep
      {/_mudblockhelp}
    '''
            .trimMultiline() +
        '\n';
  }

  static motd() {
    return '''
      {_mudblockmotd}
      $sep
      Welcome to MudBlock!
      $sep
      To get started, tap the hamburger menu at the top right corner and
      select a profile.

      For more help, type "mudhelp"
      $sep
      {/_mudblockmotd}
    '''
            .trimMultiline() +
        '\n';
  }
}


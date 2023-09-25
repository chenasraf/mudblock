import 'package:flutter/widgets.dart';

import 'alias.dart';

class Trigger extends Alias {
  Trigger({
    super.enabled = true,
    required super.id,
    required super.pattern,
    required super.action,
    super.isRegex = false,
    super.isCaseSensitive = false,
    super.isRemovedFromBuffer = false,
    super.isTemporary = false,
  });
}


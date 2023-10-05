import 'package:flutter/material.dart';
import '../platform_utils.dart';
import '../store.dart';

import '../string_utils.dart';
import 'action.dart';
import 'automation.dart';

class GameButtonData {
  const GameButtonData({
    required this.id,
    required this.label,
    required this.pressAction,
    this.labelUp,
    this.labelDown,
    this.labelLeft,
    this.labelRight,
    this.color,
    this.size = defaultSize,
    this.longPressAction,
    this.swipeUpAction,
    this.swipeDownAction,
    this.swipeLeftAction,
    this.swipeRightAction,
  });

  static const defaultSize = 60.0;

  final String id;
  final GameButtonLabelData label;
  final GameButtonLabelData? labelUp;
  final GameButtonLabelData? labelDown;
  final GameButtonLabelData? labelLeft;
  final GameButtonLabelData? labelRight;
  final Color? color;
  final double? size;
  final MUDAction pressAction;
  final MUDAction? longPressAction;
  final MUDAction? swipeUpAction;
  final MUDAction? swipeDownAction;
  final MUDAction? swipeLeftAction;
  final MUDAction? swipeRightAction;

  factory GameButtonData.empty() => GameButtonData(
        id: uuid(),
        label: GameButtonLabelData.empty(),
        pressAction: MUDAction.empty(),
      );

  factory GameButtonData.fromJson(Map<String, dynamic> json) {
    return GameButtonData(
      id: json['id'] as String,
      label: GameButtonLabelData.fromJson(json['label']),
      pressAction: MUDAction.fromJson(json['pressAction']),
      labelUp: json['labelUp'] == null
          ? null
          : GameButtonLabelData.fromJson(json['labelUp']),
      labelDown: json['labelDown'] == null
          ? null
          : GameButtonLabelData.fromJson(json['labelDown']),
      labelLeft: json['labelLeft'] == null
          ? null
          : GameButtonLabelData.fromJson(json['labelLeft']),
      labelRight: json['labelRight'] == null
          ? null
          : GameButtonLabelData.fromJson(json['labelRight']),
      color: json['color'] == null ? null : Color(json['color'] as int),
      size: json['size'] == null ? null : json['size']!.toDouble(),
      longPressAction: json['longPressAction'] == null
          ? null
          : MUDAction.fromJson(json['longPressAction']),
      swipeUpAction: json['swipeUpAction'] == null
          ? null
          : MUDAction.fromJson(json['swipeUpAction']),
      swipeDownAction: json['swipeDownAction'] == null
          ? null
          : MUDAction.fromJson(json['swipeDownAction']),
      swipeLeftAction: json['swipeLeftAction'] == null
          ? null
          : MUDAction.fromJson(json['swipeLeftAction']),
      swipeRightAction: json['swipeRightAction'] == null
          ? null
          : MUDAction.fromJson(json['swipeRightAction']),
    );
  }

  GameButtonData copyWith({
    String? id,
    GameButtonLabelData? label,
    GameButtonLabelData? labelUp,
    GameButtonLabelData? labelDown,
    GameButtonLabelData? labelLeft,
    GameButtonLabelData? labelRight,
    Color? color,
    double? size,
    MUDAction? pressAction,
    MUDAction? longPressAction,
    MUDAction? swipeUpAction,
    MUDAction? swipeDownAction,
    MUDAction? swipeLeftAction,
    MUDAction? swipeRightAction,
  }) =>
      GameButtonData(
        id: id ?? this.id,
        label: label ?? this.label,
        labelUp: labelUp ?? this.labelUp,
        labelDown: labelDown ?? this.labelDown,
        labelLeft: labelLeft ?? this.labelLeft,
        labelRight: labelRight ?? this.labelRight,
        color: color ?? this.color,
        size: size ?? this.size,
        pressAction: pressAction ?? this.pressAction,
        longPressAction: longPressAction ?? this.longPressAction,
        swipeUpAction: swipeUpAction ?? this.swipeUpAction,
        swipeDownAction: swipeDownAction ?? this.swipeDownAction,
        swipeLeftAction: swipeLeftAction ?? this.swipeLeftAction,
        swipeRightAction: swipeRightAction ?? this.swipeRightAction,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label.toJson(),
        'pressAction': pressAction.toJson(),
        'labelUp': labelUp?.toJson(),
        'labelDown': labelDown?.toJson(),
        'labelLeft': labelLeft?.toJson(),
        'labelRight': labelRight?.toJson(),
        'color': color?.value,
        'size': size,
        'longPressAction': longPressAction?.toJson(),
        'swipeUpAction': swipeUpAction?.toJson(),
        'swipeDownAction': swipeDownAction?.toJson(),
        'swipeLeftAction': swipeLeftAction?.toJson(),
        'swipeRightAction': swipeRightAction?.toJson(),
      };

  MUDAction directionalAction(GameButtonDirection direction) {
    switch (direction) {
      case GameButtonDirection.up:
        return swipeUpAction ?? pressAction;
      case GameButtonDirection.down:
        return swipeDownAction ?? pressAction;
      case GameButtonDirection.left:
        return swipeLeftAction ?? pressAction;
      case GameButtonDirection.right:
        return swipeRightAction ?? pressAction;
      default:
        return pressAction;
    }
  }

  MUDAction? actionForDirection(GameButtonDirection direction) {
    switch (direction) {
      case GameButtonDirection.none:
        return pressAction;
      case GameButtonDirection.up:
        return swipeUpAction;
      case GameButtonDirection.down:
        return swipeDownAction;
      case GameButtonDirection.left:
        return swipeLeftAction;
      case GameButtonDirection.right:
        return swipeRightAction;
      default:
        return null;
    }
  }
}

class GameButton extends StatefulWidget {
  const GameButton({
    super.key,
    required this.data,
  });

  final GameButtonData data;

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> with GameStoreStateMixin {
  late GameButtonDirection _direction;
  final parentAutomation = Automation.empty();
  Offset? _dragStart;
  Offset? _dragEnd;

  //
  GameButtonData get data => widget.data;

  @override
  void initState() {
    _direction = GameButtonDirection.none;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final curIcon = _currentDirectionIcon(context);
    return _listener(
      context: context,
      child: Container(
        width: data.size,
        height: data.size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _color(context),
        ),
        child: IconTheme(
          data: _iconTheme(curIcon, context),
          child: Icon(curIcon.icon),
        ),
      ),
    );
  }

  double get _swipeMinDist =>
      (data.size ??
          IconTheme.of(context).size ??
          const IconThemeData.fallback().size!) /
      2;

  Widget _listener({
    required BuildContext context,
    required Widget child,
  }) {
    if (PlatformUtils.isDesktop) {
      return Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        child: child,
      );
    }

    return GestureDetector(
      onTap: _onPressed,
      onLongPress: _onLongPress,
      onVerticalDragStart: _onDragStart,
      onVerticalDragUpdate: _onDragUpdate,
      onVerticalDragEnd: _onDragEnd,
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: child,
    );
  }

  GameButtonLabelData _currentDirectionIcon(BuildContext context) {
    switch (_direction) {
      case GameButtonDirection.up:
        return data.labelUp ?? data.label;
      case GameButtonDirection.down:
        return data.labelDown ?? data.label;
      case GameButtonDirection.left:
        return data.labelLeft ?? data.label;
      case GameButtonDirection.right:
        return data.labelRight ?? data.label;
      default:
        return data.label;
    }
  }

  IconThemeData _iconTheme(GameButtonLabelData icon, BuildContext context) =>
      icon.iconTheme ?? IconTheme.of(context);

  Color _color(BuildContext context) =>
      data.color ??
      Theme.of(context).buttonTheme.colorScheme?.background ??
      Colors.grey;

  void _onPressed() {
    _callCurrentDirection();
  }

  void _onLongPress() {
    _callAction(data.longPressAction);
  }

  void _onDragStart(DragStartDetails details) {
    _dragStart = details.globalPosition;
    setState(() {
      _direction = GameButtonDirection.none;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final pos = details.globalPosition;
    final direction = _getRelativeDragDirection(_dragStart!, pos);

    if (direction != _direction) {
      setState(() {
        _direction = direction;
      });
    }
  }

  void _onDragEnd(DragEndDetails details) {
    _callCurrentDirection();
    setState(() {
      _direction = GameButtonDirection.none;
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    _callCurrentDirection();
    setState(() {
      _direction = GameButtonDirection.none;
    });
  }

  void _onPointerDown(PointerDownEvent event) {
    _dragStart = event.position;
    setState(() {
      _direction = GameButtonDirection.none;
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    _dragEnd = event.position;
    final direction = _getRelativeDragDirection(_dragStart!, _dragEnd!);

    if (direction != _direction) {
      setState(() {
        _direction = direction;
      });
    }
  }

  GameButtonDirection _getRelativeDragDirection(Offset start, Offset current) {
    final diff = start - current;
    GameButtonDirection direction = _direction;

    if (diff.distance > _swipeMinDist) {
      // detect primary direction
      // horizontal
      if (diff.dx.abs() > diff.dy.abs()) {
        if (diff.dx > _swipeMinDist) {
          direction = GameButtonDirection.left;
        } else {
          direction = GameButtonDirection.right;
        }
        // vertical
      } else {
        if (diff.dy > _swipeMinDist) {
          direction = GameButtonDirection.up;
        } else {
          direction = GameButtonDirection.down;
        }
      }
      // pos is within button - no direction
    } else {
      direction = GameButtonDirection.none;
    }
    return direction;
  }

  void _callAction(MUDAction? action) {
    final act = action ?? data.directionalAction(GameButtonDirection.none);
    act.invoke(store, parentAutomation, []);
  }

  void _callCurrentDirection() {
    _callAction(data.directionalAction(_direction));
  }
}

class GameButtonLabelData {
  final String? label;
  final IconData? icon;
  final IconThemeData? iconTheme;

  GameButtonLabelData({
    this.label,
    this.icon,
    this.iconTheme,
  }) : assert(label != null || icon != null);

  factory GameButtonLabelData.empty() => GameButtonLabelData(label: '?');

  factory GameButtonLabelData.fromJson(Map<String, dynamic> json) {
    return GameButtonLabelData(
      label: json['label'],
      icon: json['icon'] != null
          ? IconData(
              json['icon'],
              fontFamily: json['iconFontFamily'] ?? 'MaterialIcons',
            )
          : null,
      iconTheme: json['iconTheme'] != null
          ? _iconThemeDataFromJson(json['iconTheme'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'icon': icon?.codePoint,
      'iconFontFamily': icon?.fontFamily,
      'iconTheme': iconTheme != null ? _iconThemeDataToJson(iconTheme!) : null,
    };
  }

  static IconThemeData _iconThemeDataFromJson(Map<String, dynamic> json) =>
      IconThemeData(
        color: json['color'] != null ? Color(json['color']) : null,
        opacity: json['opacity'] ?? 1.0,
        size: json['size'] ?? 24.0,
      );

  static Map<String, dynamic> _iconThemeDataToJson(IconThemeData data) => {
        'color': data.color?.value,
        'opacity': data.opacity,
        'size': data.size,
      };
}

enum GameButtonDirection {
  none,
  up,
  down,
  left,
  right,
}

